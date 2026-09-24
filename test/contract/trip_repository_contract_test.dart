// 012-mis-viajes: the dev trip repository, the offline demo's itinerary.
// 015 T048: the real implementation called `GET /v1/trips`, which the
// backend does not have (DEC-03). It was deleted with its tests, and release
// builds wire no trip source.
import 'package:aeropass_app/core/clock.dart';
import 'package:aeropass_app/data/dev/dev_trip_repository.dart';
import 'package:aeropass_app/domain/entities/trip.dart';
import 'package:flutter_test/flutter_test.dart';

/// 2026-09-23 12:00 UTC (07:00 in Bogotá).
final _now = DateTime.utc(2026, 9, 23, 12);

class _Clock implements Clock {
  @override
  DateTime now() => _now;
}

void main() {
  group('Dev fake', () {
    test(
      'a domestic next trip 3 h out, and three history rows in 90 days',
      () async {
        final repository = DevTripRepository(clock: _Clock());

        final snapshot = (await repository.getTrips()).valueOrNull!;

        expect(snapshot.next!.departureUtc, _now.add(const Duration(hours: 3)));
        expect(snapshot.next!.gate, 'D12');
        expect(snapshot.history, hasLength(3));
        expect(
          snapshot.history.every(
            (t) => _now.difference(t.departureUtc) < tripHistoryRetention,
          ),
          isTrue,
        );
        expect(repository.lastKnown, snapshot);
      },
    );
  });
}
