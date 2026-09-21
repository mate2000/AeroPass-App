import 'package:freezed_annotation/freezed_annotation.dart';

part 'capture_outcome.freezed.dart';

/// The single rejection-reason vocabulary shared by device-side quality
/// assessment and processor-side verification rejection (research.md §4,
/// data-model.md), per FR-008's requirement that a verification rejection
/// "MUST be translated into the same actionable vocabulary" the on-device
/// assessor already uses.
///
/// `QualityRejectionReason` (below) is a `typedef` for this exact same
/// enum rather than a second, independently-defined enum — the two names
/// data-model.md gives each side (`QualityRejectionReason` /
/// `CaptureRejectionReason`) refer to one type, so there is no manual
/// mapping table to keep in sync (Constitution Principle IX/X: a sealed
/// type can't drift the way two hand-synced enums can). The device-side
/// `HeuristicQualityAssessor` never produces [unreadable] — that variant is
/// processor-only, reachable only via `DocumentVerificationRepositoryImpl`'s
/// error-code mapping.
enum CaptureRejectionReason {
  /// Low Laplacian-variance edge strength — the image is too blurred to
  /// read.
  blur,

  /// A large proportion of blown-out/near-maximum-luma pixels — glare or a
  /// reflection obscures the document.
  glare,

  /// The document isn't fully inside the framing guide, or is cropped at
  /// its boundary.
  framing,

  /// The captured shape matches neither accepted document ratio (FR-019):
  /// cédula de ciudadanía nor Colombian passport.
  wrongDocument,

  /// The capture's pixel dimensions are below the minimum floor.
  lowResolution,

  /// Processor-only: whatever the verification provider rejected that the
  /// on-device heuristics did not catch (research.md §4). Never produced
  /// by [QualityAssessment].
  unreadable,
}

/// Alias for [CaptureRejectionReason], used at the device-side assessment
/// boundary (`DocumentQualityAssessor`/`QualityAssessment`) so each side's
/// code reads with the vocabulary name data-model.md gives it, while both
/// names resolve to the one enum research.md §4 requires.
typedef QualityRejectionReason = CaptureRejectionReason;

/// The on-device judgement of whether a captured frame is usable, per
/// data-model.md's Key Entities. Never carries the frame's bytes itself —
/// only the frame's [DocumentQualityAssessor.assess] call site holds those,
/// discarded immediately after (FR-010).
@freezed
sealed class QualityAssessment with _$QualityAssessment {
  /// Passes every on-device check; eligible for submission to
  /// [DocumentVerificationRepository] (FR-006).
  const factory QualityAssessment.usable() = QualityAssessmentUsable;

  /// Failed on-device; MUST NEVER be submitted for verification (FR-006).
  const factory QualityAssessment.rejected({
    required QualityRejectionReason reason,
  }) = QualityAssessmentRejected;
}

/// The result of submitting a [QualityAssessment.usable] capture to the
/// verification processor, per data-model.md.
@freezed
sealed class CaptureOutcome with _$CaptureOutcome {
  /// The processor accepted the capture; the flow advances to data
  /// confirmation (004 stub).
  const factory CaptureOutcome.accepted() = CaptureOutcomeAccepted;

  /// The processor rejected the capture; the passenger is returned to this
  /// screen with [reason] expressed in the same actionable vocabulary as a
  /// device-side rejection (FR-008) — never the processor's own error
  /// text.
  const factory CaptureOutcome.rejected({
    required CaptureRejectionReason reason,
  }) = CaptureOutcomeRejected;
}
