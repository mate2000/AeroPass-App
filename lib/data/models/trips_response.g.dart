// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trips_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TripsResponse _$TripsResponseFromJson(Map<String, dynamic> json) =>
    TripsResponse(
      segments: (json['segments'] as List<dynamic>?)
          ?.map((e) => TripSegmentResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TripsResponseToJson(TripsResponse instance) =>
    <String, dynamic>{'segments': instance.segments};

TripSegmentResponse _$TripSegmentResponseFromJson(
  Map<String, dynamic> json,
) => TripSegmentResponse(
  id: json['id'] as String?,
  origin: json['origin'] == null
      ? null
      : AirportResponse.fromJson(json['origin'] as Map<String, dynamic>),
  destination: json['destination'] == null
      ? null
      : AirportResponse.fromJson(json['destination'] as Map<String, dynamic>),
  flightNumber: json['flightNumber'] as String?,
  departureLocal: json['departureLocal'] as String?,
  status: json['status'] as String?,
  live: json['live'] as bool?,
  gate: json['gate'] as String?,
  seat: json['seat'] as String?,
  connectsTo: json['connectsTo'] == null
      ? null
      : AirportResponse.fromJson(json['connectsTo'] as Map<String, dynamic>),
  domestic: json['domestic'] as bool?,
);

Map<String, dynamic> _$TripSegmentResponseToJson(
  TripSegmentResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'origin': instance.origin,
  'destination': instance.destination,
  'flightNumber': instance.flightNumber,
  'departureLocal': instance.departureLocal,
  'status': instance.status,
  'live': instance.live,
  'gate': instance.gate,
  'seat': instance.seat,
  'connectsTo': instance.connectsTo,
  'domestic': instance.domestic,
};

AirportResponse _$AirportResponseFromJson(Map<String, dynamic> json) =>
    AirportResponse(
      code: json['code'] as String?,
      city: json['city'] as String?,
    );

Map<String, dynamic> _$AirportResponseToJson(AirportResponse instance) =>
    <String, dynamic>{'code': instance.code, 'city': instance.city};
