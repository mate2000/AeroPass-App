// 012-mis-viajes T007: departure-local dates and "Hoy / Mañana" in the
// departure airport's clock (FR-014), and the greeting (research.md §5).
import 'package:aeropass_app/domain/entities/trip.dart';
import 'package:aeropass_app/features/trips/trip_time_format.dart';
import 'package:flutter_test/flutter_test.dart';

const _bogota = Duration(hours: -5);

Trip _trip(DateTime departureUtc) => Trip(
  id: 't',
  origin: const Airport(code: 'BOG', city: 'Bogotá'),
  destination: const Airport(code: 'MDE', city: 'Medellín'),
  flightNumber: 'AV 9201',
  departureUtc: departureUtc,
  departureOffset: _bogota,
  status: TripStatus.onTime,
  live: true,
);

void main() {
  group('describeDeparture', () {
    test('the time is the airport wall time', () {
      // 19:35 UTC is 14:35 in Bogotá.
      final d = describeDeparture(
        _trip(DateTime.utc(2026, 9, 23, 19, 35)),
        nowUtc: DateTime.utc(2026, 9, 23, 13),
        deviceOffset: _bogota,
      );
      expect(d.local.hour, 14);
      expect(d.local.minute, 35);
      expect(d.day, TripDay.today);
      expect(d.deviceZoneDiffers, isFalse);
    });

    test('a 00:30 departure is "Mañana" in Bogotá, even with a device in UTC '
        'where it is already the next day', () {
      // Departure 2026-09-24 00:30 Bogotá = 05:30 UTC.
      // Now 2026-09-24 01:00 UTC = 2026-09-23 20:00 in Bogotá.
      final d = describeDeparture(
        _trip(DateTime.utc(2026, 9, 24, 5, 30)),
        nowUtc: DateTime.utc(2026, 9, 24, 1),
        deviceOffset: Duration.zero,
      );
      expect(d.day, TripDay.tomorrow);
      expect(d.local.hour, 0);
      expect(d.deviceZoneDiffers, isTrue);
    });

    test(
      'at 23:59 the day before in Bogotá, a 00:30 departure is "Mañana"',
      () {
        final d = describeDeparture(
          _trip(DateTime.utc(2026, 9, 24, 5, 30)),
          nowUtc: DateTime.utc(2026, 9, 24, 4, 59),
          deviceOffset: _bogota,
        );
        expect(d.day, TripDay.tomorrow);
      },
    );

    test('after midnight in Bogotá the same departure is "Hoy"', () {
      final d = describeDeparture(
        _trip(DateTime.utc(2026, 9, 24, 5, 30)),
        nowUtc: DateTime.utc(2026, 9, 24, 5, 1),
        deviceOffset: _bogota,
      );
      expect(d.day, TripDay.today);
    });

    test('two days away is a date', () {
      final d = describeDeparture(
        _trip(DateTime.utc(2026, 9, 26, 19, 35)),
        nowUtc: DateTime.utc(2026, 9, 23, 13),
        deviceOffset: _bogota,
      );
      expect(d.day, TripDay.other);
      expect(d.local.day, 26);
    });
  });

  group('greetingFor', () {
    for (final (hour, expected) in [
      (4, Greeting.evening),
      (5, Greeting.morning),
      (11, Greeting.morning),
      (12, Greeting.afternoon),
      (18, Greeting.afternoon),
      (19, Greeting.evening),
      (23, Greeting.evening),
    ]) {
      test('$hour h is ${expected.name}', () {
        expect(greetingFor(hour), expected);
      });
    }
  });
}
