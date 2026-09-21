# Implementation Plan: Welcome & Enrollment Entry Point (01 Bienvenida)

**Branch**: `001-bienvenida` | **Date**: 2026-09-21 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-bienvenida/spec.md`

## Summary

The app's entry point: on launch, silently resolve credential status behind a brief branded splash,
then either route an already-valid passenger straight to their trips surface (never showing this
screen) or present the welcome screen — value proposition, the three enrollment steps, and a single
primary action into consent, plus a secondary path for account recovery on a new device. Built as a
single Flutter `WelcomeView` + `WelcomeViewModel` over a shared `CredentialRepository` port, following
the app's View → ViewModel → Repository → Service layering. No capture, no persistence beyond the
credential's own cached status; enrollment-progress resume and the analytics session id are
in-memory/process-lifetime only, per the Constitution Check resolution below.

## Technical Context

**Language/Version**: Dart / Flutter, stable channel. Exact SDK patch is pinned via FVM
(`.fvmrc`) at repo scaffolding time rather than hard-coded here — see research.md.

**Primary Dependencies**: `provider` (ChangeNotifier ViewModels + DI, per Flutter's official
app-architecture guide referenced in Constitution Principle VIII); `go_router` (routing, incl. deep
link handling); `freezed` + `json_serializable` (generated immutable models, `copyWith`, sealed
`Result<T>` and status types per Principle IX); `flutter_localizations` + Flutter `gen-l10n` (FR-016
localization layer); `flutter_secure_storage` (read of the locally cached credential, Keystore/
Keychain-backed per the Security & Compliance Constraints); `dio` with certificate pinning
(credential-status network call, fail-closed on pinning failure).

**Storage**: `flutter_secure_storage`, read-only from this feature (cached credential token +
validity window + status, written by the credential-issuance feature, not this one). No other
persisted storage: enrollment-progress resume and the analytics session id are in-memory only for
the lifetime of the app process (see Constitution Check).

**Testing**: `flutter_test` (unit + widget), `mocktail` (fake `CredentialRepository` for contract
tests per Principle II/IV — no provider SDK or network involved in the fake path).

**Target Platform**: Android and iOS. Interim minimum-spec baseline — Android 8.0 (API 26) / iOS
15.0 — pending the product team's formal minimum-spec device publication (spec Assumption: "defined
elsewhere"); see research.md for rationale and the follow-up to confirm before release.

**Project Type**: Mobile app (Flutter, feature-first, single app targeting Android + iOS)

**Performance Goals**: Splash-to-interactive ≤2s p90 cold launch on the minimum-spec device (SC-003);
enrolled-passenger launch-to-trips ≤3s (SC-004).

**Constraints**: Screen MUST render and remain usable fully offline (FR-009); primary action reachable
one-handed without scrolling on the minimum supported screen size (FR-015); WCAG AA contrast, full
screen-reader traversal, no color-only state signaling (FR-014); zero camera permission requests and
zero outbound personal data before consent (FR-003); credential-status network call MUST use TLS with
certificate pinning and fail closed on a pinning failure (Security & Compliance Constraints).

**Scale/Scope**: One screen (`WelcomeView`), one `WelcomeViewModel`, one shared `CredentialRepository`
port + fake/real `CredentialService` implementations, one analytics event emitter. No new persisted
schema.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| I. Consent and Data Minimization | **PASS** (post-narrowing) | Originally FAILED: FR-008 (resume) and FR-013 (analytics session id) as first drafted required persisting data outside Principle I's allowlist, which the constitution says cannot be waived by plan-level justification. Resolved by narrowing the spec (see spec.md Clarifications, 2026-09-21, plan-driven entry): resume and the analytics session id are now in-memory/process-lifetime only — never written to disk — so nothing new is added to the persisted-state list. No camera/document/biometric capture occurs on this screen at all. |
| II. The Verification Provider Is an Adapter | **N/A for this feature** | This screen makes no OCR/liveness/face-match calls. The only external call is credential-status, behind `CredentialRepository`, which is itself adapter-shaped (fake-testable, no SDK types in domain/presentation) in the same spirit. |
| III. Every Flow Has a Failure Path | **PASS** | The launch credential check and the primary-action transition are the feature's two async operations. Each defines loading (splash / command running), success (route to trips / advance to consent), recoverable failure (unreachable backend → last-known-state banner, FR-007), and terminal framing (revoked/expired → explained re-enrollment, FR-006). No snackbar/toast is used for these. |
| IV. Test-First on the Trust Boundary | **PASS (governs implementation order)** | This screen's `WelcomeViewModel` classifies credential validity (valid / expired-revoked / unreachable) — a trust-boundary decision. Unit tests for each state transition, a contract test for `CredentialRepository` (fake vs. real, same suite), and widget tests for empty/loading/error/populated states are required and MUST be written first, per tasks.md ordering. |
| V. Airport-Grade Experience Constraints | **PASS** | FR-009 (offline render), FR-015 (one-handed reach), SC-003 (cold start ≤2s). Brightness-raise and 60fps hold are scoped to capture/credential/QR screens by the constitution, not this screen — N/A here. |
| VI. Accessibility Is a Gate, Not a Polish Pass | **PASS** | FR-014 covers AA contrast, semantic labels, no color-only signaling; widget tests include a screen-reader traversal check. |
| VII. Observability Without PII | **PASS (post-narrowing)** | FR-013's anonymous session id is generated fresh per launch, in-memory only, sufficient to correlate this screen's own funnel events. Cross-launch "repeat use across flights" is computed elsewhere (backend, credential-linked) once enrolled — explicitly out of scope for this pre-enrollment screen, so no conflict with Principle VII's funnel-measurability requirement, which applies to the product's funnel as a whole, not to this single unauthenticated screen in isolation. |
| VIII. Architecture Follows the Flutter App Architecture Guide | **PASS** | See Project Structure below: View → ViewModel → Repository → Service, feature-first (`features/enrollment/welcome`), shared design tokens in an untouchable common module. |
| IX. Mandated Code Patterns | **PASS** | `CredentialRepository.getStatus()` returns `Result<CredentialStatus>`; the primary action is exposed as a `Command` carrying running/completed/error state (structurally guaranteeing Principle III's states); `CredentialStatus` is a sealed type (`Valid`, `ExpiredOrRevoked`, `Unreachable`), not booleans; constructor injection throughout; no optimistic state — the trips-surface route and the "valid" framing only render once `CredentialRepository` has confirmed status. |
| X. Craft Standards Apply to Every Line | **PASS (enforced at review, not plan time)** | No violations anticipated at this scope (one view, one viewmodel, one repository/service pair); file-size and function-length budgets are well within reach for a single-screen feature. |

No unresolved gate failures. No Complexity Tracking entries required.

## Project Structure

### Documentation (this feature)

```text
specs/001-bienvenida/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md        # Phase 1 output (/speckit-plan command)
├── quickstart.md        # Phase 1 output (/speckit-plan command)
├── contracts/           # Phase 1 output (/speckit-plan command)
│   ├── credential-status-port.md
│   └── analytics-events.md
└── tasks.md             # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
lib/
├── app/
│   ├── app.dart                        # MaterialApp, theme, localization wiring
│   ├── router.dart                     # go_router config incl. deep-link handling
│   └── composition_root.dart           # DI wiring: constructs services/repositories, injects into ViewModels
├── core/
│   ├── result.dart                     # sealed Result<T> (Ok/Error)
│   ├── command.dart                    # Command<T>: running/completed/error state wrapper
│   └── design/                         # shared design tokens & primitives (Principle VIII: common module)
├── domain/
│   ├── entities/
│   │   └── credential_status.dart      # sealed CredentialStatus: Valid, ExpiredOrRevoked, Unreachable
│   └── repositories/
│       └── credential_repository.dart  # abstract port consumed by ViewModels
├── data/
│   ├── services/
│   │   ├── credential_service.dart     # dio + certificate pinning + flutter_secure_storage read
│   │   └── credential_repository_impl.dart
│   └── models/                         # backend DTOs; never imported outside data/
└── features/
    └── enrollment/
        └── welcome/
            ├── welcome_view.dart        # WelcomeView: composition only
            ├── welcome_viewmodel.dart   # WelcomeViewModel: no Flutter imports, testable headless
            └── widgets/                 # named widget classes (no _buildX methods)

test/
├── contract/
│   └── credential_repository_contract_test.dart  # run against fake AND real implementations
├── unit/
│   └── welcome_viewmodel_test.dart
└── widget/
    └── welcome_view_test.dart          # empty/loading/error/populated states
```

**Structure Decision**: Feature-first layout per Constitution Principle VIII. This feature owns only
`features/enrollment/welcome/` (view + viewmodel + widgets); `CredentialRepository` lives under
`domain/`/`data/` because it is a shared domain port other features (trips-and-pass, and later
credential issuance) will also depend on — repositories are not feature-private. Shared design tokens
live in `core/design/`, which no feature may write to.

## Complexity Tracking

*No entries — Constitution Check passes with no unjustified violations after the spec was narrowed
to remove the Principle I conflict.*
