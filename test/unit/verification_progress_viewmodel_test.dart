// 007-validando: VerificationProgressViewModel — observes the backend job,
// advances stages only when reported, completes issuance only on a confirmed
// credential, and routes every outcome by contracts/outcome-routing.md.
// Replaces 008's placeholder view-model tests; 008's hand-off cases (R1–R4)
// are kept, reached through a matched job.
import 'dart:io';
import 'dart:typed_data';

import 'package:aeropass_app/app/activated_credential_handoff.dart';
import 'package:aeropass_app/app/enrollment_session_controller.dart';
import 'package:aeropass_app/app/pending_document_controller.dart';
import 'package:aeropass_app/app/technical_error_controller.dart';
import 'package:aeropass_app/core/clock.dart';
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/activated_credential.dart';
import 'package:aeropass_app/domain/entities/capture_attempt_counter.dart';
import 'package:aeropass_app/domain/entities/credential_lifecycle_status.dart';
import 'package:aeropass_app/domain/entities/enrollment_session.dart';
import 'package:aeropass_app/domain/entities/extraction_result.dart';
import 'package:aeropass_app/domain/entities/issuance_outcome.dart';
import 'package:aeropass_app/domain/entities/service_failure.dart';
import 'package:aeropass_app/domain/entities/transport_failure.dart';
import 'package:aeropass_app/domain/entities/verification_job_status.dart';
import 'package:aeropass_app/domain/entities/verification_outcome.dart';
import 'package:aeropass_app/domain/entities/verification_stage.dart';
import 'package:aeropass_app/features/enrollment/verification/verification_progress_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_analytics_emitter.dart';
import '../fakes/fake_capture_attempt_counter_repository.dart';
import '../fakes/fake_credential_issuance_repository.dart';
import '../fakes/fake_verification_job_repository.dart';

class MutableClock implements Clock {
  MutableClock(this.current);
  DateTime current;
  @override
  DateTime now() => current;
}

final _credential = ActivatedCredential(
  holderName: 'Mateo González Restrepo',
  documentLast4: '7890',
  issuingCountry: 'COL',
  issuedAt: DateTime.utc(2026, 9, 23),
  validUntil: DateTime.utc(2031, 9, 23),
);

Result<VerificationJobStatus> inProgress(StageStatus doc, StageStatus face) =>
    Result.ok(
      VerificationJobStatus.inProgress(
        documentCheck: doc,
        faceComparison: face,
      ),
    );

Result<VerificationJobStatus> completed(VerificationOutcome outcome) =>
    Result.ok(
      VerificationJobStatus.completed(
        outcome: outcome,
        documentCheck: outcome is VerificationDocumentRejected
            ? StageStatus.failed
            : StageStatus.passed,
        faceComparison: switch (outcome) {
          VerificationMatched() => StageStatus.passed,
          VerificationDocumentRejected() => StageStatus.pending,
          _ => StageStatus.failed,
        },
      ),
    );

/// Shared fixture for every section of this file.
class Harness {
  Harness() {
    session
      ..startOrResume()
      ..markIdentityConfirmed();
  }

  final job = FakeVerificationJobRepository();
  final issuance = FakeCredentialIssuanceRepository();
  final handoff = ActivatedCredentialHandoff();
  final clock = MutableClock(DateTime.utc(2026, 9, 23, 12));
  late final session = EnrollmentSessionController(clock: clock);
  final pendingDocument = PendingDocumentController();
  final counters = FakeCaptureAttemptCounterRepository();
  final analytics = FakeAnalyticsEmitter();
  final technicalErrors = TechnicalErrorController();

  static const pollInterval = Duration(milliseconds: 1);
  static const failurePause = Duration(milliseconds: 5);

  VerificationProgressViewModel build({
    Duration slowNoticeAfter = const Duration(seconds: 10),
    Duration hardTimeoutAfter = const Duration(seconds: 30),
    Duration poll = pollInterval,
  }) => VerificationProgressViewModel(
    jobRepository: job,
    issuanceRepository: issuance,
    handoff: handoff,
    enrollmentSessionController: session,
    pendingDocumentController: pendingDocument,
    attemptCounterRepository: counters,
    analyticsEmitter: analytics,
    technicalErrorController: technicalErrors,
    clock: clock,
    pollInterval: poll,
    slowNoticeAfter: slowNoticeAfter,
    hardTimeoutAfter: hardTimeoutAfter,
    failureDisplayPause: failurePause,
  );

  int counter(AttemptCounterScope scope) =>
      counters.currentForTesting(scope)?.count ?? 0;

  List<String> eventNames() => analytics.events.map((e) => e.name).toList();

  Map<String, Object?>? outcomeEvent() => analytics.events
      .where((e) => e.name == 'verification_outcome')
      .map((e) => e.payload)
      .singleOrNull;
}

/// Lets the poll loop and any pause run to completion.
Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 40));

Map<VerificationStage, StageStatus> stagesOf(
  VerificationProgressViewModel vm,
) => switch (vm.state) {
  VerificationWaiting(:final stages) => stages,
  VerificationFailed(:final stages) => stages,
};

void main() {
  group('US1: a successful wait', () {
    test(
      'emits verification_step_entered and starts with every stage pending',
      () {
        final h = Harness()
          ..job.scriptResults([
            inProgress(StageStatus.pending, StageStatus.pending),
          ]);

        final vm = h.build();

        expect(h.eventNames().first, 'verification_step_entered');
        expect(stagesOf(vm), {
          VerificationStage.documentCheck: StageStatus.pending,
          VerificationStage.faceComparison: StageStatus.pending,
          VerificationStage.issuance: StageStatus.pending,
        });
        vm.dispose();
      },
    );

    test('maps reported stages and polls repeatedly', () async {
      final h = Harness()
        ..job.scriptResults([
          inProgress(StageStatus.running, StageStatus.pending),
          inProgress(StageStatus.passed, StageStatus.running),
        ]);

      final vm = h.build();
      await settle();

      expect(stagesOf(vm)[VerificationStage.documentCheck], StageStatus.passed);
      expect(
        stagesOf(vm)[VerificationStage.faceComparison],
        StageStatus.running,
      );
      expect(stagesOf(vm)[VerificationStage.issuance], StageStatus.pending);
      expect(h.job.callCount, greaterThan(2));
      vm.dispose();
    });

    test('never moves a stage backwards', () async {
      final h = Harness()
        ..job.scriptResults([
          inProgress(StageStatus.passed, StageStatus.running),
          inProgress(StageStatus.running, StageStatus.pending),
        ]);

      final vm = h.build();
      await settle();

      expect(stagesOf(vm)[VerificationStage.documentCheck], StageStatus.passed);
      expect(
        stagesOf(vm)[VerificationStage.faceComparison],
        StageStatus.running,
      );
      vm.dispose();
    });

    test(
      'a single failed poll changes nothing, and polling continues',
      () async {
        final h = Harness()
          ..job.scriptResults([
            inProgress(StageStatus.running, StageStatus.pending),
            Result.error(const SocketException('blip')),
            inProgress(StageStatus.passed, StageStatus.running),
          ]);

        final vm = h.build();
        await settle();

        expect(vm.pendingNavigation, isNull);
        expect(vm.state, isA<VerificationWaiting>());
        expect(
          stagesOf(vm)[VerificationStage.documentCheck],
          StageStatus.passed,
        );
        vm.dispose();
      },
    );

    test('R1: matched then activated completes issuance, hands off, and '
        'targets screen 08', () async {
      final h = Harness()
        ..job.scriptResults([completed(const VerificationOutcome.matched())])
        ..issuance.scriptResult(
          Result.ok(IssuanceOutcome.activated(credential: _credential)),
        );
      h.counters.seed(
        AttemptCounterScope.selfieLiveness,
        CaptureAttemptCounter(count: 2, lastResetAt: DateTime.utc(2026)),
      );
      h.counters.seed(
        AttemptCounterScope.documentCapture,
        CaptureAttemptCounter(count: 1, lastResetAt: DateTime.utc(2026)),
      );

      final vm = h.build();
      await settle();

      expect(h.counter(AttemptCounterScope.documentCapture), 0);
      expect(h.issuance.callCount, 1);
      expect(stagesOf(vm)[VerificationStage.issuance], StageStatus.passed);
      expect(h.handoff.current, _credential);
      expect(h.session.current, isNull);
      expect(h.counter(AttemptCounterScope.selfieLiveness), 0);
      expect(
        vm.pendingNavigation,
        VerificationNavigationTarget.credentialActivated,
      );
      expect(h.outcomeEvent()?['kind'], 'activated');
      expect(
        h.eventNames(),
        containsAllInOrder([
          'credential_issuance_requested',
          'credential_issuance_outcome',
        ]),
      );
      vm.dispose();
    });

    test(
      'issuance shows running, never passed, while its request is in flight',
      () async {
        final h = Harness()
          ..job.scriptResults([completed(const VerificationOutcome.matched())]);
        final gate = h.issuance.gate();

        final vm = h.build();
        await settle();

        expect(
          stagesOf(vm)[VerificationStage.faceComparison],
          StageStatus.passed,
        );
        expect(stagesOf(vm)[VerificationStage.issuance], StageStatus.running);
        expect(h.handoff.hasCredential, isFalse);

        gate.complete(
          Result.ok(IssuanceOutcome.activated(credential: _credential)),
        );
        await settle();
        expect(stagesOf(vm)[VerificationStage.issuance], StageStatus.passed);
        vm.dispose();
      },
    );

    test('stops polling once the job has completed', () async {
      final h = Harness()
        ..job.scriptResults([completed(const VerificationOutcome.matched())])
        ..issuance.scriptResult(
          Result.ok(IssuanceOutcome.activated(credential: _credential)),
        );

      final vm = h.build();
      await settle();
      final calls = h.job.callCount;
      await settle();

      expect(h.job.callCount, calls);
      vm.dispose();
    });

    test('consumeNavigation clears the one-shot target', () async {
      final h = Harness()
        ..job.scriptResults([completed(const VerificationOutcome.matched())])
        ..issuance.scriptResult(
          Result.ok(IssuanceOutcome.activated(credential: _credential)),
        );
      final vm = h.build();
      await settle();

      vm.consumeNavigation();

      expect(vm.pendingNavigation, isNull);
      vm.dispose();
    });
  });

  // T026: rows R2–R10 of contracts/outcome-routing.md.
  group('US2: every failure is routed and counted correctly', () {
    Future<(Harness, VerificationProgressViewModel)> run({
      required Result<VerificationJobStatus> job,
      Result<IssuanceOutcome>? issuance,
      void Function(Harness h)? arrange,
    }) async {
      final h = Harness()..job.scriptResults([job]);
      if (issuance != null) h.issuance.scriptResult(issuance);
      arrange?.call(h);
      final vm = h.build();
      await settle();
      return (h, vm);
    }

    VerificationStage? failedStageOf(VerificationProgressViewModel vm) =>
        switch (vm.state) {
          VerificationFailed(:final failedStage) => failedStage,
          VerificationWaiting() => null,
        };

    test(
      'the failure is shown before navigating, for the configured pause',
      () async {
        final h = Harness()
          ..job.scriptResults([
            completed(const VerificationOutcome.faceMismatch()),
          ]);
        final vm = h.build();

        await Future<void>.delayed(const Duration(milliseconds: 2));
        expect(vm.state, isA<VerificationFailed>());
        expect(vm.pendingNavigation, isNull);

        await settle();
        expect(
          vm.pendingNavigation,
          VerificationNavigationTarget.retryGuidance,
        );
        vm.dispose();
      },
    );

    for (final (row, outcome) in [
      (
        'R2',
        const IssuanceOutcome.notActive(
          status: CredentialLifecycleStatus.suspended,
        ),
      ),
      ('R3', const IssuanceOutcome.incomplete()),
    ]) {
      test(
        '$row: matched, issuance not usable -> credentialNotActive, nothing counted',
        () async {
          final (h, vm) = await run(
            job: completed(const VerificationOutcome.matched()),
            issuance: Result.ok(outcome),
          );

          expect(failedStageOf(vm), VerificationStage.issuance);
          expect(
            vm.pendingNavigation,
            VerificationNavigationTarget.credentialNotActive,
          );
          expect(h.handoff.hasCredential, isFalse);
          expect(h.counter(AttemptCounterScope.documentCapture), 0);
          expect(h.counter(AttemptCounterScope.selfieLiveness), 0);
          expect(h.outcomeEvent()?['kind'], 'notActive');
          vm.dispose();
        },
      );
    }

    test(
      'R4: matched, issuance error -> technicalError, nothing counted',
      () async {
        final (h, vm) = await run(
          job: completed(const VerificationOutcome.matched()),
          issuance: Result.error(const SocketException('down')),
        );

        expect(failedStageOf(vm), VerificationStage.issuance);
        expect(
          vm.pendingNavigation,
          VerificationNavigationTarget.technicalError,
        );
        expect(h.counter(AttemptCounterScope.selfieLiveness), 0);
        expect(h.outcomeEvent()?['kind'], 'serviceFailure');
        vm.dispose();
      },
    );

    test(
      'R5: document rejected below the limit -> documentCapture, session and '
      'pending document reset, document counter charged',
      () async {
        final (h, vm) = await run(
          job: completed(const VerificationOutcome.documentRejected()),
          arrange: (h) => h.pendingDocument.set(
            Uint8List(1),
            const ExtractionResult(fields: []),
          ),
        );

        expect(failedStageOf(vm), VerificationStage.documentCheck);
        expect(
          vm.pendingNavigation,
          VerificationNavigationTarget.documentCapture,
        );
        expect(h.counter(AttemptCounterScope.documentCapture), 1);
        expect(h.counter(AttemptCounterScope.selfieLiveness), 0);
        expect(h.session.current!.identityConfirmed, isFalse);
        expect(
          h.session.current!.stepReached,
          const EnrollmentStep.documentCapture(),
        );
        expect(h.pendingDocument.hasPendingDocument, isFalse);
        expect(h.outcomeEvent()?['kind'], 'documentRejected');
        vm.dispose();
      },
    );

    test('R6: document rejected at the limit -> retryGuidance, counter left '
        'at the limit (009 FR-017)', () async {
      final (h, vm) = await run(
        job: completed(const VerificationOutcome.documentRejected()),
        arrange: (h) => h.counters.seed(
          AttemptCounterScope.documentCapture,
          CaptureAttemptCounter(
            count: captureAttemptLimit - 1,
            lastResetAt: DateTime.utc(2026),
          ),
        ),
      );

      expect(vm.pendingNavigation, VerificationNavigationTarget.retryGuidance);
      expect(
        h.counter(AttemptCounterScope.documentCapture),
        captureAttemptLimit,
      );
      vm.dispose();
    });

    for (final (row, outcome) in [
      ('R7', const VerificationOutcome.faceMismatch()),
      ('R8', const VerificationOutcome.livenessRejected()),
      ('R9', const VerificationOutcome.attackDetected()),
    ]) {
      test(
        '$row: ${outcome.runtimeType} -> retryGuidance, selfie counter charged',
        () async {
          final (h, vm) = await run(job: completed(outcome));

          expect(failedStageOf(vm), VerificationStage.faceComparison);
          expect(
            vm.pendingNavigation,
            VerificationNavigationTarget.retryGuidance,
          );
          expect(h.counter(AttemptCounterScope.selfieLiveness), 1);
          expect(h.counter(AttemptCounterScope.documentCapture), 0);
          expect(h.outcomeEvent()?['kind'], 'biometricRejected');
          vm.dispose();
        },
      );
    }

    test('R7, R8 and R9 produce identical state and events', () async {
      final results = <String>[];
      for (final outcome in const [
        VerificationOutcome.faceMismatch(),
        VerificationOutcome.livenessRejected(),
        VerificationOutcome.attackDetected(),
      ]) {
        final (h, vm) = await run(job: completed(outcome));
        final events = h.analytics.events
            .where((e) => e.name != 'verification_outcome')
            .map((e) => '${e.name}${e.payload}')
            .join('|');
        results.add(
          '${vm.state}|${vm.pendingNavigation}|$events|${h.outcomeEvent()?['kind']}',
        );
        vm.dispose();
      }

      expect(results.toSet(), hasLength(1));
    });

    test('R10: service failure -> technicalError on the running stage, nothing counted', () async {
      final h = Harness()
        ..job.scriptResults([
          inProgress(StageStatus.passed, StageStatus.running),
          completed(const VerificationOutcome.serviceFailure()),
        ]);
      final vm = h.build();
      await settle();

      expect(failedStageOf(vm), VerificationStage.faceComparison);
      expect(vm.pendingNavigation, VerificationNavigationTarget.technicalError);
      expect(h.counter(AttemptCounterScope.selfieLiveness), 0);
      expect(h.counter(AttemptCounterScope.documentCapture), 0);
      expect(h.outcomeEvent()?['kind'], 'serviceFailure');
      vm.dispose();
    });

    test('verification_outcome fires once, with elapsedSeconds', () async {
      final (h, vm) = await run(
        job: completed(const VerificationOutcome.faceMismatch()),
      );

      final outcomes = h.analytics.events.where(
        (e) => e.name == 'verification_outcome',
      );
      expect(outcomes, hasLength(1));
      expect(outcomes.single.payload['elapsedSeconds'], isA<int>());
      vm.dispose();
    });

    test('issuance is never passed on any failure row', () async {
      for (final job in [
        completed(const VerificationOutcome.documentRejected()),
        completed(const VerificationOutcome.faceMismatch()),
        completed(const VerificationOutcome.serviceFailure()),
      ]) {
        final (_, vm) = await run(job: job);
        expect(
          stagesOf(vm)[VerificationStage.issuance],
          isNot(StageStatus.passed),
        );
        vm.dispose();
      }
    });
  });

  // T032: the notice, the timeout, and resuming.
  group('US3: the wait stalls or is interrupted', () {
    test(
      'the slow notice appears at slowNoticeAfter and polling continues',
      () async {
        final h = Harness()
          ..job.scriptResults([
            inProgress(StageStatus.running, StageStatus.pending),
          ]);
        final vm = h.build(slowNoticeAfter: const Duration(milliseconds: 10));

        await settle();

        expect((vm.state as VerificationWaiting).slowNoticeVisible, isTrue);
        expect(h.eventNames(), contains('verification_slow_notice_shown'));
        final calls = h.job.callCount;
        await settle();
        expect(h.job.callCount, greaterThan(calls));
        vm.dispose();
      },
    );

    test('dismissSlowNotice hides it without stopping the wait', () async {
      final h = Harness()
        ..job.scriptResults([
          inProgress(StageStatus.running, StageStatus.pending),
        ]);
      final vm = h.build(slowNoticeAfter: const Duration(milliseconds: 10));
      await settle();

      vm.dismissSlowNotice();

      expect((vm.state as VerificationWaiting).slowNoticeVisible, isFalse);
      expect(vm.pendingNavigation, isNull);
      vm.dispose();
    });

    test(
      'R11: the hard timeout routes to technicalError with nothing counted',
      () async {
        final h = Harness()
          ..job.scriptResults([
            inProgress(StageStatus.passed, StageStatus.running),
          ]);
        final vm = h.build(hardTimeoutAfter: const Duration(milliseconds: 10));

        await settle();

        expect(
          vm.pendingNavigation,
          VerificationNavigationTarget.technicalError,
        );
        expect(h.eventNames(), contains('verification_timed_out'));
        expect(h.outcomeEvent()?['kind'], 'timedOut');
        expect(h.counter(AttemptCounterScope.selfieLiveness), 0);
        expect(h.counter(AttemptCounterScope.documentCapture), 0);
        vm.dispose();
      },
    );

    test('onAppResumed fires the timeout at once when the clock shows it has passed', () async {
      final h = Harness()
        ..job.scriptResults([
          inProgress(StageStatus.running, StageStatus.pending),
        ]);
      final vm = h.build();
      await settle();

      h.clock.current = h.clock.current.add(const Duration(seconds: 31));
      await vm.onAppResumed();
      await settle();

      expect(vm.pendingNavigation, VerificationNavigationTarget.technicalError);
      vm.dispose();
    });

    test(
      'onAppResumed shows the notice when 10 s have passed but not 30',
      () async {
        final h = Harness()
          ..job.scriptResults([
            inProgress(StageStatus.running, StageStatus.pending),
          ]);
        final vm = h.build();
        await settle();

        h.clock.current = h.clock.current.add(const Duration(seconds: 12));
        await vm.onAppResumed();

        expect((vm.state as VerificationWaiting).slowNoticeVisible, isTrue);
        expect(vm.pendingNavigation, isNull);
        vm.dispose();
      },
    );

    test('onAppResumed polls immediately', () async {
      final h = Harness()
        ..job.scriptResults([
          inProgress(StageStatus.running, StageStatus.pending),
        ]);
      // A slow interval, so no scheduled poll can be in flight when the
      // resume arrives (the ViewModel rightly skips a concurrent poll).
      final vm = h.build(poll: const Duration(hours: 1));
      await settle();
      final calls = h.job.callCount;

      await vm.onAppResumed();

      expect(h.job.callCount, greaterThan(calls));
      vm.dispose();
    });

    test('onHelpOpened emits verification_help_opened', () async {
      final h = Harness()
        ..job.scriptResults([
          inProgress(StageStatus.running, StageStatus.pending),
        ]);
      final vm = h.build();

      vm.onHelpOpened();

      expect(h.eventNames(), contains('verification_help_opened'));
      vm.dispose();
    });
  });

  // 009-reintento addendum cases 7–8.
  group('009: the retry policy at verification', () {
    test(
      'matched resets both counters, even when issuance then fails',
      () async {
        final h = Harness()
          ..job.scriptResults([completed(const VerificationOutcome.matched())])
          ..issuance.scriptResult(Result.error(const SocketException('down')));
        h.counters.seed(
          AttemptCounterScope.documentCapture,
          CaptureAttemptCounter(count: 2, lastResetAt: DateTime.utc(2026)),
        );
        h.counters.seed(
          AttemptCounterScope.selfieLiveness,
          CaptureAttemptCounter(count: 2, lastResetAt: DateTime.utc(2026)),
        );

        final vm = h.build();
        await settle();

        expect(h.counter(AttemptCounterScope.documentCapture), 0);
        expect(h.counter(AttemptCounterScope.selfieLiveness), 0);
        vm.dispose();
      },
    );

    test('a biometric rejection that reaches the limit leaves the selfie '
        'counter at the limit', () async {
      final h = Harness()
        ..job.scriptResults([
          completed(const VerificationOutcome.faceMismatch()),
        ]);
      h.counters.seed(
        AttemptCounterScope.selfieLiveness,
        CaptureAttemptCounter(
          count: captureAttemptLimit - 1,
          lastResetAt: DateTime.utc(2026),
        ),
      );

      final vm = h.build();
      await settle();

      expect(vm.pendingNavigation, VerificationNavigationTarget.retryGuidance);
      expect(
        h.counter(AttemptCounterScope.selfieLiveness),
        captureAttemptLimit,
      );
      vm.dispose();
    });
  });

  group('011: what 007 records before opening screen 11', () {
    Future<(Harness, VerificationProgressViewModel)> run({
      required List<Result<VerificationJobStatus>> job,
      Result<IssuanceOutcome>? issuance,
      Duration hardTimeoutAfter = const Duration(seconds: 30),
    }) async {
      final h = Harness()..job.scriptResults(job);
      if (issuance != null) h.issuance.scriptResult(issuance);
      final vm = h.build(hardTimeoutAfter: hardTimeoutAfter);
      await settle();
      return (h, vm);
    }

    void expectNothingCounted(Harness h) {
      expect(h.counter(AttemptCounterScope.selfieLiveness), 0);
      expect(h.counter(AttemptCounterScope.documentCapture), 0);
    }

    test(
      'row 1: a service failure from the job is a terminal service failure',
      () async {
        final (h, vm) = await run(
          job: [
            inProgress(StageStatus.passed, StageStatus.running),
            completed(const VerificationOutcome.serviceFailure()),
          ],
        );

        final failure = h.technicalErrors.current!;
        expect(failure.failureClass, ServiceFailureClass.service);
        expect(failure.stage, VerificationStage.faceComparison);
        expect(failure.jobTerminal, isTrue);
        expect(failure.occurredAt, h.clock.now());
        expect(
          vm.pendingNavigation,
          VerificationNavigationTarget.technicalError,
        );
        expectNothingCounted(h);
        vm.dispose();
      },
    );

    for (final (row, error, expected) in [
      (
        'row 2',
        TransportFailure.service(StateError('503')),
        ServiceFailureClass.service,
      ),
      (
        'row 3',
        TransportFailure.connectivity(StateError('offline')),
        ServiceFailureClass.connectivity,
      ),
      ('row 4', StateError('unknown'), ServiceFailureClass.undetermined),
    ]) {
      test(
        '$row: issuance ${error.runtimeType} records ${expected.name}, not terminal',
        () async {
          final (h, vm) = await run(
            job: [completed(const VerificationOutcome.matched())],
            issuance: Result.error(error),
          );

          final failure = h.technicalErrors.current!;
          expect(failure.failureClass, expected);
          expect(failure.stage, VerificationStage.issuance);
          expect(failure.jobTerminal, isFalse);
          expect(
            vm.pendingNavigation,
            VerificationNavigationTarget.technicalError,
          );
          vm.dispose();
        },
      );
    }

    test(
      'row 5: a timeout after only connectivity failures records connectivity',
      () async {
        final (h, vm) = await run(
          job: [
            Result.error(TransportFailure.connectivity(StateError('offline'))),
          ],
          hardTimeoutAfter: const Duration(milliseconds: 10),
        );

        final failure = h.technicalErrors.current!;
        expect(failure.failureClass, ServiceFailureClass.connectivity);
        expect(failure.jobTerminal, isFalse);
        expect(
          vm.pendingNavigation,
          VerificationNavigationTarget.technicalError,
        );
        expectNothingCounted(h);
        vm.dispose();
      },
    );

    test(
      'row 6: a timeout after the service kept answering records undetermined',
      () async {
        final (h, vm) = await run(
          job: [inProgress(StageStatus.passed, StageStatus.running)],
          hardTimeoutAfter: const Duration(milliseconds: 10),
        );

        final failure = h.technicalErrors.current!;
        expect(failure.failureClass, ServiceFailureClass.undetermined);
        expect(failure.stage, VerificationStage.faceComparison);
        expect(failure.jobTerminal, isFalse);
        expectNothingCounted(h);
        vm.dispose();
      },
    );

    test(
      'row 6: a timeout after mixed failures records undetermined',
      () async {
        final (h, vm) = await run(
          job: [
            Result.error(TransportFailure.connectivity(StateError('offline'))),
            Result.error(StateError('something else')),
          ],
          hardTimeoutAfter: const Duration(milliseconds: 10),
        );

        expect(
          h.technicalErrors.current!.failureClass,
          ServiceFailureClass.undetermined,
        );
        vm.dispose();
      },
    );

    test('a rejection records nothing', () async {
      final (h, vm) = await run(
        job: [completed(const VerificationOutcome.faceMismatch())],
      );
      expect(h.technicalErrors.current, isNull);
      vm.dispose();
    });

    test('activation after an earlier technical error resolves it and emits the elapsed time', () async {
      final h = Harness()
        ..job.scriptResults([completed(const VerificationOutcome.matched())])
        ..issuance.scriptResult(
          Result.ok(IssuanceOutcome.activated(credential: _credential)),
        );
      h.technicalErrors
        ..record(
          ServiceFailure(
            failureClass: ServiceFailureClass.service,
            stage: VerificationStage.issuance,
            jobTerminal: false,
            occurredAt: h.clock.now().subtract(const Duration(seconds: 75)),
          ),
        )
        ..registerArrival();

      final vm = h.build();
      await settle();

      final resolved = h.analytics.events
          .where((e) => e.name == 'technical_error_resolved')
          .single;
      expect(resolved.payload['elapsedSeconds'], 75);
      expect(h.technicalErrors.current, isNull);
      expect(h.technicalErrors.arrivals, 0);
      vm.dispose();
    });

    test('activation with no earlier technical error emits nothing', () async {
      final (h, vm) = await run(
        job: [completed(const VerificationOutcome.matched())],
        issuance: Result.ok(IssuanceOutcome.activated(credential: _credential)),
      );
      expect(h.eventNames(), isNot(contains('technical_error_resolved')));
      vm.dispose();
    });
  });
}
