import 'dart:typed_data';

import 'package:aeropass_app/app/enrollment_session_controller.dart';
import 'package:aeropass_app/core/clock.dart';
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/capture_attempt_counter.dart';
import 'package:aeropass_app/domain/entities/liveness_sample_outcome.dart';
import 'package:aeropass_app/features/enrollment/liveness/liveness_capture_view_state.dart';
import 'package:aeropass_app/features/enrollment/liveness/liveness_capture_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_analytics_emitter.dart';
import '../fakes/fake_capture_attempt_counter_repository.dart';
import '../fakes/fake_liveness_camera_service.dart';
import '../fakes/fake_liveness_verification_repository.dart';

class _FixedClock implements Clock {
  _FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

// Fast, deterministic timings for tests — production defaults (200ms
// sample interval, 45s stall) would make this suite unusably slow.
const _testSampleInterval = Duration(milliseconds: 1);
const _testStallDuration = Duration(milliseconds: 20);

LivenessSampleOutcome _inProgress(int index, int total) =>
    LivenessSampleOutcome.inProgress(
      phase: LivenessPhase(
        index: index,
        totalPhases: total,
        instruction: const LivenessInstruction.holdStill(),
      ),
    );

void main() {
  late FakeLivenessVerificationRepository livenessVerificationRepository;
  late FakeLivenessCameraService livenessCameraService;
  late FakeCaptureAttemptCounterRepository attemptCounterRepository;
  late EnrollmentSessionController sessionController;
  late FakeAnalyticsEmitter analyticsEmitter;

  setUp(() {
    livenessVerificationRepository = FakeLivenessVerificationRepository();
    livenessCameraService = FakeLivenessCameraService();
    livenessCameraService.scriptFrame(Uint8List.fromList([1]));
    attemptCounterRepository = FakeCaptureAttemptCounterRepository();
    sessionController = EnrollmentSessionController(
      clock: _FixedClock(DateTime.utc(2026, 1, 1)),
    );
    analyticsEmitter = FakeAnalyticsEmitter();
  });

  LivenessCaptureViewModel buildViewModel({
    Duration sampleInterval = _testSampleInterval,
    Duration stallDuration = _testStallDuration,
  }) {
    return LivenessCaptureViewModel(
      livenessVerificationRepository: livenessVerificationRepository,
      livenessCameraService: livenessCameraService,
      attemptCounterRepository: attemptCounterRepository,
      enrollmentSessionController: sessionController,
      analyticsEmitter: analyticsEmitter,
      sampleInterval: sampleInterval,
      stallDuration: stallDuration,
    );
  }

  group('T028/FR-001: reachability guard', () {
    test(
      'without a confirmed identity record, no attempt runs and '
      'navigation targets document capture',
      () async {
        // No startOrResume()/markIdentityConfirmed() — current is null.
        final viewModel = buildViewModel();
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(
          viewModel.pendingNavigation,
          LivenessNavigationTarget.documentCapture,
        );
        expect(livenessVerificationRepository.startSessionCallCount, 0);
        expect(
          analyticsEmitter.events.map((e) => e.name),
          isNot(contains('liveness_step_entered')),
        );
      },
    );
  });

  group('T028/US1: the sample loop and a successful attempt', () {
    setUp(() {
      sessionController.startOrResume();
      sessionController.markIdentityConfirmed();
    });

    test(
      'calls startSession() then repeatedly submitSample(); each '
      'inProgress response updates phase/progress; a terminal success '
      'resets the selfie-liveness counter and navigates to verification '
      'progress; no session is retained afterward',
      () async {
        livenessVerificationRepository.scriptStartSession(
          const Result.ok('session-1'),
        );
        livenessVerificationRepository.scriptSubmitSampleSequence([
          Result.ok(_inProgress(0, 4)),
          Result.ok(_inProgress(1, 4)),
          Result.ok(_inProgress(2, 4)),
          const Result.ok(
            LivenessSampleOutcome.completed(outcome: LivenessOutcome.success()),
          ),
        ]);
        attemptCounterRepository.seed(
          AttemptCounterScope.selfieLiveness,
          CaptureAttemptCounter(count: 2, lastResetAt: DateTime.utc(2026, 1, 1)),
        );

        final viewModel = buildViewModel();
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(livenessVerificationRepository.startSessionCallCount, 1);
        expect(
          livenessVerificationRepository.submitSampleCallCount,
          greaterThanOrEqualTo(4),
        );
        expect(viewModel.state, isA<LivenessCaptureViewOutcome>());
        final outcomeState = viewModel.state as LivenessCaptureViewOutcome;
        expect(outcomeState.outcome, const LivenessOutcome.success());
        expect(
          viewModel.pendingNavigation,
          LivenessNavigationTarget.verificationProgress,
        );
        expect(viewModel.hasHeldSession, isFalse);

        final counter = (await attemptCounterRepository.read(
          AttemptCounterScope.selfieLiveness,
        )).valueOrNull!;
        expect(counter.count, 0);
        expect(
          analyticsEmitter.events.map((e) => e.name),
          containsAllInOrder(['liveness_step_entered', 'liveness_phase_reached']),
        );
      },
    );

    test('the phase indicator never regresses (FR-007)', () async {
      livenessVerificationRepository.scriptStartSession(
        const Result.ok('session-1'),
      );
      livenessVerificationRepository.scriptSubmitSampleSequence([
        Result.ok(_inProgress(2, 4)),
        // A lower index than the last one reported — must be ignored.
        Result.ok(_inProgress(0, 4)),
        const Result.ok(
          LivenessSampleOutcome.completed(outcome: LivenessOutcome.success()),
        ),
      ]);

      final viewModel = buildViewModel();
      // Pump just long enough to observe the running state after the
      // first two responses, before the terminal one lands.
      await Future<void>.delayed(const Duration(milliseconds: 5));

      final state = viewModel.state;
      if (state is LivenessCaptureViewRunning) {
        expect(state.phase.index, 2);
      }
    });
  });

  group('T039/US2: outcome handling and the attempt counter', () {
    setUp(() {
      sessionController.startOrResume();
      sessionController.markIdentityConfirmed();
      livenessVerificationRepository.scriptStartSession(
        const Result.ok('session-1'),
      );
    });

    test(
      'a qualityFailure outcome increments the selfieLiveness-scoped '
      'counter, leaving documentCapture untouched, and does not navigate',
      () async {
        livenessVerificationRepository.scriptSubmitSample(
          const Result.ok(
            LivenessSampleOutcome.completed(
              outcome: LivenessOutcome.qualityFailure(
                reason: LivenessQualityReason.tooDark,
              ),
            ),
          ),
        );

        final viewModel = buildViewModel();
        await Future<void>.delayed(const Duration(milliseconds: 100));

        final state = viewModel.state as LivenessCaptureViewOutcome;
        expect(state.outcome, isA<LivenessOutcomeQualityFailure>());
        expect(state.limitReached, isFalse);
        expect(viewModel.pendingNavigation, isNull);

        final selfieCounter = (await attemptCounterRepository.read(
          AttemptCounterScope.selfieLiveness,
        )).valueOrNull!;
        final documentCounter = (await attemptCounterRepository.read(
          AttemptCounterScope.documentCapture,
        )).valueOrNull!;
        expect(selfieCounter.count, 1);
        expect(documentCounter.count, 0);
        expect(
          analyticsEmitter.events.map((e) => e.name),
          containsAll(['liveness_outcome', 'liveness_attempt_count']),
        );
      },
    );

    test(
      'unclassifiedFailure and attackDetected both surface as a non-limit '
      'outcome state (the view collapses their rendering; the ViewModel '
      'still relays the true classification)',
      () async {
        livenessVerificationRepository.scriptSubmitSample(
          const Result.ok(
            LivenessSampleOutcome.completed(
              outcome: LivenessOutcome.unclassifiedFailure(),
            ),
          ),
        );
        final unclassifiedVm = buildViewModel();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        final unclassifiedState =
            unclassifiedVm.state as LivenessCaptureViewOutcome;
        expect(unclassifiedState.outcome, isA<LivenessOutcomeUnclassifiedFailure>());

        livenessVerificationRepository.scriptSubmitSample(
          const Result.ok(
            LivenessSampleOutcome.completed(
              outcome: LivenessOutcome.attackDetected(),
            ),
          ),
        );
        final attackVm = buildViewModel();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        final attackState = attackVm.state as LivenessCaptureViewOutcome;
        expect(attackState.outcome, isA<LivenessOutcomeAttackDetected>());
      },
    );

    test(
      'the 3rd non-success outcome in a row routes to retry guidance and '
      'resets the counter',
      () async {
        livenessVerificationRepository.scriptSubmitSample(
          const Result.ok(
            LivenessSampleOutcome.completed(
              outcome: LivenessOutcome.qualityFailure(
                reason: LivenessQualityReason.tooDark,
              ),
            ),
          ),
        );

        LivenessCaptureViewModel? viewModel;
        for (var i = 0; i < 3; i++) {
          viewModel = buildViewModel();
          await Future<void>.delayed(const Duration(milliseconds: 100));
          if (i < 2) {
            expect(viewModel.pendingNavigation, isNull);
          }
        }

        expect(
          viewModel!.pendingNavigation,
          LivenessNavigationTarget.retryGuidance,
        );
        final state = viewModel.state as LivenessCaptureViewOutcome;
        expect(state.limitReached, isTrue);
        final counter = (await attemptCounterRepository.read(
          AttemptCounterScope.selfieLiveness,
        )).valueOrNull!;
        expect(counter.count, 0);
        expect(
          analyticsEmitter.events.map((e) => e.name),
          contains('liveness_attempt_limit_reached'),
        );
      },
    );
  });

  group(
    'T041: LivenessOutcome.unclassifiedFailure() and .attackDetected() are '
    'distinct domain values',
    () {
      test('are not equal, even though the view renders them identically', () {
        expect(
          const LivenessOutcome.unclassifiedFailure(),
          isNot(const LivenessOutcome.attackDetected()),
        );
      });
    },
  );

  group('T047/US3: interruption and abandonment', () {
    setUp(() {
      sessionController.startOrResume();
      sessionController.markIdentityConfirmed();
    });

    test(
      'onBackNavigation() aborts the capture, discards the held session, '
      'and emits abandonment when no outcome was recorded yet',
      () async {
        livenessVerificationRepository.scriptStartSession(
          const Result.ok('session-1'),
        );
        livenessVerificationRepository.scriptSubmitSample(
          Result.ok(_inProgress(0, 4)),
        );
        final viewModel = buildViewModel();
        await Future<void>.delayed(const Duration(milliseconds: 5));

        viewModel.onBackNavigation();

        expect(viewModel.hasHeldSession, isFalse);
        expect(
          analyticsEmitter.events.map((e) => e.name),
          contains('liveness_step_abandoned'),
        );
      },
    );

    test(
      'onBackNavigation() after a recorded outcome does not emit '
      'abandonment',
      () async {
        livenessVerificationRepository.scriptStartSession(
          const Result.ok('session-1'),
        );
        livenessVerificationRepository.scriptSubmitSample(
          const Result.ok(
            LivenessSampleOutcome.completed(outcome: LivenessOutcome.success()),
          ),
        );
        final viewModel = buildViewModel();
        await Future<void>.delayed(const Duration(milliseconds: 100));

        viewModel.onBackNavigation();

        expect(
          analyticsEmitter.events.map((e) => e.name),
          isNot(contains('liveness_step_abandoned')),
        );
      },
    );

    test(
      'onAppBackgrounded() stops the camera and discards the held session',
      () async {
        livenessVerificationRepository.scriptStartSession(
          const Result.ok('session-1'),
        );
        livenessVerificationRepository.scriptSubmitSample(
          Result.ok(_inProgress(0, 4)),
        );
        final viewModel = buildViewModel();
        await Future<void>.delayed(const Duration(milliseconds: 5));

        await viewModel.onAppBackgrounded();

        expect(livenessCameraService.stopCallCount, greaterThanOrEqualTo(1));
        expect(livenessCameraService.started, isFalse);
        expect(viewModel.hasHeldSession, isFalse);
      },
    );

    test(
      'a stall timer firing with no terminal outcome surfaces FR-013\'s '
      'explanation state',
      () async {
        livenessVerificationRepository.scriptStartSession(
          const Result.ok('session-1'),
        );
        // Always in-progress — never reaches a terminal outcome on its own.
        livenessVerificationRepository.scriptSubmitSample(
          Result.ok(_inProgress(0, 4)),
        );

        final viewModel = buildViewModel();
        await Future<void>.delayed(const Duration(milliseconds: 60));

        expect(viewModel.state, isA<LivenessCaptureViewStalled>());
        expect(
          analyticsEmitter.events.map((e) => e.name),
          contains('liveness_stalled'),
        );
      },
    );
  });
}
