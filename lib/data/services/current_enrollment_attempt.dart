import '../../core/result.dart';
import '../../domain/entities/consent_record.dart';
import '../../domain/entities/enrollment_attempt_id.dart';
import '../../domain/repositories/consent_repository.dart';

/// The enrollment attempt funnel telemetry is tagged with
/// (015 research §10, data-model `CurrentEnrollmentAttempt`).
///
/// Held in memory only: its source is the `EnrollmentAttemptId` the consent
/// record already persists, so nothing new is stored (Principle I).
class CurrentEnrollmentAttempt {
  CurrentEnrollmentAttempt({required ConsentRepository consentRepository})
    : _consentRepository = consentRepository;

  final ConsentRepository _consentRepository;
  EnrollmentAttemptId? _value;
  bool _changedSinceLoadStarted = false;

  /// The attempt in progress, or null before consent or after withdrawal.
  EnrollmentAttemptId? get value => _value;

  /// Reads the local consent record once. An attempt set while this read is
  /// in flight wins, since it is newer than what the read returns.
  Future<void> load() async {
    _changedSinceLoadStarted = false;
    final result = await _consentRepository.getLocalRecord();
    if (_changedSinceLoadStarted) return;
    final record = switch (result) {
      Ok(:final value) => value,
      Error() => null,
    };
    _value = record?.status == ConsentRecordStatus.active
        ? record!.enrollmentAttemptId
        : null;
  }

  void set(EnrollmentAttemptId attemptId) {
    _changedSinceLoadStarted = true;
    _value = attemptId;
  }

  void clear() {
    _changedSinceLoadStarted = true;
    _value = null;
  }
}
