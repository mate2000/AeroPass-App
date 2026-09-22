# Implementation Plan: Liveness Capture (06 Selfie · liveness)

**Branch**: `006-selfie-liveness` | **Date**: 2026-09-22 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/006-selfie-liveness/spec.md`

## Summary

An automatic, hands-free front-camera capture: the passenger is framed in an oval, guided through
processor-reported phases by an instruction that changes and is announced non-visually, and the
capture ends in one of four classifications — success, a specific quality failure, an unclassified
quality failure, or a detected presentation attack — the last two rendered with the byte-identical
generic message, so a passenger can never learn from the screen itself whether they were flagged as
an attack. The device never computes any of this: every phase, progress value, and outcome comes
from repeated `Result`-returning calls to a processor-backed port, mirroring 003's adapter pattern
rather than introducing a new one. This feature also touches three already-shipped pieces of
003/004/005 code — the attempt counter (generalized to serve two independent steps), the
confirmation ViewModel (a new `identityConfirmed` session flag this screen's reachability guard
depends on), and nothing in 005 itself, since its existing guard-free design (004's research.md §1)
turned out to be exactly why this screen needs its own, data-backed guard rather than reusing 005's
step flag.

## Technical Context

**Language/Version**: Dart / Flutter, the same FVM-pinned stable channel (3.47.5) as 001–005 — no
change.

**Primary Dependencies**: Reuses `provider`, `go_router`, `freezed`, `flutter_secure_storage`, `dio`
(pinned), `camera`, `mocktail`. **No new package dependency** — the front-camera capability, the
non-visual announcement mechanism (`SemanticsService`), and haptic feedback
(`HapticFeedback`) are all already available via packages this project already depends on.

**Storage**: `flutter_secure_storage`, extended with one new key pair (the selfie-liveness attempt
counter, count + last-reset timestamp) — already within Constitution Principle I's existing,
generically-worded allowlist entry (research.md §3); no amendment needed, unlike 003's own counter
which required one. No frame, session id, or biometric content is ever persisted (FR-008,
not relaxable in any mode per the Delivery Mode section).

**Testing**: `flutter_test`, `mocktail`. This screen decides a verification outcome's
classification and, via the reachability guard, gates access to a trust-boundary-adjacent flow —
Constitution Principle IV's mandatory test-first ordering applies squarely here, more so than any
screen since 003/004.

**Target Platform**: Android 8.0 / iOS 15.0 — unchanged app-wide baseline. Front-camera capability
specifically (no new permission beyond what 003 already requested — spec.md's Assumptions).

**Project Type**: Mobile app (Flutter, feature-first) — extends the existing project; also modifies
003's `CaptureAttemptCounterRepository` contract and 004's `DocumentConfirmationViewModel` (both
mechanical, behavior-preserving for their own features — research.md §3, §4).

**Performance Goals**: ≥95% of passengers complete this step within 30s at p90 (SC-004); the sample
loop (grab frame → submit → render) must stay imperceptibly fast per iteration since it drives a
visibly-updating progress arc, not just a background poll.

**Constraints**: The device never concludes liveness, genuineness, or matching, in any build or
mode (FR-002, not relaxable — the one requirement the Delivery Mode section calls out twice); frames
and derived biometric data are memory-only and discarded on every exit path (FR-008, not
relaxable); progress and phase never move on a timer or backwards (FR-006/FR-007); the
attack-detection outcome is never visually distinguishable from the unclassified-quality outcome
(FR-010, resolved in Clarifications); touch input never affects the capture (FR-018); this screen's
own attempt counter is independent of 003's (FR-012, resolved in Clarifications).

**Scale/Scope**: One screen (`LivenessCaptureView`) with a handful of rendered states (loading,
running with phase/progress, specific-failure, generic-failure, stalled); two new domain ports
(`LivenessVerificationRepository`, `LivenessCameraService`) each with fake, dev, and real
implementations and contract tests; a generalization of one existing port
(`CaptureAttemptCounterRepository`); a new session-state field (`identityConfirmed`) and its one
write site in 004; one new placeholder route (007's stub).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design — no changes below
between the two passes; design did not surface a new violation.*

Evaluated against constitution **v1.4.0**.

| Principle | Status | Notes |
|---|---|---|
| I. Consent and Data Minimization | **PASS** | The one new persisted item (selfie-liveness attempt counter) is already covered by the existing, generically-worded allowlist entry (research.md §3) — no amendment needed. Frames, sample bytes, and session ids are in-memory only, discarded on every exit path (FR-008), extending the same raw-artifact discipline 003/004 already apply. |
| II. The Verification Provider Is an Adapter | **PASS** | `LivenessVerificationRepository` is the adapter boundary: no processor SDK type, phase code, or outcome code crosses into `LivenessCaptureViewModel` — everything is normalized to `LivenessPhase`/`LivenessInstruction`/`LivenessOutcome` at the service boundary (research.md §1, §7), exactly 003's pattern applied to a repeated-call rather than single-call contract. |
| III. Every Flow Has a Failure Path | **PASS, and this is the principle's own "Happy-Path Development Mode" carve-out's clearest test case** | Full states: loading → running (phase/progress) → success / specific-quality-failure / shared-generic-failure / stalled, each naming its recovery (retry, retry-guidance routing, agent escalation) per FR-009/FR-010/FR-012/FR-013/FR-016. Happy-path mode may stub *which* failures are reachable (the dev fake always succeeds) but the states themselves, and FR-002's "device never decides" rule specifically, are NOT relaxable — the Delivery Mode section calls this out twice for exactly this reason. |
| IV. Test-First on the Trust Boundary | **PASS (mandatory here, not just expected)** | This screen decides a verification outcome's classification (Principle IV's own named example) and gates access via the reachability guard. Contract tests for both new ports, unit tests for the outcome-classification/message-collapsing logic (research.md §7), and the updated attempt-counter contract tests, all written first. |
| V. Airport-Grade Experience Constraints | **PASS** | No auto-advance timer substitutes for real progress (FR-006); the stall timeout (FR-013) is a bound, not a driver, of progress; primary controls (help, back) reachable one-handed, matching 003's capture-screen layout. |
| VI. Accessibility Is a Gate, Not a Polish Pass | **PASS** | FR-005's non-visual instruction channel is this screen's accessibility requirement made structural — a passenger looking at the camera is, by the spec's own words, not reading the screen, so `SemanticsService.announce` + haptic feedback (research.md §6) aren't a polish pass, they're the primary channel for a sighted-but-camera-focused passenger too. The shared generic-failure message (FR-010) is conveyed by text, never color alone, consistent with 003's own error-state discipline. |
| VII. Observability Without PII | **PASS** | contracts/analytics-events.md's events carry phase indices and outcome *categories* (including `attackDetected` as a classification, never as passenger-visible text) — never a frame, a session id's contents, or biometric data. Research.md §8 explains why carrying the full classification locally is still PII-free: it's a security classification of an attempt, not of the passenger. |
| VIII. Architecture Follows the Flutter App Architecture Guide | **PASS** | `features/enrollment/liveness/`; `LivenessVerificationRepository` lives under `domain/repositories/` (shared port, matching 003/004's pattern); `LivenessCameraService` lives under `data/services/` unmodeled as a domain repository, mirroring `CameraCaptureService`'s own precedent exactly (research.md §2's own stated reasoning: hardware-lifecycle infrastructure, not domain-model-owning). |
| IX. Mandated Code Patterns | **PASS** | `Result<T>` from both new repositories (research.md §1's polling design, not a new Stream-based repository-boundary shape); the sample-loop and confirm-style actions exposed as `Command`s; `LivenessOutcome`/`LivenessSampleOutcome`/`LivenessInstruction` are sealed types, not booleans; constructor injection throughout; no optimistic state — the flow only advances to 007 after a real `Ok(...completed(LivenessOutcome.success()))`. |
| X. Craft Standards Apply to Every Line | **PASS** | The attempt-counter generalization (research.md §3) is the Boy Scout Rule applied to a port that would otherwise have been duplicated wholesale — documented as a deliberate cross-feature fix, not smuggled-in refactoring. No new dependency introduced for capabilities (front camera, non-visual announcement) this project already has access to. |

No unresolved gate failures. Two deliberate cross-feature touches (research.md §3, §4) are
mechanical and behavior-preserving for 003/004 — not constitutional deviations, and not entered in
Complexity Tracking for the same reason 004's and 005's own cross-feature touches weren't.

## Project Structure

### Documentation (this feature)

```text
specs/006-selfie-liveness/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md         # Phase 1 output (/speckit-plan command)
├── quickstart.md         # Phase 1 output (/speckit-plan command)
├── contracts/            # Phase 1 output (/speckit-plan command)
│   ├── liveness-verification-port.md       # new port
│   ├── liveness-camera-service-port.md      # new port
│   ├── attempt-counter-port-addendum.md     # change to 003's existing port
│   └── analytics-events.md                  # new events
└── tasks.md              # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root) — additions/changes to the existing project

```text
lib/
├── app/
│   ├── router.dart                              # CHANGE: real LivenessCaptureView at its route;
│   │                                             #   reachability guard (identityConfirmed);
│   │                                             #   new verificationProgress placeholder route
│   ├── composition_root.dart                     # CHANGE: wire LivenessVerificationRepository,
│   │                                             #   LivenessCameraService (dev/real per
│   │                                             #   HappyPathFlags), scope-aware attempt counter
│   └── enrollment_session_controller.dart        # CHANGE: markIdentityConfirmed()
├── domain/
│   ├── entities/
│   │   ├── enrollment_session.dart               # CHANGE: identityConfirmed field
│   │   ├── capture_attempt_counter.dart          # CHANGE: add AttemptCounterScope enum
│   │   ├── liveness_phase.dart                   # NEW: LivenessPhase, LivenessInstruction
│   │   ├── liveness_outcome.dart                 # NEW: LivenessOutcome, LivenessQualityReason
│   │   └── liveness_sample_outcome.dart          # NEW: LivenessSampleOutcome
│   └── repositories/
│       ├── capture_attempt_counter_repository.dart  # CHANGE: scope parameter on all 3 methods
│       └── liveness_verification_repository.dart    # NEW: abstract port
├── data/
│   ├── dev/
│   │   ├── dev_liveness_verification_repository.dart  # NEW: always-succeeds fake (research.md §10)
│   │   └── dev_liveness_camera_service.dart            # NEW
│   ├── models/
│   │   ├── liveness_sample_response.dart          # NEW DTO (inbound)
│   └── services/
│       ├── capture_attempt_counter_service.dart      # CHANGE: scope-derived storage keys
│       ├── capture_attempt_counter_repository_impl.dart  # CHANGE: forwards scope
│       ├── liveness_verification_service.dart         # NEW: dio (pinned) call
│       ├── liveness_verification_repository_impl.dart # NEW
│       └── liveness_camera_service.dart                # NEW: abstract LivenessCameraService +
│                                                        #   FrontCameraLivenessService (one file,
│                                                        #   mirrors camera_capture_service.dart's
│                                                        #   own precedent)
└── features/
    └── enrollment/
        ├── capture/
        │   └── capture_viewmodel.dart              # CHANGE: pass AttemptCounterScope.documentCapture
        │                                           #   at its 3 attempt-counter call sites
        ├── confirmation/
        │   └── document_confirmation_viewmodel.dart # CHANGE: inject EnrollmentSessionController;
        │                                            #   call markIdentityConfirmed() on confirm
        └── liveness/
            ├── liveness_capture_view.dart                    # NEW
            ├── liveness_capture_viewmodel.dart                # NEW
            ├── liveness_capture_view_state.dart               # NEW
            ├── verification_progress_placeholder_view.dart    # NEW: 007 stub
            └── widgets/
                ├── liveness_oval_overlay.dart          # NEW: oval + turquoise progress arc (CustomPainter)
                ├── phase_indicator.dart                 # NEW: the four dots, index-only-advances
                ├── liveness_instruction_banner.dart      # NEW: dynamic instruction text
                └── liveness_failure_message.dart          # NEW: specific vs. shared-generic rendering

test/
├── contract/
│   ├── liveness_verification_repository_contract_test.dart  # NEW: fake AND real
│   ├── liveness_camera_service_contract_test.dart             # NEW: fake AND real
│   └── capture_attempt_counter_repository_contract_test.dart  # CHANGE: scope-parameterized, re-run
│                                                               #   003's 4 cases per scope
├── unit/
│   ├── capture_viewmodel_test.dart                 # CHANGE: update attempt-counter call assertions
│   ├── document_confirmation_viewmodel_test.dart    # CHANGE: assert markIdentityConfirmed() called
│   └── liveness_capture_viewmodel_test.dart          # NEW
├── widget/
│   ├── router_test.dart                              # CHANGE: assert the reachability guard
│   └── liveness_capture_view_test.dart                # NEW
└── fakes/
    ├── fake_capture_attempt_counter_repository.dart    # CHANGE: scope-aware
    ├── fake_liveness_verification_repository.dart       # NEW
    └── fake_liveness_camera_service.dart                 # NEW
```

**Structure Decision**: Same feature-first layout 001–005 already establish. `LivenessVerificationRepository`
lives under `domain/repositories/` (shared port, domain-owned per Principle II);
`LivenessCameraService` lives under `data/services/` as hardware-lifecycle infrastructure, exactly
mirroring `CameraCaptureService`'s own precedent (research.md §2). The capture *screen* is
feature-private under `features/enrollment/liveness/`. The attempt-counter generalization
(research.md §3) and the `identityConfirmed` session flag (research.md §4) are both cross-cutting
changes to already-shipped code, scoped as narrowly as each fix allows.

## Complexity Tracking

*No entries — the Constitution Check passes with no unjustified violations. The two cross-feature
changes (003's attempt-counter port, 004's confirmation ViewModel) are documented in research.md §3
and §4 as scoped, mechanical, behavior-preserving fixes with their own migration obligations and
regression coverage — not constitutional deviations requiring justification.*
