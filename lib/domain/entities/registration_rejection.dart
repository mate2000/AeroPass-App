import 'extraction_result.dart';

/// Why the backend refused a registration (015 contracts/outcome-mapping.md
/// "Registration"). It is returned as the `Result.error` payload of
/// `IdentityRecordRepository.confirm`, so 004 can react to each case
/// instead of showing one generic failure (SC-004).
///
/// A transport failure is not one of these. It stays a `TransportFailure`
/// or a `SessionUnavailable`.
sealed class RegistrationRejection {
  const RegistrationRejection();
}

/// 422 `DATOS_INVALIDOS`: the backend named the offending fields (FR-016).
/// `documentType` is not a [FieldKey], so it is carried separately.
final class InvalidFields extends RegistrationRejection {
  const InvalidFields({required this.fields, this.documentType = false});

  final Set<FieldKey> fields;
  final bool documentType;
}

/// 422 `DOCUMENTO_VENCIDO`: the document expired before today.
final class DocumentExpired extends RegistrationRejection {
  const DocumentExpired();
}

/// 409 `CUENTA_YA_REGISTRADA`: this session already registered a different
/// document.
final class AccountHasOtherDocument extends RegistrationRejection {
  const AccountHasOtherDocument();
}

/// 409 `DOCUMENTO_YA_REGISTRADO`: another account holds this document. That
/// is usually a passenger who lost their session (V-09), so it routes to the
/// agent path and is never shown as their error (FR-001a).
final class DocumentOwnedElsewhere extends RegistrationRejection {
  const DocumentOwnedElsewhere();
}

/// 413 or 415, or a photo over the limit caught on the device: take the
/// photo again.
final class RecaptureDocument extends RegistrationRejection {
  const RecaptureDocument();
}

/// 503 `ALMACENAMIENTO_NO_DISPONIBLE`: a service condition, not a rejection
/// (FR-014).
final class RegistrationServiceBusy extends RegistrationRejection {
  const RegistrationServiceBusy({this.retryAfter});

  final Duration? retryAfter;
}
