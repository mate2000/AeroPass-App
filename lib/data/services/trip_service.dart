import 'package:dio/dio.dart';

import '../models/trips_response.dart';

/// Reads the passenger's trips over the pinned `dio` client (012-mis-viajes,
/// contracts/trip-port.md). The request carries only the anonymous
/// enrollment attempt id; the backend matches itineraries on the enrolled
/// document. Stateless; transport failures throw and are converted by
/// `TripRepositoryImpl`.
class TripService {
  TripService({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<TripsResponse> fetchTrips({
    required String enrollmentAttemptId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/v1/trips',
      queryParameters: {'enrollmentAttemptId': enrollmentAttemptId},
    );
    return TripsResponse.fromJson(response.data!);
  }
}
