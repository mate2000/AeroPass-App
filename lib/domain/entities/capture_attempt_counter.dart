import 'package:freezed_annotation/freezed_annotation.dart';

part 'capture_attempt_counter.freezed.dart';

/// The **only** new persisted entity this feature introduces (data-model.md,
/// plan.md's Constitution Check), per Constitution Principle I's amended
/// (v1.3.0) persisted-state allowlist: "a per-step capture-attempt counter
/// (count + last-reset timestamp only — never an image, extraction result,
/// or other capture content), scoped to the specific step it protects."
///
/// A durable, device-level cap on failed capture attempts (FR-009) — MUST
/// survive the app process being killed, which is why this exists as a
/// persisted entity at all rather than in-memory session state (the
/// Clarifications session that drove the constitution amendment: an
/// in-memory counter would let a passenger bypass the cap by force-killing
/// and reopening the app).
@freezed
sealed class CaptureAttemptCounter with _$CaptureAttemptCounter {
  const factory CaptureAttemptCounter({
    /// Failed attempts since [lastResetAt]. Incremented on any `rejected`
    /// outcome (device- or processor-side); NOT incremented on `accepted`.
    required int count,

    /// Set on successful completion of this step (an `accepted` capture)
    /// or explicit routing to retry guidance (research.md §3) — a future,
    /// unrelated enrollment attempt starts with a clean counter rather
    /// than inheriting a stale one.
    required DateTime lastResetAt,
  }) = _CaptureAttemptCounter;
}

/// FR-009: the limit is 3 failed attempts within the current continuous
/// run — a named constant per Constitution Principle X ("no magic
/// values").
const int captureAttemptLimit = 3;
