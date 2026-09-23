import 'package:freezed_annotation/freezed_annotation.dart';

part 'liveness_outcome.freezed.dart';

/// Specific, actionable quality-failure reasons (FR-009), rendered in 005's
/// established vocabulary style.
enum LivenessQualityReason {
  tooDark,
  faceOutOfFrame,
  movementDetected,
  multipleFacesDetected,
  faceObstructed,
}

/// The processor's terminal decision for one liveness attempt
/// (data-model.md, research.md §7) — the port through which FR-002's
/// security boundary is enforced structurally. [unclassifiedFailure] and
/// [attackDetected] are distinct domain values (required for SC-007's audit
/// obligation) but MUST render the exact same passenger-facing generic
/// message, byte-for-byte (Clarifications) — that collapsing happens at the
/// view layer, never here.
@freezed
sealed class LivenessOutcome with _$LivenessOutcome {
  /// Advances to verification progress (007).
  const factory LivenessOutcome.success() = LivenessOutcomeSuccess;

  /// A specific, actionable message (FR-009), in 005's vocabulary.
  const factory LivenessOutcome.qualityFailure({
    required LivenessQualityReason reason,
  }) = LivenessOutcomeQualityFailure;

  /// The shared generic message (research.md §7) — a transport failure
  /// exhausting its retry bound, or a processor code carrying no security
  /// signal.
  const factory LivenessOutcome.unclassifiedFailure() =
      LivenessOutcomeUnclassifiedFailure;

  /// The same shared generic message, byte-for-byte, never a distinct
  /// string or styling (Clarifications) — only the audit trail
  /// distinguishes this from [unclassifiedFailure].
  const factory LivenessOutcome.attackDetected() =
      LivenessOutcomeAttackDetected;
}
