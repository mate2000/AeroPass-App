import 'package:meta/meta.dart';

import '../../core/result.dart';
import '../entities/capture_attempt_counter.dart';

/// The port backing the constitution's amended Principle I persisted state
/// (count + last-reset timestamp only), per
/// contracts/capture-attempt-counter-port.md — generalized (006-selfie-liveness,
/// research.md §3, contracts/attempt-counter-port-addendum.md) to serve any
/// number of independent, per-step attempt budgets via [AttemptCounterScope],
/// rather than one hardcoded to document capture.
abstract class CaptureAttemptCounterRepository {
  /// Returns the current counter for [scope], or a fresh
  /// `CaptureAttemptCounter(count: 0, lastResetAt: <now>)` if none has ever
  /// been written for that scope — never `Ok(null)`, since a zeroed counter
  /// is itself a valid, meaningful value here.
  @useResult
  Future<Result<CaptureAttemptCounter>> read(AttemptCounterScope scope);

  /// Persists `count + 1` for [scope] with the same `lastResetAt`, and
  /// returns the updated value.
  @useResult
  Future<Result<CaptureAttemptCounter>> increment(AttemptCounterScope scope);

  /// Persists `count: 0` for [scope] with a fresh `lastResetAt`, and returns
  /// the updated value. Called on a successful capture or when the
  /// limit-reached routing occurs — the limit protects one continuous run of
  /// attempts, not a lifetime ban.
  @useResult
  Future<Result<CaptureAttemptCounter>> reset(AttemptCounterScope scope);
}
