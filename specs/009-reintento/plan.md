# Implementation Plan: Verification Retry (09 Reintento)

**Branch**: `009-reintento` | **Date**: 2026-09-23 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/009-reintento/spec.md`

## Summary

The screen a passenger sees when verification could not confirm them, or when a capture step's
attempt limit is reached. It replaces the retry-guidance placeholder that 003, 006 and 007 already
route to. The screen reads the two existing attempt counters and derives one of three states from
them — selfie retry, selfie limit, document limit — so a forged link can never offer a retry past
the limit. Its copy is generic enough to be shared by face mismatch, liveness rejection and attack
detection, never shows an attempt count, and uses 005's face wording. The larger change is the
retry policy itself: 003, 006 and 007 stop resetting counters on success of a capture step or on
reaching the limit, 007 resets both counters on a verification match, and 003 and 006 refuse to
open the camera once their limit is reached. Together these make the limit actually hold.

## Technical Context

**Language/Version**: Dart / Flutter, the same pinned stable channel (3.47.5) as 001–008.

**Primary Dependencies**: Reuses `provider`, `go_router`, `freezed`, `mocktail`. **No new package
dependency.**

**Storage**: none new. Reads the existing per-step attempt counters through
`CaptureAttemptCounterRepository`; their local implementation stands in for FR-006's backend
counter in happy-path mode (research.md §3).

**Testing**: `flutter_test`, `mocktail`, golden tests. The retry policy decides how many paid
validations a passenger may consume and whether a retry is offered, so Principle IV's test-first
ordering applies to the policy changes and the state derivation.

**Target Platform**: Android 8.0 / iOS 15.0. Unchanged.

**Project Type**: Mobile app (Flutter, feature-first). Adds one screen; changes three shipped view
models' counter handling.

**Performance Goals**: none specific; the screen reads two local values on open.

**Constraints**: No retry offered at or past the limit (FR-010); no attempt count shown (FR-008);
no comparison or detection wording (FR-003); a route to a person in every state (FR-009); no red
error styling (FR-002).

**Scale/Scope**: One screen with three states; one view model; three analytics events; three
cross-feature policy changes.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design; no change.*

Evaluated against constitution **v1.4.0**.

| Principle | Status | Notes |
|---|---|---|
| I. Consent and Data Minimization | **PASS** | Nothing new persisted; the counters are already allowlisted. No images or samples on this screen. |
| II. The Verification Provider Is an Adapter | **PASS** | The screen sees only counter values and states; no provider codes reach it. |
| III. Every Flow Has a Failure Path | **PASS** | Every state leads to a person, and the limit states name the checkpoint alternative. Deferrals (tailored advice, backend counter, agent context) are listed by identifier in the spec. |
| IV. Test-First on the Trust Boundary | **PASS (mandatory here)** | The state derivation and the three policy changes are tested before implementation; goldens for the screen. |
| V. Airport-Grade Experience Constraints | **PASS** | Two large actions reachable one-handed; the limit state states what is available right now. |
| VI. Accessibility Is a Gate | **PASS** | Title and body announced on entry; state carried by text, not colour. |
| VII. Observability Without PII | **PASS** | Three events with an enum payload; no event isolates attack detection. |
| VIII. Architecture | **PASS** | Screen under `features/enrollment/retry/`; view composition only. |
| IX. Mandated Code Patterns | **PASS** | Constructor injection, `Result` from the counter port, enum state. |
| X. Craft Standards | **PASS** | The policy lives in one place per step, and the counter port is reused rather than duplicated. |

No unjustified gate failures.

## Project Structure

### Documentation (this feature)

```text
specs/009-reintento/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── retry-guidance-screen.md     # the three states
│   ├── retry-policy-addendum.md     # changes to 003, 006, 007
│   └── analytics-events.md          # new events
├── assets/09-reintento.png
└── tasks.md                         # /speckit-tasks
```

### Source Code (repository root) — additions and changes

```text
lib/
├── app/router.dart                          # CHANGE: retry-guidance route builds the new screen
├── core/design/app_colors.dart              # CHANGE: amber, amberTile
├── domain/
│   ├── entities/retry_guidance_state.dart   # NEW: enum
│   └── repositories/analytics_emitter.dart  # CHANGE: 3 new methods
├── data/services/logging_analytics_emitter.dart  # CHANGE: 3 new methods
├── features/
│   ├── retry_guidance_placeholder_view.dart # REMOVED (replaced)
│   └── enrollment/
│       ├── retry/
│       │   ├── retry_guidance_view.dart     # NEW
│       │   ├── retry_guidance_viewmodel.dart # NEW
│       │   └── widgets/advice_card.dart     # NEW
│       ├── capture/capture_viewmodel.dart   # CHANGE: policy (addendum 003)
│       ├── liveness/liveness_capture_viewmodel.dart  # CHANGE: policy (addendum 006)
│       └── verification/verification_progress_viewmodel.dart  # CHANGE: policy (addendum 007)
└── l10n/app_es.arb                          # CHANGE: screen 09 strings

test/
├── unit/
│   ├── retry_guidance_viewmodel_test.dart   # NEW
│   ├── capture_viewmodel_test.dart          # CHANGE
│   ├── liveness_capture_viewmodel_test.dart # CHANGE
│   └── verification_progress_viewmodel_test.dart  # CHANGE
├── widget/retry_guidance_view_test.dart     # NEW: incl. goldens
└── fakes/fake_analytics_emitter.dart        # CHANGE
```

**Structure Decision**: the feature-first layout 001–008 use. The screen moves from the shared
`features/` placeholder into `features/enrollment/retry/`, since it is now a real enrollment
screen.

## Complexity Tracking

*No entries. The Constitution Check passes with no violations. The changes to 003, 006 and 007 are
required by the clarified retry policy and are specified, with regression tests, in
contracts/retry-policy-addendum.md.*
