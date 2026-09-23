import 'package:json_annotation/json_annotation.dart';

part 'credential_status_response.g.dart';

/// The backend's credential-status endpoint response shape. A pure data
/// transfer object — it MUST NOT appear outside `lib/data/` (Constitution
/// Principle II / repository-pattern craft rule: "repositories return
/// domain models and Result, never DTOs").
@JsonSerializable()
class CredentialStatusResponse {
  CredentialStatusResponse({
    required this.status,
    this.validUntil,
    this.holderName,
    this.documentLast4,
  });

  factory CredentialStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$CredentialStatusResponseFromJson(json);

  /// One of `valid`, `expired`, `revoked`, or `no_credential`.
  final String status;
  final DateTime? validUntil;

  /// 012-mis-viajes: optional display fields for the home strip.
  final String? holderName;
  final String? documentLast4;

  Map<String, dynamic> toJson() => _$CredentialStatusResponseToJson(this);
}
