import 'package:dio/dio.dart';

import '../models/credential_issuance_response.dart';

/// Wraps the backend's credential-issuance endpoint over the pinned `dio`
/// client (contracts/credential-issuance-port.md, 008-identidad-activa).
/// Stateless; transport failures are left to throw and are converted to
/// `Result.error` by `CredentialIssuanceRepositoryImpl` (Principle IX).
class CredentialIssuanceService {
  CredentialIssuanceService({required Dio dio}) : _dio = dio;

  final Dio _dio;

  /// The request carries only the anonymous enrollment attempt id, never
  /// personal data.
  Future<CredentialIssuanceResponse> requestIssuance({
    required String enrollmentAttemptId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/v1/credential/issuance',
      data: {'enrollmentAttemptId': enrollmentAttemptId},
    );
    return CredentialIssuanceResponse.fromJson(response.data!);
  }
}
