import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../models/backend/resultado_verificacion_dto.dart';

/// `POST /v1/biometrics/verifications` (015 contracts/backend-api.md): one
/// selfie in, a verification result out, synchronously.
class BiometricService {
  BiometricService({required Dio dio}) : _dio = dio;

  final Dio _dio;

  static const verifyPath = '/v1/biometrics/verifications';

  /// Slightly longer than the backend's own provider timeout. The backend
  /// answers `NO_CONCLUYENTE` when its breaker opens, so the app waits for
  /// that answer rather than cutting it off (research.md §7).
  static const verifyReceiveTimeout = Duration(seconds: 35);
  static const uploadSendTimeout = Duration(seconds: 30);

  Future<ResultadoVerificacionDto> verify(Uint8List selfieJpeg) async {
    final response = await _dio.post<Map<String, dynamic>>(
      verifyPath,
      data: selfieForm(selfieJpeg),
      options: Options(
        sendTimeout: uploadSendTimeout,
        receiveTimeout: verifyReceiveTimeout,
      ),
    );
    return ResultadoVerificacionDto.fromJson(response.data!);
  }

  /// Public for the contract test.
  static FormData selfieForm(Uint8List selfieJpeg) => FormData.fromMap({
    'selfie': MultipartFile.fromBytes(
      selfieJpeg,
      filename: 'selfie.jpg',
      contentType: DioMediaType('image', 'jpeg'),
    ),
  });
}
