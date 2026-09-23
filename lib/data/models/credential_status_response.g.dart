// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credential_status_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CredentialStatusResponse _$CredentialStatusResponseFromJson(
  Map<String, dynamic> json,
) => CredentialStatusResponse(
  status: json['status'] as String,
  validUntil: json['validUntil'] == null
      ? null
      : DateTime.parse(json['validUntil'] as String),
  holderName: json['holderName'] as String?,
  documentLast4: json['documentLast4'] as String?,
);

Map<String, dynamic> _$CredentialStatusResponseToJson(
  CredentialStatusResponse instance,
) => <String, dynamic>{
  'status': instance.status,
  'validUntil': instance.validUntil?.toIso8601String(),
  'holderName': instance.holderName,
  'documentLast4': instance.documentLast4,
};
