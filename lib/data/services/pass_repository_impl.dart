import '../../app/clock_trust_monitor.dart';
import '../../core/clock.dart';
import '../../core/result.dart';
import '../../domain/entities/pass.dart';
import '../../domain/repositories/consent_repository.dart';
import '../../domain/repositories/pass_repository.dart';
import '../models/pass_responses.dart';
import 'pass_service.dart';
import 'transport_error_mapper.dart';

/// The real `PassRepository` (014-qr-pase, contracts/pass-port.md).
///
/// The mapping is strict: an unknown state or next checkpoint is an error,
/// never "active"; a missing server time is an error, because the clock
/// cannot be checked without it; a validity longer than 24 h is clamped.
/// Every server time is handed to the [ClockTrustMonitor]. Phase A keeps the
/// active pass in memory only and never reads a secret.
class PassRepositoryImpl implements PassRepository {
  PassRepositoryImpl(
    this._service, {
    required ConsentRepository consentRepository,
    required ClockTrustMonitor clockTrustMonitor,
    required Clock clock,
  }) : _consentRepository = consentRepository,
       _clockTrust = clockTrustMonitor,
       _clock = clock;

  final PassService _service;
  final ConsentRepository _consentRepository;
  final ClockTrustMonitor _clockTrust;
  final Clock _clock;

  static const _minRotationSeconds = 10;
  static const _maxRotationSeconds = 60;

  final Map<String, Pass> _activeByTrip = {};

  @override
  Future<Result<Pass>> issue(String tripId) async {
    final attemptId = (await _consentRepository.getLocalRecord())
        .valueOrNull
        ?.enrollmentAttemptId
        .value;
    if (attemptId == null) {
      return Result.error(StateError('no local consent record for the pass'));
    }
    try {
      final response = await _service.issue(
        enrollmentAttemptId: attemptId,
        tripId: tripId,
      );
      final serverTime = _parse(response.serverTime);
      if (serverTime == null) {
        return Result.error(const FormatException('pass without server time'));
      }
      _clockTrust.observeServerTime(serverTime);
      final pass = _pass(response, tripId, serverTime);
      if (pass == null) {
        return Result.error(const FormatException('pass issuance malformed'));
      }
      _activeByTrip[tripId] = pass;
      return Result.ok(pass);
    } catch (e, st) {
      return Result.error(mapTransportError(e), st);
    }
  }

  @override
  Future<Result<PassState>> status(String passId) async {
    try {
      final response = await _service.status(passId);
      final serverTime = _parse(response.serverTime);
      if (serverTime == null) {
        return Result.error(
          const FormatException('status without server time'),
        );
      }
      _clockTrust.observeServerTime(serverTime);
      final state = _state(response, passId);
      if (state == null) {
        return Result.error(const FormatException('unrecognized pass status'));
      }
      return Result.ok(state);
    } catch (e, st) {
      return Result.error(mapTransportError(e), st);
    }
  }

  @override
  Pass? activePassFor(String tripId) {
    final pass = _activeByTrip[tripId];
    if (pass == null) return null;
    if (!_clock.now().isBefore(pass.validUntil)) {
      _activeByTrip.remove(tripId);
      return null;
    }
    return pass;
  }

  @override
  Future<void> forget(String passId) async {
    _activeByTrip.removeWhere((_, pass) => pass.passId == passId);
  }

  Pass? _pass(PassIssueResponse r, String tripId, DateTime serverTime) {
    final passId = r.passId?.trim() ?? '';
    final checkpoint = _checkpoint(r.nextCheckpoint);
    final validUntil = _parse(r.validUntil);
    final rotation = r.rotationSeconds ?? passRotation.inSeconds;
    if (passId.isEmpty ||
        checkpoint == null ||
        validUntil == null ||
        rotation < _minRotationSeconds ||
        rotation > _maxRotationSeconds) {
      return null;
    }
    final ceiling = serverTime.add(passMaxOfflineValidity);
    return Pass(
      passId: passId,
      tripId: tripId,
      nextCheckpoint: checkpoint,
      validUntil: validUntil.isAfter(ceiling) ? ceiling : validUntil,
      rotation: Duration(seconds: rotation),
    );
  }

  PassState? _state(PassStatusResponse r, String passId) {
    final validated = {
      for (final wire in r.validated ?? const <String>[]) ?_checkpoint(wire),
    };
    switch (r.flightStatus) {
      case 'cancelled':
        return const PassState.flightChanged(cancelled: true);
      case 'changed':
        return const PassState.flightChanged(cancelled: false);
    }
    switch (r.state) {
      case 'expired':
        return const PassState.expired();
      case 'revoked':
        return const PassState.revoked();
      case 'boarded':
        return const PassState.boarded();
      case 'active':
        final next = _checkpoint(r.nextCheckpoint);
        final known = _activeByTrip.values
            .where((p) => p.passId == passId)
            .firstOrNull;
        if (next == null || known == null) return null;
        final updated = known.copyWith(
          nextCheckpoint: next,
          validated: validated,
        );
        _activeByTrip[known.tripId] = updated;
        return PassState.active(updated);
      default:
        return null;
    }
  }

  static Checkpoint? _checkpoint(String? wire) => switch (wire) {
    'security' => Checkpoint.security,
    'boarding' => Checkpoint.boarding,
    _ => null,
  };

  static DateTime? _parse(String? wire) =>
      wire == null ? null : DateTime.tryParse(wire)?.toUtc();
}
