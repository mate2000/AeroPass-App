import 'package:aeropass_app/app/enrollment_session_controller.dart';
import 'package:aeropass_app/core/clock.dart';
import 'package:aeropass_app/domain/entities/enrollment_session.dart';
import 'package:aeropass_app/features/enrollment/selfie/selfie_instructions_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_analytics_emitter.dart';

class _FixedClock implements Clock {
  _FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

void main() {
  late EnrollmentSessionController sessionController;
  late FakeAnalyticsEmitter analyticsEmitter;

  setUp(() {
    sessionController = EnrollmentSessionController(
      clock: _FixedClock(DateTime.utc(2026, 1, 1)),
    );
    sessionController.startOrResume();
    analyticsEmitter = FakeAnalyticsEmitter();
  });

  SelfieInstructionsViewModel buildViewModel() => SelfieInstructionsViewModel(
    enrollmentSessionController: sessionController,
    analyticsEmitter: analyticsEmitter,
  );

  group('T012 [US1]: entry', () {
    test(
      'construction advances the enrollment session to selfieCapture and emits entry analytics',
      () {
        buildViewModel();

        expect(
          sessionController.current!.stepReached,
          const EnrollmentStep.selfieCapture(),
        );
        expect(
          analyticsEmitter.events.map((e) => e.name),
          contains('selfie_instructions_step_entered'),
        );
      },
    );
  });

  group('T012 [US1]: advance', () {
    test('advance completion emits selfie_instructions_advanced', () async {
      final viewModel = buildViewModel();

      await viewModel.advance.run();

      expect(viewModel.advance.completed, isTrue);
      expect(
        analyticsEmitter.events.map((e) => e.name),
        contains('selfie_instructions_advanced'),
      );
    });
  });

  group('T021 [US2]: help and back navigation', () {
    test('onHelpOpened emits selfie_instructions_help_opened', () {
      final viewModel = buildViewModel();

      viewModel.onHelpOpened();

      expect(
        analyticsEmitter.events.map((e) => e.name),
        contains('selfie_instructions_help_opened'),
      );
    });

    test(
      'onBackNavigation emits abandonment when the passenger never advanced',
      () {
        final viewModel = buildViewModel();

        viewModel.onBackNavigation();

        expect(
          analyticsEmitter.events.map((e) => e.name),
          contains('selfie_instructions_step_abandoned'),
        );
      },
    );

    test(
      'onBackNavigation does not emit abandonment after the passenger advanced',
      () async {
        final viewModel = buildViewModel();
        await viewModel.advance.run();

        viewModel.onBackNavigation();

        expect(
          analyticsEmitter.events.map((e) => e.name),
          isNot(contains('selfie_instructions_step_abandoned')),
        );
      },
    );

    test('dispose() disposes the advance command without throwing', () {
      final viewModel = buildViewModel();

      expect(viewModel.dispose, returnsNormally);
    });
  });
}
