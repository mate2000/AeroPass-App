import 'package:dio/dio.dart';

import '../models/pass_responses.dart';

/// The pass endpoints over the pinned `dio` client (014-qr-pase,
/// contracts/pass-port.md). Requests carry only the anonymous enrollment
/// attempt id and opaque trip and pass ids. Stateless; transport failures
/// throw and are converted by the repository and code source.
class PassService {
  PassService({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<PassIssueResponse> issue({
    required String enrollmentAttemptId,
    required String tripId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/v1/passes',
      data: {'enrollmentAttemptId': enrollmentAttemptId, 'tripId': tripId},
    );
    return PassIssueResponse.fromJson(response.data!);
  }

  Future<PassCodeResponse> currentCode(String passId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/v1/passes/${Uri.encodeComponent(passId)}/code',
    );
    return PassCodeResponse.fromJson(response.data!);
  }

  Future<PassStatusResponse> status(String passId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/v1/passes/${Uri.encodeComponent(passId)}/status',
    );
    return PassStatusResponse.fromJson(response.data!);
  }
}
