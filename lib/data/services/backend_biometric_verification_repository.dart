import 'dart:typed_data';

import 'package:dio/dio.dart' show DioException;

import '../../core/diagnostics.dart';
import '../../core/result.dart';
import '../../domain/entities/backend_error.dart';
import '../../domain/entities/session_state.dart';
import '../../domain/entities/verification_result.dart';
import '../../domain/repositories/biometric_verification_repository.dart';
import 'backend_error_mapper.dart';
import 'biometric_service.dart';
import 'selfie_verification_cause.dart';
import 'verification_result_mapper.dart';

/// [BiometricVerificationRepository] over `POST /v1/biometrics/verifications`
/// (015 contracts/backend-api.md). A selfie over the backend's 4 MB limit is
/// refused before sending.
class BackendBiometricVerificationRepository
    implements BiometricVerificationRepository {
  BackendBiometricVerificationRepository(
    this._service, {
    Diagnostics diagnostics = const Diagnostics(),
  }) : _diagnostics = diagnostics;

  final BiometricService _service;
  final Diagnostics _diagnostics;

  /// The backend's `MAX_IMAGE_BYTES` (`domain/images.py`).
  static const maxSelfieBytes = 4 * 1024 * 1024;

  @override
  Future<Result<VerificationResult>> verify(Uint8List selfieJpeg) async {
    final before = causeBeforeSending(selfieJpeg, maxBytes: maxSelfieBytes);
    if (before == SelfieVerificationCause.emptySelfie ||
        before == SelfieVerificationCause.tooLarge) {
      _logCause(before!, selfieJpeg);
      return const Result.ok(RecaptureSelfie());
    }
    if (before == SelfieVerificationCause.notJpeg) {
      // Sent anyway: the backend's answer (415) is the authority. Logged so
      // a camera producing another format is visible.
      _logCause(before!, selfieJpeg, sent: true);
    }
    final watch = Stopwatch()..start();
    try {
      final dto = await _service.verify(selfieJpeg);
      final result = verificationResultFromDto(dto);
      // Never the scores: they are not shown, and not needed to diagnose.
      _diagnostics.info('biometric_verify', {
        'resultado': dto.resultado.name,
        'motivo': dto.motivoFallo?.name,
        'estado': dto.estadoPasajero.name,
        'intentos_restantes': dto.intentosRestantes,
        'reintentar_en': dto.reintentarEnSegundos,
        'mapped': result.runtimeType,
        'bytes': selfieJpeg.length,
        'ms': watch.elapsedMilliseconds,
      });
      _logCause(causeForAnswer(dto), selfieJpeg, ms: watch.elapsedMilliseconds);
      return Result.ok(result);
    } catch (e, st) {
      final mapped = mapBackendError(e);
      _diagnostics.error('biometric_verify_failed', {
        'code': mapped is BackendError ? mapped.code.name : mapped.runtimeType,
        'raw_error': e.runtimeType,
        'bytes': selfieJpeg.length,
        'ms': watch.elapsedMilliseconds,
      });
      _logCause(
        causeForFailure(e, mapped),
        selfieJpeg,
        ms: watch.elapsedMilliseconds,
        status: e is DioException ? e.response?.statusCode : null,
      );
      if (mapped is! BackendError) return Result.error(mapped, st);
      return switch (mapped.code) {
        BackendErrorCode.pasajeroNoRegistrado => const Result.ok(
          NotRegistered(),
        ),
        BackendErrorCode.estadoNoPermiteVerificacion => const Result.ok(
          StateChanged(),
        ),
        BackendErrorCode.imagenDemasiadoGrande ||
        BackendErrorCode.formatoNoAdmitido ||
        BackendErrorCode.datosInvalidos => const Result.ok(RecaptureSelfie()),
        BackendErrorCode.noAutenticado => Result.error(
          const SessionUnavailable(),
          st,
        ),
        // Not documented for this endpoint: the generic path, by code.
        BackendErrorCode.documentoVencido ||
        BackendErrorCode.documentoYaRegistrado ||
        BackendErrorCode.cuentaYaRegistrada ||
        BackendErrorCode.almacenamientoNoDisponible ||
        BackendErrorCode.identidadNoActiva ||
        BackendErrorCode.limiteEmisionExcedido ||
        BackendErrorCode.credencialNoEncontrada ||
        BackendErrorCode.unknown => Result.error(mapped, st),
      };
    }
  }

  /// One `selfie_verification` event per attempt, naming its cause. Every
  /// cause but `approved` is an error, so each one is an issue in Sentry,
  /// grouped by cause.
  void _logCause(
    SelfieVerificationCause cause,
    Uint8List selfie, {
    int? ms,
    int? status,
    bool sent = false,
  }) {
    final attributes = {
      'code': cause.name,
      'bytes': selfie.length,
      'jpeg': looksLikeJpeg(selfie),
      'status': status,
      'ms': ms,
      if (sent) 'sent_anyway': true,
    };
    if (cause == SelfieVerificationCause.approved) {
      _diagnostics.info('selfie_verification', attributes);
    } else {
      _diagnostics.error('selfie_verification', attributes);
    }
  }
}
