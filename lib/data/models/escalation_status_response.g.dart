// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'escalation_status_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EscalationStatusResponse _$EscalationStatusResponseFromJson(
  Map<String, dynamic> json,
) => EscalationStatusResponse(
  state: json['state'] as String?,
  openedAt: json['openedAt'] as String?,
  arrival: json['arrival'] as String?,
  channels: (json['channels'] as List<dynamic>?)
      ?.map((e) => AgentChannelResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  outcome: json['outcome'] as String?,
  resetScope: json['resetScope'] as String?,
);

Map<String, dynamic> _$EscalationStatusResponseToJson(
  EscalationStatusResponse instance,
) => <String, dynamic>{
  'state': instance.state,
  'openedAt': instance.openedAt,
  'arrival': instance.arrival,
  'channels': instance.channels?.map((e) => e.toJson()).toList(),
  'outcome': instance.outcome,
  'resetScope': instance.resetScope,
};

AgentChannelResponse _$AgentChannelResponseFromJson(
  Map<String, dynamic> json,
) => AgentChannelResponse(
  kind: json['kind'] as String?,
  available: json['available'] as bool?,
  nextOpensAt: json['nextOpensAt'] as String?,
  waitMinMinutes: (json['waitMinMinutes'] as num?)?.toInt(),
  waitMaxMinutes: (json['waitMaxMinutes'] as num?)?.toInt(),
  hours: json['hours'] as String?,
  locationName: json['locationName'] as String?,
  locationDetail: json['locationDetail'] as String?,
);

Map<String, dynamic> _$AgentChannelResponseToJson(
  AgentChannelResponse instance,
) => <String, dynamic>{
  'kind': instance.kind,
  'available': instance.available,
  'nextOpensAt': instance.nextOpensAt,
  'waitMinMinutes': instance.waitMinMinutes,
  'waitMaxMinutes': instance.waitMaxMinutes,
  'hours': instance.hours,
  'locationName': instance.locationName,
  'locationDetail': instance.locationDetail,
};
