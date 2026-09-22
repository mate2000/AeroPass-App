import 'package:json_annotation/json_annotation.dart';

part 'field_reverification_response.g.dart';

/// The backend's field-reverification endpoint response shape. A pure data
/// transfer object — it MUST NOT appear outside `lib/data/` (Constitution
/// Principle II / repository-pattern craft rule).
@JsonSerializable()
class FieldReverificationResponse {
  FieldReverificationResponse({required this.confirmed});

  factory FieldReverificationResponse.fromJson(Map<String, dynamic> json) =>
      _$FieldReverificationResponseFromJson(json);

  /// Whether the automated re-read of the disputed field, from the
  /// retained image, agrees with the candidate value submitted. A response
  /// missing this key entirely (a field the processor cannot re-read, or an
  /// otherwise malformed response) parses as `null`, which
  /// `FieldReverificationRepositoryImpl` maps to `disagreed()` rather than
  /// throwing (contracts/field-reverification-port.md, case 4).
  final bool? confirmed;

  Map<String, dynamic> toJson() => _$FieldReverificationResponseToJson(this);
}
