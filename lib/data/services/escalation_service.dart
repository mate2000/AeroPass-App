import 'package:dio/dio.dart';

import '../models/escalation_status_response.dart';

/// Opens and reads the backend escalation case over the pinned `dio` client
/// (010-escalar-agente, contracts/escalation-port.md). The request carries
/// only the anonymous enrollment attempt id. Stateless; transport failures
/// are left to throw and are converted by `EscalationRepositoryImpl`.
class EscalationService {
  EscalationService({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<EscalationStatusResponse> openOrResume({
    required String enrollmentAttemptId,
    required String arrival,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/v1/escalations',
      data: {'enrollmentAttemptId': enrollmentAttemptId, 'arrival': arrival},
    );
    return EscalationStatusResponse.fromJson(response.data!);
  }

  Future<EscalationStatusResponse> fetchCurrent({
    required String enrollmentAttemptId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/v1/escalations/current',
      queryParameters: {'enrollmentAttemptId': enrollmentAttemptId},
    );
    return EscalationStatusResponse.fromJson(response.data!);
  }
}
