# Implementation Plan: Informed Consent Gate (02 Consentimiento)

**Branch**: `002-consentimiento` | **Date**: 2026-09-21 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/002-consentimiento/spec.md`

## Summary

Replace the `/enrollment/consent` route's current stub (`ConsentPlaceholderView`, from
001-bienvenida) with the real consent gate: a dynamically-fetched, versioned consent text rendered
as a dimmed-background sheet over the welcome screen, a blocking unchecked checkbox, and an
"Acepto y continúo" action that stays disabled — accessibly, not just by color — until checked. On
confirmation, the app durably records consent (backend + a local secure-storage copy) before
advancing to the (still out-of-scope) document-capture route. Declining, the system back gesture,
and dismissal are all wired to the same outcome. Withdrawal is built as a `ConsentRepository`
capability with an offline-safe local status machine, reachable today from a minimal placeholder
account route (the polished "account surface" itself stays out of scope, per spec.md).

## Technical Context

**Language/Version**: Dart / Flutter, the same FVM-pinned stable channel 001-bienvenida already
established (`.fvmrc`, Flutter 3.47.5) — no change.

**Primary Dependencies**: Reuses 001-bienvenida's stack as-is — `provider`, `go_router`, `freezed` +
`json_serializable`, `flutter_secure_storage`, `dio` via the existing `buildPinnedDio` factory,
`flutter_localizations`/`gen-l10n`, `mocktail` for tests. **No new third-party dependency is
introduced** — see research.md §3 and §4 for the two places a new dependency looked tempting
(UUID generation, connectivity detection) and was avoided by reusing existing code or a simpler
design.

**Storage**: `flutter_secure_storage`, read/write from this feature — a local `ConsentRecord` copy
(text version id, enrollment attempt id, confirmed-at timestamp, and a status field covering both
"active" and the withdrawal lifecycle). This is explicitly within the constitution's Principle I
allowlist ("the user's consent record with timestamp and version") and the Security & Compliance
Constraints ("Credential tokens and consent records MUST be stored in platform-backed secure
storage") — see Constitution Check below for why withdrawal status rides on this same record
instead of introducing a new persisted entity.

**Testing**: `flutter_test` (unit + widget), `mocktail` (fake `ConsentRepository` for contract tests
per Principle II/IV — this screen's ViewModel classifies consent-confirmation state, which
Principle IV names directly as trust-boundary code: "consent capture").

**Target Platform**: Android 8.0 (API 26) / iOS 15.0 — the interim baseline 001-bienvenida's
research.md already set for the whole app; not revisited here.

**Project Type**: Mobile app (Flutter, feature-first) — extends the existing project, no new app
scaffold.

**Performance Goals**: Median time at the gate ≤30s (SC-007), within the app-wide ≤3-minute p90
enrollment budget.

**Constraints**: Full consent text and both outcomes (accept/decline) reachable and screen-reader
announced at maximum text size (FR-013, SC-008); advance action's disabled state conveyed to
assistive tech, not by color alone (FR-006); recording MUST NOT be attempted, and the gate MUST say
so plainly, when offline (FR-008, Edge Cases); a withdrawal made offline MUST survive app
termination and deliver once connectivity returns, without the passenger repeating it (FR-016).

**Scale/Scope**: One screen (`ConsentView`, rendered as a dimmed-overlay sheet route), one
`ConsentRepository` port + real/fake implementations, one minimal placeholder route for reaching
withdrawal. No new persisted schema beyond fields added to the single `ConsentRecord`.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| I. Consent and Data Minimization | **PASS** | The local `ConsentRecord` copy (text version id, enrollment attempt id, confirmed-at, status) is exactly "the user's consent record with timestamp and version" the allowlist already names. Withdrawal is modeled as a **status transition on that same record** (`active → withdrawalPending → withdrawn`, with a `withdrawalRequestedAt` field) rather than a second persisted entity — this is a deliberate design choice made *during this planning pass* to avoid repeating 001-bienvenida's Principle I conflict (which required narrowing the spec or amending the constitution). No document/biometric capture occurs on this screen. |
| II. The Verification Provider Is an Adapter | **N/A for this feature** | No OCR/liveness/face-match call here. `ConsentRepository` follows the same adapter shape (fake-testable, no SDK/DTO leakage past `data/`) for consistency, not because Principle II itself governs it. |
| III. Every Flow Has a Failure Path | **PASS** | Two async operations: fetching the current consent text (loading → ready → recoverable-failure "text unavailable, retry" → the gate never silently falls back to a stale copy, per the Edge Cases) and confirming consent (running → recorded → recoverable-failure "couldn't save, try again" per FR-008, no terminal dead end — the passenger can retry or decline). |
| IV. Test-First on the Trust Boundary | **PASS (governs task ordering)** | Consent capture is named explicitly in Principle IV as trust-boundary code. `ConsentViewModel`'s classification of text-load/confirm/decline/offline-blocked state, and `ConsentRepositoryImpl`'s mapping of backend responses, MUST have tests written first, per tasks.md. |
| V. Airport-Grade Experience Constraints | **PASS** | No network-optional requirement here (unlike the welcome screen's QR pass) — this gate's Edge Cases explicitly require blocking offline rather than degrading gracefully, which is the correct, deliberate exception: recording consent is not a display-only concern. |
| VI. Accessibility Is a Gate, Not a Polish Pass | **PASS** | FR-006/FR-013/SC-008 cover contrast-independent disabled-state signaling, full-text screen-reader reachability at max text size, and an accessibility audit gate. |
| VII. Observability Without PII | **PASS** | FR-017's funnel events (presentation, confirmation, decline, abandonment) are keyed to the same in-memory, per-launch `AnalyticsSessionId` 001-bienvenida already established — never the durable `EnrollmentAttemptId`, and never consent text content. |
| VIII. Architecture Follows the Flutter App Architecture Guide | **PASS** | `features/enrollment/consent/` (view + viewmodel + widgets); `ConsentRepository`/`ConsentService` live under `domain/`/`data/` since (like `CredentialRepository`) nothing about them is feature-private. |
| IX. Mandated Code Patterns | **PASS** | `ConsentRepository` methods return `Result<T>`; the confirm/decline/withdraw actions are `Command`s; `ConsentRecordStatus` is a sealed type (active/withdrawalPending/withdrawn), not booleans; constructor injection throughout; no optimistic state — the route only advances past the gate once `recordConsent` has actually returned `Ok`. |
| X. Craft Standards Apply to Every Line | **PASS (enforced at review)** | Comparable scope to 001-bienvenida's welcome feature; no anticipated violations. |

No unresolved gate failures. No Complexity Tracking entries required.

## Project Structure

### Documentation (this feature)

```text
specs/002-consentimiento/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md        # Phase 1 output (/speckit-plan command)
├── quickstart.md        # Phase 1 output (/speckit-plan command)
├── contracts/           # Phase 1 output (/speckit-plan command)
│   ├── consent-repository-port.md
│   └── analytics-events.md
├── assets/
│   └── 02-consentimiento.png
└── tasks.md             # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root) — additions/changes to the existing project

```text
lib/
├── app/
│   └── router.dart                          # CHANGE: consent route's builder + a sheet-style
│                                              #   pageBuilder (see research.md §1); add /account
│                                              #   placeholder route
├── core/
│   └── (reused as-is: result.dart, command.dart, clock.dart, uuid.dart, analytics_session.dart)
├── domain/
│   ├── entities/
│   │   ├── consent_text_version.dart          # NEW: ConsentTextVersion, ConsentPoint
│   │   ├── consent_record.dart                # NEW: ConsentRecord, ConsentRecordStatus (sealed)
│   │   ├── enrollment_attempt_id.dart          # NEW: durable anonymous id (core/uuid.dart-backed)
│   │   └── processing_scope.dart               # NEW: sealed ProcessingScope (identityVerification)
│   └── repositories/
│       └── consent_repository.dart             # NEW: abstract port
├── data/
│   └── services/
│       ├── consent_service.dart                # NEW: dio (pinned) + flutter_secure_storage
│       └── consent_repository_impl.dart        # NEW
└── features/
    ├── enrollment/
    │   ├── consent/
    │   │   ├── consent_view.dart               # NEW: replaces ConsentPlaceholderView at the route
    │   │   ├── consent_viewmodel.dart           # NEW
    │   │   └── widgets/                         # NEW: consent_point_tile, confirmation_checkbox,
    │   │                                        #   primary/secondary action, unavailable_message
    │   └── document_capture_placeholder_view.dart  # NEW: gated destination stub (003, out of scope)
    └── account/
        └── withdrawal_placeholder_view.dart     # NEW: minimal 2-action withdrawal entry point

test/
├── contract/
│   └── consent_repository_contract_test.dart    # NEW: fake AND real implementations
├── unit/
│   └── consent_viewmodel_test.dart              # NEW
└── widget/
    └── consent_view_test.dart                   # NEW
```

**Structure Decision**: Same feature-first layout 001-bienvenida established. `ConsentRepository`
lives under `domain/`/`data/` (shared, not feature-private) because trips-and-pass and later
features will also need to check consent currency. The consent *screen* itself is feature-private
under `features/enrollment/consent/`. `ConsentPlaceholderView` (001-bienvenida) and its route wiring
are replaced, not kept alongside the real implementation.

## Complexity Tracking

*No entries — Constitution Check passes with no unjustified violations. The one place a violation
was nearly introduced (withdrawal as a second persisted entity) was designed around during this
planning pass rather than accepted as a tracked deviation.*
