import 'verification_submission.dart';
import '../core/result.dart';
import '../domain/entities/transport_failure.dart';
import '../domain/entities/verification_job_status.dart';
import '../domain/entities/verification_outcome.dart';
import '../domain/entities/verification_result.dart';
import '../domain/entities/verification_stage.dart';
import '../domain/repositories/verification_job_repository.dart';

/// 007's [VerificationJobRepository], read from the in-memory
/// [VerificationSubmission] instead of a remote job (015 research.md §7).
/// 007's routing, timers and resume stay as they are. Only where the status
/// comes from changes.
///
/// | Submission | Job status |
/// |---|---|
/// | in flight | in progress: document check passed (it was registered), face comparison running |
/// | [Verified] | matched: issuance then reads `/me` |
/// | [Failed] match | face mismatch |
/// | [Failed] generic | liveness rejected. 007 treats both identically for the passenger (FR-006) |
/// | [Inconclusive] | service failure: 011, nothing consumed (FR-005) |
/// | [NeedsReview] | manual review: 010 (FR-009) |
/// | [StateChanged] | matched: issuance re-reads `/me` and routes by its state |
/// | [NotRegistered] | document rejected: back to capture, to register again |
/// | [RecaptureSelfie] | face mismatch: 009 offers the selfie again |
/// | failed, connectivity | the error, so 007's timeout classes it as the connection's |
/// | failed, anything else | service failure |
/// | idle | the error: there is nothing to observe |
class SubmissionBackedJobRepository implements VerificationJobRepository {
  SubmissionBackedJobRepository(this._submission);

  final VerificationSubmission _submission;

  @override
  Future<Result<VerificationJobStatus>> getStatus() async {
    return switch (_submission.state) {
      SubmissionIdle() => Result.error(StateError('no verification submitted')),
      SubmissionInFlight() => const Result.ok(
        VerificationJobStatus.inProgress(
          documentCheck: StageStatus.passed,
          faceComparison: StageStatus.running,
        ),
      ),
      SubmissionDone(:final result) => Result.ok(_completed(_outcome(result))),
      SubmissionFailed(:final error) when error is ConnectivityFailure =>
        Result.error(error),
      SubmissionFailed() => Result.ok(
        _completed(const VerificationOutcome.serviceFailure()),
      ),
    };
  }

  static VerificationOutcome _outcome(VerificationResult result) =>
      switch (result) {
        Verified() || StateChanged() => const VerificationOutcome.matched(),
        Failed(reason: FailureReason.match) ||
        RecaptureSelfie() => const VerificationOutcome.faceMismatch(),
        Failed(reason: FailureReason.generic) =>
          const VerificationOutcome.livenessRejected(),
        Inconclusive() => const VerificationOutcome.serviceFailure(),
        NeedsReview() => const VerificationOutcome.manualReview(),
        NotRegistered() => const VerificationOutcome.documentRejected(),
      };

  static VerificationJobStatus _completed(VerificationOutcome outcome) {
    final faceFailed =
        outcome is! VerificationMatched &&
        outcome is! VerificationServiceFailure;
    return VerificationJobStatus.completed(
      outcome: outcome,
      documentCheck: outcome is VerificationDocumentRejected
          ? StageStatus.failed
          : StageStatus.passed,
      faceComparison: outcome is VerificationMatched
          ? StageStatus.passed
          : faceFailed && outcome is! VerificationDocumentRejected
          ? StageStatus.failed
          : StageStatus.running,
    );
  }
}
