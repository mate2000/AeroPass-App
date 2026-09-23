import 'package:aeropass_app/app/technical_error_controller.dart';
import 'package:aeropass_app/domain/entities/service_failure.dart';
import 'package:aeropass_app/domain/entities/verification_stage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_clock.dart';

void main() {
  late FakeClock clock;
  late TechnicalErrorController controller;

  ServiceFailure failure(
    ServiceFailureClass failureClass, {
    bool terminal = false,
  }) => ServiceFailure(
    failureClass: failureClass,
    stage: VerificationStage.faceComparison,
    jobTerminal: terminal,
    occurredAt: clock.now(),
  );

  setUp(() {
    clock = FakeClock();
    controller = TechnicalErrorController();
  });

  test('starts empty', () {
    expect(controller.current, isNull);
    expect(controller.takeReportable(), isFalse);
  });

  test('record replaces any previous record', () {
    controller.record(failure(ServiceFailureClass.connectivity));
    final second = failure(ServiceFailureClass.service, terminal: true);
    controller.record(second);
    expect(controller.current, second);
  });

  test('takeReportable is true once for a service record', () {
    controller.record(failure(ServiceFailureClass.service));
    expect(controller.takeReportable(), isTrue);
    expect(controller.takeReportable(), isFalse);

    controller.record(failure(ServiceFailureClass.service));
    expect(
      controller.takeReportable(),
      isTrue,
      reason: 'a new record is reportable again',
    );
  });

  test('takeReportable is never true for connectivity or undetermined', () {
    controller.record(failure(ServiceFailureClass.connectivity));
    expect(controller.takeReportable(), isFalse);
    controller.record(failure(ServiceFailureClass.undetermined));
    expect(controller.takeReportable(), isFalse);
  });

  test('registerArrival paces 0, 15, 30, 60, 60 seconds', () {
    final holds = [for (var i = 0; i < 5; i++) controller.registerArrival()];
    expect(holds, const [
      Duration.zero,
      Duration(seconds: 15),
      Duration(seconds: 30),
      Duration(seconds: 60),
      Duration(seconds: 60),
    ]);
    expect(controller.arrivals, 5);
  });

  test('resolve returns the time since the first failure, then resets', () {
    controller.record(failure(ServiceFailureClass.service));
    controller.registerArrival();
    clock.advance(const Duration(seconds: 40));
    controller.record(failure(ServiceFailureClass.connectivity));
    controller.registerArrival();
    clock.advance(const Duration(seconds: 50));

    expect(controller.resolve(clock.now()), const Duration(seconds: 90));
    expect(controller.current, isNull);
    expect(
      controller.registerArrival(),
      Duration.zero,
      reason: 'pacing starts over',
    );
  });

  test('resolve with no failure this run returns null', () {
    expect(controller.resolve(clock.now()), isNull);
  });
}
