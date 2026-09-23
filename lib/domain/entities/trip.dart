import 'package:freezed_annotation/freezed_annotation.dart';

part 'trip.freezed.dart';

/// 012-mis-viajes FR-008: a trip may be started from this long before its
/// scheduled departure.
const tripWindowBeforeDeparture = Duration(hours: 24);

/// 012-mis-viajes FR-012 (Clarifications): how far back history goes.
const tripHistoryRetention = Duration(days: 90);

/// An airport as shown and announced: the code on screen, the city read
/// aloud (FR-015).
@freezed
sealed class Airport with _$Airport {
  const factory Airport({required String code, required String city}) =
      _Airport;
}

/// The airline's status for a segment. Anything unrecognized is [unknown],
/// never on time.
enum TripStatus { onTime, delayed, cancelled, departed, unknown }

/// One domestic flight segment associated with the credential
/// (012-mis-viajes, data-model.md). Owned by the airline integration; the app
/// only reads it.
@freezed
sealed class Trip with _$Trip {
  const Trip._();

  const factory Trip({
    /// Opaque. Never reaches an analytics event.
    required String id,
    required Airport origin,
    required Airport destination,

    /// For example "AV 9201". Display only, never an event.
    required String flightNumber,
    required DateTime departureUtc,

    /// The departure airport's UTC offset on that date (research.md §5).
    required Duration departureOffset,
    required TripStatus status,

    /// False when the airline has no live integration for this flight
    /// (FR-006).
    required bool live,
    String? gate,
    String? seat,

    /// Set when this segment continues on a connection.
    Airport? connectsTo,
  }) = _Trip;

  /// The departure in the departure airport's own clock, as a UTC-flagged
  /// value whose fields read as that local wall time (FR-014).
  DateTime get departureLocal => departureUtc.toUtc().add(departureOffset);

  DateTime get tripWindowOpensAt =>
      departureUtc.subtract(tripWindowBeforeDeparture);
}

/// One successful read of the trip source.
@freezed
sealed class TripsSnapshot with _$TripsSnapshot {
  const factory TripsSnapshot({
    Trip? next,

    /// Newest first, domestic only, at most 90 days old.
    required List<Trip> history,
    required DateTime fetchedAt,
  }) = _TripsSnapshot;
}
