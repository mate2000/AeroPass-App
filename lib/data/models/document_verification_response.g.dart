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
);

Map<String, dynamic> _$DocumentVerificationResponseToJson(
  DocumentVerificationResponse instance,
) => <String, dynamic>{'outcome': instance.outcome, 'reason': instance.reason};
