import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../models/liveness_sample_response.dart';

/// Wraps the single external data source `LivenessVerificationRepositoryImpl`
/// needs (Constitution Principle VIII): a certificate-pinned `dio` client
/// for the liveness-session/sample calls.
///
/// Constructor-injected (Principle IX). Holds no state itself and exposes
/// only Futures (Principle VIII); any transport failure is left to throw —
/// mapping that into `Result.error` is
/// `LivenessVerificationRepositoryImpl`'s job, at the service boundary.
class LivenessVerificationService {
  LivenessVerificationService({required Dio dio}) : _dio = dio;

  final Dio _dio;

  /// Begins one attempt. Throws on any transport failure (network, timeout,
  /// non-2xx, TLS/pinning failure).
  Future<String> startSession() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/v1/liveness-verification/sessions',
    );
    return response.data!['sessionId'] as String;
  }

  /// Submits one sampled frame. [frameBytes] is sent in this call's request
  /// body only — never written anywhere by this service, and never
  /// retained after this method returns (FR-008).
  Future<LivenessSampleResponse> submitSample({
    required String sessionId,
    required Uint8List frameBytes,
  }) async {
    final formData = FormData.fromMap({
      'frame': MultipartFile.fromBytes(frameBytes, filename: 'sample.bin'),
    });
    final response = await _dio.post<Map<String, dynamic>>(
      '/v1/liveness-verification/sessions/$sessionId/samples',
      data: formData,
    );
    return LivenessSampleResponse.fromJson(response.data!);
  }
}
