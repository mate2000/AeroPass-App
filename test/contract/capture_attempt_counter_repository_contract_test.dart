// Contract: CaptureAttemptCounterRepository
// (contracts/capture-attempt-counter-port.md,
// contracts/attempt-counter-port-addendum.md).
//
// The same case suite runs against BOTH the fake and the real
// implementation, unmodified — Constitution Principle X's Liskov
// requirement. Cases 1-4 run once per AttemptCounterScope (006-selfie-liveness);
// cases 5-6 prove the scopes are independent of one another.
import 'package:aeropass_app/core/clock.dart';
import 'package:aeropass_app/data/services/capture_attempt_counter_repository_impl.dart';
import 'package:aeropass_app/data/services/capture_attempt_counter_service.dart';
import 'package:aeropass_app/domain/entities/capture_attempt_counter.dart';
import 'package:aeropass_app/domain/repositories/capture_attempt_counter_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_capture_attempt_counter_repository.dart';
import '../fakes/fake_secure_storage_platform.dart';

class _FakeClock implements Clock {
  _FakeClock(this._now);
  DateTime _now;
  @override
  DateTime now() => _now;
  void advance(Duration d) => _now = _now.add(d);
}

void main() {
  group('Fake implementation', () {
    for (final scope in AttemptCounterScope.values) {
      group(scope.name, () => _runContractTests(_FakeHarnessFactory(), scope));
    }
    _runIndependenceTests(_FakeHarnessFactory());
  });

  group('Real implementation', () {
    for (final scope in AttemptCounterScope.values) {
      group(scope.name, () => _runContractTests(_RealHarnessFactory(), scope));
    }
    _runIndependenceTests(_RealHarnessFactory());
  });
}

void _runContractTests(_HarnessFactory factory, AttemptCounterScope scope) {
  test('1. read() with nothing ever written -> Ok(CaptureAttemptCounter(count: 0, ...))', () async {
    final harness = factory.create();

    final result = await harness.repository.read(scope);

    final counter = result.when(
      ok: (c) => c,
      error: (e, st) =>
          fail('expected Ok(CaptureAttemptCounter), got Error: $e'),
    );
    expect(counter.count, 0);
  });

  test('2. increment() three times in a row -> read() afterward reflects '
      'count: 3 with the same lastResetAt each time', () async {
    final harness = factory.create();

    final first = (await harness.repository.increment(scope)).valueOrNull!;
    final second = (await harness.repository.increment(scope)).valueOrNull!;
    final third = (await harness.repository.increment(scope)).valueOrNull!;

    expect(third.count, 3);
    expect(second.lastResetAt, first.lastResetAt);
    expect(third.lastResetAt, first.lastResetAt);

    final afterRead = (await harness.repository.read(scope)).valueOrNull!;
    expect(afterRead.count, 3);
    expect(afterRead.lastResetAt, first.lastResetAt);
  });

  test('3. reset() after a nonzero count -> read() afterward reflects count: 0 '
      'and a new lastResetAt strictly later than the previous one', () async {
    final harness = factory.create();

    final beforeReset = (await harness.repository.increment(scope))
        .valueOrNull!;
    harness.advanceClock(const Duration(seconds: 1));
    final afterReset = (await harness.repository.reset(scope)).valueOrNull!;

    expect(afterReset.count, 0);
    expect(afterReset.lastResetAt.isAfter(beforeReset.lastResetAt), isTrue);

    final read = (await harness.repository.read(scope)).valueOrNull!;
    expect(read.count, 0);
    expect(read.lastResetAt, afterReset.lastResetAt);
  });

  test('4. The counter survives being read by a new instance of the repository '
      '(simulating an app restart)', () async {
    final harness = factory.create();
    final _ = await harness.repository.increment(scope);
    final _ = await harness.repository.increment(scope);

    final restarted = harness.createNewInstance();
    final result = await restarted.read(scope);

    final counter = result.when(
      ok: (c) => c,
      error: (e, st) =>
          fail('expected Ok(CaptureAttemptCounter), got Error: $e'),
    );
    expect(counter.count, 2);
  });
}

void _runIndependenceTests(_HarnessFactory factory) {
  group('scope independence (attempt-counter-port-addendum.md)', () {
    test(
      '5. incrementing one scope does not affect another scope\'s count',
      () async {
        final harness = factory.create();

        final _ = await harness.repository.increment(
          AttemptCounterScope.documentCapture,
        );
        final _ = await harness.repository.increment(
          AttemptCounterScope.documentCapture,
        );

        final documentCount = (await harness.repository.read(
          AttemptCounterScope.documentCapture,
        )).valueOrNull!;
        final selfieCount = (await harness.repository.read(
          AttemptCounterScope.selfieLiveness,
        )).valueOrNull!;

        expect(documentCount.count, 2);
        expect(selfieCount.count, 0);
      },
    );

    test(
      '6. resetting one scope does not affect another scope\'s nonzero count',
      () async {
        final harness = factory.create();

        final _ = await harness.repository.increment(
          AttemptCounterScope.documentCapture,
        );
        final _ = await harness.repository.increment(
          AttemptCounterScope.selfieLiveness,
        );
        final _ = await harness.repository.increment(
          AttemptCounterScope.selfieLiveness,
        );

        final _ = await harness.repository.reset(
          AttemptCounterScope.documentCapture,
        );

        final documentCount = (await harness.repository.read(
          AttemptCounterScope.documentCapture,
        )).valueOrNull!;
        final selfieCount = (await harness.repository.read(
          AttemptCounterScope.selfieLiveness,
        )).valueOrNull!;

        expect(documentCount.count, 0);
        expect(selfieCount.count, 2);
      },
    );
  });
}

/// Stages a contract scenario's preconditions, independently of which
/// implementation backs [repository].
abstract class _Harness {
  CaptureAttemptCounterRepository get repository;

  void advanceClock(Duration d);

  /// Constructs a *new* repository instance backed by the same underlying
  /// storage, simulating an app restart (case 4).
  CaptureAttemptCounterRepository createNewInstance();
}

abstract class _HarnessFactory {
  _Harness create();
}

// --- Fake-backed harness -------------------------------------------------

class _FakeHarnessFactory implements _HarnessFactory {
  @override
  _Harness create() => _FakeHarness();
}

class _FakeHarness implements _Harness {
  final _clock = _FakeClock(DateTime.utc(2026, 1, 1));
  late FakeCaptureAttemptCounterRepository _repo =
      FakeCaptureAttemptCounterRepository(now: _clock.now);

  @override
  CaptureAttemptCounterRepository get repository => _repo;

  @override
  void advanceClock(Duration d) => _clock.advance(d);

  @override
  CaptureAttemptCounterRepository createNewInstance() {
    // The fake has no external storage to persist across instances by
    // design (it's an in-memory double, contracts/…: "no secure storage").
    // Seeding the new instance from the old one's synchronous snapshot is
    // this fake's substitute for "a new instance reads the same
    // underlying store" — the real implementation's harness below is what
    // actually proves persistence across a fresh object graph.
    final next = FakeCaptureAttemptCounterRepository(now: _clock.now);
    for (final scope in AttemptCounterScope.values) {
      final snapshot = _repo.currentForTesting(scope);
      if (snapshot != null) {
        next.seed(scope, snapshot);
      }
    }
    _repo = next;
    return next;
  }
}

// --- Real-backed harness --------------------------------------------------

class _RealHarnessFactory implements _HarnessFactory {
  @override
  _Harness create() => _RealHarness();
}

class _RealHarness implements _Harness {
  _RealHarness() {
    FlutterSecureStoragePlatform.instance = _storagePlatform;
  }

  final _storagePlatform = FakeSecureStoragePlatform();
  final _clock = _FakeClock(DateTime.utc(2026, 1, 1));

  late final CaptureAttemptCounterRepository _repo = _build();

  CaptureAttemptCounterRepository _build() {
    final service = CaptureAttemptCounterService(
      secureStorage: const FlutterSecureStorage(),
    );
    return CaptureAttemptCounterRepositoryImpl(service, clock: _clock);
  }

  @override
  CaptureAttemptCounterRepository get repository => _repo;

  @override
  void advanceClock(Duration d) => _clock.advance(d);

  @override
  CaptureAttemptCounterRepository createNewInstance() {
    // Same backing FakeSecureStoragePlatform (simulating the same device's
    // Keystore/Keychain), but a brand-new service/repository object graph
    // — simulating a fresh app process reading persisted state.
    return _build();
  }
}
