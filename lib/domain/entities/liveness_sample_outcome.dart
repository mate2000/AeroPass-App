import 'package:freezed_annotation/freezed_annotation.dart';

import 'liveness_outcome.dart';
import 'liveness_phase.dart';

part 'liveness_sample_outcome.freezed.dart';

/// What `LivenessVerificationRepository.submitSample()` returns per call
/// (data-model.md, research.md §1). Progress (the "64%" badge, FR-006) is
/// derived from `phase.index / phase.totalPhases` — never from elapsed
/// time, satisfying FR-006's "MUST NOT advance on elapsed time alone" by
/// construction: there is no timer anywhere in this calculation.
@freezed
sealed class LivenessSampleOutcome with _$LivenessSampleOutcome {
  /// The capture continues; the view updates phase/progress from [phase].
  const factory LivenessSampleOutcome.inProgress({
    required LivenessPhase phase,
  }) = LivenessSampleOutcomeInProgress;

  /// Terminal — the attempt is over.
  const factory LivenessSampleOutcome.completed({
    required LivenessOutcome outcome,
  }) = LivenessSampleOutcomeCompleted;
}
