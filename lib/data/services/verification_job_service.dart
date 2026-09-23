import 'package:dio/dio.dart';

import '../models/verification_job_response.dart';

/// Reads the backend's current verification job over the pinned `dio`
/// client (007-validando, contracts/verification-job-port.md). Read-only:
/// there is deliberately no method here that submits anything (FR-010).
/// Stateless; transport failures are left to throw and are converted to
/// `Result.error` by `VerificationJobRepositoryImpl` (Principle IX).
class VerificationJobService {
  VerificationJobService({required Dio dio}) : _dio = dio;

  final Dio _dio;

  /// [enrollmentAttemptId] is anonymous and carries no personal data.
  Future<VerificationJobResponse> fetchCurrentJob({
    required String enrollmentAttemptId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/v1/verification/jobs/current',
      queryParameters: {'enrollmentAttemptId': enrollmentAttemptId},
    );
    return VerificationJobResponse.fromJson(response.data!);
  }
}
