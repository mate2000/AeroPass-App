import 'package:json_annotation/json_annotation.dart';

part 'service_status_response.g.dart';

/// Inbound DTO for `GET /v1/service-status` (011-error-tecnico,
/// contracts/service-status-port.md). Every field is nullable, so malformed
/// data maps to a failed read in `ServiceStatusRepositoryImpl` instead of
/// throwing. Never leaves `lib/data/` (Principle II).
@JsonSerializable()
class ServiceStatusResponse {
  ServiceStatusResponse({this.steps, this.retryAfter});

  factory ServiceStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$ServiceStatusResponseFromJson(json);

  final List<ServiceStepResponse>? steps;
  final String? retryAfter;

  Map<String, dynamic> toJson() => _$ServiceStatusResponseToJson(this);
}

@JsonSerializable()
class ServiceStepResponse {
  ServiceStepResponse({this.step, this.health});

  factory ServiceStepResponse.fromJson(Map<String, dynamic> json) =>
      _$ServiceStepResponseFromJson(json);

  final String? step;
  final String? health;

  Map<String, dynamic> toJson() => _$ServiceStepResponseToJson(this);
}
