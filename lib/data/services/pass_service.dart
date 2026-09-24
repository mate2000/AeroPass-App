import 'package:dio/dio.dart';

import '../models/backend/detalle_pase_dto.dart';
import '../models/backend/pase_dto.dart';

/// `POST /v1/passes` and `GET /v1/passes/{credencial_id}` (015
/// contracts/backend-api.md). Stateless. Failures throw and are mapped by
/// the repository.
class PassService {
  PassService({required Dio dio}) : _dio = dio;

  final Dio _dio;

  static const issuePath = '/v1/passes';

  /// Issues a pass, or renews it: the same call for the same flight revokes
  /// or refreshes the previous credential and returns a new one.
  Future<PaseDto> issue(String codigoVuelo) async {
    final response = await _dio.post<Map<String, dynamic>>(
      issuePath,
      data: {'codigo_vuelo': codigoVuelo},
    );
    return PaseDto.fromJson(response.data!);
  }

  /// The pass's state. There is no token here: the token exists only in the
  /// issuance response.
  Future<DetallePaseDto> detail(String credencialId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$issuePath/${Uri.encodeComponent(credencialId)}',
    );
    return DetallePaseDto.fromJson(response.data!);
  }
}
