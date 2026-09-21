import '../../core/clock.dart';
import '../../core/result.dart';
import '../../domain/entities/capture_attempt_counter.dart';
import '../../domain/repositories/capture_attempt_counter_repository.dart';
import 'capture_attempt_counter_service.dart';

/// The real `CaptureAttemptCounterRepository` implementation, backed by
/// `CaptureAttemptCounterService`. Per
/// contracts/capture-attempt-counter-port.md: no secure-storage exception
/// or raw string encoding may cross out of this class — callers only ever
/// see `CaptureAttemptCounter`/`Result`.
///
/// MUST satisfy the exact same contract test suite as
/// `FakeCaptureAttemptCounterRepository`, unmodified (Constitution
/// Principle X, Liskov) — see
/// test/contract/capture_attempt_counter_repository_contract_test.dart.
class CaptureAttemptCounterRepositoryImpl
    implements CaptureAttemptCounterRepository {
  CaptureAttemptCounterRepositoryImpl(this._service, {required Clock clock})
    : _clock = clock;

  final CaptureAttemptCounterService _service;
  final Clock _clock;

  @override
  Future<Result<CaptureAttemptCounter>> read() async {
    try {
      final existing = await _service.read();
      if (existing != null) {
        return Result.ok(existing);
      }
      // Never Ok(null) — a zeroed counter is itself a valid, meaningful
      // value here (contract case 1).
      final fresh = CaptureAttemptCounter(count: 0, lastResetAt: _clock.now());
      return Result.ok(fresh);
    } catch (e, st) {
      return Result.error(e, st);
    }
  }

  @override
  Future<Result<CaptureAttemptCounter>> increment() async {
    try {
      final current = await _service.read() ??
          CaptureAttemptCounter(count: 0, lastResetAt: _clock.now());
      final next = current.copyWith(count: current.count + 1);
      await _service.write(next);
      return Result.ok(next);
    } catch (e, st) {
      return Result.error(e, st);
    }
  }

  @override
  Future<Result<CaptureAttemptCounter>> reset() async {
    try {
      final next = CaptureAttemptCounter(count: 0, lastResetAt: _clock.now());
      await _service.write(next);
      return Result.ok(next);
    } catch (e, st) {
      return Result.error(e, st);
    }
  }
}
