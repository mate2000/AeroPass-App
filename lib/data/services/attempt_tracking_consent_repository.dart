import '../../core/result.dart';
import '../../domain/entities/consent_record.dart';
import '../../domain/entities/consent_text_version.dart';
import '../../domain/repositories/consent_repository.dart';
import 'current_enrollment_attempt.dart';

/// Wraps any `ConsentRepository` (real or dev) and keeps
/// [CurrentEnrollmentAttempt] in step with it: a confirmed consent starts a
/// new attempt, a withdrawal ends it (015 research §10). Every call is
/// delegated unchanged, so the wrapped repositories need no edits.
class AttemptTrackingConsentRepository implements ConsentRepository {
  AttemptTrackingConsentRepository(
    this._inner, {
    required CurrentEnrollmentAttempt attempt,
  }) : _attempt = attempt;

  final ConsentRepository _inner;
  final CurrentEnrollmentAttempt _attempt;

  @override
  Future<Result<ConsentTextVersion>> getCurrentText() =>
      _inner.getCurrentText();

  @override
  Future<Result<ConsentRecord>> recordConsent({
    required String textVersionId,
  }) async {
    final result = await _inner.recordConsent(textVersionId: textVersionId);
    if (result case Ok(:final value)) _attempt.set(value.enrollmentAttemptId);
    return result;
  }

  @override
  Future<Result<ConsentRecord?>> getLocalRecord() => _inner.getLocalRecord();

  @override
  Future<Result<ConsentRecord>> withdraw() async {
    final result = await _inner.withdraw();
    if (result is Ok<ConsentRecord>) _attempt.clear();
    return result;
  }

  @override
  Future<void> retryPendingWithdrawal() => _inner.retryPendingWithdrawal();
}
