import 'package:freezed_annotation/freezed_annotation.dart';

part 'extraction_result.freezed.dart';

/// The four fields spec.md's UI Reference names, shared by `ExtractedField`,
/// `FieldCorrection`, and `ConfirmedField` — exactly one vocabulary for
/// "which field," never a per-layer re-encoding (data-model.md).
enum FieldKey { fullName, documentNumber, nationality, expiryDate }

/// The processor's per-field read (research.md §2). Sealed rather than a
/// nullable `value` on a single type — Constitution Principle IX — so
/// "the processor tried and failed to read this field" (FR-009's explicit
/// gap) is structurally distinct from "this field has an empty string."
@freezed
sealed class ExtractedField with _$ExtractedField {
  /// [value] is the raw/canonical form: ISO-8601 (`yyyy-MM-dd`) for
  /// [FieldKey.expiryDate] (research.md §3), the literal string otherwise.
  /// [confidence] is `0.0`–`1.0`.
  const factory ExtractedField.present({
    required FieldKey key,
    required String value,
    required double confidence,
  }) = ExtractedFieldPresent;

  /// The processor attempted this document type's field set and could not
  /// read this one.
  const factory ExtractedField.missing({required FieldKey key}) =
      ExtractedFieldMissing;

  // `key` is common to both variants, so freezed already generates one
  // shared getter for it on the base type — no manual override needed.
}

/// One document's extraction, held for the session only (never persisted —
/// see `PendingDocumentController`).
@freezed
sealed class ExtractionResult with _$ExtractionResult {
  const factory ExtractionResult({required List<ExtractedField> fields}) =
      _ExtractionResult;

  const ExtractionResult._();

  ExtractedField? fieldFor(FieldKey key) {
    for (final field in fields) {
      if (field.key == key) return field;
    }
    return null;
  }

  /// Parses [FieldKey.expiryDate]'s ISO-8601 value, if present — not a
  /// stored field (research.md §3). `null` if the field is missing or
  /// unparseable.
  DateTime? get parsedExpiryDate {
    final field = fieldFor(FieldKey.expiryDate);
    if (field is! ExtractedFieldPresent) return null;
    return DateTime.tryParse(field.value);
  }
}
