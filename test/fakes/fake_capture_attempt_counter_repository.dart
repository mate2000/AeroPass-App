import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/capture_attempt_counter.dart';
import 'package:aeropass_app/domain/repositories/capture_attempt_counter_repository.dart';

/// An in-memory `CaptureAttemptCounterRepository` double, per
/// contracts/capture-attempt-counter-port.md — no secure storage, same
/// scripted-double pattern as the app's other fakes.
class FakeCaptureAttemptCounterRepository
    implements CaptureAttemptCounterRepository {
  FakeCaptureAttemptCounterRepository({DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  CaptureAttemptCounter? _counter;

  /// Seeds the current counter directly (e.g. to simulate an app restart
  /// with attempts already recorded).
  void seed(CaptureAttemptCounter counter) {
    _counter = counter;
  }

  /// Synchronous peek at the current in-memory value, or `null` if nothing
  /// has ever been written — used only by test harnesses to simulate "a new
  /// instance reading the same underlying store" (this fake has no real
  /// external store to share, by design).
  CaptureAttemptCounter? get currentForTesting => _counter;

  @override
  Future<Result<CaptureAttemptCounter>> read() async {
    final current = _counter ??= CaptureAttemptCounter(
      count: 0,
      lastResetAt: _now(),
    );
    return Result.ok(current);
  }

  @override
  Future<Result<CaptureAttemptCounter>> increment() async {
    final current = _counter ??= CaptureAttemptCounter(
      count: 0,
      lastResetAt: _now(),
    );
    final next = current.copyWith(count: current.count + 1);
    _counter = next;
    return Result.ok(next);
  }

  @override
  Future<Result<CaptureAttemptCounter>> reset() async {
    final next = CaptureAttemptCounter(count: 0, lastResetAt: _now());
    _counter = next;
    return Result.ok(next);
  }
}
