// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_job_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerificationJobResponse _$VerificationJobResponseFromJson(
  Map<String, dynamic> json,
) => VerificationJobResponse(
  state: json['state'] as String?,
  documentCheck: json['documentCheck'] as String?,
  faceComparison: json['faceComparison'] as String?,
  outcome: json['outcome'] as String?,
  resumableUntil: json['resumableUntil'] as String?,
);

Map<String, dynamic> _$VerificationJobResponseToJson(
  VerificationJobResponse instance,
) => <String, dynamic>{
  'state': instance.state,
  'documentCheck': instance.documentCheck,
  'faceComparison': instance.faceComparison,
  'outcome': instance.outcome,
  'resumableUntil': instance.resumableUntil,
};
