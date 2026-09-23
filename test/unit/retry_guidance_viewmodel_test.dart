// 009-reintento T006/T012: RetryGuidanceViewModel derives its state from the
// attempt counters, never from how the screen was reached (research.md §1).
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/capture_attempt_counter.dart';
import 'package:aeropass_app/domain/entities/retry_guidance_state.dart';
import 'package:aeropass_app/domain/repositories/capture_attempt_counter_repository.dart';
import 'package:aeropass_app/features/enrollment/retry/retry_guidance_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_analytics_emitter.dart';
import '../fakes/fake_capture_attempt_counter_repository.dart';

class _FailingCounters implements CaptureAttemptCounterRepository {
  @override
  Future<Result<CaptureAttemptCounter>> read(AttemptCounterScope scope) async =>
      Result.error(StateError('keystore unavailable'));

  @override
  Future<Result<CaptureAttemptCounter>> increment(AttemptCounterScope scope) =>
      throw UnimplementedError();

  @override
  Future<Result<CaptureAttemptCounter>> reset(AttemptCounterScope scope) =>
      throw UnimplementedError();
}

void main() {
  late FakeCaptureAttemptCounterRepository counters;
  late FakeAnalyticsEmitter analytics;

  setUp(() {
    counters = FakeCaptureAttemptCounterRepository();
    analytics = FakeAnalyticsEmitter();
  });

  void seed(AttemptCounterScope scope, int count) => counters.seed(
    scope,
    CaptureAttemptCounter(count: count, lastResetAt: DateTime.utc(2026)),
  );

  Future<RetryGuidanceViewModel> build([
    CaptureAttemptCounterRepository? repository,
  ]) async {
    final vm = RetryGuidanceViewModel(
      attemptCounterRepository: repository ?? counters,
      analyticsEmitter: analytics,
    );
    await pumpEventQueue();
    return vm;
  }

  group('US1', () {
    test(
      'both counters below the limit give selfieRetry, with a retry',
      () async {
        seed(AttemptCounterScope.selfieLiveness, 1);

        final vm = await build();

        expect(vm.state, RetryGuidanceState.selfieRetry);
        expect(vm.canRetry, isTrue);
      },
    );

    test('retry_guidance_shown fires once, with the state', () async {
      await build();

      final shown = analytics.events.where(
        (e) => e.name == 'retry_guidance_shown',
      );
      expect(shown, hasLength(1));
      expect(shown.single.payload, {'state': 'selfieRetry'});
    });

    test('onRetry fires retry_guidance_retry_taken once', () async {
      final vm = await build();
      analytics.events.clear();

      vm.onRetry();

      expect(analytics.events.single.name, 'retry_guidance_retry_taken');
    });

    test(
      'onAgentRoute fires retry_guidance_agent_route_taken with the state',
      () async {
        final vm = await build();
        analytics.events.clear();

        vm.onAgentRoute();

        expect(
          analytics.events.single.name,
          'retry_guidance_agent_route_taken',
        );
        expect(analytics.events.single.payload, {'state': 'selfieRetry'});
      },
    );

    test('state is null until the counters have been read', () {
      final vm = RetryGuidanceViewModel(
        attemptCounterRepository: counters,
        analyticsEmitter: analytics,
      );

      expect(vm.state, isNull);
      expect(vm.canRetry, isFalse);
    });
  });

  group('US2', () {
    test(
      'the selfie counter at the limit gives selfieLimit, with no retry',
      () async {
        seed(AttemptCounterScope.selfieLiveness, captureAttemptLimit);

        final vm = await build();

        expect(vm.state, RetryGuidanceState.selfieLimit);
        expect(vm.canRetry, isFalse);
      },
    );

    test('the document counter at the limit gives documentLimit', () async {
      seed(AttemptCounterScope.documentCapture, captureAttemptLimit);

      final vm = await build();

      expect(vm.state, RetryGuidanceState.documentLimit);
      expect(vm.canRetry, isFalse);
    });

    test('documentLimit wins when both counters are at the limit', () async {
      seed(AttemptCounterScope.documentCapture, captureAttemptLimit);
      seed(AttemptCounterScope.selfieLiveness, captureAttemptLimit);

      final vm = await build();

      expect(vm.state, RetryGuidanceState.documentLimit);
    });

    test('a failed counter read gives selfieLimit: never a retry it cannot justify', () async {
      final vm = await build(_FailingCounters());

      expect(vm.state, RetryGuidanceState.selfieLimit);
      expect(vm.canRetry, isFalse);
    });
  });
}
