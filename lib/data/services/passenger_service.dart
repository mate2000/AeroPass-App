import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../models/backend/pasajero_dto.dart';

/// `POST /v1/identity` and `GET /v1/identity/me` (015
/// contracts/backend-api.md). Transport and backend errors are thrown as
/// `DioException`. The repositories map them with `mapBackendError`.
class PassengerService {
  PassengerService({required Dio dio}) : _dio = dio;

  final Dio _dio;

  static const registerPath = '/v1/identity';
  static const mePath = '/v1/identity/me';

  /// The upload has its own send timeout: a document photo can be a few MB.
  static const uploadSendTimeout = Duration(seconds: 30);

  /// Multipart with all five parts (FR-002). The photo part declares
  /// `image/jpeg`, which must match its bytes (V-02).
  Future<({PasajeroDto pasajero, bool created})> register({
    required String nombreCompleto,
    required String tipoDocumento,
    required String numeroDocumento,
    required String fechaVencimiento,
    required Uint8List fotoDocumento,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      registerPath,
      data: registrationForm(
        nombreCompleto: nombreCompleto,
        tipoDocumento: tipoDocumento,
        numeroDocumento: numeroDocumento,
        fechaVencimiento: fechaVencimiento,
        fotoDocumento: fotoDocumento,
      ),
      options: Options(sendTimeout: uploadSendTimeout),
    );
    return (
      pasajero: PasajeroDto.fromJson(response.data!),
      created: response.statusCode == 201,
    );
  }

  Future<PasajeroDto> me() async {
    final response = await _dio.get<Map<String, dynamic>>(mePath);
    return PasajeroDto.fromJson(response.data!);
  }

  /// The registration body. It is public so the contract test can check the
  /// parts without a network.
  static FormData registrationForm({
    required String nombreCompleto,
    required String tipoDocumento,
    required String numeroDocumento,
    required String fechaVencimiento,
    required Uint8List fotoDocumento,
  }) => FormData.fromMap({
    'nombre_completo': nombreCompleto,
    'tipo_documento': tipoDocumento,
    'numero_documento': numeroDocumento,
    'fecha_vencimiento': fechaVencimiento,
    'foto_documento': MultipartFile.fromBytes(
      fotoDocumento,
      filename: 'documento.jpg',
      contentType: DioMediaType('image', 'jpeg'),
    ),
  });
}
