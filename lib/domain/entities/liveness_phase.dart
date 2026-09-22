import 'package:freezed_annotation/freezed_annotation.dart';

part 'liveness_phase.freezed.dart';

/// The app-owned instruction vocabulary for an in-progress liveness capture
/// (data-model.md) — never raw processor text, mirroring
/// `CaptureRejectionReason`'s precedent. The real adapter maps the
/// processor's own instruction codes onto this fixed set (FR-004); an
/// unrecognized code maps to [LivenessInstruction.holdStill] as the safest
/// fallback (asks for nothing new, never regresses progress).
@freezed
sealed class LivenessInstruction with _$LivenessInstruction {
  const factory LivenessInstruction.moveCloser() = LivenessInstructionMoveCloser;
  const factory LivenessInstruction.moveBack() = LivenessInstructionMoveBack;
  const factory LivenessInstruction.centerFace() = LivenessInstructionCenterFace;
  const factory LivenessInstruction.holdStill() = LivenessInstructionHoldStill;
  const factory LivenessInstruction.lookAtCamera() = LivenessInstructionLookAtCamera;
  const factory LivenessInstruction.improveLighting() =
      LivenessInstructionImproveLighting;
}

/// One stage of the current attempt, as reported by the processor
/// (data-model.md). The phase indicator's dot count is [totalPhases]; the
/// indicator only ever advances (FR-007) — [index] is never allowed to
/// regress within one attempt.
@freezed
sealed class LivenessPhase with _$LivenessPhase {
  const factory LivenessPhase({
    /// 0-based, ordinal within this attempt.
    required int index,

    /// As reported for this attempt — the phase indicator's dot count.
    required int totalPhases,
    required LivenessInstruction instruction,
  }) = _LivenessPhase;
}
