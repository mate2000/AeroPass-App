# Implementation Plan: Selfie Instructions (05 Instrucciones selfie)

**Branch**: `005-instrucciones-selfie` | **Date**: 2026-09-21 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/005-instrucciones-selfie/spec.md`

## Summary

A single, static instructional screen between document confirmation and liveness capture: it
states why a facial capture is needed and the three conditions for a successful one, phrased as
actions rather than prohibitions (CONFLICT-001, resolved in spec.md — no removal instruction for a
religious head covering). It activates no camera, transmits nothing, and gates nothing; a single
"Tomar selfie" action advances to the (stubbed) liveness capture step. This is the first feature
built under the spec's "Happy Path First" delivery mode, which required a constitution amendment
(v1.3.0 → v1.4.0) before this plan could pass its Constitution Check — Principle III's failure-path
mandate now carries a bounded, flag-gated carve-out for exactly the relaxations that mode names.
This plan also closes the release-safety gap that amendment requires for the two happy-path flags
002 and 004 already introduced, since neither currently has any guard against being enabled in a
release build.

## Technical Context

**Language/Version**: Dart / Flutter, the same FVM-pinned stable channel (3.47.5) as 001–004 — no
change.

**Primary Dependencies**: Reuses `provider`, `go_router`, `freezed`. **No new package dependency**
— the framing-preview illustration is a self-contained `CustomPainter` (research.md §3), not a
dashed-border package.

**Storage**: None. This screen introduces no persisted state of any kind (Constitution Principle
I, unaffected).

**Testing**: `flutter_test`, `mocktail`. This screen is not trust-boundary code under Principle IV
(it decides no identity state, credential validity, or verification outcome) — tests are expected
per general craft standards, but their ordering is not constitutionally mandated. The
`HappyPathFlags.assertReleaseSafe` guard this plan introduces *is* worth testing rigorously, since
it is the mechanism the constitution's new carve-out depends on.

**Target Platform**: Android 8.0 / iOS 15.0 — unchanged app-wide baseline. No new platform
capability, no new permission (FR-004; the camera permission from 003 is not re-requested here).

**Project Type**: Mobile app (Flutter, feature-first) — extends the existing project; also
relocates two prior features' dev-flag constants into shared infrastructure (research.md §4) and
extends one shared widget (`StepIndicator`, research.md §2).

**Performance Goals**: SC-002's ≤12s median is a usage-pattern outcome, not a rendering-performance
target — this screen has no async work at all to bound.

**Constraints**: No camera activation, capture, or transmission of any kind (FR-004); confirmation
never gates progress (FR-005); the illustration carries no information not also in text (FR-006);
all content reachable by assistive technology and unclipped at maximum text size (FR-011); the
step indicator shows document-complete/selfie-active (FR-009, via the newly parameterized shared
widget).

**Scale/Scope**: One screen (`SelfieInstructionsView`) with effectively one rendered state (no
loading, no error — nothing asynchronous happens here); one new shared cross-cutting module
(`HappyPathFlags`); one shared-widget extension (`StepIndicator`); four new `AnalyticsEmitter`
methods; one new placeholder route (liveness capture, 006's destination).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design — no changes below
between the two passes; design did not surface a new violation.*

Evaluated against constitution **v1.4.0** (amended this planning session — see the Sync Impact
Report at the top of `.specify/memory/constitution.md`).

| Principle | Status | Notes |
|---|---|---|
| I. Consent and Data Minimization | **PASS** | No new persisted state, no raw artifact of any kind on this screen (no camera). |
| II. The Verification Provider Is an Adapter | **PASS (N/A)** | This screen never calls the verification provider, directly or through a port. |
| III. Every Flow Has a Failure Path | **PASS (under the new Happy-Path Development Mode carve-out, v1.4.0)** | This screen has no async operation to have failure states for in the first place (FR-004 forbids the one thing — a camera/transmission call — that would need them); the carve-out this plan invokes is really for 006's benefit, but this plan is what closes the release-safety mechanism the carve-out requires (research.md §4), so it's recorded here rather than deferred silently. |
| IV. Test-First on the Trust Boundary | **PASS (N/A)** | Decides no identity state, credential validity, or verification outcome — outside the mandated boundary. Tests are still written (craft standard), ordering not mandated. |
| V. Airport-Grade Experience Constraints | **PASS** | Primary action reachable in the bottom half; no auto-advance timer (FR-005 — advice only, passenger-initiated); content available with no network dependency. |
| VI. Accessibility Is a Gate, Not a Polish Pass | **PASS** | FR-011/SC-006: the three conditions and title/subtitle are real, screen-reader-reachable text; the illustration is `ExcludeSemantics`d, never the sole carrier of information (FR-006). |
| VII. Observability Without PII | **PASS** | contracts/analytics-events.md's four events carry only the anonymous session id — the "no personal data" half of FR-010 is the one part of it the new carve-out does NOT relax. |
| VIII. Architecture Follows the Flutter App Architecture Guide | **PASS** | `features/enrollment/selfie/`; `StepIndicator`'s extension stays in the existing shared `core/design/` module; `HappyPathFlags` is `core/`-level cross-cutting infrastructure, not feature-private, since 002/004 already depend on the flags it centralizes. |
| IX. Mandated Code Patterns | **PASS** | `advance` exposed as a `Command0<void>` (research.md §5); no sealed type invented for a choice that doesn't exist (rejected alternative in §5); no optimistic state (there is no state to be optimistic about). |
| X. Craft Standards Apply to Every Line | **PASS** | KISS: no domain entity for static copy (data-model.md), no dashed-border dependency for one shape (research.md §3), no `pendingNavigation` enum for one destination (research.md §5); DRY: reuses `captureConventionalProcessStatement`-style precedent of not re-wording copy that already exists elsewhere when it says the same thing (N/A here — no reused string this time, noted for completeness). |

No unresolved gate failures. The one deviation from the two prior features' pattern (no
reachability guard, research.md §1) is a considered simplification following from this screen
genuinely having no data dependency, not an oversight — recorded in research.md, not Complexity
Tracking, since it removes a mechanism rather than adding an unjustified one.

## Project Structure

### Documentation (this feature)

```text
specs/005-instrucciones-selfie/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md         # Phase 1 output (/speckit-plan command)
├── quickstart.md         # Phase 1 output (/speckit-plan command)
├── contracts/            # Phase 1 output (/speckit-plan command)
│   ├── analytics-events.md
│   └── happy-path-flags-contract.md
└── tasks.md              # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root) — additions/changes to the existing project

```text
lib/
├── core/
│   ├── happy_path_flags.dart                     # NEW: centralizes USE_FAKE_CONSENT_BACKEND
│   │                                              #   (relocated from composition_root.dart) and
│   │                                              #   USE_FAKE_VERIFICATION_BACKEND (relocated),
│   │                                              #   plus assertReleaseSafe() (research.md §4)
│   └── design/
│       └── step_indicator.dart                    # CHANGE: add required currentStep param
│                                                   #   (EnrollmentProgressStep), research.md §2
├── domain/
│   └── repositories/
│       └── analytics_emitter.dart                 # CHANGE: 4 new methods for this screen
├── data/
│   └── services/
│       └── logging_analytics_emitter.dart         # CHANGE: implement the 4 new methods
├── app/
│   ├── composition_root.dart                      # CHANGE: read flags from HappyPathFlags
│   └── router.dart                                # CHANGE: real SelfieInstructionsView at
│                                                   #   AppRoutes.selfieInstructions; new
│                                                   #   AppRoutes.livenessCapture placeholder route
└── features/
    └── enrollment/
        ├── capture/
        │   └── capture_view.dart                  # CHANGE: pass currentStep: .document explicitly
        ├── confirmation/
        │   └── document_confirmation_view.dart    # CHANGE: pass currentStep: .document explicitly
        └── selfie/
            ├── selfie_instructions_view.dart              # NEW
            ├── selfie_instructions_viewmodel.dart          # NEW
            ├── liveness_capture_placeholder_view.dart      # NEW: 006 stub (success destination)
            └── widgets/
                ├── capture_conditions_list.dart             # NEW: the 3 conditions, per data-model.md
                └── selfie_frame_preview.dart                 # NEW: dashed-oval illustration

lib/main.dart                                       # CHANGE: HappyPathFlags.assertReleaseSafe()
                                                     #   before runApp

test/
├── unit/
│   ├── happy_path_flags_test.dart                  # NEW: the 4 cases in contracts/happy-path-
│   │                                               #   flags-contract.md
│   └── selfie_instructions_viewmodel_test.dart      # NEW
├── widget/
│   └── selfie_instructions_view_test.dart          # NEW
└── fakes/
    └── fake_analytics_emitter.dart                  # CHANGE: implement the 4 new methods
```

**Structure Decision**: Same feature-first layout 001–004 already establish. `HappyPathFlags` is
new `core/`-level infrastructure (not feature-private) since it centralizes flags two *other*
features already introduced. `StepIndicator`'s extension stays inside the existing shared
`core/design/` module it was moved to in 004. The selfie *screen* is feature-private under
`features/enrollment/selfie/`.

## Complexity Tracking

*No entries — the Constitution Check passes with no unjustified violations. The two cross-feature
touches (relocating 002/004's flag constants; adding a required parameter to 003/004's
`StepIndicator` call sites) are both mechanical relocations/extensions with no behavior change to
either prior feature, documented in research.md §2 and §4 rather than invented here.*
