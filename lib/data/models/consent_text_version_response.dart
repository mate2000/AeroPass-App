import 'package:json_annotation/json_annotation.dart';

part 'consent_text_version_response.g.dart';

/// The backend's current-consent-text endpoint response shape. A pure data
/// transfer object — it MUST NOT appear outside `lib/data/` (Constitution
/// Principle II / repository-pattern craft rule: "repositories return
/// domain models and Result, never DTOs").
@JsonSerializable()
class ConsentTextVersionResponse {
  ConsentTextVersionResponse({
    required this.id,
    required this.points,
    required this.rightsStatement,
    required this.optionalityStatement,
    required this.processorDisclosure,
    required this.privacyPolicyUrl,
    required this.termsUrl,
    required this.publishedAt,
  });

  factory ConsentTextVersionResponse.fromJson(Map<String, dynamic> json) =>
      _$ConsentTextVersionResponseFromJson(json);

  final String id;
  final List<ConsentPointResponse> points;
  final String rightsStatement;
  final String optionalityStatement;
  final String processorDisclosure;
  final String privacyPolicyUrl;
  final String termsUrl;
  final DateTime publishedAt;

  Map<String, dynamic> toJson() => _$ConsentTextVersionResponseToJson(this);
}

@JsonSerializable()
class ConsentPointResponse {
  ConsentPointResponse({
    required this.icon,
    required this.heading,
    required this.body,
  });

  factory ConsentPointResponse.fromJson(Map<String, dynamic> json) =>
      _$ConsentPointResponseFromJson(json);

  /// One of `camera`, `clock`, `share`.
  final String icon;
  final String heading;
  final String body;

  Map<String, dynamic> toJson() => _$ConsentPointResponseToJson(this);
}
