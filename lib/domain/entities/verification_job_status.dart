import 'package:freezed_annotation/freezed_annotation.dart';

import 'verification_outcome.dart';
import 'verification_stage.dart';

part 'verification_job_status.freezed.dart';

/// What one `VerificationJobRepository.getStatus()` call returns
/// (007-validando, data-model.md).
@freezed
sealed class VerificationJobStatus with _$VerificationJobStatus {
  const factory VerificationJobStatus.inProgress({
    required StageStatus documentCheck,
    required StageStatus faceComparison,

    /// 011-error-tecnico: until when a cold launch resumes this job
    /// (backend-owned, 24 h after a failure). Null means not resumable.
    DateTime? resumableUntil,
  }) = VerificationJobInProgress;

  const factory VerificationJobStatus.completed({
    required VerificationOutcome outcome,
    required StageStatus documentCheck,
    required StageStatus faceComparison,
    DateTime? resumableUntil,
  }) = VerificationJobCompleted;
}
