import '../../domain/entities/verification_result.dart';
import '../models/backend/backend_enums.dart';
import '../models/backend/resultado_verificacion_dto.dart';

/// `ResultadoVerificacionDto` → [VerificationResult], by the row order of
/// 015 contracts/outcome-mapping.md, where the first match wins:
///
/// 1. `REQUIERE_REVISION_MANUAL` → [NeedsReview]. The state beats the
///    counter.
/// 2. `EXITOSO` → [Verified].
/// 3. `NO_CONCLUYENTE` → [Inconclusive], which consumes nothing.
/// 4. `FALLIDO` with no attempts left → [NeedsReview].
/// 5. to 7. `FALLIDO` → [Failed]. Only `COMPARACION` keeps a reason:
///    `LIVENESS` and a null reason are both generic (FR-006).
///
/// Scores are read here and nowhere else, and they are dropped (FR-007).
VerificationResult verificationResultFromDto(ResultadoVerificacionDto dto) {
  if (dto.estadoPasajero == EstadoPasajeroWire.requiereRevisionManual) {
    return const NeedsReview();
  }
  return switch (dto.resultado) {
    ResultadoIntentoWire.exitoso => Verified(identityId: dto.identidadId),
    ResultadoIntentoWire.noConcluyente => Inconclusive(
      retryAfter: dto.reintentarEnSegundos == null
          ? null
          : Duration(seconds: dto.reintentarEnSegundos!),
    ),
    ResultadoIntentoWire.fallido when dto.intentosRestantes <= 0 =>
      const NeedsReview(),
    ResultadoIntentoWire.fallido => Failed(
      reason: dto.motivoFallo == MotivoFalloWire.comparacion
          ? FailureReason.match
          : FailureReason.generic,
      remaining: dto.intentosRestantes,
    ),
  };
}
