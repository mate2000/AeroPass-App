import 'package:json_annotation/json_annotation.dart';

part 'escalation_status_response.g.dart';

/// Inbound DTO for `GET /v1/escalations/current` and `POST /v1/escalations`
/// (010-escalar-agente, data-model.md). Every field is nullable, so malformed
/// data maps to its safest reading in `EscalationRepositoryImpl` instead of
/// throwing. Never leaves `lib/data/` (Principle II).
@JsonSerializable(explicitToJson: true)
class EscalationStatusResponse {
  EscalationStatusResponse({
    this.state,
    this.openedAt,
    this.arrival,
    this.channels,
    this.outcome,
    this.resetScope,
  });

  factory EscalationStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$EscalationStatusResponseFromJson(json);

  final String? state;
  final String? openedAt;
  final String? arrival;
  final List<AgentChannelResponse>? channels;
  final String? outcome;
  final String? resetScope;

  Map<String, dynamic> toJson() => _$EscalationStatusResponseToJson(this);
}

/// One channel inside [EscalationStatusResponse].
@JsonSerializable()
class AgentChannelResponse {
  AgentChannelResponse({
    this.kind,
    this.available,
    this.nextOpensAt,
    this.waitMinMinutes,
    this.waitMaxMinutes,
    this.hours,
    this.locationName,
    this.locationDetail,
  });

  factory AgentChannelResponse.fromJson(Map<String, dynamic> json) =>
      _$AgentChannelResponseFromJson(json);

  final String? kind;
  final bool? available;
  final String? nextOpensAt;
  final int? waitMinMinutes;
  final int? waitMaxMinutes;
  final String? hours;
  final String? locationName;
  final String? locationDetail;

  Map<String, dynamic> toJson() => _$AgentChannelResponseToJson(this);
}
