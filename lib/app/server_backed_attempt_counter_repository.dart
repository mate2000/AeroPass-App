import '../core/clock.dart';
import '../core/result.dart';
import '../domain/entities/capture_attempt_counter.dart';
import '../domain/entities/verification_result.dart';
import '../domain/repositories/capture_attempt_counter_repository.dart';
import 'verification_submission.dart';

/// The selfie counter, read from the server (015 FR-008). The app keeps no
/// verification-attempt count of its own.
///
/// - **The selfie scope** is derived from the last verification result's
///   `intentos_restantes`: `count = limit − remaining`. Increment and reset
///   change nothing, because the backend decides. With no result yet in this
///   run, the count is 0; the backend still enforces its limit, and a
///   passenger at it gets `REQUIERE_REVISION_MANUAL` (NeedsReview → 010).
/// - **The document scope** is 003's capture-quality counter, which the
///   constitution allows, so it is delegated unchanged.
class ServerBackedAttemptCounterRepository
    implements CaptureAttemptCounterRepository {
  ServerBackedAttemptCounterRepository({
    required CaptureAttemptCounterRepository local,
    required VerificationSubmission submission,
    required Clock clock,
  }) : _local = local,
       _submission = submission,
       _clock = clock;

  final CaptureAttemptCounterRepository _local;
  final VerificationSubmission _submission;
  final Clock _clock;

  @override
  Future<Result<CaptureAttemptCounter>> read(AttemptCounterScope scope) =>
      scope == AttemptCounterScope.selfieLiveness
      ? Future.value(Result.ok(_serverCount()))
      : _local.read(scope);

  @override
  Future<Result<CaptureAttemptCounter>> increment(AttemptCounterScope scope) =>
      read(scope).then(
        (current) => scope == AttemptCounterScope.selfieLiveness
            ? current
            : _local.increment(scope),
      );

  @override
  Future<Result<CaptureAttemptCounter>> reset(AttemptCounterScope scope) =>
      scope == AttemptCounterScope.selfieLiveness
      ? read(scope)
      : _local.reset(scope);

  CaptureAttemptCounter _serverCount() {
    final count = switch (_submission.lastResult) {
      Failed(:final remaining) => (captureAttemptLimit - remaining).clamp(
        0,
        captureAttemptLimit,
      ),
      NeedsReview() => captureAttemptLimit,
      _ => 0,
    };
    return CaptureAttemptCounter(count: count, lastResetAt: _clock.now());
  }
}
