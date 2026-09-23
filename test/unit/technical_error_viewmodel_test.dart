// 011-error-tecnico: screen 11's ViewModel. Every claim has a source, the
// retry goes where the preserved state resumes, no attempt is consumed, and
// retries are paced (contracts/technical-error-routing.md).
import 'package:aeropass_app/app/enrollment_session_controller.dart';
import 'package:aeropass_app/app/technical_error_controller.dart';
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/service_failure.dart';
import 'package:aeropass_app/domain/entities/service_status.dart';
import 'package:aeropass_app/domain/entities/verification_stage.dart';
import 'package:aeropass_app/features/enrollment/technical_error/technical_error_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_analytics_emitter.dart';
import '../fakes/fake_clock.dart';
import '../fakes/fake_operational_alert_reporter.dart';
import '../fakes/fake_service_status_repository.dart';

Result<ServiceStatus> statusOf({
  StepHealth documentScan = StepHealth.operational,
  StepHealth selfie = StepHealth.operational,
  StepHealth issuance = StepHealth.operational,
  DateTime? retryAfter,
}) => Result.ok(
  ServiceStatus(
    steps: {
      JourneyStep.documentScan: documentScan,
      JourneyStep.selfie: selfie,
      JourneyStep.issuance: issuance,
    },
    retryAfter: retryAfter,
  ),
);

class Harness {
  Harness({bool identityConfirmed = true, bool canClaim = false})
    : alerts = FakeOperationalAlertReporter(canClaimNotification: canClaim) {
    if (identityConfirmed) {
      session
        ..startOrResume()
        ..markIdentityConfirmed();
    }
  }

  final clock = FakeClock();
  late final session = EnrollmentSessionController(clock: clock);
  final controller = TechnicalErrorController();
  final status = FakeServiceStatusRepository();
  final FakeOperationalAlertReporter alerts;
  final analytics = FakeAnalyticsEmitter();

  void recordFailure(
    ServiceFailureClass failureClass, {
    bool terminal = false,
    VerificationStage stage = VerificationStage.faceComparison,
  }) => controller.record(
    ServiceFailure(
      failureClass: failureClass,
      stage: stage,
      jobTerminal: terminal,
      occurredAt: clock.now(),
    ),
  );

  TechnicalErrorViewModel build({
    Duration statusPollInterval = const Duration(hours: 1),
  }) => TechnicalErrorViewModel(
    technicalErrorController: controller,
    enrollmentSessionController: session,
    statusRepository: status,
    alertReporter: alerts,
    analyticsEmitter: analytics,
    clock: clock,
    statusPollInterval: statusPollInterval,
    countdownTick: const Duration(milliseconds: 1),
  );

  List<String> eventNames() => analytics.events.map((e) => e.name).toList();

  Map<String, Object?> event(String name) =>
      analytics.events.singleWhere((e) => e.name == name).payload;
}

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  group('US1: the failure is not theirs, and progress is kept', () {
    test('the class comes from the record', () {
      for (final failureClass in ServiceFailureClass.values) {
        final h = Harness()..recordFailure(failureClass);
        final vm = h.build();
        expect(vm.failureClass, failureClass);
        vm.dispose();
      }
    });

    test('with nothing recorded the wording is undetermined', () {
      final vm = Harness().build();
      expect(vm.failureClass, ServiceFailureClass.undetermined);
      expect(vm.needsNewSelfie, isFalse);
      vm.dispose();
    });

    test('needsNewSelfie follows jobTerminal', () {
      final h = Harness()
        ..recordFailure(ServiceFailureClass.service, terminal: true);
      final vm = h.build();
      expect(vm.needsNewSelfie, isTrue);
      vm.dispose();
    });

    test('preservation is claimed only with a confirmed identity record', () {
      final confirmed = Harness().build();
      final unconfirmed = Harness(identityConfirmed: false).build();
      expect(confirmed.showPreservation, isTrue);
      expect(unconfirmed.showPreservation, isFalse);
      confirmed.dispose();
      unconfirmed.dispose();
    });

    test('retry goes to the selfie when the job can never finish', () {
      final h = Harness()
        ..recordFailure(ServiceFailureClass.service, terminal: true);
      final vm = h.build()..retry();
      expect(vm.pendingNavigation, TechnicalErrorTarget.selfie);
      expect(h.event('technical_error_retry'), {
        'destination': 'selfie',
        'arrival': 1,
      });
      vm.dispose();
    });

    for (final failureClass in ServiceFailureClass.values) {
      test(
        'retry goes back to verification for a non-terminal ${failureClass.name} failure',
        () {
          final h = Harness()..recordFailure(failureClass);
          final vm = h.build()..retry();
          expect(vm.pendingNavigation, TechnicalErrorTarget.verification);
          vm.dispose();
        },
      );
    }

    test('retry with nothing recorded goes back to verification', () {
      final vm = Harness().build()..retry();
      expect(vm.pendingNavigation, TechnicalErrorTarget.verification);
      vm.dispose();
    });

    test('Salir goes to welcome and keeps the session and the record', () {
      final h = Harness()..recordFailure(ServiceFailureClass.service);
      final vm = h.build()..exit();
      expect(vm.pendingNavigation, TechnicalErrorTarget.welcome);
      expect(h.session.current?.identityConfirmed, isTrue);
      expect(h.controller.current, isNotNull);
      expect(h.eventNames(), contains('technical_error_exit'));
      vm.dispose();
    });

    test('consumeNavigation clears the target', () {
      final vm = Harness().build()..exit();
      vm.consumeNavigation();
      expect(vm.pendingNavigation, isNull);
      vm.dispose();
    });

    test('the entry event carries the class, stage and jobTerminal', () {
      final h = Harness()
        ..recordFailure(
          ServiceFailureClass.service,
          terminal: true,
          stage: VerificationStage.documentCheck,
        );
      final vm = h.build();
      expect(h.event('technical_error_shown'), {
        'failureClass': 'service',
        'stage': 'documentCheck',
        'jobTerminal': true,
      });
      vm.dispose();
    });
  });

  group('US2: the status card has a live source', () {
    test(
      'a successful read sets the status, and the event fires once',
      () async {
        final h = Harness()
          ..status.scriptResults([statusOf(selfie: StepHealth.degraded)]);
        final vm = h.build(statusPollInterval: const Duration(milliseconds: 5));
        await settle();

        expect(vm.status?.steps[JourneyStep.selfie], StepHealth.degraded);
        expect(h.status.callCount, greaterThan(1));
        expect(
          h.analytics.events.where(
            (e) => e.name == 'technical_error_status_shown',
          ),
          hasLength(1),
        );
        expect(h.event('technical_error_status_shown'), {
          'documentScan': 'operational',
          'selfie': 'degraded',
          'issuance': 'operational',
        });
        vm.dispose();
      },
    );

    test('everything operational still gives a status to show', () async {
      final h = Harness()..status.scriptResults([statusOf()]);
      final vm = h.build();
      await settle();
      expect(vm.status, isNotNull);
      vm.dispose();
    });

    test('a failed read gives no status', () async {
      final vm = Harness().build();
      await settle();
      expect(vm.status, isNull);
      vm.dispose();
    });

    test(
      'a later failed read clears the status, and a change replaces it',
      () async {
        final h = Harness()
          ..status.scriptResults([
            statusOf(selfie: StepHealth.degraded),
            Result.error(StateError('down')),
            statusOf(),
          ]);
        final vm = h.build(statusPollInterval: const Duration(milliseconds: 5));
        await Future<void>.delayed(Duration.zero);
        expect(vm.status?.worst, StepHealth.degraded);

        await Future<void>.delayed(const Duration(milliseconds: 8));
        expect(vm.status, isNull);

        await Future<void>.delayed(const Duration(milliseconds: 8));
        expect(vm.status?.worst, StepHealth.operational);
        vm.dispose();
      },
    );

    test('dispose stops polling', () async {
      final h = Harness()..status.scriptResults([statusOf()]);
      final vm = h.build(statusPollInterval: const Duration(milliseconds: 2));
      await settle();
      vm.dispose();
      final calls = h.status.callCount;
      await settle();
      expect(h.status.callCount, calls);
    });
  });

  group('US2: the notification claim has an alert behind it', () {
    test('a service failure is reported exactly once', () async {
      final h = Harness()
        ..recordFailure(
          ServiceFailureClass.service,
          stage: VerificationStage.issuance,
        );
      final first = h.build();
      await settle();
      first.dispose();
      final second = h.build();
      second.dispose();

      expect(h.alerts.reported, [VerificationStage.issuance]);
    });

    for (final failureClass in [
      ServiceFailureClass.connectivity,
      ServiceFailureClass.undetermined,
    ]) {
      test('a ${failureClass.name} failure is never reported', () {
        final h = Harness()..recordFailure(failureClass);
        h.build().dispose();
        expect(h.alerts.reported, isEmpty);
      });
    }

    test('nothing recorded is never reported', () {
      final h = Harness();
      h.build().dispose();
      expect(h.alerts.reported, isEmpty);
    });

    for (final (failureClass, canClaim, shown) in [
      (ServiceFailureClass.service, true, true),
      (ServiceFailureClass.service, false, false),
      (ServiceFailureClass.connectivity, true, false),
      (ServiceFailureClass.undetermined, true, false),
    ]) {
      test(
        'claim for ${failureClass.name} with canClaim=$canClaim is shown=$shown',
        () {
          final h = Harness(canClaim: canClaim)..recordFailure(failureClass);
          final vm = h.build();
          expect(vm.showNotificationClaim, shown);
          vm.dispose();
        },
      );
    }
  });

  group('US2: retries are paced', () {
    test('the first arrival is not held', () {
      final vm = Harness().build();
      expect(vm.retryHeld, isFalse);
      vm.dispose();
    });

    test('arrivals are held 0, 15, 30, 60 and 60 seconds', () {
      final h = Harness();
      final holds = <int>[];
      for (var i = 0; i < 5; i++) {
        final vm = h.build();
        holds.add(vm.retryRemainingSeconds);
        vm.dispose();
      }
      expect(holds, [0, 15, 30, 60, 60]);
    });

    test('a tap while held does nothing; after the hold it retries', () {
      final h = Harness();
      h.build().dispose();
      final vm = h.build()..retry();
      expect(vm.pendingNavigation, isNull);
      expect(h.eventNames(), isNot(contains('technical_error_retry')));

      h.clock.advance(const Duration(seconds: 15));
      vm.retry();
      expect(vm.pendingNavigation, TechnicalErrorTarget.verification);
      expect(h.event('technical_error_retry')['arrival'], 2);
      vm.dispose();
    });

    test('resolve starts the pacing over', () {
      final h = Harness();
      h.build().dispose();
      h.controller.resolve(h.clock.now());
      final vm = h.build();
      expect(vm.retryHeld, isFalse);
      vm.dispose();
    });

    test('a later retryAfter from the source replaces the schedule', () async {
      final h = Harness();
      h.status.scriptResults([
        statusOf(
          selfie: StepHealth.degraded,
          retryAfter: h.clock.now().add(const Duration(minutes: 2)),
        ),
      ]);
      final vm = h.build();
      await settle();
      expect(vm.retryRemainingSeconds, 120);
      expect(vm.retryAfter, isNotNull);
      vm.dispose();
    });

    test(
      'an earlier or past retryAfter does not shorten the schedule',
      () async {
        final h = Harness();
        h.build().dispose();
        h.status.scriptResults([
          statusOf(retryAfter: h.clock.now().add(const Duration(seconds: 5))),
        ]);
        final vm = h.build();
        await settle();
        expect(vm.retryRemainingSeconds, 15);
        vm.dispose();

        h.status.scriptResults([
          statusOf(
            retryAfter: h.clock.now().subtract(const Duration(minutes: 1)),
          ),
        ]);
        final later = h.build();
        await settle();
        expect(later.retryAfter, isNull);
        later.dispose();
      },
    );

    test('the countdown notifies until the hold ends, then stops', () async {
      final h = Harness();
      h.build().dispose();
      final vm = h.build();
      var notifications = 0;
      vm.addListener(() => notifications++);
      await settle();
      expect(notifications, greaterThan(0));

      h.clock.advance(const Duration(seconds: 15));
      await settle();
      final afterHold = notifications;
      await settle();
      expect(notifications, afterHold);
      expect(vm.retryHeld, isFalse);
      vm.dispose();
    });
  });
}
