# Research: Liveness Capture (06 Selfie · liveness)

No `NEEDS CLARIFICATION` markers remain — the spec's own two were resolved from precedent, and the
one that surfaced in `/speckit-clarify` (the generic-message cover) is a spec-level decision, not a
technical unknown. What follows are the technical design decisions needed to implement this
feature, several of which touch already-shipped 003/004/005 code — each is called out individually,
per this project's established practice.

## §1 — FR-002's security boundary: a polling `Result<T>` port, not a Dart `Stream`

**Decision**: `LivenessVerificationRepository` exposes two `Future<Result<T>>` methods — `startSession()`
and `submitSample(sessionId, frameBytes)` — called repeatedly by `LivenessCaptureViewModel` in a
loop (grab a frame → submit → read the response's phase/progress/outcome → repeat) until a terminal
`LivenessOutcome` is returned, the attempt limit is hit, or the stall timeout elapses. Not a `Stream`-
based, bidirectional protocol.

**Rationale**: FR-002 is the whole reason this feature exists in its current shape — "the app MUST
NOT conclude that a capture is live, genuine, or matching, in any build or mode." A `Result`-returning,
repeatedly-called method makes this structural rather than a matter of discipline: every single call
site that could theoretically inspect a frame and "decide" instead just relays whatever the last
`Result` said, exactly mirroring how `DocumentVerificationRepository.submit()` already works (003) —
the ViewModel never branches on frame *content*, only on the *port's returned classification*. A
`Stream<LivenessSignal>` port would work too, but it's a genuinely new repository-boundary shape this
codebase doesn't otherwise use (every existing port is request/response), and Constitution Principle
X's KISS guidance favors the mechanism this project already knows over a novel one for a single call
site. Repeated polling also composes cleanly with FR-013's stall timeout (a plain timer around the
loop) and FR-014's interruption handling (stop looping, discard the in-flight frame) without needing
stream-cancellation semantics.

**Alternatives considered**:
- *A `Stream<LivenessSignal>` the repository returns once, carrying every phase/progress/outcome
  update*: rejected — see above; also harder to fake deterministically in widget tests than a
  scripted sequence of `Future` returns.
- *An on-device model deciding "is this a live face" locally, with the processor only used for a
  final confirmation*: rejected outright — this is precisely the shape FR-002 forbids ("a
  development build that decides liveness on the device teaches the codebase the wrong shape, and
  that shape is the vulnerability").

## §2 — A new front-camera service, not an extension of `CameraCaptureService`

**Decision**: a new `LivenessCameraService` port (front lens, continuous frame sampling) — not a
parameter added to 003's `CameraCaptureService` (rear lens, single manual `capture()` call per
activation).

**Rationale**: the two have fundamentally different interaction shapes — 003's is "wait for an
explicit tap, then take exactly one photo"; this screen's is "sample frames automatically and
repeatedly for as long as the attempt runs, with no passenger action." Interface segregation
(Constitution Principle X: "a consumer depends on the narrowest port that covers its need") argues
against widening `CameraCaptureService`'s contract to cover both shapes — `CaptureViewModel` would
gain methods it never calls, and this screen would gain a `capture()` method that doesn't fit its
automatic model. Both wrap the same underlying `camera` plugin (already a dependency, front-lens
selection and `startImageStream` are both capabilities it already exposes and that 003's real
implementation already uses for the rear lens), so no new package dependency either way.

**Alternatives considered**:
- *Add a `lensDirection` parameter and a `sampleFrames()` stream method to `CameraCaptureService`*:
  rejected per interface segregation above.
- *Reuse `CameraCaptureService` unmodified and adapt around it*: rejected — its `capture()` method
  is a poor fit for "grab whatever the current preview frame is, repeatedly, with no user action."

## §3 — Generalizing the capture-attempt counter (`AttemptCounterScope`) — touches 003

**Decision**: `CaptureAttemptCounterRepository`'s three methods (`read`/`increment`/`reset`) each
gain a required `AttemptCounterScope scope` parameter (`documentCapture` | `selfieLiveness`).
`CaptureAttemptCounterService` maps each scope to its own pair of secure-storage keys internally.
`CaptureViewModel` (003) updates its three call sites to pass `AttemptCounterScope.documentCapture`
explicitly; `LivenessCaptureViewModel` uses `AttemptCounterScope.selfieLiveness`. The existing
`CaptureAttemptCounter` entity and the `captureAttemptLimit = 3` constant are reused unchanged — the
Clarifications session confirmed this screen's limit is also 3, so no second constant is needed.

**Rationale**: the Clarifications session resolved that this screen's attempt limit is *separate*
from document capture's, and Constitution Principle I's allowlist entry is already worded generically
("a per-step capture-attempt counter... scoped to the specific step it protects") — it was never
written to name 003 specifically. The two counters are the same *knowledge* (a durable, per-step,
count+last-reset-timestamp cap), so Principle X's DRY guidance argues against copy-pasting the whole
service/repository/impl a second time with only the storage-key strings changed — that would be the
literal duplication DRY warns against, not two things that "merely look alike." A scope *parameter*
was chosen over two separate provider-registered instances specifically because `provider`'s DI
resolves by *type*: `context.read<CaptureAttemptCounterRepository>()` cannot distinguish "the
document one" from "the selfie one" if both are registered as the same type, so scoping has to live
in the call, not in which instance gets injected.

**Consequence (cross-feature impact)**: this modifies 003's already-shipped `CaptureViewModel` (its
three attempt-counter call sites) and its test suite (`FakeCaptureAttemptCounterRepository`,
`capture_attempt_counter_repository_contract_test.dart`). Mechanical and behavior-preserving for
003 — every call site simply now says which step it means — but re-run as regression coverage
regardless, per this project's established practice (004/005 did the same for their own
cross-feature touches).

**Alternatives considered**:
- *Two distinct port types sharing a common base implementation class*: rejected — still duplicates
  the abstract interface declaration for no behavioral benefit over a parameter.
- *A single global counter shared by both steps*: rejected outright — the Clarifications session
  explicitly resolved these as separate budgets; conflating them would let a document-capture retry
  spend down the selfie step's budget and vice versa, which is not what either spec asked for.

## §4 — The reachability guard needs new session state — touches 004

**Decision**: `EnrollmentSession` gains a new field, `identityConfirmed` (`bool`, `@Default(false)`).
`EnrollmentSessionController` gains `markIdentityConfirmed()`. `DocumentConfirmationViewModel` (004)
is now also constructor-injected with `EnrollmentSessionController` and calls
`markIdentityConfirmed()` in `_confirm()`'s success branch, alongside its existing
`_pendingDocumentController.clear()`. The router's redirect for this screen's route checks
`EnrollmentSessionController.current?.identityConfirmed == true`; if not, it redirects to
`AppRoutes.documentCapture` (the direct fix: redo 003/004).

**Rationale**: FR-001 requires this capture not open "without... a confirmed identity record from
screen 004" — a real guard, not a formality, the same category of requirement 003's consent-currency
guard and 004's `PendingDocumentController`-empty guard already enforce. The obvious-looking
shortcut — checking `EnrollmentSessionController.current?.stepReached == EnrollmentStep.selfieCapture()`
— turns out **not** to prove it: 005's own `SelfieInstructionsViewModel` sets that same step
unconditionally on load, with no data dependency of its own (004's research.md §1 deliberately gave
005 no reachability guard, since it needs no data). A deep link straight to 006 would bounce through
005 (which asks for nothing and sets the flag anyway) and land back on 006 having proven nothing.
`PendingDocumentController` itself can't be reused for this guard either — 004 deliberately clears it
on a successful confirm, so it's already empty by the time a legitimate passenger reaches 006. A
dedicated, minimal boolean, set only at the one point a confirmation actually succeeded, is the
smallest fix that's actually load-bearing. It carries no identity data itself (Constitution
Principle I is unaffected — this is in-memory-only session-progress state, the same category
`stepReached` already is, not a new persisted-state category), so no constitution change is needed,
unlike §3.

**Consequence (cross-feature impact)**: this modifies 004's already-shipped `DocumentConfirmationViewModel`
(new constructor dependency, one new call in `_confirm()`) and its test suite/composition root
wiring. Mechanical and additive — no existing 004 behavior changes.

**Alternatives considered**:
- *Redirect target: back to `documentConfirmation` (004) instead of `documentCapture` (003)*:
  rejected — 004's own guard-equivalent (`PendingDocumentController` empty) would immediately bounce
  such a passenger onward to 003 anyway; sending them to 003 directly is the same outcome with one
  fewer redirect hop.
- *Persist `identityConfirmed` (or the whole record) so a killed-and-relaunched app remembers it*:
  rejected — out of scope and unnecessary: an app-process kill already loses `EnrollmentSessionController`'s
  entire state (it's documented as "never persisted... a fresh instance is created every app
  launch"), so 003's and 004's own guards already send a relaunched passenger back to redo those
  steps in that case. This screen's guard is consistent with that existing, accepted limitation, not
  a new one.

## §5 — Screenshot/recording blocking: confirmed not applied (spec Clarifications)

No new decision here — spec.md's Clarifications already resolved this, matching 003/004's identical
precedent exactly. Recorded here only so `/speckit-tasks` has a single place that confirms every
"screenshot blocking" question this feature raised is closed, not partially answered.

## §6 — The non-visual instruction channel (FR-005): no new dependency

**Decision**: each instruction change calls `SemanticsService.announce(text, TextDirection.ltr)`
(`package:flutter/semantics.dart`) — audible via the platform screen reader (TalkBack/VoiceOver) —
and `HapticFeedback.selectionClick()` (`package:flutter/services.dart`) on the same change. Both are
part of the Flutter SDK already used elsewhere in this app; no new package.

**Rationale**: FR-005 requires "at least one" non-visual channel; providing both costs nothing extra
and directly serves SC-009 (a passenger relying on non-visual channels can complete a capture
unaided). `SemanticsService.announce` is the standard Flutter mechanism for a one-off spoken
announcement outside of focus-driven semantics — the same tool this codebase would reach for
regardless, since Constitution Principle VI already mandates accessible, non-color-alone signaling
throughout.

## §7 — The `LivenessOutcome` taxonomy and the shared generic message (spec Clarifications)

**Decision**: `LivenessOutcome` is sealed with four variants: `.success()`,
`.qualityFailure({required LivenessQualityReason reason})`, `.unclassifiedFailure()`, and
`.attackDetected()`. `LivenessQualityReason` is a small, fixed, app-owned enum (`tooDark`,
`faceOutOfFrame`, `movementDetected`, `multipleFacesDetected`, `faceObstructed`) — the real adapter
maps whatever code the processor returns onto this vocabulary, falling back to `.unclassifiedFailure()`
for anything it doesn't recognize (mirroring 003's `_mapReason` "fall back rather than throw"
discipline). The view renders exactly one generic failure message for *both* `.unclassifiedFailure()`
and `.attackDetected()` — same string, same widget, same styling — per the Clarifications
resolution; only `.qualityFailure(reason)` renders per-reason specific guidance.

**Rationale**: this is the direct implementation of the Clarifications answer — attack detection
must share its cover with a *real*, legitimately-reachable outcome, or the generic message's mere
presence becomes the tell. Falling back to `.unclassifiedFailure()` for any processor reason code
the adapter's mapping doesn't recognize means that outcome is genuinely reachable in production (an
unfamiliar or new processor error code), not a synthetic case invented only to give attack detection
cover.

## §8 — Audit trail vs. local analytics (SC-007 vs. FR-017)

**Decision**: SC-007 ("100% of capture outcomes are recorded with their specific classification in
the audit trail") is satisfied server-side — every `submitSample` call already carries the full
classification in the processor's response, which the backend that fronts the real processor is
responsible for logging; this app does not build a second, separate audit-log mechanism. Locally,
`AnalyticsEmitter`'s outcome event (FR-017) *does* carry the full classification (including
`attackDetected` specifically, as an enum value, never as passenger-visible text) — this is
operational telemetry a security/fraud team would need, analogous to how 003's
`captureVerificationRejected` event already carries `CaptureRejectionReason` — and is not "personal
data" in the sense FR-017/Principle VII forbid (it identifies a security classification of an
attempt, not the passenger).

**Rationale**: building a bespoke on-device "audit trail" distinct from both the backend's own
request log and the existing analytics pipeline would be a new persistence/reporting mechanism this
spec never asked for and the constitution doesn't sanction (no new persisted state is listed as
needed). Reusing the existing `AnalyticsEmitter` contract for the *local* half of this obligation,
and treating the backend's own log as authoritative for the *durable* half, is the smallest design
that satisfies SC-007 without inventing new infrastructure.

## §9 — Stall timeout and interruption handling: mirrors 003

**Decision**: a single `Timer` (45s per spec.md's Assumption) started when the capture attempt
begins, cancelled on any terminal outcome, firing FR-013's "ends with an explanation" state if
nothing terminal has happened by then. `WidgetsBindingObserver` (mirroring 003's `CaptureView`
exactly) stops the camera and discards all held frames on
`AppLifecycleState.paused`/`inactive`/`hidden`, satisfying FR-014's backgrounding/lock/call-seizure
cases uniformly — the OS delivers the same lifecycle callback regardless of which of those caused it,
so this screen doesn't need to distinguish among them any more than 003 did.

**Rationale**: both mechanisms already exist in this codebase for the analogous problem (003's own
capture lifecycle); reusing the same shape is the smallest, most consistent implementation and keeps
this screen's tests structurally comparable to 003's own lifecycle tests.

## §10 — Happy-path fake processor: reuses the existing flag, no new one

**Decision**: `DevLivenessVerificationRepository` and `DevLivenessCameraService` (fakes that always
progress through a scripted phase sequence and terminate in `.success()`) are wired behind the
*existing* `HappyPathFlags.useFakeVerificationBackend` flag (005's `HappyPathFlags` module) — not a
new, screen-specific flag.

**Rationale**: the spec's own Delivery Mode section frames this as "the liveness decision may be
served by a fake processor" under the *same* happy-path umbrella 004 already uses that flag for
("no verification backend deployed yet"). A liveness-specific flag would fragment the "is any
verification backend faked right now" question across two separately-toggled flags for no
operational benefit — `USE_FAKE_VERIFICATION_BACKEND=true` already means exactly "nothing downstream
of document capture has a real backend yet," and liveness is downstream of document capture.
`HappyPathFlags.assertReleaseSafe()` (v1.4.0's release-safety mechanism) already covers this flag —
no change needed there.

**Alternatives considered**:
- *A dedicated `USE_FAKE_LIVENESS_BACKEND` flag*: rejected per the reasoning above — needless
  fragmentation of one on/off question into two flags that would always be set together in practice.
