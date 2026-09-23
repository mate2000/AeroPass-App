import 'package:json_annotation/json_annotation.dart';

part 'credential_issuance_response.g.dart';

/// Inbound DTO for `POST /v1/credential/issuance` (data-model.md,
/// 008-identidad-activa). Every field is nullable, and the dates stay
/// strings, so a missing or malformed field is detected by the mapping
/// rules of research.md §2 (and becomes `IssuanceOutcome.incomplete()`)
/// rather than thrown by the parser as if it were a transport failure.
/// Never leaves `lib/data/` (Constitution Principle II).
@JsonSerializable()
class CredentialIssuanceResponse {
  CredentialIssuanceResponse({
    this.status,
    this.token,
    this.holderName,
    this.documentLast4,
    this.issuingCountry,
    this.issuedAt,
    this.validUntil,
  });

  factory CredentialIssuanceResponse.fromJson(Map<String, dynamic> json) =>
      _$CredentialIssuanceResponseFromJson(json);

  final String? status;
  final String? token;
  final String? holderName;
  final String? documentLast4;
  final String? issuingCountry;
  final String? issuedAt;
  final String? validUntil;

  Map<String, dynamic> toJson() => _$CredentialIssuanceResponseToJson(this);
}
