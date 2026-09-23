// 012-mis-viajes T010/T028/T034: Mis viajes' ViewModel — the badge and
// action rules, refresh and staleness, the empty state, and the events
// (contracts/trips-home-ui.md).
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/credential_summary.dart';
import 'package:aeropass_app/domain/entities/pass.dart';
import 'package:aeropass_app/domain/entities/trip.dart';
import 'package:aeropass_app/domain/repositories/credential_summary_repository.dart';
import 'package:aeropass_app/features/trips/trip_time_format.dart';
import 'package:aeropass_app/features/trips/trips_home_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_analytics_emitter.dart';
import '../fakes/fake_clock.dart';
import '../fakes/fake_credential_summary_repository.dart';
import '../fakes/fake_pass_repository.dart';
import '../fakes/fake_trip_repository.dart';

const _bogota = Duration(hours: -5);

/// 2026-09-23 12:00 UTC, 07:00 in Bogotá.
final _now = DateTime.utc(2026, 9, 23, 12);

Trip _trip({
  Duration departsIn = const Duration(hours: 3),
  TripStatus status = TripStatus.onTime,
  bool live = true,
}) => Trip(
  id: 'next',
  origin: const Airport(code: 'BOG', city: 'Bogotá'),
  destination: const Airport(code: 'MDE', city: 'Medellín'),
  flightNumber: 'AV 9201',
  departureUtc: _now.add(departsIn),
  departureOffset: _bogota,
  status: status,
  live: live,
  gate: 'D12',
  seat: '22A',
);

Trip _past(int daysAgo) => Trip(
  id: 'h$daysAgo',
  origin: const Airport(code: 'MDE', city: 'Medellín'),
  destination: const Airport(code: 'CTG', city: 'Cartagena'),
  flightNumber: 'LA 4552',
  departureUtc: _now.subtract(Duration(days: daysAgo)),
  departureOffset: _bogota,
  status: TripStatus.departed,
  live: true,
);

Result<TripsSnapshot> _snapshot({Trip? next, List<Trip> history = const []}) =>
    Result.ok(TripsSnapshot(next: next, history: history, fetchedAt: _now));

Result<CredentialSummary> _summary({
  CredentialDisplayState state = CredentialDisplayState.active,
  bool confirmed = true,
}) => Result.ok(
  CredentialSummary(
    holderName: 'Mateo González Restrepo',
    documentLast4: '4821',
    state: state,
    confirmed: confirmed,
  ),
);

class Harness {
  Harness({
    Result<CredentialSummary>? summary,
    List<Result<TripsSnapshot>>? trips,
  }) {
    summaries.scriptResults([summary ?? _summary()]);
    this.trips.scriptResults(trips ?? [_snapshot(next: _trip())]);
  }

  final clock = FakeClock(_now);
  final summaries = FakeCredentialSummaryRepository();
  final trips = FakeTripRepository();
  final analytics = FakeAnalyticsEmitter();
  final passes = FakePassRepository();

  TripsHomeViewModel build({
    Duration refreshInterval = const Duration(hours: 1),
    Duration actionTick = const Duration(hours: 1),
    Duration deviceOffset = _bogota,
  }) => TripsHomeViewModel(
    summaryRepository: summaries,
    tripRepository: trips,
    analyticsEmitter: analytics,
    clock: clock,
    passRepository: passes,
    refreshInterval: refreshInterval,
    actionTick: actionTick,
    deviceOffset: () => deviceOffset,
    observeLifecycle: false,
  );

  List<String> eventNames() => analytics.events.map((e) => e.name).toList();

  Map<String, Object?> event(String name) =>
      analytics.events.singleWhere((e) => e.name == name).payload;
}

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 10));

TripActionReason? reasonOf(TripsHomeViewModel vm) => switch (vm.action) {
  TripActionUnavailable(:final reason) => reason,
  TripActionStart() || TripActionViewPass() => null,
};

void main() {
  group('US1: the badge, the next trip, and the gated start', () {
    test(
      'a confirmed active credential and a trip 3 h out can start',
      () async {
        final h = Harness();
        final vm = h.build();
        await settle();

        expect(vm.summary!.showsActive, isTrue);
        expect(vm.nextTrip!.flightNumber, 'AV 9201');
        expect(vm.action, isA<TripActionStart>());
        expect(vm.firstName, 'Mateo');
        vm.dispose();
      },
    );

    for (final (name, summary, trip, now, expected) in [
      (
        'not confirmed beats everything',
        _summary(confirmed: false),
        _trip(status: TripStatus.cancelled),
        _now,
        TripActionReason.unconfirmed,
      ),
      (
        'expired (confirmed)',
        _summary(state: CredentialDisplayState.expired),
        _trip(),
        _now,
        TripActionReason.expired,
      ),
      (
        'revoked (confirmed)',
        _summary(state: CredentialDisplayState.revoked),
        _trip(),
        _now,
        TripActionReason.revoked,
      ),
      (
        'suspended beats cancelled',
        _summary(state: CredentialDisplayState.suspended),
        _trip(status: TripStatus.cancelled),
        _now,
        TripActionReason.suspended,
      ),
      (
        'cancelled beats the window',
        _summary(),
        _trip(
          departsIn: const Duration(hours: 30),
          status: TripStatus.cancelled,
        ),
        _now,
        TripActionReason.cancelled,
      ),
      (
        'before the 24 h window',
        _summary(),
        _trip(departsIn: const Duration(hours: 30)),
        _now,
        TripActionReason.notYetOpen,
      ),
    ]) {
      test('action: $name', () async {
        final h = Harness(
          summary: summary,
          trips: [_snapshot(next: trip)],
        );
        h.clock.set(now);
        final vm = h.build();
        await settle();

        expect(reasonOf(vm), expected);
        vm.dispose();
      });
    }

    test('before the window, the action says when it opens', () async {
      final h = Harness(
        trips: [_snapshot(next: _trip(departsIn: const Duration(hours: 30)))],
      );
      final vm = h.build();
      await settle();

      final action = vm.action as TripActionUnavailable;
      expect(action.availableFrom, _now.add(const Duration(hours: 6)));
      vm.dispose();
    });

    test('the window opens exactly 24 h before departure', () async {
      final h = Harness(
        trips: [_snapshot(next: _trip(departsIn: const Duration(hours: 24)))],
      );
      final vm = h.build();
      await settle();
      expect(vm.action, isA<TripActionStart>());

      h.clock.set(_now.subtract(const Duration(seconds: 1)));
      expect(reasonOf(vm), TripActionReason.notYetOpen);
      vm.dispose();
    });

    test('at or after departure the action is not offered', () async {
      final h = Harness();
      final vm = h.build();
      await settle();
      h.clock.advance(const Duration(hours: 3));
      expect(reasonOf(vm), TripActionReason.departed);
      vm.dispose();
    });

    test('a failed first summary read counts as not confirmed', () async {
      final h = Harness(summary: Result.error(StateError('nothing known')));
      final vm = h.build();
      await settle();

      expect(vm.summary, isNull);
      expect(reasonOf(vm), TripActionReason.unconfirmed);
      vm.dispose();
    });

    test('NoCredentialFailure goes to welcome', () async {
      final h = Harness(summary: Result.error(const NoCredentialFailure()));
      final vm = h.build();
      await settle();

      expect(vm.pendingNavigation, TripsHomeTarget.welcome);
      vm.dispose();
    });

    test(
      'startTrip emits trip_started with the completed count and navigates',
      () async {
        final h = Harness(
          trips: [
            _snapshot(next: _trip(), history: [_past(10), _past(30)]),
          ],
        );
        final vm = h.build();
        await settle();

        vm.startTrip();

        expect(vm.pendingNavigation, TripsHomeTarget.startTrip);
        expect(h.event('trip_started'), {'completedTripsLast90Days': 2});
        vm.dispose();
      },
    );

    test('startTrip is ignored when the action is not enabled', () async {
      final h = Harness(summary: _summary(confirmed: false));
      final vm = h.build();
      await settle();

      vm.startTrip();

      expect(vm.pendingNavigation, isNull);
      expect(h.eventNames(), isNot(contains('trip_started')));
      vm.dispose();
    });

    test('the visit events carry only the contract fields', () async {
      final h = Harness();
      final vm = h.build();
      await settle();

      expect(h.event('trips_home_shown'), {
        'hasNextTrip': true,
        'credentialConfirmed': true,
      });
      expect(h.event('trip_displayed'), {
        'status': 'onTime',
        'live': true,
        'withinWindow': true,
      });
      vm.dispose();
    });

    test('the greeting follows the device hour', () async {
      final h = Harness();
      final morning = h.build();
      expect(morning.greeting, Greeting.morning);
      morning.dispose();

      final evening = h.build(deviceOffset: const Duration(hours: 9));
      expect(evening.greeting, Greeting.evening);
      evening.dispose();
    });

    test('the departure is described in the airport clock', () async {
      final h = Harness();
      final vm = h.build(deviceOffset: Duration.zero);
      await settle();

      final departure = vm.nextDeparture!;
      expect(departure.day, TripDay.today);
      expect(departure.local.hour, 10);
      expect(departure.deviceZoneDiffers, isTrue);
      vm.dispose();
    });
  });

  group('US2: current, or visibly not', () {
    test('the screen re-reads on its refresh interval', () async {
      final h = Harness();
      final vm = h.build(refreshInterval: const Duration(milliseconds: 5));
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(h.trips.callCount, greaterThan(2));
      expect(h.summaries.callCount, greaterThan(2));
      vm.dispose();
    });

    test('returning to the foreground re-reads at once', () async {
      final h = Harness();
      final vm = h.build();
      await settle();
      final before = h.trips.callCount;

      vm.onAppResumed();
      await settle();

      expect(h.trips.callCount, before + 1);
      vm.dispose();
    });

    test('a failed refresh keeps the snapshot and marks it stale', () async {
      final h = Harness(
        trips: [
          _snapshot(next: _trip()),
          Result.error(StateError('offline')),
        ],
      );
      final vm = h.build();
      await settle();
      expect(vm.tripsStale, isFalse);

      h.clock.advance(const Duration(minutes: 3));
      await vm.refresh();

      expect(vm.nextTrip?.flightNumber, 'AV 9201');
      expect(vm.tripsStale, isTrue);
      expect(vm.minutesSinceTripsFetched, 3);

      h.trips.scriptResults([_snapshot(next: _trip())]);
      await vm.refresh();
      expect(vm.tripsStale, isFalse);
      vm.dispose();
    });

    test('with no snapshot this session a failed read is "unavailable", and '
        'retry reads again', () async {
      final h = Harness(trips: [Result.error(StateError('offline'))]);
      final vm = h.build();
      await settle();

      expect(vm.tripsUnavailable, isTrue);
      expect(vm.nextTrip, isNull);

      h.trips.scriptResults([_snapshot(next: _trip())]);
      await vm.retryTrips();
      expect(vm.tripsUnavailable, isFalse);
      expect(vm.nextTrip, isNotNull);
      vm.dispose();
    });

    test('the snapshot from earlier in the session is shown at once', () async {
      final h = Harness(trips: [Result.error(StateError('offline'))]);
      h.trips.lastKnown = (_snapshot(next: _trip()) as Ok<TripsSnapshot>).value;
      final vm = h.build();

      expect(vm.nextTrip, isNotNull, reason: 'before any read completes');
      await settle();
      expect(vm.tripsStale, isTrue);
      vm.dispose();
    });

    test('the action tick opens the window on time', () async {
      final h = Harness(
        trips: [_snapshot(next: _trip(departsIn: const Duration(hours: 25)))],
      );
      final vm = h.build(actionTick: const Duration(milliseconds: 5));
      await settle();
      expect(reasonOf(vm), TripActionReason.notYetOpen);

      var notified = false;
      vm.addListener(() => notified = true);
      h.clock.advance(const Duration(hours: 1));
      await settle();

      expect(notified, isTrue);
      expect(vm.action, isA<TripActionStart>());
      vm.dispose();
    });

    test('a credential that becomes unconfirmed disables the action, and a '
        'confirmed read re-enables it', () async {
      final h = Harness();
      final vm = h.build();
      await settle();
      expect(vm.action, isA<TripActionStart>());

      h.summaries.scriptResults([Result.error(StateError('offline'))]);
      await vm.refresh();
      expect(vm.summary?.confirmed, isFalse);
      expect(vm.summary?.showsActive, isFalse);
      expect(reasonOf(vm), TripActionReason.unconfirmed);

      h.summaries.scriptResults([_summary()]);
      await vm.refresh();
      expect(vm.action, isA<TripActionStart>());
      vm.dispose();
    });

    test('dispose stops the refreshes', () async {
      final h = Harness();
      final vm = h.build(refreshInterval: const Duration(milliseconds: 2));
      await settle();
      vm.dispose();
      final calls = h.trips.callCount;
      await settle();
      expect(h.trips.callCount, calls);
    });
  });

  group('US3: no trip, and history', () {
    test('no next trip emits trips_empty_shown once', () async {
      final h = Harness(trips: [_snapshot()]);
      final vm = h.build();
      await settle();
      await vm.refresh();

      expect(vm.nextTrip, isNull);
      expect(
        h.eventNames().where((n) => n == 'trips_empty_shown'),
        hasLength(1),
      );
      expect(h.event('trips_home_shown')['hasNextTrip'], false);
      vm.dispose();
    });

    test('a failed read with no snapshot is not the empty state', () async {
      final h = Harness(trips: [Result.error(StateError('offline'))]);
      final vm = h.build();
      await settle();
      expect(h.eventNames(), isNot(contains('trips_empty_shown')));
      vm.dispose();
    });

    test(
      'onHistoryVisible emits trips_history_viewed once per visit',
      () async {
        final h = Harness(
          trips: [
            _snapshot(next: _trip(), history: [_past(5), _past(9), _past(20)]),
          ],
        );
        final vm = h.build();
        await settle();

        vm
          ..onHistoryVisible()
          ..onHistoryVisible();

        expect(
          h.eventNames().where((n) => n == 'trips_history_viewed'),
          hasLength(1),
        );
        expect(h.event('trips_history_viewed'), {'rowCount': 3});
        vm.dispose();
      },
    );

    test('no history emits nothing', () async {
      final h = Harness();
      final vm = h.build();
      await settle();
      vm.onHistoryVisible();
      expect(h.eventNames(), isNot(contains('trips_history_viewed')));
      vm.dispose();
    });
  });

  // 014-qr-pase T023 (FR-022): a pass already issued is reopened directly.
  group('014: "Ver pase"', () {
    Pass passFor(String tripId) => Pass(
      passId: 'pass-1',
      tripId: tripId,
      nextCheckpoint: Checkpoint.security,
      validUntil: _now.add(const Duration(hours: 3)),
    );

    test(
      'with an active pass the action is "Ver pase", even unconfirmed',
      () async {
        final h = Harness(summary: _summary(confirmed: false));
        h.passes.seedActive(passFor('next'));
        final vm = h.build();
        await settle();

        expect(vm.action, isA<TripActionViewPass>());
        vm.viewPass();
        expect(vm.pendingNavigation, TripsHomeTarget.viewPass);
        vm.dispose();
      },
    );

    test(
      'without a pass the 012 rules apply, and viewPass does nothing',
      () async {
        final h = Harness(summary: _summary(confirmed: false));
        final vm = h.build();
        await settle();

        expect(reasonOf(vm), TripActionReason.unconfirmed);
        vm.viewPass();
        expect(vm.pendingNavigation, isNull);
        vm.dispose();
      },
    );

    test(
      'once the pass is forgotten the card returns to the 012 rules',
      () async {
        final h = Harness();
        h.passes.seedActive(passFor('next'));
        final vm = h.build();
        await settle();
        expect(vm.action, isA<TripActionViewPass>());

        await h.passes.forget('pass-1');
        vm.onReturned();
        expect(vm.action, isA<TripActionStart>());
        vm.dispose();
      },
    );
  });
}
