// 014-qr-pase T010/T022/T032: screen 14's ViewModel. A code is shown only
// while the backend says the pass is active, the clock is trusted, the
// validity holds and the device is trusted. Rotation and the stepper follow
// the clock and the backend, never elapsed time or navigation.
import 'package:aeropass_app/app/clock_trust_monitor.dart';
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/pass.dart';
import 'package:aeropass_app/domain/entities/transport_failure.dart';
import 'package:aeropass_app/features/pass/pass_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_analytics_emitter.dart';
import '../fakes/fake_clock.dart';
import '../fakes/fake_pass_display.dart';
import '../fakes/fake_pass_repository.dart';

/// On a rotation boundary: 12:00:00 UTC.
final _now = DateTime.utc(2026, 9, 23, 12);

Pass _pass({
  Checkpoint next = Checkpoint.security,
  Set<Checkpoint> validated = const {},
  Duration validFor = const Duration(hours: 3),
}) => Pass(
  passId: 'pass-1',
  tripId: 'trip-1',
  nextCheckpoint: next,
  validated: validated,
  validUntil: _now.add(validFor),
);

class Harness {
  Harness({DevicePosture posture = const DevicePosture.trusted()})
    : posture = FakeDevicePostureChecker(posture) {
    trust = ClockTrustMonitor(clock: clock, monotonicNow: () => monotonic)
      ..observeServerTime(_now);
  }

  final clock = FakeClock(_now);
  Duration monotonic = Duration.zero;
  late final ClockTrustMonitor trust;
  final passes = FakePassRepository();
  final codes = FakePassCodeSource();
  final display = FakePassDisplayGuard();
  final FakeDevicePostureChecker posture;
  final analytics = FakeAnalyticsEmitter();
  int devExpired = 0;

  /// Real time passes: the wall clock and monotonic time move together.
  void advance(Duration d) {
    clock.advance(d);
    monotonic += d;
  }

  PassViewModel build({
    bool withDevExpire = false,
    Duration tick = const Duration(hours: 1),
  }) => PassViewModel(
    tripId: 'trip-1',
    passRepository: passes,
    codeSource: codes,
    displayGuard: display,
    postureChecker: posture,
    clockTrust: trust,
    analyticsEmitter: analytics,
    clock: clock,
    onDevExpire: withDevExpire ? () => devExpired++ : null,
    tick: tick,
    statusPollInterval: const Duration(hours: 1),
    observeLifecycle: false,
  );

  List<String> eventNames() => analytics.events.map((e) => e.name).toList();

  List<Map<String, Object?>> payloadsOf(String name) => analytics.events
      .where((e) => e.name == name)
      .map((e) => e.payload)
      .toList();
}

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 10));

PassUnavailableReason? reasonOf(PassViewModel vm) => switch (vm.state) {
  PassUnavailable(:final reason) => reason,
  _ => null,
};

String? payloadOf(PassViewModel vm) => switch (vm.state) {
  PassShowing(:final code) => code.payload,
  _ => null,
};

Future<void> tick(PassViewModel vm) async {
  // The ViewModel's tick is private; a resume recomputes the same way, so
  // tests drive rotation through the public status poll and resume paths.
  vm.onAppResumed();
  await settle();
}

void main() {
  group('US1: present, rotate, advance, board', () {
    test(
      'opens by issuing a pass and showing its code, in pass mode',
      () async {
        final h = Harness()..passes.scriptIssues([Result.ok(_pass())]);
        final vm = h.build();
        await settle();

        expect(vm.state, isA<PassShowing>());
        expect(payloadOf(vm), startsWith('TEST.'));
        expect(vm.secondsLeft, 30);
        expect(h.passes.issueCount, 1);
        expect(h.display.on, isTrue);
        expect(h.payloadsOf('pass_displayed'), [
          {'checkpoint': 'security', 'offlineCapable': false},
        ]);
        vm.dispose();
      },
    );

    test('reuses an active pass instead of issuing another', () async {
      final h = Harness()..passes.seedActive(_pass());
      final vm = h.build();
      await settle();

      expect(vm.state, isA<PassShowing>());
      expect(h.passes.issueCount, 0);
      vm.dispose();
    });

    test(
      'the code changes at the window boundary, with pass_rotated',
      () async {
        final h = Harness()..passes.scriptIssues([Result.ok(_pass())]);
        final vm = h.build();
        await settle();
        final first = payloadOf(vm);

        h.advance(const Duration(seconds: 12));
        await tick(vm);
        expect(payloadOf(vm), first, reason: 'same window');
        expect(vm.secondsLeft, 18);

        h.advance(const Duration(seconds: 18));
        await tick(vm);
        expect(payloadOf(vm), isNot(first));
        vm.dispose();
      },
    );

    test(
      'the running tick rotates the code with no passenger action',
      () async {
        final h = Harness()..passes.scriptIssues([Result.ok(_pass())]);
        final vm = h.build(tick: const Duration(milliseconds: 2));
        await settle();
        final first = payloadOf(vm);

        h.advance(const Duration(seconds: 30));
        await settle();

        expect(payloadOf(vm), isNot(first));
        expect(vm.rotations, 1);
        expect(h.payloadsOf('pass_rotated'), [
          {'checkpoint': 'security'},
        ]);
        vm.dispose();
      },
    );

    test('the stepper advances only on the backend status', () async {
      final h = Harness()..passes.scriptIssues([Result.ok(_pass())]);
      final vm = h.build();
      await settle();
      expect((vm.state as PassShowing).pass.validated, isEmpty);

      h.advance(const Duration(minutes: 10));
      await tick(vm);
      expect(
        (vm.state as PassShowing).pass.validated,
        isEmpty,
        reason: 'time alone',
      );

      h.passes.scriptStatuses([
        Result.ok(
          PassState.active(
            _pass(next: Checkpoint.boarding, validated: {Checkpoint.security}),
          ),
        ),
      ]);
      await vm.pollStatus();

      final pass = (vm.state as PassShowing).pass;
      expect(pass.validated, {Checkpoint.security});
      expect(pass.nextCheckpoint, Checkpoint.boarding);
      expect(h.payloadsOf('pass_validated'), [
        {'checkpoint': 'security', 'secondsSinceOpened': 600},
      ]);
      vm.dispose();
    });

    test(
      'boarding hides the code, forgets the pass and leaves pass mode',
      () async {
        final h = Harness()..passes.scriptIssues([Result.ok(_pass())]);
        final vm = h.build();
        await settle();

        h.passes.scriptStatuses([const Result.ok(PassState.boarded())]);
        await vm.pollStatus();

        expect(vm.state, isA<PassBoardedView>());
        expect(h.passes.forgotten, ['pass-1']);
        expect(h.display.on, isFalse);
        expect(h.payloadsOf('pass_validated').last['checkpoint'], 'boarding');

        final statuses = h.passes.statusCount;
        await vm.pollStatus();
        expect(h.passes.statusCount, statuses, reason: 'polling stops');
        vm.dispose();
      },
    );

    test(
      'pass mode is on only while a code is shown, and off on dispose',
      () async {
        final h = Harness()..passes.scriptIssues([Result.ok(_pass())]);
        final vm = h.build();
        expect(h.display.on, isFalse, reason: 'not while loading');
        await settle();
        expect(h.display.on, isTrue);

        vm.dispose();
        expect(h.display.on, isFalse);
      },
    );

    test(
      'a pause leaves pass mode; a resume recomputes and re-enters',
      () async {
        final h = Harness()..passes.scriptIssues([Result.ok(_pass())]);
        final vm = h.build();
        await settle();
        final before = payloadOf(vm);

        vm.onAppPaused();
        await settle();
        expect(h.display.on, isFalse);

        h.advance(const Duration(minutes: 3));
        vm.onAppResumed();
        await settle();

        expect(h.display.on, isTrue);
        expect(
          payloadOf(vm),
          isNot(before),
          reason: 'never the pre-pause code',
        );
        vm.dispose();
      },
    );
  });

  group('US2: honest offline and clock states (phase A)', () {
    test(
      'offline without a pass: no code, and connectivity is named',
      () async {
        final h = Harness()
          ..passes.scriptIssues([
            Result.error(TransportFailure.connectivity(StateError('offline'))),
          ]);
        final vm = h.build();
        await settle();

        expect(reasonOf(vm), PassUnavailableReason.offlineWithoutPass);
        expect(h.display.on, isFalse);
        vm.dispose();
      },
    );

    test('a code that cannot be fetched offline is not shown', () async {
      final h = Harness()..passes.scriptIssues([Result.ok(_pass())]);
      final vm = h.build();
      await settle();

      h.codes.failing = true;
      h.advance(const Duration(seconds: 30));
      await tick(vm);

      expect(payloadOf(vm), isNull);
      expect(reasonOf(vm), isNotNull);
      vm.dispose();
    });

    test('a clock more than 30 s off shows no code', () async {
      final h = Harness()..passes.scriptIssues([Result.ok(_pass())]);
      h.trust.observeServerTime(_now.add(const Duration(seconds: 31)));
      final vm = h.build();
      await settle();

      expect(reasonOf(vm), PassUnavailableReason.untrustedClock);
      expect(h.display.on, isFalse);
      vm.dispose();
    });

    test('a wall-clock jump while showing hides the code; a trusted contact '
        'restores it', () async {
      final h = Harness()..passes.scriptIssues([Result.ok(_pass())]);
      final vm = h.build();
      await settle();
      expect(vm.state, isA<PassShowing>());

      h.clock.advance(const Duration(minutes: 2));
      await tick(vm);
      expect(reasonOf(vm), PassUnavailableReason.untrustedClock);

      h.trust.observeServerTime(h.clock.now());
      h.passes.scriptStatuses([Result.ok(PassState.active(_pass()))]);
      await vm.retry();
      expect(vm.state, isA<PassShowing>());
      vm.dispose();
    });

    test(
      'past its validity, even offline, the pass is expired and forgotten',
      () async {
        final h = Harness()
          ..passes.scriptIssues([
            Result.ok(_pass(validFor: const Duration(minutes: 1))),
          ]);
        final vm = h.build();
        await settle();

        h.advance(const Duration(minutes: 1));
        await tick(vm);

        expect(reasonOf(vm), PassUnavailableReason.expired);
        expect(h.passes.forgotten, ['pass-1']);
        vm.dispose();
      },
    );
  });

  group('US3: expired, revoked, changed, reissue, posture', () {
    for (final (state, reason) in [
      (const PassState.expired(), PassUnavailableReason.expired),
      (const PassState.revoked(), PassUnavailableReason.revoked),
      (
        const PassState.flightChanged(cancelled: true),
        PassUnavailableReason.flightCancelled,
      ),
      (
        const PassState.flightChanged(cancelled: false),
        PassUnavailableReason.flightChanged,
      ),
    ]) {
      test('${state.runtimeType} shows no code: ${reason.name}', () async {
        final h = Harness()..passes.scriptIssues([Result.ok(_pass())]);
        final vm = h.build();
        await settle();

        h.passes.scriptStatuses([Result.ok(state)]);
        await vm.pollStatus();

        expect(reasonOf(vm), reason);
        expect(payloadOf(vm), isNull);
        expect(h.display.on, isFalse);
        expect(h.payloadsOf('pass_expired').last, {'reason': reason.name});
        vm.dispose();
      });
    }

    test(
      'a failed issuance that is not the connection is issuanceFailed',
      () async {
        final h = Harness()
          ..passes.scriptIssues([Result.error(StateError('500'))]);
        final vm = h.build();
        await settle();
        expect(reasonOf(vm), PassUnavailableReason.issuanceFailed);
        vm.dispose();
      },
    );

    test(
      'requesting a new code forgets the old one and shows the new one',
      () async {
        final h = Harness()
          ..passes.scriptIssues([
            Result.ok(_pass()),
            Result.ok(_pass().copyWith(passId: 'pass-2')),
          ]);
        final vm = h.build();
        await settle();
        h.passes.scriptStatuses([const Result.ok(PassState.expired())]);
        await vm.pollStatus();

        await vm.requestNewPass();

        expect((vm.state as PassShowing).pass.passId, 'pass-2');
        expect(h.passes.forgotten, contains('pass-1'));
        expect(h.payloadsOf('pass_reissue_requested'), [
          {'succeeded': true},
        ]);
        vm.dispose();
      },
    );

    test('a new code that cannot be issued says so, with no code', () async {
      final h = Harness()
        ..passes.scriptIssues([
          Result.ok(_pass()),
          Result.error(StateError('500')),
        ]);
      final vm = h.build();
      await settle();

      await vm.requestNewPass();

      expect(reasonOf(vm), PassUnavailableReason.issuanceFailed);
      expect(h.payloadsOf('pass_reissue_requested'), [
        {'succeeded': false},
      ]);
      vm.dispose();
    });

    test('a compromised device never asks for a pass', () async {
      final h = Harness(posture: const DevicePosture.compromised(['su_binary']))
        ..passes.scriptIssues([Result.ok(_pass())]);
      final vm = h.build();
      await settle();

      expect(reasonOf(vm), PassUnavailableReason.compromisedDevice);
      expect(h.passes.issueCount, 0);
      expect(h.display.on, isFalse);
      vm.dispose();
    });

    test(
      'the dev control expires through the backend, not on the device',
      () async {
        final h = Harness()..passes.scriptIssues([Result.ok(_pass())]);
        final vm = h.build(withDevExpire: true);
        await settle();
        expect(vm.canDevExpire, isTrue);

        h.passes.scriptStatuses([const Result.ok(PassState.expired())]);
        await vm.devExpire();

        expect(h.devExpired, 1);
        expect(reasonOf(vm), PassUnavailableReason.expired);
        vm.dispose();
      },
    );

    test('without the dev hook the control can do nothing', () async {
      final h = Harness()..passes.scriptIssues([Result.ok(_pass())]);
      final vm = h.build();
      await settle();
      expect(vm.canDevExpire, isFalse);
      await vm.devExpire();
      expect(vm.state, isA<PassShowing>());
      vm.dispose();
    });

    test('help is recorded', () async {
      final h = Harness()..passes.scriptIssues([Result.ok(_pass())]);
      final vm = h.build()..onHelpOpened();
      expect(h.eventNames(), contains('pass_help_opened'));
      vm.dispose();
    });
  });
}
