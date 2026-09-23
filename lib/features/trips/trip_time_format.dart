import '../../domain/entities/trip.dart';

/// Which day a departure falls on, in the departure airport's clock
/// (012-mis-viajes FR-014).
enum TripDay { today, tomorrow, other }

/// The home greeting, from the device's current local hour (research.md §5).
enum Greeting { morning, afternoon, evening }

/// A departure described in its airport's own clock.
class DepartureDescription {
  const DepartureDescription({
    required this.day,
    required this.local,
    required this.deviceZoneDiffers,
  });

  final TripDay day;

  /// The departure's wall time at the airport. Its fields read as that local
  /// time; it is UTC-flagged only so no device zone is applied to it.
  final DateTime local;

  /// True when the device is not on the airport's clock, so the time must
  /// name whose clock it is.
  final bool deviceZoneDiffers;
}

/// Describes [trip]'s departure. "Hoy" and "Mañana" compare calendar days
/// at the departure airport, never on the device, so a 00:30 flight reads
/// correctly around midnight wherever the passenger is.
DepartureDescription describeDeparture(
  Trip trip, {
  required DateTime nowUtc,
  required Duration deviceOffset,
}) {
  final local = trip.departureLocal;
  final airportNow = nowUtc.toUtc().add(trip.departureOffset);
  final departureDay = DateTime.utc(local.year, local.month, local.day);
  final today = DateTime.utc(airportNow.year, airportNow.month, airportNow.day);
  final days = departureDay.difference(today).inDays;
  return DepartureDescription(
    day: switch (days) {
      0 => TripDay.today,
      1 => TripDay.tomorrow,
      _ => TripDay.other,
    },
    local: local,
    deviceZoneDiffers: deviceOffset != trip.departureOffset,
  );
}

/// 5–11 morning, 12–18 afternoon, otherwise evening.
Greeting greetingFor(int hour) {
  if (hour >= 5 && hour < 12) return Greeting.morning;
  if (hour >= 12 && hour < 19) return Greeting.afternoon;
  return Greeting.evening;
}
