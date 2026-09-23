import '../../core/result.dart';
import '../../domain/entities/verification_job_status.dart';
import '../../domain/entities/verification_outcome.dart';
import '../../domain/entities/verification_stage.dart';
import '../../domain/repositories/verification_job_repository.dart';

/// A local, no-network `VerificationJobRepository` used only when the app is
/// launched with `USE_FAKE_VERIFICATION_BACKEND=true` (007-validando,
/// research.md §14) — never reachable from production wiring, and covered by
/// `HappyPathFlags.assertReleaseSafe`.
///
/// It plays the backend on a fixed schedule measured from its first poll:
/// the document check runs, then passes at [documentPassedAfter]; the face
/// comparison runs, then the job completes `matched` at [matchedAfter]. The
/// schedule belongs to this fake, not to the screen: the screen renders only
/// what is reported (FR-004).
class DevVerificationJobRepository implements VerificationJobRepository {
  DevVerificationJobRepository({DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  DateTime? _firstPollAt;

  /// 011-error-tecnico quickstart.md: forces a failure for the device
  /// walk-through. `service_failure` completes every job with a service
  /// failure; `hang` never finishes, so 007's hard timeout fires. Unset, the
  /// job matches as before. Only reachable with the fake backend.
  static const forcedFailure = String.fromEnvironment(
    'DEV_VERIFICATION_FAILURE',
  );

  /// The 24-hour resume window the real backend sets after a failure.
  static const resumeWindow = Duration(hours: 24);

  static const documentPassedAfter = Duration(milliseconds: 1500);
  static const matchedAfter = Duration(milliseconds: 3000);

  @override
  Future<Result<VerificationJobStatus>> getStatus() async {
    final now = _now();
    final start = _firstPollAt ??= now;
    final elapsed = now.difference(start);

    if (forcedFailure == 'hang') {
      return Result.ok(
        VerificationJobStatus.inProgress(
          documentCheck: StageStatus.passed,
          faceComparison: StageStatus.running,
          resumableUntil: start.add(resumeWindow),
        ),
      );
    }
    if (elapsed < documentPassedAfter) {
      return const Result.ok(
        VerificationJobStatus.inProgress(
          documentCheck: StageStatus.running,
          faceComparison: StageStatus.pending,
        ),
      );
    }
    if (elapsed < matchedAfter) {
      return const Result.ok(
        VerificationJobStatus.inProgress(
          documentCheck: StageStatus.passed,
          faceComparison: StageStatus.running,
        ),
      );
    }
    if (forcedFailure == 'service_failure') {
      return Result.ok(
        VerificationJobStatus.completed(
          outcome: const VerificationOutcome.serviceFailure(),
          documentCheck: StageStatus.passed,
          faceComparison: StageStatus.failed,
          resumableUntil: now.add(resumeWindow),
        ),
      );
    }
    return const Result.ok(
      VerificationJobStatus.completed(
        outcome: VerificationOutcome.matched(),
        documentCheck: StageStatus.passed,
        faceComparison: StageStatus.passed,
      ),
    );
  }
}
