// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pass_responses.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PassIssueResponse _$PassIssueResponseFromJson(Map<String, dynamic> json) =>
    PassIssueResponse(
      passId: json['passId'] as String?,
      nextCheckpoint: json['nextCheckpoint'] as String?,
      validUntil: json['validUntil'] as String?,
      rotationSeconds: (json['rotationSeconds'] as num?)?.toInt(),
      serverTime: json['serverTime'] as String?,
    );

Map<String, dynamic> _$PassIssueResponseToJson(PassIssueResponse instance) =>
    <String, dynamic>{
      'passId': instance.passId,
      'nextCheckpoint': instance.nextCheckpoint,
      'validUntil': instance.validUntil,
      'rotationSeconds': instance.rotationSeconds,
      'serverTime': instance.serverTime,
    };

PassCodeResponse _$PassCodeResponseFromJson(Map<String, dynamic> json) =>
    PassCodeResponse(
      payload: json['payload'] as String?,
      windowStartsAt: json['windowStartsAt'] as String?,
      windowEndsAt: json['windowEndsAt'] as String?,
      serverTime: json['serverTime'] as String?,
    );

Map<String, dynamic> _$PassCodeResponseToJson(PassCodeResponse instance) =>
    <String, dynamic>{
      'payload': instance.payload,
      'windowStartsAt': instance.windowStartsAt,
      'windowEndsAt': instance.windowEndsAt,
      'serverTime': instance.serverTime,
    };

PassStatusResponse _$PassStatusResponseFromJson(Map<String, dynamic> json) =>
    PassStatusResponse(
      state: json['state'] as String?,
      validated: (json['validated'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      nextCheckpoint: json['nextCheckpoint'] as String?,
      flightStatus: json['flightStatus'] as String?,
      serverTime: json['serverTime'] as String?,
    );

Map<String, dynamic> _$PassStatusResponseToJson(PassStatusResponse instance) =>
    <String, dynamic>{
      'state': instance.state,
      'validated': instance.validated,
      'nextCheckpoint': instance.nextCheckpoint,
      'flightStatus': instance.flightStatus,
      'serverTime': instance.serverTime,
    };
