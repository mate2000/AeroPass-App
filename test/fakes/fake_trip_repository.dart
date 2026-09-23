import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/trip.dart';
import 'package:aeropass_app/domain/repositories/trip_repository.dart';

/// Scripted `TripRepository` (012-mis-viajes). Each read takes the next
/// scripted result, then repeats the last one. A successful read updates
/// [lastKnown], as the real implementation does. With nothing scripted,
/// every read fails.
class FakeTripRepository implements TripRepository {
  final List<Result<TripsSnapshot>> _queue = [];
  Result<TripsSnapshot>? _last;
  int callCount = 0;

  @override
  TripsSnapshot? lastKnown;

  void scriptResults(List<Result<TripsSnapshot>> results) {
    _queue
      ..clear()
      ..addAll(results);
  }

  @override
  Future<Result<TripsSnapshot>> getTrips() async {
    callCount++;
    if (_queue.isNotEmpty) _last = _queue.removeAt(0);
    final result =
        _last ??
        Result.error(StateError('FakeTripRepository: nothing scripted'));
    if (result case Ok(:final value)) lastKnown = value;
    return result;
  }
}
