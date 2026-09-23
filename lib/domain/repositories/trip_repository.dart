import 'package:meta/meta.dart';

import '../../core/result.dart';
import '../entities/trip.dart';

/// The read-only trip source for Mis viajes (012-mis-viajes,
/// contracts/trip-port.md). The airline pushes itineraries, matched on the
/// enrolled document; the app never creates or edits a trip.
abstract class TripRepository {
  /// Reads the passenger's domestic trips: the next one, and up to 90 days
  /// of history. A failed read leaves [lastKnown] unchanged.
  @useResult
  Future<Result<TripsSnapshot>> getTrips();

  /// The last good snapshot in this app session, held in memory only. It is
  /// never written to the device (FR-013, CONFLICT-005).
  TripsSnapshot? get lastKnown;
}
