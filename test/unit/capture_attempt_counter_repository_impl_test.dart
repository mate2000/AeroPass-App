// Exercises CaptureAttemptCounterRepositoryImpl's genuine-storage-failure
// branches (Result.error paths) — not part of the required 4-case contract
// suite (contracts/capture-attempt-counter-port.md, which only covers
// "no data yet" and success paths), but real trust-boundary code
// (Constitution Principle IV) that should not go untested.
import 'package:aeropass_app/core/clock.dart';
import 'package:aeropass_app/data/services/capture_attempt_counter_repository_impl.dart';
import 'package:aeropass_app/data/services/capture_attempt_counter_service.dart';
import 'package:aeropass_app/domain/entities/capture_attempt_counter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

class _FixedClock implements Clock {
  const _FixedClock();
  @override
  DateTime now() => DateTime.utc(2026, 1, 1);
}

/// Throws on every call — simulates a genuine platform secure-storage
/// failure (as opposed to "nothing written yet", which is a normal,
/// non-throwing empty read).
class _ThrowingSecureStoragePlatform extends FlutterSecureStoragePlatform {
  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async => throw StateError('storage unavailable');

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async => throw StateError('storage unavailable');

  @override
  Future<bool> containsKey({
    required String key,
    required Map<String, String> options,
  }) async => throw StateError('storage unavailable');

  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) async => throw StateError('storage unavailable');

  @override
  Future<Map<String, String>> readAll({
    required Map<String, String> options,
  }) async => throw StateError('storage unavailable');

  @override
  Future<void> deleteAll({required Map<String, String> options}) async =>
      throw StateError('storage unavailable');
}

void main() {
  late CaptureAttemptCounterRepositoryImpl repository;

  setUp(() {
    FlutterSecureStoragePlatform.instance = _ThrowingSecureStoragePlatform();
    final service = CaptureAttemptCounterService(
      secureStorage: const FlutterSecureStorage(),
    );
    repository = CaptureAttemptCounterRepositoryImpl(
      service,
      clock: const _FixedClock(),
    );
  });

  test('read() surfaces a genuine storage failure as Error', () async {
    final result = await repository.read(AttemptCounterScope.documentCapture);
    expect(result.isError, isTrue);
  });

  test('increment() surfaces a genuine storage failure as Error', () async {
    final result = await repository.increment(
      AttemptCounterScope.documentCapture,
    );
    expect(result.isError, isTrue);
  });

  test('reset() surfaces a genuine storage failure as Error', () async {
    final result = await repository.reset(AttemptCounterScope.documentCapture);
    expect(result.isError, isTrue);
  });
}
