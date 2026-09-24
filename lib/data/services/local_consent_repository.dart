import '../../core/clock.dart';
import '../../core/result.dart';
import '../../domain/entities/consent_record.dart';
import '../../domain/entities/consent_text_version.dart';
import '../../domain/entities/enrollment_attempt_id.dart';
import '../../domain/entities/processing_scope.dart';
import '../../domain/repositories/consent_repository.dart';
import '../../domain/repositories/session_token_provider.dart';
import 'bundled_consent_text.dart';
import 'consent_service.dart';
import 'credential_service.dart';

/// 002's [ConsentRepository] with no consent backend (015 DEC-02,
/// research.md §14 and §15).
///
/// - **The text** is bundled with the app ([bundledConsentText]).
/// - **The record** (version, timestamp, scope) is kept in secure storage,
///   which the allowlist permits. Capture stays blocked behind it (002
///   FR-001), exactly as before.
/// - **There is no server-side evidence**, so auditable consent (002 SC-001,
///   SC-002) cannot be claimed. That is a release blocker, not a pass.
/// - **Withdrawal** clears everything on this device, including the cached
///   credential, and signs the session out, so the registration can no
///   longer be reached from here. It cannot delete what the backend holds,
///   because no endpoint exists for that. The screen says so (T061).
class LocalConsentRepository implements ConsentRepository {
  LocalConsentRepository(
    this._store, {
    required CredentialService credentialService,
    required SessionTokenProvider sessionTokenProvider,
    required Clock clock,
  }) : _credentialService = credentialService,
       _sessionTokenProvider = sessionTokenProvider,
       _clock = clock;

  final ConsentService _store;
  final CredentialService _credentialService;
  final SessionTokenProvider _sessionTokenProvider;
  final Clock _clock;

  @override
  Future<Result<ConsentTextVersion>> getCurrentText() async =>
      Result.ok(bundledConsentText);

  @override
  Future<Result<ConsentRecord>> recordConsent({
    required String textVersionId,
  }) async {
    if (textVersionId != bundledConsentTextVersionId) {
      return Result.error(
        StateError('consent to a text version this app does not carry'),
      );
    }
    final record = ConsentRecord(
      textVersionId: textVersionId,
      enrollmentAttemptId: EnrollmentAttemptId.generate(),
      scope: ProcessingScope.identityVerification,
      confirmedAt: _clock.now(),
      status: ConsentRecordStatus.active,
    );
    try {
      await _store.writeLocalRecord(record);
    } catch (e, st) {
      // Not recorded, so the gate stays closed (002 FR-008).
      return Result.error(e, st);
    }
    return Result.ok(record);
  }

  @override
  Future<Result<ConsentRecord?>> getLocalRecord() async {
    try {
      return Result.ok(await _store.readLocalRecord());
    } catch (e, st) {
      return Result.error(e, st);
    }
  }

  @override
  Future<Result<ConsentRecord>> withdraw() async {
    final ConsentRecord? current;
    try {
      current = await _store.readLocalRecord();
    } catch (e, st) {
      return Result.error(e, st);
    }
    if (current == null) {
      return Result.error(StateError('no local record to withdraw'));
    }
    final withdrawn = current.copyWith(
      status: ConsentRecordStatus.withdrawn,
      withdrawalRequestedAt: _clock.now(),
    );
    try {
      await _store.writeLocalRecord(withdrawn);
      await _credentialService.clearCachedCredential();
    } catch (e, st) {
      return Result.error(e, st);
    }
    await _sessionTokenProvider.signOut();
    return Result.ok(withdrawn);
  }

  /// No backend withdrawal exists, so nothing is ever pending.
  @override
  Future<void> retryPendingWithdrawal() async {}
}
