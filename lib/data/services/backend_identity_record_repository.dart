import 'dart:typed_data';

import '../../core/result.dart';
import '../../domain/entities/backend_error.dart';
import '../../domain/entities/extraction_result.dart';
import '../../domain/entities/identity_record.dart';
import '../../domain/entities/registration_rejection.dart';
import '../../domain/entities/registration_rules.dart';
import '../../domain/entities/session_state.dart';
import '../../domain/repositories/identity_record_repository.dart';
import 'backend_error_mapper.dart';
import 'credential_service.dart';
import 'passenger_mapper.dart';
import 'passenger_service.dart';

/// Registers the passenger with the backend (`POST /v1/identity`, 015
/// FR-002 to FR-004, research.md §8), from 004's typed fields and 003's
/// photo.
///
/// - **Before sending**: a missing or oversize photo is refused with
///   [RecaptureDocument], so the backend never sees it. A missing document
///   type is refused with [InvalidFields].
/// - **201 and 200 are both success**, because resubmission is idempotent
///   (FR-003). Only then is the display subset stored: the backend's name
///   and the last four characters of its masked number (FR-004). Neither the
///   full number nor the record is stored.
/// - **A refusal** is `Result.error(RegistrationRejection)`
///   (contracts/outcome-mapping.md). A transport failure stays a
///   `TransportFailure` or a [SessionUnavailable].
class BackendIdentityRecordRepository implements IdentityRecordRepository {
  BackendIdentityRecordRepository(
    this._service, {
    required CredentialService credentialService,
  }) : _credentialService = credentialService;

  final PassengerService _service;
  final CredentialService _credentialService;

  /// The backend's `MAX_IMAGE_BYTES` (`domain/images.py`).
  static const maxPhotoBytes = 4 * 1024 * 1024;

  static const _wireFields = <String, FieldKey>{
    'nombre_completo': FieldKey.fullName,
    'numero_documento': FieldKey.documentNumber,
    'fecha_vencimiento': FieldKey.expiryDate,
  };

  @override
  Future<Result<IdentityRecord>> confirm(
    IdentityRecord record, {
    Uint8List? documentPhoto,
  }) async {
    if (documentPhoto == null ||
        documentPhoto.isEmpty ||
        documentPhoto.length > maxPhotoBytes) {
      return const Result.error(RecaptureDocument());
    }
    final documentType = record.documentType;
    if (documentType == null) {
      return const Result.error(InvalidFields(fields: {}, documentType: true));
    }
    String valueOf(FieldKey key) => record.fields
        .firstWhere(
          (field) => field.key == key,
          orElse: () => ConfirmedField(
            key: key,
            value: '',
            source: FieldSource.passengerCorrected,
          ),
        )
        .value;
    final expiry = RegistrationRules.parseExpiry(valueOf(FieldKey.expiryDate));

    try {
      final (:pasajero, created: _) = await _service.register(
        nombreCompleto: RegistrationRules.normalizeName(
          valueOf(FieldKey.fullName),
        ),
        tipoDocumento: documentTypeToWire(documentType),
        numeroDocumento: RegistrationRules.normalizeNumber(
          valueOf(FieldKey.documentNumber),
        ),
        fechaVencimiento: expiry == null
            ? valueOf(FieldKey.expiryDate)
            : RegistrationRules.wireDate(expiry),
        fotoDocumento: documentPhoto,
      );
      final passenger = passengerFromDto(pasajero);
      await _credentialService.writeDisplayFields(
        holderName: passenger.holderName,
        documentLast4: lastFourOf(passenger.maskedNumber),
      );
      return Result.ok(record);
    } catch (e, st) {
      return Result.error(_rejectionFor(mapBackendError(e)), st);
    }
  }

  Object _rejectionFor(Object mapped) {
    if (mapped is! BackendError) return mapped;
    return switch (mapped.code) {
      BackendErrorCode.datosInvalidos => _invalidFields(mapped.fields),
      BackendErrorCode.documentoVencido => const DocumentExpired(),
      BackendErrorCode.cuentaYaRegistrada => const AccountHasOtherDocument(),
      BackendErrorCode.documentoYaRegistrado => const DocumentOwnedElsewhere(),
      BackendErrorCode.imagenDemasiadoGrande ||
      BackendErrorCode.formatoNoAdmitido => const RecaptureDocument(),
      BackendErrorCode.almacenamientoNoDisponible => RegistrationServiceBusy(
        retryAfter: mapped.retryAfter,
      ),
      BackendErrorCode.noAutenticado => const SessionUnavailable(),
      // Not documented for this endpoint: the generic path, by code only.
      BackendErrorCode.pasajeroNoRegistrado ||
      BackendErrorCode.estadoNoPermiteVerificacion ||
      BackendErrorCode.identidadNoActiva ||
      BackendErrorCode.limiteEmisionExcedido ||
      BackendErrorCode.credencialNoEncontrada ||
      BackendErrorCode.unknown => mapped,
    };
  }

  RegistrationRejection _invalidFields(List<String> wire) {
    if (wire.contains('foto_documento') &&
        wire.every((field) => field == 'foto_documento')) {
      return const RecaptureDocument();
    }
    return InvalidFields(
      fields: {for (final field in wire) ?_wireFields[field]},
      documentType: wire.contains('tipo_documento'),
    );
  }
}
