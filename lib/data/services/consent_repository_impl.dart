import '../../core/clock.dart';
import '../../core/result.dart';
import '../../domain/entities/consent_record.dart';
import '../../domain/entities/consent_text_version.dart';
import '../../domain/entities/enrollment_attempt_id.dart';
import '../../domain/entities/processing_scope.dart';
import '../../domain/repositories/consent_repository.dart';
import '../models/consent_text_version_response.dart';
import 'consent_service.dart';
import 'credential_service.dart';

/// The real `ConsentRepository` implementation, backed by `ConsentService`.
/// Per contracts/consent-repository-port.md: no `dio` exception, DTO, or
/// raw JSON shape may cross out of this class — callers only ever see
/// `ConsentTextVersion`/`ConsentRecord`/`Result`.
///
/// MUST satisfy the exact same contract test suite as
/// `FakeConsentRepository`, unmodified (Constitution Principle X, Liskov)
/// — see test/contract/consent_repository_contract_test.dart.
class ConsentRepositoryImpl implements ConsentRepository {
  ConsentRepositoryImpl(
    this._service, {
    required Clock clock,
    required CredentialService credentialService,
  }) : _clock = clock,
       _credentialService = credentialService;

  final ConsentService _service;
  final Clock _clock;

  /// 008-identidad-activa, research.md §6: withdrawal deletes the cached
  /// credential in the same local-effect step.
  final CredentialService _credentialService;

  /// Guards against overlapping opportunistic retries (research.md §4):
  /// `_redirect` may call this more than once in quick succession across
  /// route re-evaluations.
  bool _retryInFlight = false;

  @override
  Future<Result<ConsentTextVersion>> getCurrentText() async {
    try {
      final response = await _service.fetchCurrentText();
      return Result.ok(_mapTextVersion(response));
    } catch (e, st) {
      // Any transport or parse failure is mapped to Error here — never a
      // bare exception crossing into ConsentViewModel (Principle IX). A
      // failed fetch is never satisfied from a stale/cached copy
      // (research.md §5).
      return Result.error(e, st);
    }
  }

  @override
  Future<Result<ConsentRecord>> recordConsent({
    required String textVersionId,
  }) async {
    final enrollmentAttemptId = EnrollmentAttemptId.generate();
    final confirmedAt = _clock.now();
    try {
      await _service.submitConsent({
        'textVersionId': textVersionId,
        'enrollmentAttemptId': enrollmentAttemptId.value,
        'scope': ProcessingScope.identityVerification.name,
        'confirmedAt': confirmedAt.toIso8601String(),
      });
    } catch (e, st) {
      // Offline or backend-rejected: no local record is written (FR-007's
      // "durably record before capture is reachable" requires the backend
      // to have actually confirmed first).
      return Result.error(e, st);
    }

    final record = ConsentRecord(
      textVersionId: textVersionId,
      enrollmentAttemptId: enrollmentAttemptId,
      scope: ProcessingScope.identityVerification,
      confirmedAt: confirmedAt,
      status: ConsentRecordStatus.active,
    );
    try {
      await _service.writeLocalRecord(record);
    } catch (e, st) {
      // Backend confirmed, but the local secure-storage write failed:
      // still surfaced as Error, per FR-008 ("the flow MUST NOT advance"
      // when the record cannot be durably stored).
      return Result.error(e, st);
    }
    return Result.ok(record);
  }

  @override
  Future<Result<ConsentRecord?>> getLocalRecord() async {
    try {
      return Result.ok(await _service.readLocalRecord());
    } catch (e, st) {
      return Result.error(e, st);
    }
  }

  @override
  Future<Result<ConsentRecord>> withdraw() async {
    final ConsentRecord? current;
    try {
      current = await _service.readLocalRecord();
    } catch (e, st) {
      return Result.error(e, st);
    }
    if (current == null) {
      return Result.error(StateError('no local consent record to withdraw'));
    }

    final pending = current.copyWith(
      status: ConsentRecordStatus.withdrawalPending,
      withdrawalRequestedAt: _clock.now(),
    );
    try {
      // The local effect (SC-005: credential/pass invalidation, ≤1s, no
      // network dependency) is durable the instant this write completes —
      // it does not wait for backend confirmation.
      await _service.writeLocalRecord(pending);
    } catch (e, st) {
      return Result.error(e, st);
    }
    try {
      // 008-identidad-activa (contracts/consent-withdrawal-addendum.md):
      // Principle I — "revoking MUST immediately invalidate the local
      // credential". Before backend delivery, so it needs no network. A
      // withdrawal that leaves a usable credential behind is not a
      // successful withdrawal.
      await _credentialService.clearCachedCredential();
    } catch (e, st) {
      return Result.error(e, st);
    }

    try {
      await _service.submitWithdrawal({
        'textVersionId': pending.textVersionId,
        'enrollmentAttemptId': pending.enrollmentAttemptId.value,
      });
    } catch (_) {
      // Delivery failed or the device is offline: the record stays
      // withdrawalPending locally (already durable above) and
      // retryPendingWithdrawal() picks it up later (research.md §4). This
      // is not an Error — the local withdrawal itself succeeded.
      return Result.ok(pending);
    }

    final withdrawn = pending.copyWith(status: ConsentRecordStatus.withdrawn);
    try {
      await _service.writeLocalRecord(withdrawn);
    } catch (e, st) {
      return Result.error(e, st);
    }
    return Result.ok(withdrawn);
  }

  @override
  Future<void> retryPendingWithdrawal() async {
    if (_retryInFlight) return;
    _retryInFlight = true;
    try {
      final current = await _service.readLocalRecord();
      if (current == null ||
          current.status != ConsentRecordStatus.withdrawalPending) {
        return;
      }
      await _service.submitWithdrawal({
        'textVersionId': current.textVersionId,
        'enrollmentAttemptId': current.enrollmentAttemptId.value,
      });
      final withdrawn = current.copyWith(status: ConsentRecordStatus.withdrawn);
      await _service.writeLocalRecord(withdrawn);
    } catch (_) {
      // Never throws — swallowed and simply retried on the next
      // opportunistic call (research.md §4).
    } finally {
      _retryInFlight = false;
    }
  }

  ConsentTextVersion _mapTextVersion(ConsentTextVersionResponse response) {
    return ConsentTextVersion(
      id: response.id,
      points: response.points
          .map(
            (point) => ConsentPoint(
              icon: _mapIcon(point.icon),
              heading: point.heading,
              body: point.body,
            ),
          )
          .toList(growable: false),
      rightsStatement: response.rightsStatement,
      optionalityStatement: response.optionalityStatement,
      processorDisclosure: response.processorDisclosure,
      privacyPolicyUrl: response.privacyPolicyUrl,
      termsUrl: response.termsUrl,
      publishedAt: response.publishedAt,
    );
  }

  ConsentPointIcon _mapIcon(String raw) {
    switch (raw) {
      case 'camera':
        return ConsentPointIcon.camera;
      case 'clock':
        return ConsentPointIcon.clock;
      case 'share':
        return ConsentPointIcon.share;
      default:
        throw FormatException('unknown consent point icon: $raw');
    }
  }
}
