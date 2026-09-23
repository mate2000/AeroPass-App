import 'package:dio/dio.dart';

import '../models/service_status_response.dart';

/// Reads the live service status over the pinned `dio` client
/// (011-error-tecnico, contracts/service-status-port.md). The request carries
/// only the anonymous enrollment attempt id, so the backend can scope the
/// status to the passenger's airport. Stateless; transport failures throw and
/// are converted by `ServiceStatusRepositoryImpl`.
class ServiceStatusService {
  ServiceStatusService({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<ServiceStatusResponse> fetchStatus({
    required String enrollmentAttemptId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/v1/service-status',
      queryParameters: {'enrollmentAttemptId': enrollmentAttemptId},
    );
    return ServiceStatusResponse.fromJson(response.data!);
  }
}
