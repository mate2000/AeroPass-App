# Implementation Plan: Verification In Progress (07 Validando)

**Branch**: `007-validando` | **Date**: 2026-09-23 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/007-validando/spec.md`

## Summary

The wait between the selfie and the activated credential. The screen observes, and never submits,
a backend verification job identified by the enrollment attempt id already stored in the consent
record, so a capture can never be verified twice and relaunch recovery needs no new stored data.
Two stages come from polling that job; the third is 008's existing issuance call, which is also
the only place the final stage can be drawn complete. Every terminal result goes through one
routing table that decides the destination and which attempt counter, if any, is charged. A
10-second notice, a 30-second hard timeout and a 1.5-second failure display bound the wait without
ever advancing it. The screen replaces 008's placeholder and keeps its hand-off intact.

## Technical Context

**Language/Version**: Dart / Flutter, the same pinned stable channel (3.47.5) as 001–008.

**Primary Dependencies**: Reuses `provider`, `go_router`, `freezed`, `json_serializable`, `dio`
(pinned), `mocktail`. **No new package dependency.** Announcements use `SemanticsService`, as 006
does.

**Storage**: none new. The job is keyed by the existing `EnrollmentAttemptId` (research.md §1).
Reuses the per-step attempt counters already in secure storage.

**Testing**: `flutter_test`, `mocktail`, golden tests. The screen decides which outcome a passenger
sees and whether an identity is declared created, so Principle IV's test-first ordering applies:
the job-port contract tests and the routing-table unit tests come first.

**Target Platform**: Android 8.0 / iOS 15.0. Unchanged.

**Project Type**: Mobile app (Flutter, feature-first). Extends the project; changes 008's
verification view model and placeholder view, the shared `StepIndicator`, and
`EnrollmentSessionController`.

**Performance Goals**: ≥95% of verifications resolve within 10 seconds (SC-001); polling at one
request per second.

**Constraints**: No stage complete before the backend reports it (FR-003); issuance complete only
on `IssuanceActivated` (FR-005); no progress from elapsed time (FR-004); hard timeout at 30 seconds,
inside the 60-second contingency budget (FR-009); attack detection indistinguishable from a face
mismatch (FR-012); no submission of samples from this screen (FR-010).

**Scale/Scope**: One screen with two rendered states; one new domain port with dev, fake and real
implementations; one placeholder route (technical error); two small backward-compatible changes to
shared code.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design; design removed the
constitution amendment the spec anticipated for FR-010 (research.md §1).*

Evaluated against constitution **v1.4.0**.

| Principle | Status | Notes |
|---|---|---|
| I. Consent and Data Minimization | **PASS** | Nothing new persisted; no samples handled on this screen. The job is keyed by the allowlisted consent record's attempt id, so no amendment is needed. |
| II. The Verification Provider Is an Adapter | **PASS** | `VerificationJobRepository` normalizes every provider code at the data boundary; unknown codes become `serviceFailure`. |
| III. Every Flow Has a Failure Path | **PASS** | Every result maps to a destination (contracts/outcome-routing.md). Only relaunch recovery is deferred, and is listed by identifier in the spec. |
| IV. Test-First on the Trust Boundary | **PASS (mandatory here)** | Contract tests for the job port; unit tests for rows R1–R11; widget tests and goldens for the screen. |
| V. Airport-Grade Experience Constraints | **PASS** | Timers bound the wait and never drive progress; the hard timeout and its checkpoint message meet the contingency budget. |
| VI. Accessibility Is a Gate | **PASS** | Stage changes and outcomes announced; failure conveyed by icon and text, not colour alone. |
| VII. Observability Without PII | **PASS** | Enum and integer payloads only; attack detection folded into `biometricRejected`. |
| VIII. Architecture | **PASS** | Port under `domain/repositories/`; screen under `features/enrollment/verification/`; view composition only. |
| IX. Mandated Code Patterns | **PASS** | `Result<T>`, sealed status and outcome types, constructor injection, no optimistic state. |
| X. Craft Standards | **PASS** | One routing table; named duration constants; shared widgets extended with defaults rather than forked. |

No unjustified gate failures.

## Project Structure

### Documentation (this feature)

```text
specs/007-validando/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── verification-job-port.md       # new port
│   ├── outcome-routing.md             # routing and counting table
│   ├── analytics-events.md            # new events
│   └── step-indicator-addendum.md     # change to a shared widget
├── assets/07-validando.png
└── tasks.md                           # /speckit-tasks
```

### Source Code (repository root) — additions and changes

```text
lib/
├── app/
│   ├── router.dart                        # CHANGE: verification route builds the new view and
│   │                                      #   view model; new technicalError route
│   ├── composition_root.dart              # CHANGE: wire VerificationJobRepository (dev/real)
│   └── enrollment_session_controller.dart # CHANGE: returnToDocumentCapture()
├── core/design/
│   └── step_indicator.dart                # CHANGE: currentStepReached, onLightSurface
├── domain/
│   ├── entities/
│   │   ├── verification_stage.dart        # NEW: VerificationStage, StageStatus
│   │   ├── verification_outcome.dart      # NEW: sealed VerificationOutcome, VerificationOutcomeKind
│   │   └── verification_job_status.dart   # NEW: sealed VerificationJobStatus
│   └── repositories/
│       ├── verification_job_repository.dart  # NEW: abstract port
│       └── analytics_emitter.dart            # CHANGE: 6 new methods
├── data/
│   ├── dev/dev_verification_job_repository.dart        # NEW: schedule-driven fake
│   ├── models/verification_job_response.dart           # NEW DTO
│   └── services/
│       ├── verification_job_service.dart               # NEW: pinned dio GET
│       ├── verification_job_repository_impl.dart       # NEW: mapping
│       └── logging_analytics_emitter.dart              # CHANGE: 6 new methods
├── features/
│   ├── technical_error_placeholder_view.dart           # NEW: 011 stub with "Consultar de nuevo"
│   └── enrollment/
│       ├── liveness/
│       │   ├── verification_progress_placeholder_view.dart  # REMOVED (replaced)
│       │   └── verification_progress_viewmodel.dart         # MOVED + REWRITTEN (below)
│       └── verification/
│           ├── verification_progress_view.dart              # NEW: the real screen
│           ├── verification_progress_viewmodel.dart         # polling, stages, timers, routing
│           └── widgets/
│               ├── verification_illustration.dart           # document → face, stage-fraction ring
│               ├── verification_checklist.dart              # three stages, pending/running/passed/failed
│               └── slow_notice.dart                         # "Seguir esperando" + "Ayuda"
└── l10n/app_es.arb                        # CHANGE: screen 07 and technical-error strings

test/
├── contract/verification_job_repository_contract_test.dart  # NEW: fake AND real
├── unit/verification_progress_viewmodel_test.dart           # REWRITTEN: R1–R11 + 008's cases
├── widget/
│   ├── verification_progress_view_test.dart                 # NEW: incl. goldens
│   ├── step_indicator_test.dart                             # NEW: addendum cases
│   └── router_test.dart                                     # CHANGE: technical error route
└── fakes/
    ├── fake_verification_job_repository.dart                # NEW
    └── fake_analytics_emitter.dart                          # CHANGE
```

**Structure Decision**: the feature-first layout 001–008 use. The view model moves from
`liveness/` to a new `verification/` folder, because the screen is no longer a liveness
placeholder. The technical-error placeholder sits beside the other shared placeholders
(retry guidance, agent escalation, help), since several screens will route to it.

**Scope note**: the spec lets outcome routing (FR-008) and the timeout (FR-009) be deferred in
happy-path mode. Both are small once the job port exists, so this plan builds them now; only
relaunch recovery (FR-010) and its events stay deferred. The spec's deferral table is updated to
match during implementation.

## Complexity Tracking

*No entries. The Constitution Check passes with no violations. The changes to 008's view model,
the shared step indicator and the session controller are scoped, backward-compatible touches with
regression tests, like 006's and 008's cross-feature changes.*
