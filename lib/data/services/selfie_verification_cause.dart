import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../domain/entities/backend_error.dart';
import '../models/backend/resultado_verificacion_dto.dart';
import '../models/backend/backend_enums.dart';

/// Why a selfie verification ended the way it did, in one word for the
/// production logs (the `selfie_verification` event). Each value names one
/// of the causes found in the backend's pipeline (`POST
/// /v1/biometrics/verifications`: image checks, Vercel Blob with a 3 s limit,
/// the biometric provider behind a circuit breaker, Vercel's 30 s limit).
enum SelfieVerificationCause {
  // Before sending.
  emptySelfie,
  tooLarge,
  notJpeg,

  // The backend answered 200.
  approved,
  rejectedLiveness,
  rejectedMatch,

  /// `NO_CONCLUYENTE`: the provider failed or timed out (4 s), the circuit
  /// breaker is open, or the document photo could not be read.
  inconclusive,
  manualReview,

  // The backend answered with an error.
  notRegistered,

  /// 409: the passenger is not `PENDIENTE_VERIFICACION`.
  passengerNotPending,

  /// 503 `ALMACENAMIENTO_NO_DISPONIBLE`: uploading the selfie or reading the
  /// document photo from Vercel Blob failed or took over 3 s.
  blobStorage,
  imageRejectedTooLarge,
  imageRejectedFormat,
  invalidData,
  session,

  /// 504, or 5xx with no `codigo`: Vercel cut the function (30 s).
  backendFunctionTimeout,
  backendError,

  // The request did not complete.
  appSendTimeout,
  appReceiveTimeout,
  connection,
  unreadableResponse,
  other,
}

/// JPEG files start with FF D8 FF, which the backend checks against the
/// declared type (`sniff_content_type`).
bool looksLikeJpeg(Uint8List bytes) =>
    bytes.length >= 3 &&
    bytes[0] == 0xFF &&
    bytes[1] == 0xD8 &&
    bytes[2] == 0xFF;

/// The cause known before sending, or null when the selfie can be sent.
SelfieVerificationCause? causeBeforeSending(
  Uint8List selfie, {
  required int maxBytes,
}) {
  if (selfie.isEmpty) return SelfieVerificationCause.emptySelfie;
  if (selfie.length > maxBytes) return SelfieVerificationCause.tooLarge;
  if (!looksLikeJpeg(selfie)) return SelfieVerificationCause.notJpeg;
  return null;
}

/// The cause for a 200 answer.
SelfieVerificationCause causeForAnswer(ResultadoVerificacionDto dto) {
  if (dto.estadoPasajero == EstadoPasajeroWire.requiereRevisionManual) {
    return SelfieVerificationCause.manualReview;
  }
  return switch (dto.resultado) {
    ResultadoIntentoWire.exitoso => SelfieVerificationCause.approved,
    ResultadoIntentoWire.noConcluyente => SelfieVerificationCause.inconclusive,
    ResultadoIntentoWire.fallido =>
      dto.motivoFallo == MotivoFalloWire.liveness
          ? SelfieVerificationCause.rejectedLiveness
          : SelfieVerificationCause.rejectedMatch,
  };
}

/// The cause for a failed call. [raw] is the exception as thrown, and
/// [mapped] is what `mapBackendError` made of it.
SelfieVerificationCause causeForFailure(Object raw, Object mapped) {
  if (mapped is BackendError) {
    return switch (mapped.code) {
      BackendErrorCode.pasajeroNoRegistrado =>
        SelfieVerificationCause.notRegistered,
      BackendErrorCode.estadoNoPermiteVerificacion =>
        SelfieVerificationCause.passengerNotPending,
      BackendErrorCode.almacenamientoNoDisponible =>
        SelfieVerificationCause.blobStorage,
      BackendErrorCode.imagenDemasiadoGrande =>
        SelfieVerificationCause.imageRejectedTooLarge,
      BackendErrorCode.formatoNoAdmitido =>
        SelfieVerificationCause.imageRejectedFormat,
      BackendErrorCode.datosInvalidos => SelfieVerificationCause.invalidData,
      BackendErrorCode.noAutenticado => SelfieVerificationCause.session,
      _ => _byStatus(raw),
    };
  }
  return _byStatus(raw);
}

SelfieVerificationCause _byStatus(Object raw) {
  if (raw is! DioException) return SelfieVerificationCause.unreadableResponse;
  final status = raw.response?.statusCode;
  if (status == 504) return SelfieVerificationCause.backendFunctionTimeout;
  if (status != null && status >= 500) {
    final data = raw.response?.data;
    final hasCodigo = data is Map && data['codigo'] is String;
    return hasCodigo
        ? SelfieVerificationCause.backendError
        : SelfieVerificationCause.backendFunctionTimeout;
  }
  return switch (raw.type) {
    DioExceptionType.sendTimeout => SelfieVerificationCause.appSendTimeout,
    DioExceptionType.receiveTimeout =>
      SelfieVerificationCause.appReceiveTimeout,
    DioExceptionType.connectionTimeout ||
    DioExceptionType.connectionError => SelfieVerificationCause.connection,
    DioExceptionType.badResponse => SelfieVerificationCause.backendError,
    _ => SelfieVerificationCause.other,
  };
}
