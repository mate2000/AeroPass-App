import 'package:freezed_annotation/freezed_annotation.dart';

part 'passenger_record.freezed.dart';

/// The document types the backend accepts (`TipoDocumento`), which closes
/// spec 003's accepted-document question (015 verification record).
enum DocumentType { cc, ce, pasaporte }

/// The backend's passenger state (`EstadoPasajero`). It decides resume
/// (015 FR-023) and the agent path (FR-009).
enum PassengerState { pendingVerification, verified, manualReview }

/// The registered passenger, from `PasajeroResponse` (015 data-model.md).
///
/// [maskedNumber] is the backend's masked string, verbatim: the app never
/// holds or rebuilds the full number (FR-004). Only [holderName] and
/// [maskedNumber] are ever persisted, as the display subset (Principle I).
@freezed
sealed class PassengerRecord with _$PassengerRecord {
  const factory PassengerRecord({
    required String passengerId,
    required DocumentType documentType,
    required String holderName,
    required String maskedNumber,
    required DateTime documentExpiry,
    required PassengerState state,
    required int failedAttempts,
    String? identityId,
  }) = _PassengerRecord;
}
