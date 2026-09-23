// 010-escalar-agente T008/T022/T026: EscalationViewModel — arrival from the
// counters, open or resume, preselection and honest availability, and every
// outcome. An approval reaches 008 only through the issuance port (FR-011).
import 'dart:io';

import 'package:aeropass_app/app/activated_credential_handoff.dart';
import 'package:aeropass_app/app/enrollment_session_controller.dart';
import 'package:aeropass_app/core/clock.dart';
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/activated_credential.dart';
import 'package:aeropass_app/domain/entities/capture_attempt_counter.dart';
import 'package:aeropass_app/domain/entities/credential_lifecycle_status.dart';
import 'package:aeropass_app/domain/entities/escalation.dart';
import 'package:aeropass_app/domain/entities/issuance_outcome.dart';
import 'package:aeropass_app/features/enrollment/escalation/escalation_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_analytics_emitter.dart';
import '../fakes/fake_capture_attempt_counter_repository.dart';
import '../fakes/fake_credential_issuance_repository.dart';
import '../fakes/fake_escalation_repository.dart';

class _Clock implements Clock {
  DateTime current = DateTime.utc(2026, 9, 23, 12);
  @override
  DateTime now() => current;
}

final _case = EscalationCase(
  openedAt: DateTime.utc(2026, 9, 23, 12),
  arrival: EscalationArrival.byChoice,
);

AgentChannel module({bool available = true}) => AgentChannel(
  kind: AgentChannelKind.module,
  available: available,
  nextOpensAt: available ? null : DateTime.utc(2026, 9, 24, 11),
  hours: 'Lun–Vie 6:00am–10:00pm',
  locationName: 'Aeropuerto de prueba',
  locationDetail: 'Segundo piso',
);

AgentChannel chat({bool available = true}) => AgentChannel(
  kind: AgentChannelKind.chat,
  available: available,
  nextOpensAt: available ? null : DateTime.utc(2026, 9, 24, 8),
  hours: 'Todos los días',
);

Result<EscalationStatus> open(List<AgentChannel> channels) =>
    Result.ok(EscalationStatus.open(escalation: _case, channels: channels));

Result<EscalationStatus> resolved(EscalationOutcome outcome) =>
    Result.ok(EscalationStatus.resolved(outcome: outcome));

final _credential = ActivatedCredential(
  holderName: 'Mateo González Restrepo',
  documentLast4: '7890',
  issuingCountry: 'COL',
  issuedAt: DateTime.utc(2026, 9, 23),
  validUntil: DateTime.utc(2031, 9, 23),
);

class _Harness {
  _Harness() {
    escalations.openResult = Result.ok(_case);
    session.startOrResume();
  }

  final escalations = FakeEscalationRepository();
  final issuance = FakeCredentialIssuanceRepository();
  final handoff = ActivatedCredentialHandoff();
  final clock = _Clock();
  late final session = EnrollmentSessionController(clock: clock);
  final counters = FakeCaptureAttemptCounterRepository();
  final analytics = FakeAnalyticsEmitter();

  void seed(AttemptCounterScope scope, int count) => counters.seed(
    scope,
    CaptureAttemptCounter(count: count, lastResetAt: DateTime.utc(2026)),
  );

  int counter(AttemptCounterScope scope) =>
      counters.currentForTesting(scope)?.count ?? 0;

  EscalationViewModel build() => EscalationViewModel(
    escalationRepository: escalations,
    issuanceRepository: issuance,
    handoff: handoff,
    enrollmentSessionController: session,
    attemptCounterRepository: counters,
    analyticsEmitter: analytics,
    clock: clock,
    pollInterval: const Duration(milliseconds: 1),
  );

  List<String> names() => analytics.events.map((e) => e.name).toList();

  Map<String, Object?>? payloadOf(String name) =>
      analytics.events.where((e) => e.name == name).firstOrNull?.payload;
}

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 30));

void main() {
  group('US1: reaching a person', () {
    test(
      'arrival is byChoice below the limit, and openOrResume gets it once',
      () async {
        final h = _Harness()
          ..escalations.scriptStatuses([
            open([module(), chat()]),
          ]);

        final vm = h.build();
        await settle();

        expect(h.escalations.openCallCount, 1);
        expect(h.escalations.lastArrival, EscalationArrival.byChoice);
        expect(vm.arrival, EscalationArrival.byChoice);
        expect(h.payloadOf('escalation_shown'), {'arrival': 'byChoice'});
        vm.dispose();
      },
    );

    test('arrival is afterLimit when a counter is at the limit', () async {
      final h = _Harness()
        ..escalations.scriptStatuses([
          open([module(), chat()]),
        ]);
      h.seed(AttemptCounterScope.selfieLiveness, captureAttemptLimit);

      final vm = h.build();
      await settle();

      expect(vm.arrival, EscalationArrival.afterLimit);
      expect(h.escalations.lastArrival, EscalationArrival.afterLimit);
      vm.dispose();
    });

    test(
      'the module is preselected when available, and status is polled',
      () async {
        final h = _Harness()
          ..escalations.scriptStatuses([
            open([module(), chat()]),
          ]);

        final vm = h.build();
        await settle();

        expect(vm.state, isA<EscalationViewOpen>());
        expect(vm.selectedChannel, AgentChannelKind.module);
        expect(h.escalations.statusCallCount, greaterThan(2));
        vm.dispose();
      },
    );

    test('credentialIssued goes through issuance: activated sets the hand-off, '
        'clears the session and targets screen 08', () async {
      final h = _Harness()
        ..escalations.scriptStatuses([
          resolved(const EscalationOutcome.credentialIssued()),
        ])
        ..issuance.scriptResult(
          Result.ok(IssuanceOutcome.activated(credential: _credential)),
        );

      final vm = h.build();
      await settle();

      expect(h.issuance.callCount, 1);
      expect(h.handoff.current, _credential);
      expect(h.session.current, isNull);
      expect(
        vm.pendingNavigation,
        EscalationNavigationTarget.credentialActivated,
      );
      expect(h.payloadOf('escalation_outcome')?['kind'], 'credentialIssued');
      vm.dispose();
    });

    for (final (scope, target) in [
      (
        AttemptCounterScope.documentCapture,
        EscalationNavigationTarget.documentCapture,
      ),
      (
        AttemptCounterScope.selfieLiveness,
        EscalationNavigationTarget.livenessCapture,
      ),
    ]) {
      test(
        'attemptsReset(${scope.name}) resets that counter and targets its capture',
        () async {
          final h = _Harness()
            ..escalations.scriptStatuses([
              resolved(EscalationOutcome.attemptsReset(scope: scope)),
            ]);
          h.seed(scope, captureAttemptLimit);

          final vm = h.build();
          await settle();

          expect(h.counter(scope), 0);
          expect(vm.pendingNavigation, target);
          expect(h.payloadOf('escalation_outcome')?['kind'], 'attemptsReset');
          vm.dispose();
        },
      );
    }

    test('escalation_outcome fires once, with elapsedSeconds', () async {
      final h = _Harness()
        ..escalations.scriptStatuses([
          resolved(const EscalationOutcome.declined()),
        ]);

      final vm = h.build();
      await settle();
      await settle();

      final outcomes = h.analytics.events.where(
        (e) => e.name == 'escalation_outcome',
      );
      expect(outcomes, hasLength(1));
      expect(outcomes.single.payload['elapsedSeconds'], isA<int>());
      vm.dispose();
    });

    test('select and the primary action emit their events', () async {
      final h = _Harness()
        ..escalations.scriptStatuses([
          open([module(), chat()]),
        ]);
      final vm = h.build();
      await settle();

      vm.select(AgentChannelKind.chat);
      final started = vm.onPrimaryAction();

      expect(vm.selectedChannel, AgentChannelKind.chat);
      expect(started, AgentChannelKind.chat);
      expect(h.payloadOf('escalation_channel_selected'), {'channel': 'chat'});
      expect(h.payloadOf('escalation_handoff_started'), {'channel': 'chat'});
      vm.dispose();
    });
  });

  group('US2: honest availability', () {
    test('module closed and chat open preselects the chat', () async {
      final h = _Harness()
        ..escalations.scriptStatuses([
          open([module(available: false), chat()]),
        ]);

      final vm = h.build();
      await settle();

      expect(vm.selectedChannel, AgentChannelKind.chat);
      vm.dispose();
    });

    test(
      'with both closed nothing is selected and there is no primary action',
      () async {
        final h = _Harness()
          ..escalations.scriptStatuses([
            open([module(available: false), chat(available: false)]),
          ]);

        final vm = h.build();
        await settle();

        expect(vm.selectedChannel, isNull);
        expect(vm.onPrimaryAction(), isNull);
        vm.dispose();
      },
    );

    test('an unavailable channel cannot be selected', () async {
      final h = _Harness()
        ..escalations.scriptStatuses([
          open([module(), chat(available: false)]),
        ]);
      final vm = h.build();
      await settle();

      vm.select(AgentChannelKind.chat);

      expect(vm.selectedChannel, AgentChannelKind.module);
      vm.dispose();
    });

    test(
      'a selected channel that closes falls back, and the change is reported',
      () async {
        final h = _Harness()
          ..escalations.scriptStatuses([
            open([module(), chat()]),
            open([module(available: false), chat()]),
          ]);

        final vm = h.build();
        await settle();

        expect(vm.selectedChannel, AgentChannelKind.chat);
        final offered = h.analytics.events
            .where((e) => e.name == 'escalation_channels_offered')
            .map((e) => e.payload)
            .toList();
        expect(offered, [
          {'moduleAvailable': true, 'chatAvailable': true},
          {'moduleAvailable': false, 'chatAvailable': true},
        ]);
        vm.dispose();
      },
    );
  });

  group('US3: no false accept, and every other outcome', () {
    for (final (name, result) in [
      (
        'notActive',
        const Result<IssuanceOutcome>.ok(
          IssuanceOutcome.notActive(
            status: CredentialLifecycleStatus.suspended,
          ),
        ),
      ),
      (
        'incomplete',
        const Result<IssuanceOutcome>.ok(IssuanceOutcome.incomplete()),
      ),
      ('error', Result<IssuanceOutcome>.error(const SocketException('down'))),
    ]) {
      test(
        'credentialIssued with issuance $name sets no hand-off, targets nothing, '
        'and keeps checking',
        () async {
          final h = _Harness()
            ..escalations.scriptStatuses([
              resolved(const EscalationOutcome.credentialIssued()),
            ])
            ..issuance.scriptResult(result);

          final vm = h.build();
          await settle();

          expect(h.handoff.hasCredential, isFalse);
          expect(vm.pendingNavigation, isNull);
          expect(h.issuance.callCount, greaterThan(1));
          vm.dispose();
        },
      );
    }

    test('declined shows the declined state and stops checking', () async {
      final h = _Harness()
        ..escalations.scriptStatuses([
          resolved(const EscalationOutcome.declined()),
        ]);

      final vm = h.build();
      await settle();
      final calls = h.escalations.statusCallCount;
      await settle();

      expect(vm.state, const EscalationViewState.declined());
      expect(h.escalations.statusCallCount, calls);
      expect(h.handoff.hasCredential, isFalse);
      vm.dispose();
    });

    test('expired shows the expired state, and reopen() opens again', () async {
      final h = _Harness()
        ..escalations.scriptStatuses([
          const Result.ok(EscalationStatus.expired()),
        ]);

      final vm = h.build();
      await settle();
      expect(vm.state, const EscalationViewState.expired());
      expect(h.payloadOf('escalation_outcome')?['kind'], 'expired');

      h.escalations.scriptStatuses([
        open([module(), chat()]),
      ]);
      await vm.reopen();
      await settle();

      expect(h.escalations.openCallCount, 2);
      expect(vm.state, isA<EscalationViewOpen>());
      vm.dispose();
    });

    test('a failed open shows the unavailable state; a failed read changes nothing', () async {
      final h = _Harness();
      h.escalations.openResult = Result.error(const SocketException('offline'));

      final vm = h.build();
      await settle();
      expect(vm.state, const EscalationViewState.unavailable());

      final h2 = _Harness()
        ..escalations.scriptStatuses([
          open([module(), chat()]),
          Result.error(const SocketException('blip')),
        ]);
      final vm2 = h2.build();
      await settle();
      expect(vm2.state, isA<EscalationViewOpen>());
      expect(vm2.pendingNavigation, isNull);

      vm.dispose();
      vm2.dispose();
    });
  });
}
