import 'package:json_annotation/json_annotation.dart';

part 'trips_response.g.dart';

/// Inbound DTO for `GET /v1/trips` (012-mis-viajes, contracts/trip-port.md).
/// Every field is nullable, so malformed segments are dropped in
/// `TripRepositoryImpl` instead of throwing. Never leaves `lib/data/`.
@JsonSerializable()
class TripsResponse {
  TripsResponse({this.segments});

  factory TripsResponse.fromJson(Map<String, dynamic> json) =>
      _$TripsResponseFromJson(json);

  final List<TripSegmentResponse>? segments;

  Map<String, dynamic> toJson() => _$TripsResponseToJson(this);
}

@JsonSerializable()
class TripSegmentResponse {
  TripSegmentResponse({
    this.id,
    this.origin,
    this.destination,
    this.flightNumber,
    this.departureLocal,
    this.status,
    this.live,
    this.gate,
    this.seat,
    this.connectsTo,
    this.domestic,
  });

  factory TripSegmentResponse.fromJson(Map<String, dynamic> json) =>
      _$TripSegmentResponseFromJson(json);

  final String? id;
  final AirportResponse? origin;
  final AirportResponse? destination;
  final String? flightNumber;

  /// ISO 8601 with the departure airport's offset, for example
  /// `2026-09-23T14:35:00-05:00`.
  final String? departureLocal;
  final String? status;
  final bool? live;
  final String? gate;
  final String? seat;
  final AirportResponse? connectsTo;
  final bool? domestic;

  Map<String, dynamic> toJson() => _$TripSegmentResponseToJson(this);
}

@JsonSerializable()
class AirportResponse {
  AirportResponse({this.code, this.city});

  factory AirportResponse.fromJson(Map<String, dynamic> json) =>
      _$AirportResponseFromJson(json);

  final String? code;
  final String? city;

  Map<String, dynamic> toJson() => _$AirportResponseToJson(this);
}
