import 'package:freezed_annotation/freezed_annotation.dart';

part 'backend_error.freezed.dart';

/// Every `codigo` the AeroPass backend documents (`domain/errors.py`,
/// 015 contracts/backend-api.md), plus [unknown] for anything else.
///
/// Repositories map these to their own sealed outcomes
/// (contracts/outcome-mapping.md). None of these names may reach a
/// passenger-visible string (FR-007).
enum BackendErrorCode {
  noAutenticado('NO_AUTENTICADO'),
  datosInvalidos('DATOS_INVALIDOS'),
  documentoVencido('DOCUMENTO_VENCIDO'),
  documentoYaRegistrado('DOCUMENTO_YA_REGISTRADO'),
  cuentaYaRegistrada('CUENTA_YA_REGISTRADA'),
  pasajeroNoRegistrado('PASAJERO_NO_REGISTRADO'),
  estadoNoPermiteVerificacion('ESTADO_NO_PERMITE_VERIFICACION'),
  imagenDemasiadoGrande('IMAGEN_DEMASIADO_GRANDE'),
  formatoNoAdmitido('FORMATO_NO_ADMITIDO'),
  almacenamientoNoDisponible('ALMACENAMIENTO_NO_DISPONIBLE'),
  identidadNoActiva('IDENTIDAD_NO_ACTIVA'),
  limiteEmisionExcedido('LIMITE_EMISION_EXCEDIDO'),
  credencialNoEncontrada('CREDENCIAL_NO_ENCONTRADA'),

  /// A code this app does not know, or a body that did not parse. It takes
  /// the generic path and is reported by status only.
  unknown('');

  const BackendErrorCode(this.wire);

  /// The backend's `codigo` string.
  final String wire;

  static BackendErrorCode fromWire(Object? codigo) => values.firstWhere(
    (code) => code != unknown && code.wire == codigo,
    orElse: () => unknown,
  );
}

/// A backend error response, typed at the service boundary (015 research.md
/// §12). The backend's `mensaje` is deliberately absent: it is never parsed,
/// so it cannot be shown or logged (FR-007, FR-017).
@freezed
sealed class BackendError with _$BackendError {
  const factory BackendError({
    required BackendErrorCode code,
    required int status,

    /// From the `Retry-After` header, on 429 and 503.
    Duration? retryAfter,

    /// From `detalles.campos` on a 422: the offending field names.
    @Default(<String>[]) List<String> fields,
  }) = _BackendError;
}
