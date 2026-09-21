import 'package:json_annotation/json_annotation.dart';

part 'document_verification_response.g.dart';

/// The backend's document-verification endpoint response shape. A pure
/// data transfer object — it MUST NOT appear outside `lib/data/`
/// (Constitution Principle II / repository-pattern craft rule:
/// "repositories return domain models and Result, never DTOs").
@JsonSerializable()
class DocumentVerificationResponse {
  DocumentVerificationResponse({required this.outcome, this.reason});

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

  Map<String, dynamic> toJson() => _$DocumentVerificationResponseToJson(this);
}
