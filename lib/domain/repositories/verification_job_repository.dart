import 'package:meta/meta.dart';

import '../../core/result.dart';
import '../entities/verification_job_status.dart';

/// The read-only port through which the verification screen learns how the
/// backend verification is going (007-validando,
/// contracts/verification-job-port.md).
///
/// It only reads: nothing here can submit samples or create a job, so a
/// capture can never be verified twice from this screen (FR-010, SC-004).
/// The job is identified by the durable `EnrollmentAttemptId` already in the
/// local consent record, so no new identifier is persisted (research.md §1).
abstract class VerificationJobRepository {
  /// Reads the current job for this enrollment attempt.
  ///
  /// `Result.error` means this one read failed (offline, timeout, non-2xx,
  /// pinning) or there is no local consent record. It is not an outcome:
  /// the caller polls again (research.md §3). All provider codes are
  /// normalized inside the implementation (Principle II).
  @useResult
  Future<Result<VerificationJobStatus>> getStatus();
}
