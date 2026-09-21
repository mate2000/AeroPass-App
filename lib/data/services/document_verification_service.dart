import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../models/document_verification_response.dart';

/// Wraps the single external data source `DocumentVerificationRepositoryImpl`
/// needs (Constitution Principle VIII: "Service — one per external data
/// source, stateless"): a certificate-pinned `dio` client for the
/// document-submission call.
///
/// Constructor-injected (Principle IX). Holds no state itself and exposes
/// only a Future (Principle VIII); any transport failure is left to throw —
/// mapping that into `Result.error` is `DocumentVerificationRepositoryImpl`'s
/// job, at the service boundary (Principle IX).
class DocumentVerificationService {
  DocumentVerificationService({required Dio dio}) : _dio = dio;

  final Dio _dio;

  /// POSTs the captured document image for verification. [documentImageBytes]
  /// is sent in this call's request body only — never written anywhere by
  /// this service, and never retained after this method returns (FR-010).
  ///
  /// Throws on any transport failure (network, timeout, non-2xx, TLS/pinning
  /// failure); a processor-side *rejection* of a readable document is a
  /// normal 2xx response with `outcome: "rejected"`, not a thrown error.
  Future<DocumentVerificationResponse> submit(
    Uint8List documentImageBytes,
  ) async {
    final formData = FormData.fromMap({
      'document': MultipartFile.fromBytes(
        documentImageBytes,
        filename: 'capture.jpg',
      ),
    });
    final response = await _dio.post<Map<String, dynamic>>(
      '/v1/document-verification',
      data: formData,
    );
    return DocumentVerificationResponse.fromJson(response.data!);
  }
}
