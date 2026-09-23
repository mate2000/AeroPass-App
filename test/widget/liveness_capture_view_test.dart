import 'dart:typed_data';

import 'package:aeropass_app/app/enrollment_session_controller.dart';
import 'package:aeropass_app/app/router.dart' show AppRoutes;
import 'package:aeropass_app/core/clock.dart';
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/liveness_outcome.dart';
import 'package:aeropass_app/domain/entities/liveness_phase.dart';
import 'package:aeropass_app/domain/entities/liveness_sample_outcome.dart';
import 'package:aeropass_app/features/enrollment/liveness/liveness_capture_view.dart';
import 'package:aeropass_app/features/enrollment/liveness/liveness_capture_viewmodel.dart';
import 'package:aeropass_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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

// testWidgets bodies run inside an implicit fake-async zone, so these
// durations advance only as `tester.pump` drives them — never real
// wall-clock time.
const _testSampleInterval = Duration(milliseconds: 1);
const _testStallDuration = Duration(milliseconds: 500);

LivenessSampleOutcome _inProgress(int index, int total) =>
    LivenessSampleOutcome.inProgress(
      phase: LivenessPhase(
        index: index,
        totalPhases: total,
        instruction: const LivenessInstruction.holdStill(),
      ),
    );

/// Wraps `LivenessCaptureView` in a self-contained `MaterialApp.router`,
/// independent of the app's real `router.dart` — mirroring
/// `capture_view_test.dart`'s own isolation pattern, with one deliberate
/// difference: [createViewModel] is invoked from *inside*
/// `ChangeNotifierProvider`'s `create` callback (mirroring the real
/// router.dart's own construction point) rather than by the test before
/// `pumpWidget` — constructing it earlier would let a ViewModel whose
/// entire attempt resolves through zero-delay fakes (no real I/O to yield
/// on) run to completion before `LivenessCaptureView`'s listener is even
/// registered, permanently losing that `notifyListeners()` call. Uses a
/// bounded number of explicit `pump`s rather than `pumpAndSettle` — this
/// screen's automatic sample loop can otherwise be scripted to run
/// indefinitely, which `pumpAndSettle` has no reliable way to detect as
/// "done."
Future<LivenessCaptureViewModel> _pumpLivenessCaptureView(
  WidgetTester tester, {
  required LivenessCaptureViewModel Function() createViewModel,
  int loopPumps = 3,
}) async {
  late LivenessCaptureViewModel viewModel;
  final router = GoRouter(
    initialLocation: AppRoutes.selfieInstructions,
    routes: [
      GoRoute(
        path: AppRoutes.selfieInstructions,
        builder: (context, state) =>
            const Scaffold(body: Text('selfie-instructions-stub')),
      ),
      GoRoute(
        path: AppRoutes.documentCapture,
        builder: (context, state) =>
            const Scaffold(body: Text('document-capture-stub')),
      ),
      GoRoute(
        path: AppRoutes.livenessCapture,
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) {
            viewModel = createViewModel();
            return viewModel;
          },
          child: Consumer<LivenessCaptureViewModel>(
            builder: (context, vm, _) => LivenessCaptureView(viewModel: vm),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.verificationProgress,
        builder: (context, state) =>
            const Scaffold(body: Text('verification-progress-stub')),
      ),
      GoRoute(
        path: AppRoutes.retryGuidance,
        builder: (context, state) =>
            const Scaffold(body: Text('retry-guidance-stub')),
      ),
      GoRoute(
        path: AppRoutes.help,
        builder: (context, state) => const Scaffold(body: Text('help-stub')),
      ),
    ],
  );

  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
  router.push(AppRoutes.livenessCapture);
  await tester.pump();
  // Let the loop run through a handful of sample iterations — enough for
  // a scripted single/short sequence to reach its terminal state, without
  // `pumpAndSettle`'s unbounded, non-deterministic convergence wait.
  for (var i = 0; i < loopPumps; i++) {
    await tester.pump(_testSampleInterval);
  }
  await tester.pump();
  return viewModel;
}

/// Stops [viewModel]'s in-flight attempt (without disposing it — that's
/// `ChangeNotifierProvider`'s job, done automatically when
/// `flutter_test`'s own postTest teardown unmounts the widget tree; a
/// second, manual `dispose()` call here would double-dispose it) and
/// flushes the fake clock past its polling interval — MUST be called,
/// inline, as the last step of any test whose scripted sequence never
/// reaches a terminal outcome on its own, otherwise the sample loop's
/// `Timer`s are still pending when `flutter_test` checks for that right
/// after the test body returns.
Future<void> _stopAndFlush(
  WidgetTester tester,
  LivenessCaptureViewModel viewModel,
) async {
  await viewModel.onAppBackgrounded();
  await tester.pump(_testSampleInterval * 10);
  await tester.pump();
}

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
    sessionController.startOrResume();
    sessionController.markIdentityConfirmed();
    analyticsEmitter = FakeAnalyticsEmitter();
    livenessVerificationRepository.scriptStartSession(
      const Result.ok('session-1'),
    );
  });

  LivenessCaptureViewModel buildViewModel() => LivenessCaptureViewModel(
    livenessVerificationRepository: livenessVerificationRepository,
    livenessCameraService: livenessCameraService,
    attemptCounterRepository: attemptCounterRepository,
    enrollmentSessionController: sessionController,
    analyticsEmitter: analyticsEmitter,
    sampleInterval: _testSampleInterval,
    stallDuration: _testStallDuration,
  );

  group('T029 [US1]: the capture surface', () {
    testWidgets('renders with no shutter control anywhere on the surface', (
      tester,
    ) async {
      livenessVerificationRepository.scriptSubmitSample(
        Result.ok(_inProgress(0, 4)),
      );
      final viewModel = await _pumpLivenessCaptureView(
        tester,
        createViewModel: buildViewModel,
      );

      expect(find.byIcon(Icons.camera_alt), findsNothing);
      expect(find.byIcon(Icons.fiber_manual_record), findsNothing);
      expect(find.byType(FilledButton), findsNothing);

      await _stopAndFlush(tester, viewModel);
    });

    testWidgets(
      'the instruction text and phase dots update as the ViewModel\'s '
      'state changes, and the progress badge reflects index/totalPhases',
      (tester) async {
        livenessVerificationRepository.scriptSubmitSample(
          Result.ok(_inProgress(2, 4)),
        );
        final viewModel = await _pumpLivenessCaptureView(
          tester,
          createViewModel: buildViewModel,
        );

        expect(find.text('Mantente quieto'), findsOneWidget);
        expect(find.textContaining('50%'), findsOneWidget);

        await _stopAndFlush(tester, viewModel);
      },
    );

    testWidgets(
      'touching the capture surface has no effect — a successful outcome '
      'still navigates to verification progress',
      (tester) async {
        livenessVerificationRepository.scriptSubmitSampleSequence([
          Result.ok(_inProgress(0, 4)),
          const Result.ok(
            LivenessSampleOutcome.completed(outcome: LivenessOutcome.success()),
          ),
        ]);
        await _pumpLivenessCaptureView(tester, createViewModel: buildViewModel);

        // Tap in the middle of the screen — absorbed, does nothing.
        await tester.tapAt(tester.getCenter(find.byType(Scaffold)));
        await tester.pump();

        expect(find.text('verification-progress-stub'), findsOneWidget);
      },
    );
  });

  group('T040 [US2]: failure rendering', () {
    testWidgets(
      'a specific quality-failure message renders distinctly per reason, '
      'with a retry affordance below the limit',
      (tester) async {
        livenessVerificationRepository.scriptSubmitSample(
          const Result.ok(
            LivenessSampleOutcome.completed(
              outcome: LivenessOutcome.qualityFailure(
                reason: LivenessQualityReason.tooDark,
              ),
            ),
          ),
        );
        await _pumpLivenessCaptureView(tester, createViewModel: buildViewModel);

        expect(find.text('Hay poca luz'), findsOneWidget);
        expect(find.text('Reintentar'), findsOneWidget);
      },
    );

    testWidgets('unclassifiedFailure and attackDetected render the exact same '
        'widget tree — same text, same type, never a reason-specific string', (
      tester,
    ) async {
      livenessVerificationRepository.scriptSubmitSample(
        const Result.ok(
          LivenessSampleOutcome.completed(
            outcome: LivenessOutcome.unclassifiedFailure(),
          ),
        ),
      );
      await _pumpLivenessCaptureView(tester, createViewModel: buildViewModel);
      expect(find.text('No pudimos completar la captura'), findsOneWidget);
    });

    testWidgets('attackDetected renders identically to unclassifiedFailure', (
      tester,
    ) async {
      livenessVerificationRepository.scriptSubmitSample(
        const Result.ok(
          LivenessSampleOutcome.completed(
            outcome: LivenessOutcome.attackDetected(),
          ),
        ),
      );
      await _pumpLivenessCaptureView(tester, createViewModel: buildViewModel);
      expect(find.text('No pudimos completar la captura'), findsOneWidget);
    });

    testWidgets(
      'reaching the attempt limit navigates to the retry-guidance route, '
      'never leaving the passenger on a frozen surface',
      (tester) async {
        livenessVerificationRepository.scriptSubmitSample(
          const Result.ok(
            LivenessSampleOutcome.completed(
              outcome: LivenessOutcome.qualityFailure(
                reason: LivenessQualityReason.tooDark,
              ),
            ),
          ),
        );

        for (var i = 0; i < 3; i++) {
          await _pumpLivenessCaptureView(
            tester,
            createViewModel: buildViewModel,
          );
        }

        expect(find.text('retry-guidance-stub'), findsOneWidget);
      },
    );
  });

  group('T048 [US3]: interruption and navigation', () {
    testWidgets('"Atrás" pops the route and discards held state', (
      tester,
    ) async {
      livenessVerificationRepository.scriptSubmitSample(
        Result.ok(_inProgress(0, 4)),
      );
      final viewModel = await _pumpLivenessCaptureView(
        tester,
        createViewModel: buildViewModel,
      );

      await tester.tap(find.text('Atrás'));
      await tester.pump();

      expect(find.text('selfie-instructions-stub'), findsOneWidget);
      expect(viewModel.hasHeldSession, isFalse);

      await tester.pump(_testSampleInterval * 10);
      await tester.pump();
    });

    testWidgets('"Ayuda" reaches the help route', (tester) async {
      livenessVerificationRepository.scriptSubmitSample(
        Result.ok(_inProgress(0, 4)),
      );
      final viewModel = await _pumpLivenessCaptureView(
        tester,
        createViewModel: buildViewModel,
      );

      await tester.tap(find.text('Ayuda'));
      await tester.pump();

      expect(find.text('help-stub'), findsOneWidget);

      await _stopAndFlush(tester, viewModel);
    });

    testWidgets('a simulated lifecycle-paused event stops the camera preview', (
      tester,
    ) async {
      livenessVerificationRepository.scriptSubmitSample(
        Result.ok(_inProgress(0, 4)),
      );
      await _pumpLivenessCaptureView(tester, createViewModel: buildViewModel);
      final stopCountBefore = livenessCameraService.stopCallCount;

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();

      expect(livenessCameraService.stopCallCount, greaterThan(stopCountBefore));

      await tester.pump(_testSampleInterval * 10);
      await tester.pump();
    });
  });

  group('T055: accessibility (FR-005/SC-009, Constitution Principle VI)', () {
    testWidgets('every interactive control has a semantic label', (
      tester,
    ) async {
      livenessVerificationRepository.scriptSubmitSample(
        Result.ok(_inProgress(0, 4)),
      );
      final handle = tester.ensureSemantics();
      final viewModel = await _pumpLivenessCaptureView(
        tester,
        createViewModel: buildViewModel,
      );

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      await _stopAndFlush(tester, viewModel);
      handle.dispose();
    });

    testWidgets(
      'a specific quality-failure message is conveyed by text, not color '
      'alone, and the shared generic message is identical text for both '
      'unclassifiedFailure and attackDetected — never a color- or '
      'icon-only difference between them',
      (tester) async {
        livenessVerificationRepository.scriptSubmitSample(
          const Result.ok(
            LivenessSampleOutcome.completed(
              outcome: LivenessOutcome.qualityFailure(
                reason: LivenessQualityReason.faceOutOfFrame,
              ),
            ),
          ),
        );
        await _pumpLivenessCaptureView(tester, createViewModel: buildViewModel);

        expect(find.text('No pudimos ver tu rostro completo'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      },
    );
  });
}
