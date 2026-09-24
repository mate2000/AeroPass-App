import '../../domain/entities/passenger_record.dart';
import '../models/backend/backend_enums.dart';
import '../models/backend/pasajero_dto.dart';

/// `PasajeroDto` → the domain (015 data-model.md). This is the only place
/// the wire enums meet the domain ones.
PassengerRecord passengerFromDto(PasajeroDto dto) => PassengerRecord(
  passengerId: dto.id,
  documentType: documentTypeFromWire(dto.tipoDocumento),
  holderName: dto.nombreCompleto,
  maskedNumber: dto.numeroDocumentoEnmascarado,
  documentExpiry: dto.fechaVencimiento,
  state: passengerStateFromWire(dto.estado),
  failedAttempts: dto.intentosFallidos,
  identityId: dto.identidadId,
);

DocumentType documentTypeFromWire(TipoDocumentoWire wire) => switch (wire) {
  TipoDocumentoWire.cc => DocumentType.cc,
  TipoDocumentoWire.ce => DocumentType.ce,
  TipoDocumentoWire.pasaporte => DocumentType.pasaporte,
};

/// The `tipo_documento` form value for a domain [DocumentType].
String documentTypeToWire(DocumentType type) => switch (type) {
  DocumentType.cc => 'CC',
  DocumentType.ce => 'CE',
  DocumentType.pasaporte => 'PASAPORTE',
};

PassengerState passengerStateFromWire(EstadoPasajeroWire wire) =>
    switch (wire) {
      EstadoPasajeroWire.pendienteVerificacion =>
        PassengerState.pendingVerification,
      EstadoPasajeroWire.verificado => PassengerState.verified,
      EstadoPasajeroWire.requiereRevisionManual => PassengerState.manualReview,
    };

/// The last four characters of the backend's masked number, for the home
/// strip's "•••• 1234" (012). The mask already hides the rest.
String lastFourOf(String maskedNumber) => maskedNumber.length <= 4
    ? maskedNumber
    : maskedNumber.substring(maskedNumber.length - 4);
