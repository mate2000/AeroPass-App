import 'package:freezed_annotation/freezed_annotation.dart';

part 'enrollment_session.freezed.dart';

/// The step an in-progress enrollment has reached. Sealed rather than an
/// enum with no payload today so a later step can grow its own fields
/// without a boolean-flag regression (Constitution Principle IX).
@freezed
sealed class EnrollmentStep with _$EnrollmentStep {
  const factory EnrollmentStep.consent() = ConsentStep;
  const factory EnrollmentStep.documentCapture() = DocumentCaptureStep;
  const factory EnrollmentStep.selfieCapture() = SelfieCaptureStep;
}

/// Tracks progress through enrollment for the resume behavior in FR-008.
///
/// **Not persisted.** Held only for the lifetime of the current app
/// process, per the Constitution Check resolution in plan.md and the
/// spec's Clarifications — it MUST NEVER be written to disk. It does not
/// survive the app process being terminated, a reinstall, or a different
/// device.
@freezed
sealed class EnrollmentSession with _$EnrollmentSession {
  const factory EnrollmentSession({
    /// Exists only to guarantee FR-004's "exactly one session" invariant
    /// under repeated/concurrent activation of the primary action; never
    /// sent to the backend or analytics as a stable identifier.
    required String id,
    required EnrollmentStep stepReached,

    /// In-memory only; used solely to decide UI copy ("continue where you
    /// left off"), not a resumability deadline.
    required DateTime startedAt,

    /// Set only by a successful 004 confirmation (research.md §4). Backs
    /// 006's reachability guard: `stepReached == selfieCapture` alone is
    /// trivially satisfiable by bouncing through 005 without ever
    /// confirming extracted data, since 005 sets that step unconditionally
    /// by design.
    @Default(false) bool identityConfirmed,
  }) = _EnrollmentSession;
}
