// 012-mis-viajes T039: no Mis viajes event carries a flight number, an
// airport code or a date — travel patterns are personal data (FR-016,
// SC-010, Principle VII).
import 'package:aeropass_app/domain/entities/trip.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_analytics_emitter.dart';

final _flightNumber = RegExp(r'\b[A-Z0-9]{2} ?\d{1,4}\b');
final _iataCode = RegExp(r'^[A-Z]{3}$');
final _date = RegExp(r'\d{4}-\d{2}-\d{2}|\d{1,2} [a-z]{3}');

void main() {
  test(
    'every 012 payload is bool, int or a status name, with no travel data',
    () {
      final analytics = FakeAnalyticsEmitter();
      for (final status in TripStatus.values) {
        analytics.tripDisplayed(
          status: status,
          live: true,
          withinWindow: false,
        );
      }
      analytics
        ..tripsHomeShown(hasNextTrip: true, credentialConfirmed: false)
        ..tripStarted(completedTripsLast90Days: 4)
        ..tripsHistoryViewed(rowCount: 3)
        ..tripsEmptyShown();

      expect(analytics.events.map((e) => e.name).toSet(), {
        'trip_displayed',
        'trips_home_shown',
        'trip_started',
        'trips_history_viewed',
        'trips_empty_shown',
      });

      for (final event in analytics.events) {
        for (final MapEntry(:key, :value) in event.payload.entries) {
          expect(
            value is bool || value is int || value is String,
            isTrue,
            reason: '${event.name}.$key',
          );
          if (value is String) {
            expect(
              TripStatus.values.map((s) => s.name),
              contains(value),
              reason: '${event.name}.$key must be a status name',
            );
            expect(value, isNot(matches(_flightNumber)));
            expect(value, isNot(matches(_iataCode)));
            expect(value, isNot(matches(_date)));
          }
        }
      }
    },
  );
}
