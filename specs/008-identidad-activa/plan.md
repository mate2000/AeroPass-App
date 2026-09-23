# Implementation Plan: Credential Activated (08 Identidad activa)

**Branch**: `008-identidad-activa` | **Date**: 2026-09-23 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/008-identidad-activa/spec.md`

## Summary

The end of enrollment: a one-time, settled screen that shows a credential the backend has just
issued as active — holder name, masked document, country, issue date and validity — and sends the
passenger on to trips or to their credential. The screen never asks for anything. The existing
verification-progress placeholder requests issuance through a new, issue-only port, writes the
token and validity to secure storage, and hands the confirmed credential over in memory. A sealed
`IssuanceOutcome` makes "active and complete" a property of the type, so a non-active or
incomplete credential can never reach the card (FR-001, FR-010). Because this feature is the first
to write a credential, it also fixes 002's withdrawal to delete it, which the constitution requires
and which would otherwise become a live defect. Screenshot blocking ships on Android now; iOS is
the one tracked gap.

## Technical Context

**Language/Version**: Dart / Flutter, the same pinned stable channel (3.47.5) as 001–006. No change.

**Primary Dependencies**: Reuses `provider`, `go_router`, `freezed`, `json_serializable`,
`flutter_secure_storage`, `dio` (pinned), `intl`, `mocktail`. **No new package dependency.**
Screenshot blocking uses a platform channel in the existing `MainActivity.kt` (research.md §13).

**Storage**: `flutter_secure_storage`, using the two credential keys 001 already reads. This
feature adds their writer and, in 002, their deletion. No new key; Principle I's allowlist is
unchanged (research.md §3). Display fields are memory-only.

**Testing**: `flutter_test`, `mocktail`, golden tests. This feature decides what credential state
the app displays and writes the credential itself, so Principle IV's test-first ordering is
mandatory: contract tests for the issuance port, the router guard, and the withdrawal addendum are
written before their implementations.

**Target Platform**: Android 8.0 / iOS 15.0. Unchanged baseline.

**Project Type**: Mobile app (Flutter, feature-first). Extends the existing project; changes 002's
consent repository, 001's credential service, and 006's verification-progress placeholder.

**Performance Goals**: The screen holds 60fps on the minimum-spec device, per Principle V for
credential screens. Enrollment budgets (≤3 min p90) are measured, not enforced, in happy-path
mode.

**Constraints**: No active credential without backend affirmation, in any build or mode (FR-001).
Screen 08 never opens for a non-active or incomplete credential (FR-010). One-time display without
new persisted state (FR-009). No full document number anywhere on the screen (FR-003, SC-005). No
personal data in events (FR-015).

**Scale/Scope**: One new screen with one rendered state. One new domain port with dev, fake and
real implementations. One new infrastructure port with Android, iOS no-op and fake
implementations. One new in-memory hand-off. Two new placeholder routes, two changed placeholders.
One cross-feature change to 002.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design; design added the 002
withdrawal fix (research.md §6) and the iOS screenshot gap (Complexity Tracking), both reflected
below.*

Evaluated against constitution **v1.4.0**.

| Principle | Status | Notes |
|---|---|---|
| I. Consent and Data Minimization | **PASS** | Only the token and validity window are persisted, both already allowlisted. Display fields stay in memory (research.md §3–§4). Withdrawal now deletes the cached credential, closing the gap this feature would otherwise open (§6). No portrait, so no retained biometric. |
| II. The Verification Provider Is an Adapter | **PASS** | The issuance DTO, endpoint and status codes stay in `lib/data/`; ViewModels see only `IssuanceOutcome` and `ActivatedCredential`. |
| III. Every Flow Has a Failure Path | **PASS, under happy-path mode** | Transport failure retries on the placeholder; non-active and incomplete route to a placeholder until their spec arrives (FR-010). Deferrals are listed by identifier in the spec. |
| IV. Test-First on the Trust Boundary | **PASS (mandatory here)** | Issuance mapping, the storage-before-success rule, the router guard and the withdrawal deletion are all trust-boundary code with contract tests written first. Golden tests for the credential surface, as Principle IV requires. |
| V. Airport-Grade Experience Constraints | **PASS** | No timers; two large actions reachable one-handed. Brightness raising applies to the QR pass, not this card. |
| VI. Accessibility Is a Gate | **PASS** | Masked document announced as words, full name always announced, name wraps rather than silently truncating (research.md §8). |
| VII. Observability Without PII | **PASS** | Four events with enum payloads only (contracts/analytics-events.md). |
| VIII. Architecture | **PASS** | `features/enrollment/credential_activated/`; port under `domain/repositories/`; hand-off under `lib/app/`, like `PendingDocumentController`. |
| IX. Mandated Code Patterns | **PASS** | `Result<T>`, sealed `IssuanceOutcome`, `Command`s for actions, constructor injection. No optimistic state: navigation happens only after `Ok(activated)` and a successful storage write. Offline-first for the credential surface is the credential detail spec's concern; this screen displays freshly issued state. |
| X. Craft Standards | **PASS** | Interface segregation drives the separate issuance port (research.md §1). No new dependency. |
| Security & Compliance | **PARTIAL, justified** | Android blocks capture with `FLAG_SECURE`. iOS protection is deferred under the spec's FR-012 deferral; see Complexity Tracking. |

No unjustified gate failures.

## Project Structure

### Documentation (this feature)

```text
specs/008-identidad-activa/
├── plan.md              # This file
├── research.md          # Phase 0
├── data-model.md        # Phase 1
├── quickstart.md        # Phase 1
├── contracts/           # Phase 1
│   ├── credential-issuance-port.md      # new port
│   ├── screen-capture-guard-port.md     # new port
│   ├── consent-withdrawal-addendum.md   # change to 002
│   └── analytics-events.md              # new events
├── assets/08-identidad-activa.png       # UI reference
└── tasks.md             # Phase 2 (/speckit-tasks, not created here)
```

### Source Code (repository root) — additions and changes

```text
lib/
├── app/
│   ├── router.dart                         # CHANGE: credentialActivated, credentialDetail,
│   │                                       #   credentialNotActive routes; guard (research.md §5)
│   ├── composition_root.dart               # CHANGE: wire issuance repo (dev/real), hand-off,
│   │                                       #   ScreenCaptureGuard; CredentialService into consent repo
│   └── activated_credential_handoff.dart   # NEW: in-memory, one-time hand-off
├── domain/
│   ├── entities/
│   │   ├── activated_credential.dart       # NEW
│   │   ├── issuance_outcome.dart           # NEW: sealed, + IssuanceOutcomeKind
│   │   ├── credential_lifecycle_status.dart # NEW: enum
│   │   └── onward_route.dart               # NEW: enum (analytics payload)
│   └── repositories/
│       ├── credential_issuance_repository.dart  # NEW: abstract port
│       └── analytics_emitter.dart          # CHANGE: 4 new methods
├── data/
│   ├── dev/
│   │   └── dev_credential_issuance_repository.dart   # NEW (research.md §14)
│   ├── models/
│   │   └── credential_issuance_response.dart         # NEW DTO (inbound)
│   └── services/
│       ├── credential_issuance_service.dart          # NEW: pinned dio POST
│       ├── credential_issuance_repository_impl.dart  # NEW: mapping + storage write
│       ├── credential_service.dart         # CHANGE: writeCachedCredential, clearCachedCredential
│       ├── consent_repository_impl.dart    # CHANGE: withdraw() clears the credential (§6)
│       ├── screen_capture_guard.dart       # NEW: port + platform-channel impl
│       └── logging_analytics_emitter.dart  # CHANGE: 4 new methods
├── features/
│   ├── credential/
│   │   └── credential_detail_placeholder_view.dart   # NEW
│   ├── account/
│   │   └── withdrawal_viewmodel.dart       # CHANGE: clear the hand-off
│   ├── trips/
│   │   └── trips_placeholder_view.dart     # CHANGE: passenger-facing FR-008 copy
│   └── enrollment/
│       ├── liveness/
│       │   ├── verification_progress_placeholder_view.dart  # CHANGE: ViewModel-backed
│       │   └── verification_progress_viewmodel.dart         # NEW: requests issuance, hands off
│       └── credential_activated/
│           ├── credential_activated_view.dart               # NEW
│           ├── credential_activated_viewmodel.dart          # NEW
│           ├── credential_not_active_placeholder_view.dart  # NEW: FR-010 destination
│           └── widgets/
│               ├── success_marker.dart          # NEW: turquoise check over navy header
│               └── credential_card.dart         # NEW: name, masked doc, dates, badge, icon
└── l10n/app_es.arb                         # CHANGE: screen 08 and placeholder strings

android/app/src/main/kotlin/com/aeropass/aeropass_app/MainActivity.kt
                                            # CHANGE: aeropass/screen_capture channel (FLAG_SECURE)

test/
├── contract/
│   ├── credential_issuance_repository_contract_test.dart   # NEW: fake AND real
│   └── consent_repository_contract_test.dart               # CHANGE: addendum cases
├── unit/
│   ├── verification_progress_viewmodel_test.dart   # NEW
│   ├── credential_activated_viewmodel_test.dart    # NEW
│   └── withdrawal_viewmodel_test.dart              # CHANGE: hand-off cleared
├── widget/
│   ├── credential_activated_view_test.dart         # NEW: semantics, back gesture, goldens
│   └── router_test.dart                            # CHANGE: guard table of research.md §5
└── fakes/
    ├── fake_credential_issuance_repository.dart    # NEW
    ├── fake_screen_capture_guard.dart              # NEW
    └── fake_analytics_emitter.dart                 # CHANGE: 4 new methods
```

**Structure Decision**: the same feature-first layout 001–006 use. The screen is feature-private
under `features/enrollment/credential_activated/`. The issuance port is domain-owned, per
Principle II. The hand-off lives in `lib/app/` beside `PendingDocumentController` and
`EnrollmentSessionController`, since it spans two routes. `ScreenCaptureGuard` lives in
`data/services/` as platform infrastructure, like `SystemSettingsLauncher`. The credential detail
placeholder gets its own `features/credential/` folder, because the persistent credential surface
is not part of enrollment.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| iOS screen-capture protection is a no-op until happy-path exit | The spec defers FR-012. The port and its call sites exist now, so exit is one iOS implementation, not new wiring (research.md §13) | A build flag cannot express "unimplemented on one platform", and a package adds a dependency Principle X requires justifying for a feature Android handles natively. Tracked in the spec's deferral table; must be closed before the airport pilot |

The change to 002's withdrawal (research.md §6) is not a violation. It is a behavior fix required by
Principle I, with its own regression tests, like 006's cross-feature touches.
