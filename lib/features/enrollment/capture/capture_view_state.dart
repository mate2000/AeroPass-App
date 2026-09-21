import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/capture_outcome.dart';

export '../../../domain/entities/capture_outcome.dart'
    show CaptureRejectionReason;

part 'capture_view_state.freezed.dart';

/// `CaptureViewModel`'s rendered state, per Constitution Principle IX
/// ("sealed types over boolean flags"):
///
/// - [CaptureViewChecking]: the consent-currency gate (FR-001) and, once
///   passed, the camera permission/initialization are being resolved.
/// - [CaptureViewPermissionDenied]: the camera permission was denied —
///   [permanent] distinguishes a first denial (offer retry, which may still
///   show the OS dialog again) from a second-or-later one in this screen's
///   lifetime (offer the system-settings route instead, never re-prompting
///   the OS dialog again, per FR-014).
/// - [CaptureViewReady]: the live preview is active. [lastRejectionReason]
///   non-null renders the same screen's error variant (US2: "the same
///   layout with the frame in red and an inline error message" — not a
///   separate screen/state). [offline] renders FR-015's
///   verification-cannot-be-sent-yet messaging.
@freezed
sealed class CaptureViewState with _$CaptureViewState {
  const factory CaptureViewState.checking() = CaptureViewChecking;

  const factory CaptureViewState.permissionDenied({
    required bool permanent,
  }) = CaptureViewPermissionDenied;

  const factory CaptureViewState.ready({
    CaptureRejectionReason? lastRejectionReason,
    @Default(false) bool offline,
  }) = CaptureViewReady;
}

/// A one-shot navigation instruction `CaptureViewModel` raises for
/// `CaptureView` to act on and then clear via `consumeNavigation()` —
/// mirrors the Command-completion-triggers-navigation pattern 001/002
/// already use, generalized here because this screen has more than one
/// navigation destination (consent gate, data confirmation, retry
/// guidance) that aren't all tied to a single Command's completion.
enum CaptureNavigationTarget {
  /// FR-001: no current consent record — back to the consent gate.
  consentGate,

  /// A capture was accepted by verification — advance to data
  /// confirmation (004 stub).
  dataConfirmation,

  /// FR-009: the 3rd failed attempt — routed to retry guidance (009 stub).
  retryGuidance,
}
