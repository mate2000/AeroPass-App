import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/consent_record.dart';
import 'package:aeropass_app/domain/entities/consent_text_version.dart';
import 'package:aeropass_app/domain/entities/enrollment_attempt_id.dart';
import 'package:aeropass_app/domain/entities/processing_scope.dart';
import 'package:aeropass_app/domain/repositories/consent_repository.dart';

/// A scripted, no-network, no-secure-storage `ConsentRepository` double,
/// per contracts/consent-repository-port.md and Constitution Principle II's
/// "full test suite against a fake with no network linked" pattern, reused
/// here for consistency. Used by widget/unit tests and by the contract test
/// suite.
class FakeConsentRepository implements ConsentRepository {
  Result<ConsentTextVersion>? _textResponse;
  Result<ConsentRecord>? _recordConsentResponse;
  ConsentRecord? _localRecord;
  bool _withdrawFails = false;
  bool retryPendingWithdrawalCalled = false;
  int getCurrentTextCallCount = 0;
  int recordConsentCallCount = 0;

  /// Sets the value the next call to [getCurrentText] returns.
  void scriptCurrentText(Result<ConsentTextVersion> response) {
    _textResponse = response;
  }

  /// Sets the value the next call to [recordConsent] returns. When `Ok`,
  /// [getLocalRecord] afterwards reflects the same record (mirroring the
  /// real implementation's "persist only after backend confirms").
  void scriptRecordConsent(Result<ConsentRecord> response) {
    _recordConsentResponse = response;
  }

  /// Seeds the local record directly (e.g. to simulate a passenger who has
  /// already consented, or has a `withdrawalPending` record).
  void seedLocalRecord(ConsentRecord? record) {
    _localRecord = record;
  }

  /// When true, [withdraw] returns `Error` even with a local record
  /// present, and `retryPendingWithdrawal` doesn't clear a pending state
  /// either — used to simulate an unreachable backend.
  void failWithdrawalDelivery({required bool fails}) {
    _withdrawFails = fails;
  }

  @override
  Future<Result<ConsentTextVersion>> getCurrentText() async {
    getCurrentTextCallCount++;
    return _textResponse ??
        Result.error(StateError('no current-text response scripted'));
  }

  @override
  Future<Result<ConsentRecord>> recordConsent({
    required String textVersionId,
  }) async {
    recordConsentCallCount++;
    final scripted = _recordConsentResponse;
    if (scripted == null) {
      final record = ConsentRecord(
        textVersionId: textVersionId,
        enrollmentAttemptId: EnrollmentAttemptId.generate(),
        scope: ProcessingScope.identityVerification,
        confirmedAt: DateTime.now(),
        status: ConsentRecordStatus.active,
      );
      _localRecord = record;
      return Result.ok(record);
    }
    return scripted.when(
      ok: (record) {
        _localRecord = record;
        return Result.ok(record);
      },
      error: (e, st) => Result.error(e, st),
    );
  }

  @override
  Future<Result<ConsentRecord?>> getLocalRecord() async {
    return Result.ok(_localRecord);
  }

  @override
  Future<Result<ConsentRecord>> withdraw() async {
    final current = _localRecord;
    if (current == null) {
      return Result.error(StateError('no local record to withdraw'));
    }
    final withdrawn = current.copyWith(
      status: _withdrawFails
          ? ConsentRecordStatus.withdrawalPending
          : ConsentRecordStatus.withdrawn,
      withdrawalRequestedAt: DateTime.now(),
    );
    _localRecord = withdrawn;
    return Result.ok(withdrawn);
  }

  @override
  Future<void> retryPendingWithdrawal() async {
    retryPendingWithdrawalCalled = true;
    final current = _localRecord;
    if (current == null ||
        current.status != ConsentRecordStatus.withdrawalPending) {
      return;
    }
    if (_withdrawFails) {
      return;
    }
    _localRecord = current.copyWith(status: ConsentRecordStatus.withdrawn);
  }
}
