import '../../core/clock.dart';
import '../../core/diagnostics.dart';
import '../../core/result.dart';
import '../../domain/entities/backend_error.dart';
import '../../domain/entities/credential_status.dart';
import '../../domain/entities/credential_summary.dart';
import '../../domain/entities/passenger_record.dart';
import '../../domain/entities/session_state.dart';
import '../../domain/repositories/credential_repository.dart';
import '../../domain/repositories/credential_summary_repository.dart';
import '../../domain/repositories/passenger_repository.dart';
import 'backend_error_mapper.dart';
import 'credential_service.dart';
import 'passenger_mapper.dart';
import 'passenger_service.dart';

/// `GET /v1/identity/me` behind every port that asks "who is this passenger,
/// and are they verified?" (015 research.md §9, FR-023):
///
/// - [PassengerRepository]: the raw record, for resume.
/// - [CredentialRepository]: 001's launch status.
/// - [CredentialSummaryRepository]: 012's strip.
///
/// The backend has no separate credential. A verified passenger's
/// `identidad_id` is the credential, and it is valid until the document
/// expires. That pair is cached, from the allowlist's "credential token and
/// its validity window" (Principle I), so the strip can say "SIN CONFIRMAR"
/// offline. It never says "ACTIVA" offline (012 FR-003).
class PassengerBackedCredentialRepository
    implements
        PassengerRepository,
        CredentialRepository,
        CredentialSummaryRepository {
  PassengerBackedCredentialRepository(
    this._service, {
    required CredentialService credentialService,
    required Clock clock,
    Diagnostics diagnostics = const Diagnostics(),
  }) : _credentialService = credentialService,
       _clock = clock,
       _diagnostics = diagnostics;

  final PassengerService _service;
  final CredentialService _credentialService;
  final Clock _clock;
  final Diagnostics _diagnostics;

  @override
  Future<Result<PassengerRecord?>> me() async {
    final watch = Stopwatch()..start();
    try {
      final passenger = passengerFromDto(await _service.me());
      _diagnostics.info('passenger_me', {
        'result': passenger.state.name,
        'has_identity': passenger.identityId != null,
        'ms': watch.elapsedMilliseconds,
      });
      return Result.ok(passenger);
    } catch (e, st) {
      final mapped = mapBackendError(e);
      _diagnostics.info('passenger_me', {
        'result': mapped is BackendError ? mapped.code.name : 'error',
        'error': mapped.runtimeType,
        // A response the DTO could not read shows up here, not as HTTP.
        'raw_error': e.runtimeType,
        'ms': watch.elapsedMilliseconds,
      });
      if (mapped is BackendError) {
        switch (mapped.code) {
          case BackendErrorCode.pasajeroNoRegistrado:
            return const Result.ok(null);
          case BackendErrorCode.noAutenticado:
            // A second 401, after the silent retry (FR-001).
            return Result.error(const SessionUnavailable(), st);
          default:
            break;
        }
      }
      return Result.error(mapped, st);
    }
  }

  /// [me], and the credential cache brought in step with the answer. Used
  /// by issuance (research.md §9), which must not report an activation
  /// whose credential was not stored.
  Future<Result<PassengerRecord?>> meAndSync() async {
    final result = await me();
    if (result case Ok(:final value)) await _statusFor(value);
    return result;
  }

  @override
  Future<Result<CredentialStatus>> getStatus() async {
    final result = await me();
    switch (result) {
      case Ok(:final value):
        return Result.ok(await _statusFor(value));
      case Error():
        final cached = await _safely(
          'cache_read',
          _credentialService.readCachedCredential,
        );
        final lastKnown = cached == null
            ? null
            : cached.validUntil.isAfter(_clock.now())
            ? CredentialStatus.valid(validUntil: cached.validUntil)
            : const CredentialStatus.expiredOrRevoked(
                reason: ExpiryReason.expired,
              );
        return Result.ok(
          CredentialStatus.unreachable(lastKnownStatus: lastKnown),
        );
    }
  }

  @override
  Future<Result<CredentialSummary>> getSummary() async {
    final result = await me();
    switch (result) {
      case Ok(value: final passenger?)
          when passenger.state == PassengerState.verified &&
              passenger.identityId != null:
        await _statusFor(passenger);
        return Result.ok(
          CredentialSummary(
            holderName: passenger.holderName,
            documentLast4: lastFourOf(passenger.maskedNumber),
            state: _isExpired(passenger.documentExpiry)
                ? CredentialDisplayState.expired
                : CredentialDisplayState.active,
            confirmed: true,
          ),
        );
      case Ok():
        return Result.error(const NoCredentialFailure());
      case Error(:final error, :final stackTrace):
        final cached = await _safely(
          'cache_read',
          _credentialService.readCachedCredential,
        );
        if (cached == null) return Result.error(error, stackTrace);
        final stored = await _safely(
          'cache_read_display',
          _credentialService.readDisplayFields,
        );
        return Result.ok(
          CredentialSummary(
            holderName: stored?.holderName,
            documentLast4: stored?.documentLast4,
            state: cached.validUntil.isAfter(_clock.now())
                ? CredentialDisplayState.active
                : CredentialDisplayState.expired,
            confirmed: false,
          ),
        );
    }
  }

  /// Maps a backend answer to 001's status, and keeps the cache in step:
  /// written for a verified passenger, cleared for everyone else.
  Future<CredentialStatus> _statusFor(PassengerRecord? passenger) async {
    final identityId = passenger?.identityId;
    if (passenger == null ||
        passenger.state != PassengerState.verified ||
        identityId == null) {
      // Pending, in review, unregistered, or verified with no identity yet,
      // which is never shown as active (research.md §9). Resume reads
      // `me()` for those.
      await _safely('cache_clear', _credentialService.clearCachedCredential);
      return const CredentialStatus.noCredential();
    }
    final validUntil = _endOfDay(passenger.documentExpiry);
    await _safely(
      'cache_write',
      () => _credentialService.writeCachedCredential(
        token: identityId,
        validUntil: validUntil,
        holderName: passenger.holderName,
        documentLast4: lastFourOf(passenger.maskedNumber),
      ),
    );
    return _isExpired(passenger.documentExpiry)
        ? const CredentialStatus.expiredOrRevoked(reason: ExpiryReason.expired)
        : CredentialStatus.valid(validUntil: validUntil);
  }

  bool _isExpired(DateTime documentExpiry) =>
      _endOfDay(documentExpiry).isBefore(_clock.now());

  /// A document is valid through its expiry day.
  static DateTime _endOfDay(DateTime day) =>
      DateTime(day.year, day.month, day.day + 1);

  /// Runs a secure-storage operation, logging how long it took and whether
  /// it failed (never its value). A failure is treated as "nothing cached".
  Future<T?> _safely<T>(String op, Future<T> Function() action) async {
    final watch = Stopwatch()..start();
    try {
      final value = await action();
      _diagnostics.info('credential_cache', {
        'op': op,
        'ms': watch.elapsedMilliseconds,
      });
      return value;
    } catch (e) {
      _diagnostics.warn('credential_cache_failed', {
        'op': op,
        'code': e.runtimeType,
        'ms': watch.elapsedMilliseconds,
      });
      return null;
    }
  }
}
