import '../../core/clock.dart';
import '../../core/result.dart';
import '../../domain/entities/trip.dart';
import '../../domain/repositories/consent_repository.dart';
import '../../domain/repositories/trip_repository.dart';
import '../models/trips_response.dart';
import 'transport_error_mapper.dart';
import 'trip_service.dart';

/// The real `TripRepository` (012-mis-viajes, contracts/trip-port.md).
///
/// The mapping is strict, and the app applies the backend's filters again:
/// only domestic segments (FR-010), only 90 days of history (FR-012), and a
/// segment missing a required field is dropped rather than guessed. An
/// unknown status is `unknown`, never on time. The last good snapshot is
/// kept in memory only (FR-013).
class TripRepositoryImpl implements TripRepository {
  TripRepositoryImpl(
    this._service, {
    required ConsentRepository consentRepository,
    required Clock clock,
  }) : _consentRepository = consentRepository,
       _clock = clock;

  final TripService _service;
  final ConsentRepository _consentRepository;
  final Clock _clock;

  TripsSnapshot? _lastKnown;

  @override
  TripsSnapshot? get lastKnown => _lastKnown;

  /// `...T14:35:00-05:00`, `...+01:00`, or `...Z`.
  static final _offsetPattern = RegExp(r'(Z|([+-])(\d{2}):?(\d{2}))$');
  static final _codePattern = RegExp(r'^[A-Z]{3}$');

  @override
  Future<Result<TripsSnapshot>> getTrips() async {
    final attemptId = (await _consentRepository.getLocalRecord())
        .valueOrNull
        ?.enrollmentAttemptId
        .value;
    if (attemptId == null) {
      return Result.error(
        StateError('no local consent record scopes the trips'),
      );
    }
    try {
      final response = await _service.fetchTrips(
        enrollmentAttemptId: attemptId,
      );
      final snapshot = _map(response);
      _lastKnown = snapshot;
      return Result.ok(snapshot);
    } catch (e, st) {
      return Result.error(mapTransportError(e), st);
    }
  }

  TripsSnapshot _map(TripsResponse response) {
    final now = _clock.now().toUtc();
    final historyFloor = now.subtract(tripHistoryRetention);
    final trips = [
      for (final segment in response.segments ?? const <TripSegmentResponse>[])
        ?_trip(segment),
    ];

    final upcoming =
        trips
            .where(
              (t) =>
                  t.status != TripStatus.departed &&
                  t.departureUtc.isAfter(now),
            )
            .toList()
          ..sort((a, b) => a.departureUtc.compareTo(b.departureUtc));
    final history =
        trips
            .where(
              (t) =>
                  (t.status == TripStatus.departed ||
                      !t.departureUtc.isAfter(now)) &&
                  !t.departureUtc.isBefore(historyFloor),
            )
            .toList()
          ..sort((a, b) => b.departureUtc.compareTo(a.departureUtc));

    return TripsSnapshot(
      next: upcoming.firstOrNull,
      history: history,
      fetchedAt: now,
    );
  }

  Trip? _trip(TripSegmentResponse wire) {
    if (wire.domestic != true) return null;
    final origin = _airport(wire.origin);
    final destination = _airport(wire.destination);
    final flight = wire.flightNumber?.trim() ?? '';
    final departure = _departure(wire.departureLocal);
    if (origin == null ||
        destination == null ||
        flight.isEmpty ||
        departure == null) {
      return null;
    }
    final live = wire.live ?? false;
    return Trip(
      id: wire.id ?? '${origin.code}-${destination.code}-${departure.$1}',
      origin: origin,
      destination: destination,
      flightNumber: flight,
      departureUtc: departure.$1,
      departureOffset: departure.$2,
      status: switch (wire.status) {
        'on_time' => TripStatus.onTime,
        'delayed' => TripStatus.delayed,
        'cancelled' => TripStatus.cancelled,
        'departed' => TripStatus.departed,
        _ => TripStatus.unknown,
      },
      live: live,
      gate: _nonBlank(wire.gate),
      seat: _nonBlank(wire.seat),
      connectsTo: _airport(wire.connectsTo),
    );
  }

  static Airport? _airport(AirportResponse? wire) {
    final code = wire?.code?.trim() ?? '';
    final city = wire?.city?.trim() ?? '';
    if (!_codePattern.hasMatch(code) || city.isEmpty) return null;
    return Airport(code: code, city: city);
  }

  /// The instant and the airport's offset. A time without an offset is
  /// dropped: without it, "Hoy" cannot be computed correctly (FR-014).
  static (DateTime, Duration)? _departure(String? wire) {
    if (wire == null) return null;
    final match = _offsetPattern.firstMatch(wire.trim());
    final instant = DateTime.tryParse(wire.trim());
    if (match == null || instant == null) return null;
    final offset = match.group(1) == 'Z'
        ? Duration.zero
        : Duration(
                hours: int.parse(match.group(3)!),
                minutes: int.parse(match.group(4)!),
              ) *
              (match.group(2) == '-' ? -1 : 1);
    return (instant.toUtc(), offset);
  }

  static String? _nonBlank(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
