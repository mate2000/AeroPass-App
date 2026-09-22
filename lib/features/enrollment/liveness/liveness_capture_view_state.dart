import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/liveness_outcome.dart';
import '../../../domain/entities/liveness_phase.dart';

export '../../../domain/entities/liveness_outcome.dart';
export '../../../domain/entities/liveness_phase.dart';

part 'liveness_capture_view_state.freezed.dart';

/// `LivenessCaptureViewModel`'s rendered state, per Constitution Principle
/// IX ("sealed types over boolean flags"):
///
/// - [LivenessCaptureViewLoading]: the camera is starting and/or
///   `startSession()` is in flight.
/// - [LivenessCaptureViewRunning]: the sample loop is active. [phase] is the
///   last `inProgress` phase reported; [progress] (`phase.index /
///   phase.totalPhases`, data-model.md) drives the badge/arc — never
///   elapsed time (FR-006).
/// - [LivenessCaptureViewOutcome]: a terminal `LivenessOutcome` was reached.
///   [limitReached] is true only when this was the 3rd non-success outcome
///   in this session, at which point `pendingNavigation` also routes to
///   retry guidance rather than offering an in-place retry.
/// - [LivenessCaptureViewStalled]: FR-013's time limit elapsed with no
///   terminal outcome.
@freezed
sealed class LivenessCaptureViewState with _$LivenessCaptureViewState {
  const factory LivenessCaptureViewState.loading() = LivenessCaptureViewLoading;

  const factory LivenessCaptureViewState.running({
    required LivenessPhase phase,
    required double progress,
  }) = LivenessCaptureViewRunning;

  const factory LivenessCaptureViewState.outcome({
    required LivenessOutcome outcome,
    required bool limitReached,
  }) = LivenessCaptureViewOutcome;

  const factory LivenessCaptureViewState.stalled() = LivenessCaptureViewStalled;
}

/// A one-shot navigation instruction `LivenessCaptureViewModel` raises for
/// `LivenessCaptureView` to act on and then clear via `consumeNavigation()`
/// — mirrors `CaptureNavigationTarget`'s precedent.
enum LivenessNavigationTarget {
  /// FR-001: a deep link or stale back-stack entry straight into this
  /// route, without a confirmed identity record — back to document
  /// capture. Router-level guard is primary (research.md §4); this is the
  /// ViewModel's own defense-in-depth check, mirroring 003's/004's
  /// identical pattern.
  documentCapture,

  /// A successful attempt — advance to verification progress (007 stub).
  verificationProgress,

  /// FR-012: the 3rd failed attempt — routed to retry guidance (009 stub).
  retryGuidance,
}
