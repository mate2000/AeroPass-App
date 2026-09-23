import 'package:json_annotation/json_annotation.dart';

part 'verification_job_response.g.dart';

/// Inbound DTO for `GET /v1/verification/jobs/current` (007-validando,
/// data-model.md). Every field is a nullable string, so malformed data maps
/// to a safe value in `VerificationJobRepositoryImpl` instead of throwing.
/// Never leaves `lib/data/` (Constitution Principle II).
@JsonSerializable()
class VerificationJobResponse {
  VerificationJobResponse({
    this.state,
    this.documentCheck,
    this.faceComparison,
    this.outcome,
    this.resumableUntil,
  });

  factory VerificationJobResponse.fromJson(Map<String, dynamic> json) =>
      _$VerificationJobResponseFromJson(json);

  final String? state;
  final String? documentCheck;
  final String? faceComparison;
  final String? outcome;

  /// 011-error-tecnico: ISO 8601, 24 h after a failure; optional.
  final String? resumableUntil;

  Map<String, dynamic> toJson() => _$VerificationJobResponseToJson(this);
}
