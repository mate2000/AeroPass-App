import 'package:json_annotation/json_annotation.dart';

part 'document_verification_response.g.dart';

/// The backend's document-verification endpoint response shape. A pure
/// data transfer object — it MUST NOT appear outside `lib/data/`
/// (Constitution Principle II / repository-pattern craft rule:
/// "repositories return domain models and Result, never DTOs").
@JsonSerializable()
class DocumentVerificationResponse {
  DocumentVerificationResponse({required this.outcome, this.reason, this.fields});

  factory DocumentVerificationResponse.fromJson(Map<String, dynamic> json) =>
      _$DocumentVerificationResponseFromJson(json);

  /// `accepted` | `rejected`.
  final String outcome;

  /// Present only when [outcome] is `rejected`. One of `blur`, `glare`,
  /// `framing`, `wrong_document`, `low_resolution`, or any other
  /// processor-specific code — `DocumentVerificationRepositoryImpl` maps an
  /// unrecognized code to `CaptureRejectionReason.unreadable` rather than
  /// throwing (contracts/document-verification-port.md, case 7).
  final String? reason;

  /// Present only when [outcome] is `accepted`
  /// (contracts/document-verification-port-addendum.md, 004-confirmar-datos).
  /// A key absent from this array (rather than an entry with a null value)
  /// is how the processor's contract represents a field it could not read
  /// for this document type — mapped to `ExtractedField.missing`.
  final List<ExtractedFieldResponse>? fields;

  Map<String, dynamic> toJson() => _$DocumentVerificationResponseToJson(this);
}

/// One entry of [DocumentVerificationResponse.fields].
@JsonSerializable()
class ExtractedFieldResponse {
  ExtractedFieldResponse({
    required this.key,
    required this.value,
    required this.confidence,
  });

  factory ExtractedFieldResponse.fromJson(Map<String, dynamic> json) =>
      _$ExtractedFieldResponseFromJson(json);

  /// `full_name` | `document_number` | `nationality` | `expiry_date`. An
  /// unrecognized key is skipped by the mapping rather than thrown
  /// (`DocumentVerificationRepositoryImpl`), mirroring the existing
  /// unrecognized-rejection-reason guard.
  final String key;

  /// The raw/canonical value — ISO-8601 (`yyyy-MM-dd`) for `expiry_date`,
  /// the literal string otherwise (004-confirmar-datos research.md §3).
  final String value;

  /// `0.0`–`1.0`.
  final double confidence;

  Map<String, dynamic> toJson() => _$ExtractedFieldResponseToJson(this);
}
