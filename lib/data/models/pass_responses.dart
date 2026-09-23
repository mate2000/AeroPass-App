import 'package:json_annotation/json_annotation.dart';

part 'pass_responses.g.dart';

/// Inbound DTOs for the pass endpoints (014-qr-pase, contracts/pass-port.md).
/// Every field is nullable, so malformed data maps to an error in
/// `PassRepositoryImpl` instead of throwing. Never leaves `lib/data/`.
///
/// Phase A deliberately has **no `secret` field**: the backend may send one
/// once phase B exists, and it must never be read or stored before the
/// constitution amendment is ratified.
@JsonSerializable()
class PassIssueResponse {
  PassIssueResponse({
    this.passId,
    this.nextCheckpoint,
    this.validUntil,
    this.rotationSeconds,
    this.serverTime,
  });

  factory PassIssueResponse.fromJson(Map<String, dynamic> json) =>
      _$PassIssueResponseFromJson(json);

  final String? passId;
  final String? nextCheckpoint;
  final String? validUntil;
  final int? rotationSeconds;
  final String? serverTime;

  Map<String, dynamic> toJson() => _$PassIssueResponseToJson(this);
}

@JsonSerializable()
class PassCodeResponse {
  PassCodeResponse({
    this.payload,
    this.windowStartsAt,
    this.windowEndsAt,
    this.serverTime,
  });

  factory PassCodeResponse.fromJson(Map<String, dynamic> json) =>
      _$PassCodeResponseFromJson(json);

  final String? payload;
  final String? windowStartsAt;
  final String? windowEndsAt;
  final String? serverTime;

  Map<String, dynamic> toJson() => _$PassCodeResponseToJson(this);
}

@JsonSerializable()
class PassStatusResponse {
  PassStatusResponse({
    this.state,
    this.validated,
    this.nextCheckpoint,
    this.flightStatus,
    this.serverTime,
  });

  factory PassStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$PassStatusResponseFromJson(json);

  final String? state;
  final List<String>? validated;
  final String? nextCheckpoint;
  final String? flightStatus;
  final String? serverTime;

  Map<String, dynamic> toJson() => _$PassStatusResponseToJson(this);
}
