# Implementation Plan: Service Failure (11 Error técnico)

**Branch**: `011-error-tecnico` | **Date**: 2026-09-23 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/011-error-tecnico/spec.md`

## Summary

Screen 11 is the screen a passenger reaches when verification could not finish for a reason that is
not theirs. It replaces 007's technical-error placeholder.

007 now decides what it knows about the failure before navigating: a known service failure, a lost
connection, or an undetermined cause. It decides from the transport errors it actually saw, which
the job and issuance repositories now wrap in a domain `TransportFailure`. It hands that to an
in-memory controller. Screen 11 words itself from the class. It never blames the passenger, and it
asserts a cause only when it has one.

The screen shows a status card in journey vocabulary only when a live source answers. It sends a
Sentry error report for known service failures. It says "equipo notificado" only when an alert rule
is confirmed to exist.

Retrying goes to the selfie when the job is dead, and back to 007 otherwise. 007 re-reads the same
job and never submits a duplicate. Retries are paced per session at 0, 15, 30 and 60 seconds.
"Salir" keeps the session. A cold launch within 24 hours resumes into 007.

Along the way this fixes a defect in 010: resume redirects fired on every navigation to welcome.

## Technical Context

**Language/Version**: Dart / Flutter, the same pinned stable channel as 001–010.

**Primary Dependencies**: Reuses `provider`, `go_router`, `freezed`, `json_serializable`, `dio`
(pinned), `sentry_flutter` and `mocktail`. **No new package**. Connectivity is inferred from the
transport error, not from `connectivity_plus` (research.md §2).

**Storage**: none new. The failure record and the retry pacing live in memory. The 24-hour window is
backend-owned, as `resumableUntil` on the job.

**Testing**: `flutter_test`, `mocktail`, golden tests. Test-first on the entry classification, the
retry destinations, the attempt-counter invariance and the launch resume (Principle IV).

**Target Platform**: Android 8.0 / iOS 15.0. Unchanged.

**Project Type**: Mobile app (Flutter, feature-first). One new screen, two new ports, and changes to
007, the job and issuance repositories, the router and `SentryConfig`.

**Performance Goals**: a status read every 15 s while the screen is open. The countdown ticks once a
second while held.

**Constraints**:

- No captured image or sample is persisted (FR-005).
- No attempt is consumed (FR-002).
- No invented status (FR-007).
- No notification claim without an alert (FR-006).
- No asserted cause without evidence (FR-010).
- No red and no amber (FR-001).
- A forward action exists in every state (FR-017).

**Scale/Scope**: One screen with a status card widget, one controller, two ports with dev, fake and
real implementations, five analytics events, a data-layer error mapper, and two router changes: the
resume rule and a defect fix.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

Evaluated against constitution **v1.4.0**.

| Principle | Status | Notes |
|---|---|---|
| I. Consent and Data Minimization | **PASS** | Nothing new persisted. The resume proof is re-read from the backend, never stored (research.md §9). No capture is kept for a retry |
| II. The Verification Provider Is an Adapter | **PASS** | Transport and status codes are normalized in the data layer. An unknown health is a failed read, never a guess |
| III. Every Flow Has a Failure Path | **PASS** | "Reintentar", "Salir" and "Ayuda" exist in every state. The deferrals are listed by identifier in the spec |
| IV. Test-First on the Trust Boundary | **PASS (mandatory here)** | Entry classification, attempt invariance, retry destinations, pacing and launch resume are tested first |
| V. Airport-Grade Experience Constraints | **PASS** | Retries are capped at 60 s, so no passenger at a gate waits minutes. "Salir" always works |
| VI. Accessibility Is a Gate | **PASS** | Health is text, the card is a live region, the held button announces its time, and the title and cause are announced on open |
| VII. Observability Without PII | **PASS, with a gate** | Events carry enums and integers only. This feature's Sentry event is stripped of user and request data. **Gate**: the global `sendDefaultPii = true` must be resolved before release (research.md §7). It predates this feature and is the user's call |
| VIII. Architecture | **PASS** | `dio` stays in `data/`. The ViewModel sees `TransportFailure` only. Ports live under `domain/repositories/` |
| IX. Mandated Code Patterns | **PASS** | `Result<T>`, sealed failure and status types, and an injected `Clock` for every timer |
| X. Craft Standards | **PASS** | No new dependency. Every interval is a named constant |

**Post-design re-check**: no change. The Principle VII gate is recorded in
contracts/operational-alert-port.md and quickstart.md, so it cannot be skipped silently.

## Project Structure

### Documentation (this feature)

```text
specs/011-error-tecnico/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── service-status-port.md          # new port
│   ├── operational-alert-port.md       # new port + Sentry event + release gates
│   ├── transport-failure-addendum.md   # change to 007/008 repositories and 008's contract
│   ├── technical-error-routing.md      # entry classification and exits
│   ├── launch-routing-addendum.md      # resume at launch + 010 defect fix
│   └── analytics-events.md             # new events
├── assets/11-error-tecnico.png
└── tasks.md                            # /speckit-tasks
```

### Source Code (repository root) — additions and changes

```text
lib/
├── app/
│   ├── technical_error_controller.dart      # NEW: record, pacing, resolve
│   ├── enrollment_session_controller.dart   # CHANGE: resumeAfterVerification()
│   ├── router.dart                          # CHANGE: screen 11 route, launch resume, splash-only
│   └── composition_root.dart                # CHANGE: wire controller + two ports
├── core/
│   ├── sentry_config.dart                   # CHANGE: alertRuleConfirmed, beforeSend
│   └── design/app_colors.dart               # CHANGE: slate, slateTile
├── domain/
│   ├── entities/
│   │   ├── transport_failure.dart           # NEW
│   │   ├── service_failure.dart             # NEW: class enum + record
│   │   ├── service_status.dart              # NEW: steps, health, status
│   │   └── verification_job_status.dart     # CHANGE: resumableUntil
│   └── repositories/
│       ├── service_status_repository.dart   # NEW
│       ├── operational_alert_reporter.dart  # NEW
│       └── analytics_emitter.dart           # CHANGE: 5 methods
├── data/
│   ├── dev/
│   │   ├── dev_service_status_repository.dart   # NEW: always "no status"
│   │   └── dev_verification_job_repository.dart # CHANGE: DEV_VERIFICATION_FAILURE
│   ├── models/service_status_response.dart      # NEW DTO
│   └── services/
│       ├── transport_error_mapper.dart          # NEW
│       ├── service_status_service.dart          # NEW: pinned dio
│       ├── service_status_repository_impl.dart  # NEW: strict mapping
│       ├── sentry_operational_alert_reporter.dart # NEW (+ no-op)
│       ├── verification_job_repository_impl.dart  # CHANGE: wrap errors, resumableUntil
│       ├── credential_issuance_repository_impl.dart # CHANGE: wrap errors
│       └── logging_analytics_emitter.dart       # CHANGE
├── features/
│   ├── technical_error_placeholder_view.dart    # REMOVED (replaced)
│   └── enrollment/
│       ├── verification/verification_progress_viewmodel.dart  # CHANGE: classify + record + resolve
│       └── technical_error/
│           ├── technical_error_view.dart        # NEW
│           ├── technical_error_viewmodel.dart   # NEW
│           └── widgets/service_status_card.dart # NEW
└── l10n/app_es.arb                              # CHANGE

test/
├── contract/
│   ├── service_status_repository_contract_test.dart       # NEW
│   ├── verification_job_repository_contract_test.dart     # CHANGE
│   └── credential_issuance_repository_contract_test.dart  # CHANGE: wrapping + idempotency
├── unit/
│   ├── technical_error_viewmodel_test.dart   # NEW
│   ├── technical_error_controller_test.dart  # NEW
│   ├── sentry_before_send_test.dart          # NEW
│   └── verification_progress_viewmodel_test.dart # CHANGE: entry classification
├── widget/
│   ├── technical_error_view_test.dart        # NEW: incl. goldens
│   └── router_test.dart                      # CHANGE: launch addendum + regressions
└── fakes/
    ├── fake_service_status_repository.dart   # NEW
    ├── fake_operational_alert_reporter.dart  # NEW
    └── fake_analytics_emitter.dart           # CHANGE
```

**Structure Decision**: the feature-first layout of 001–010. Screen 11 moves from a shared
placeholder into `features/enrollment/technical_error/`. The controller is app-layer, because both
007 and 11 use it, as with 008's hand-off.

## Complexity Tracking

*No violations. Three cross-feature changes are specified with regression tests: 007's
classification, the repositories' error wrapping, and the router's splash-only resume, which fixes a
defect in 010. The Principle VII item is a pre-existing configuration gate, not a violation
introduced here.*
