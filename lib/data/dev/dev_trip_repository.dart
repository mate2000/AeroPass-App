import '../../core/clock.dart';
import '../../core/result.dart';
import '../../domain/entities/trip.dart';
import '../../domain/repositories/trip_repository.dart';

/// Happy-path stand-in for the airline integration (012-mis-viajes,
/// contracts/trip-port.md), behind `USE_FAKE_VERIFICATION_BACKEND`.
///
/// A fixed, synthetic, domestic itinerary, relative to the first read: the
/// next trip departs 3 hours later in Bogotá time, and three past trips sit
/// inside the 90-day window. The gate, seat and time the screen shows come
/// from here, never from the screen.
class DevTripRepository implements TripRepository {
  DevTripRepository({required Clock clock}) : _clock = clock;

  final Clock _clock;
  DateTime? _firstReadAt;
  TripsSnapshot? _lastKnown;

  static const _bogotaOffset = Duration(hours: -5);
  static const _bog = Airport(code: 'BOG', city: 'Bogotá');
  static const _mde = Airport(code: 'MDE', city: 'Medellín');
  static const _ctg = Airport(code: 'CTG', city: 'Cartagena');
  static const _clo = Airport(code: 'CLO', city: 'Cali');

  @override
  TripsSnapshot? get lastKnown => _lastKnown;

  @override
  Future<Result<TripsSnapshot>> getTrips() async {
    final now = _clock.now().toUtc();
    final start = _firstReadAt ??= now;

    Trip past(
      String id,
      Airport from,
      Airport to,
      String flight,
      int daysAgo,
    ) => Trip(
      id: id,
      origin: from,
      destination: to,
      flightNumber: flight,
      departureUtc: start.subtract(Duration(days: daysAgo)),
      departureOffset: _bogotaOffset,
      status: TripStatus.departed,
      live: true,
    );

    final snapshot = TripsSnapshot(
      next: Trip(
        id: 'dev-next',
        origin: _bog,
        destination: _mde,
        flightNumber: 'AV 9201',
        departureUtc: start.add(const Duration(hours: 3)),
        departureOffset: _bogotaOffset,
        status: TripStatus.onTime,
        live: true,
        gate: 'D12',
        seat: '22A',
      ),
      history: [
        past('dev-h1', _bog, _mde, 'AV 9201', 20),
        past('dev-h2', _mde, _ctg, 'LA 4552', 36),
        past('dev-h3', _bog, _clo, 'AV 8811', 49),
      ],
      fetchedAt: now,
    );
    _lastKnown = snapshot;
    return Result.ok(snapshot);
  }
}
