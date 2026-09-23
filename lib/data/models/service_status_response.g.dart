// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_status_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceStatusResponse _$ServiceStatusResponseFromJson(
  Map<String, dynamic> json,
) => ServiceStatusResponse(
  steps: (json['steps'] as List<dynamic>?)
      ?.map((e) => ServiceStepResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  retryAfter: json['retryAfter'] as String?,
);

Map<String, dynamic> _$ServiceStatusResponseToJson(
  ServiceStatusResponse instance,
) => <String, dynamic>{
  'steps': instance.steps,
  'retryAfter': instance.retryAfter,
};

ServiceStepResponse _$ServiceStepResponseFromJson(Map<String, dynamic> json) =>
    ServiceStepResponse(
      step: json['step'] as String?,
      health: json['health'] as String?,
    );

Map<String, dynamic> _$ServiceStepResponseToJson(
  ServiceStepResponse instance,
) => <String, dynamic>{'step': instance.step, 'health': instance.health};
