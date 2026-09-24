import 'package:freezed_annotation/freezed_annotation.dart';

import 'extraction_result.dart';
import 'passenger_record.dart';

part 'identity_record.freezed.dart';

/// Whether a confirmed field's value is exactly what the processor read, or
/// was changed by the passenger (data-model.md, SC-002's audit-trail
/// distinction).
enum FieldSource { machineRead, passengerCorrected }

/// One field of the confirmed record (FR-002, FR-004).
@freezed
sealed class ConfirmedField with _$ConfirmedField {
  const factory ConfirmedField({
    required FieldKey key,
    required String value,
    required FieldSource source,

    /// Present only when [source] is [FieldSource.passengerCorrected]: the
    /// machine-extracted value before correction (SC-002's audit trail).
    String? originalValue,

    /// True when [source] is [FieldSource.passengerCorrected] and an
    /// automated re-check (not just a low-confidence pass-through)
    /// confirmed it (FR-005).
    @Default(false) bool reverified,
  }) = _ConfirmedField;
}

/// What confirmation produces (FR-002, FR-004, SC-002). Submitted in full to
/// `IdentityRecordRepository.confirm(...)`; only a display-only subset
/// (key+value pairs, no source/originalValue/reverified) is cached locally
/// after a successful confirm (research.md §5) — the full record, including
/// the audit-trail distinction, exists only in memory and on the backend.
@freezed
sealed class IdentityRecord with _$IdentityRecord {
  const factory IdentityRecord({
    required List<ConfirmedField> fields,

    /// The passenger's choice of CC, CE or Pasaporte (015 FR-002). The
    /// backend requires it, and no extraction supplies it. Null only on the
    /// dev-offline path, whose fake backend does not ask.
    DocumentType? documentType,
  }) = _IdentityRecord;
}
