import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/capture_attempt_counter.dart';
import 'package:aeropass_app/domain/repositories/capture_attempt_counter_repository.dart';

/// An in-memory `CaptureAttemptCounterRepository` double, per
/// contracts/capture-attempt-counter-port.md — no secure storage, same
/// scripted-double pattern as the app's other fakes. Scope-aware
/// (006-selfie-liveness, research.md §3): each `AttemptCounterScope` holds
/// its own independent in-memory counter.
class FakeCaptureAttemptCounterRepository
    implements CaptureAttemptCounterRepository {
  FakeCaptureAttemptCounterRepository({DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  final Map<AttemptCounterScope, CaptureAttemptCounter> _counters = {};

  /// Seeds the current counter for [scope] directly (e.g. to simulate an
  /// app restart with attempts already recorded).
  void seed(AttemptCounterScope scope, CaptureAttemptCounter counter) {
    _counters[scope] = counter;
  }

  /// Synchronous peek at [scope]'s current in-memory value, or `null` if
  /// nothing has ever been written — used only by test harnesses to
  /// simulate "a new instance reading the same underlying store" (this fake
  /// has no real external store to share, by design).
  CaptureAttemptCounter? currentForTesting(AttemptCounterScope scope) =>
      _counters[scope];

  @override
  Future<Result<CaptureAttemptCounter>> read(AttemptCounterScope scope) async {
    final current = _counters[scope] ??= CaptureAttemptCounter(
      count: 0,
      lastResetAt: _now(),
    );
    return Result.ok(current);
  }

  @override
  Future<Result<CaptureAttemptCounter>> increment(
    AttemptCounterScope scope,
  ) async {
    final current = _counters[scope] ??= CaptureAttemptCounter(
      count: 0,
      lastResetAt: _now(),
    );
    final next = current.copyWith(count: current.count + 1);
    _counters[scope] = next;
    return Result.ok(next);
  }

  @override
  Future<Result<CaptureAttemptCounter>> reset(AttemptCounterScope scope) async {
    final next = CaptureAttemptCounter(count: 0, lastResetAt: _now());
    _counters[scope] = next;
    return Result.ok(next);
  }
}
