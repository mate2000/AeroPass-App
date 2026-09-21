// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consent_text_version_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConsentTextVersionResponse _$ConsentTextVersionResponseFromJson(
  Map<String, dynamic> json,
) => ConsentTextVersionResponse(
  id: json['id'] as String,
  points: (json['points'] as List<dynamic>)
      .map((e) => ConsentPointResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  rightsStatement: json['rightsStatement'] as String,
  optionalityStatement: json['optionalityStatement'] as String,
  processorDisclosure: json['processorDisclosure'] as String,
  privacyPolicyUrl: json['privacyPolicyUrl'] as String,
  termsUrl: json['termsUrl'] as String,
  publishedAt: DateTime.parse(json['publishedAt'] as String),
);

Map<String, dynamic> _$ConsentTextVersionResponseToJson(
  ConsentTextVersionResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'points': instance.points,
  'rightsStatement': instance.rightsStatement,
  'optionalityStatement': instance.optionalityStatement,
  'processorDisclosure': instance.processorDisclosure,
  'privacyPolicyUrl': instance.privacyPolicyUrl,
  'termsUrl': instance.termsUrl,
  'publishedAt': instance.publishedAt.toIso8601String(),
};

ConsentPointResponse _$ConsentPointResponseFromJson(
  Map<String, dynamic> json,
) => ConsentPointResponse(
  icon: json['icon'] as String,
  heading: json['heading'] as String,
  body: json['body'] as String,
);

Map<String, dynamic> _$ConsentPointResponseToJson(
  ConsentPointResponse instance,
) => <String, dynamic>{
  'icon': instance.icon,
  'heading': instance.heading,
  'body': instance.body,
};
