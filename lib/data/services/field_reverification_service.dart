import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../domain/entities/extraction_result.dart';
import '../models/field_reverification_response.dart';

/// Wraps the single external data source
/// `FieldReverificationRepositoryImpl` needs (Constitution Principle VIII):
/// a certificate-pinned `dio` client for the field-reverification call.
///
/// Constructor-injected (Principle IX). Any transport failure is left to
/// throw — mapping that into `Result.error` is
/// `FieldReverificationRepositoryImpl`'s job, at the service boundary.
class FieldReverificationService {
  FieldReverificationService({required Dio dio}) : _dio = dio;

  final Dio _dio;

  /// POSTs the disputed field and the passenger's candidate value alongside
  /// the retained document image. [documentImageBytes] is sent in this
  /// call's request body only — never written anywhere by this service.
  Future<FieldReverificationResponse> reverify({
    required Uint8List documentImageBytes,
    required FieldKey field,
    required String candidateValue,
  }) async {
    final formData = FormData.fromMap({
      'field': _wireKeyFor(field),
      'candidateValue': candidateValue,
      'document': MultipartFile.fromBytes(
        documentImageBytes,
        filename: 'capture.jpg',
      ),
    });
    final response = await _dio.post<Map<String, dynamic>>(
      '/v1/field-reverification',
      data: formData,
    );
    return FieldReverificationResponse.fromJson(response.data!);
  }

  String _wireKeyFor(FieldKey key) => switch (key) {
    FieldKey.fullName => 'full_name',
    FieldKey.documentNumber => 'document_number',
    FieldKey.nationality => 'nationality',
    FieldKey.expiryDate => 'expiry_date',
  };
}
