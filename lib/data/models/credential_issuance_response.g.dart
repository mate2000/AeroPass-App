// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credential_issuance_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CredentialIssuanceResponse _$CredentialIssuanceResponseFromJson(
  Map<String, dynamic> json,
) => CredentialIssuanceResponse(
  status: json['status'] as String?,
  token: json['token'] as String?,
  holderName: json['holderName'] as String?,
  documentLast4: json['documentLast4'] as String?,
  issuingCountry: json['issuingCountry'] as String?,
  issuedAt: json['issuedAt'] as String?,
  validUntil: json['validUntil'] as String?,
);

Map<String, dynamic> _$CredentialIssuanceResponseToJson(
  CredentialIssuanceResponse instance,
) => <String, dynamic>{
  'status': instance.status,
  'token': instance.token,
  'holderName': instance.holderName,
  'documentLast4': instance.documentLast4,
  'issuingCountry': instance.issuingCountry,
  'issuedAt': instance.issuedAt,
  'validUntil': instance.validUntil,
};
