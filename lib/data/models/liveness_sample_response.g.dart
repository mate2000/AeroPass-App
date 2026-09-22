// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'liveness_sample_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LivenessSampleResponse _$LivenessSampleResponseFromJson(
  Map<String, dynamic> json,
) => LivenessSampleResponse(
  status: json['status'] as String,
  phaseIndex: (json['phaseIndex'] as num?)?.toInt(),
  totalPhases: (json['totalPhases'] as num?)?.toInt(),
  instruction: json['instruction'] as String?,
  outcome: json['outcome'] as String?,
  reason: json['reason'] as String?,
);

Map<String, dynamic> _$LivenessSampleResponseToJson(
  LivenessSampleResponse instance,
) => <String, dynamic>{
  'status': instance.status,
  'phaseIndex': instance.phaseIndex,
  'totalPhases': instance.totalPhases,
  'instruction': instance.instruction,
  'outcome': instance.outcome,
  'reason': instance.reason,
};
