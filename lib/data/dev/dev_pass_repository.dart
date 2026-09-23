import '../../app/clock_trust_monitor.dart';
import '../../core/clock.dart';
import '../../core/result.dart';
import '../../domain/entities/pass.dart';
import '../../domain/repositories/pass_code_source.dart';
import '../../domain/repositories/pass_repository.dart';

/// Happy-path stand-in for the pass backend (014-qr-pase), behind
/// `USE_FAKE_VERIFICATION_BACKEND`.
///
/// It plays the backend: it issues a synthetic pass for 3 hours, reports it
/// active, and never validates a checkpoint on its own — the stepper only
/// ever advances on a validation the backend reports (FR-009).
/// [expireNow] is the backend-side switch behind the flag-gated "Simular
/// expirado" control; nothing on the device marks a pass expired.
class DevPassRepository implements PassRepository {
  DevPassRepository({
    required Clock clock,
    required ClockTrustMonitor clockTrustMonitor,
  }) : _clock = clock,
       _clockTrust = clockTrustMonitor;

  final Clock _clock;
  final ClockTrustMonitor _clockTrust;

  static const _devValidity = Duration(hours: 3);

  final Map<String, Pass> _activeByTrip = {};
  final Set<String> _expired = {};
  int _issued = 0;

  @override
  Future<Result<Pass>> issue(String tripId) async {
    final now = _clock.now();
    _clockTrust.observeServerTime(now);
    _issued++;
    final pass = Pass(
      passId: 'dev-pass-$_issued',
      tripId: tripId,
      nextCheckpoint: Checkpoint.security,
      validUntil: now.add(_devValidity),
    );
    _activeByTrip[tripId] = pass;
    return Result.ok(pass);
  }

  @override
  Future<Result<PassState>> status(String passId) async {
    _clockTrust.observeServerTime(_clock.now());
    if (_expired.contains(passId)) return const Result.ok(PassState.expired());
    final pass = _activeByTrip.values
        .where((p) => p.passId == passId)
        .firstOrNull;
    if (pass == null) return const Result.ok(PassState.expired());
    return Result.ok(PassState.active(pass));
  }

  @override
  Pass? activePassFor(String tripId) {
    final pass = _activeByTrip[tripId];
    if (pass == null || _expired.contains(pass.passId)) return null;
    return _clock.now().isBefore(pass.validUntil) ? pass : null;
  }

  @override
  Future<void> forget(String passId) async {
    _activeByTrip.removeWhere((_, p) => p.passId == passId);
  }

  /// The fake backend expires [passId]: the next status read says so.
  void expireNow(String passId) => _expired.add(passId);
}

/// Happy-path code source: a synthetic payload per rotation window, from the
/// backend-observed time. Never a real pass format.
class DevPassCodeSource implements PassCodeSource {
  const DevPassCodeSource();

  @override
  Future<Result<PassCode>> codeAt(Pass pass, DateTime instant) async {
    final seconds = pass.rotation.inSeconds;
    final window = instant.toUtc().millisecondsSinceEpoch ~/ 1000 ~/ seconds;
    final start = DateTime.fromMillisecondsSinceEpoch(
      window * seconds * 1000,
      isUtc: true,
    );
    return Result.ok(
      PassCode(
        payload: 'AP1-DEV.$window',
        windowStartsAt: start,
        windowEndsAt: start.add(pass.rotation),
      ),
    );
  }
}
