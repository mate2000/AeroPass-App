// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_verification_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentVerificationResponse _$DocumentVerificationResponseFromJson(
  Map<String, dynamic> json,
) => DocumentVerificationResponse(
  outcome: json['outcome'] as String,
  reason: json['reason'] as String?,
  fields: (json['fields'] as List<dynamic>?)
      ?.map((e) => ExtractedFieldResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DocumentVerificationResponseToJson(
  DocumentVerificationResponse instance,
) => <String, dynamic>{
  'outcome': instance.outcome,
  'reason': instance.reason,
  'fields': instance.fields,
};

ExtractedFieldResponse _$ExtractedFieldResponseFromJson(
  Map<String, dynamic> json,
) => ExtractedFieldResponse(
  key: json['key'] as String,
  value: json['value'] as String,
  confidence: (json['confidence'] as num).toDouble(),
);

Map<String, dynamic> _$ExtractedFieldResponseToJson(
  ExtractedFieldResponse instance,
) => <String, dynamic>{
  'key': instance.key,
  'value': instance.value,
  'confidence': instance.confidence,
};
