// 007-validando T010: returnToDocumentCapture() (research.md §11).
import 'package:aeropass_app/app/enrollment_session_controller.dart';
import 'package:aeropass_app/core/clock.dart';
import 'package:aeropass_app/domain/entities/enrollment_session.dart';
import 'package:flutter_test/flutter_test.dart';

class _FixedClock implements Clock {
  const _FixedClock();
  @override
  DateTime now() => DateTime.utc(2026, 9, 23);
}

void main() {
  test(
    'returnToDocumentCapture resets the step and clears identityConfirmed',
    () {
      final controller = EnrollmentSessionController(clock: const _FixedClock())
        ..startOrResume()
        ..advanceTo(const EnrollmentStep.selfieCapture())
        ..markIdentityConfirmed();

      controller.returnToDocumentCapture();

      expect(
        controller.current!.stepReached,
        const EnrollmentStep.documentCapture(),
      );
      expect(controller.current!.identityConfirmed, isFalse);
    },
  );

  test('returnToDocumentCapture with no session is a no-op', () {
    final controller = EnrollmentSessionController(clock: const _FixedClock());

    controller.returnToDocumentCapture();

    expect(controller.current, isNull);
  });

  group('011: resumeAfterVerification', () {
    test(
      'with no session, creates one at the selfie with identity confirmed',
      () {
        final controller = EnrollmentSessionController(
          clock: const _FixedClock(),
        );

        controller.resumeAfterVerification();

        expect(
          controller.current!.stepReached,
          const EnrollmentStep.selfieCapture(),
        );
        expect(controller.current!.identityConfirmed, isTrue);
      },
    );

    test('with an existing session, changes nothing', () {
      final controller = EnrollmentSessionController(clock: const _FixedClock())
        ..startOrResume();
      final before = controller.current;

      controller.resumeAfterVerification();

      expect(controller.current, before);
    });
  });
}
