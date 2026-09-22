import 'package:json_annotation/json_annotation.dart';

part 'liveness_sample_response.g.dart';

/// The backend's liveness-sample endpoint response shape. A pure data
/// transfer object — it MUST NOT appear outside `lib/data/` (Constitution
/// Principle II / repository-pattern craft rule).
@JsonSerializable()
class LivenessSampleResponse {
  LivenessSampleResponse({
    required this.status,
    this.phaseIndex,
    this.totalPhases,
    this.instruction,
    this.outcome,
    this.reason,
  });

  factory LivenessSampleResponse.fromJson(Map<String, dynamic> json) =>
      _$LivenessSampleResponseFromJson(json);

  /// `in_progress` | `completed`.
  final String status;

  /// Present only when [status] is `in_progress`.
  final int? phaseIndex;
  final int? totalPhases;

  /// One of the processor's own instruction codes; an unrecognized value
  /// maps to `LivenessInstruction.holdStill()`
  /// (`LivenessVerificationRepositoryImpl`).
  final String? instruction;

  /// Present only when [status] is `completed`. `success` |
  /// `quality_failure` | `unclassified_failure` | `attack_detected`, or any
  /// other processor-specific code — an unrecognized code maps to
  /// `LivenessOutcome.unclassifiedFailure()` rather than throwing
  /// (contracts/liveness-verification-port.md, case 7).
  final String? outcome;

  /// Present only when [outcome] is `quality_failure`.
  final String? reason;

  Map<String, dynamic> toJson() => _$LivenessSampleResponseToJson(this);
}
