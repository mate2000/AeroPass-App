# Implementation Plan: Trips Home (12 Mis viajes)

**Branch**: `012-mis-viajes` | **Date**: 2026-09-23 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/012-mis-viajes/spec.md`

## Summary

This is the enrolled passenger's home. It replaces the trips placeholder inside a new three-tab
shell: Viajes, Identidad, and Perfil. Perfil carries the consent-withdrawal entry the constitution
requires.

**The credential strip** reads a new `CredentialSummary`: holder, masked number, state, and whether
the backend confirmed it just now. "ACTIVA" is rendered only when the credential is active and
confirmed. The holder name and last four digits are stored with the token, which the constitution's
display-only allowance permits, so the strip also works offline.

**The trip card** reads a new trip port. It shows domestic segments only and 90 days of history, and
it keeps departure times in the airport's own clock. The card refreshes on open, on return to the
app, and every 60 seconds. When a refresh fails, it keeps the last snapshot in memory and marks it
stale. It never writes trips to disk.

**"Iniciar viaje"** is enabled only when three things hold: the credential is confirmed active, the
flight is not cancelled, and the departure is less than 24 hours away. Otherwise the card states the
reason. The action leads to a placeholder for 013 and never to a pass.

## Technical Context

**Language/Version**: Dart / Flutter, the same pinned stable channel as 001–011.

**Primary Dependencies**: Reuses `provider`, `go_router` (adds a `ShellRoute`), `freezed`,
`json_serializable`, `dio` (pinned), `flutter_secure_storage`, `intl` and `mocktail`. **No new
package**. Departure times carry their UTC offset from the backend, so no time zone package is
needed (research.md §5).

**Storage**: two new secure-storage keys, the holder name and the last four digits. Both are
display-only identity fields on the constitution's allowlist. No trip data is stored.

**Testing**: `flutter_test`, `mocktail`, golden tests. Test-first on the badge rule, the trip-action
table, the domestic and 90-day filters, and the time-zone arithmetic (Principle IV).

**Target Platform**: Android 8.0 / iOS 15.0. Unchanged.

**Project Type**: Mobile app (Flutter, feature-first). Adds one screen, a tab shell, a Perfil
placeholder and a 013 placeholder. Changes the credential status mapping, storage, the issuance
write and the router.

**Performance Goals**: interactive within 2 s of a cold launch at p90 (SC-005). The strip renders
from storage before the network answers. Refresh every 60 s while visible.

**Constraints**:

- "ACTIVA" only from a confirmed backend read (FR-003).
- No trip started without a confirmed credential (FR-009).
- No international segment (FR-010), and no history older than 90 days (FR-012).
- No stored itinerary (FR-013).
- No facial image (FR-018).
- No flight data in events (FR-016).

**Scale/Scope**: one screen, three widgets (strip, trip card, history list), a shell, two
placeholders, two ports with dev, fake and real implementations, a dev credential repository for
001's launch rule, five events and one storage addendum.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

Evaluated against constitution **v1.4.0**.

| Principle | Status | Notes |
|---|---|---|
| I. Consent and Data Minimization | **PASS** | The two new stored fields are display-only identity fields already shown on 004 and 008, which the allowlist covers. No itinerary is stored (CONFLICT-005). Withdrawal is two taps away through Perfil and clears the new keys |
| II. The Verification Provider Is an Adapter | **PASS** | Airline data is mapped at the data boundary. Unknown status reads as `unknown`, never as on time |
| III. Every Flow Has a Failure Path | **PASS** | Offline, stale, empty, cancelled and not-confirmed states each state what to do. The deferrals are listed by identifier in the spec. The dev credential repository is behind the existing release-guarded flag |
| IV. Test-First on the Trust Boundary | **PASS (mandatory here)** | The badge rule, the action table and the filters are tested first |
| V. Airport-Grade Experience Constraints | **PASS** | No navigation to reach the trip, a 2 s cold-launch target, and reasons instead of failures after a tap |
| VI. Accessibility Is a Gate | **PASS** | Cities are announced instead of codes, disabled reasons are the semantics labels, and plain-text history rows |
| VII. Observability Without PII | **PASS, with a flagged limitation** | Payloads carry no flight data. Repeat use across flights is derived from a count, because the per-launch session id cannot link passengers (research.md §9). A true cohort would need an amendment; that is raised, not assumed |
| VIII. Architecture | **PASS** | Ports under `domain/repositories/`. The screen lives under `features/trips/`. The in-memory snapshot is kept in the repository |
| IX. Mandated Code Patterns | **PASS** | `Result<T>`, sealed action and summary types, injected `Clock` and lifecycle listener |
| X. Craft Standards | **PASS** | No new dependency. The 60 s, 24 h, 90 days and 1 min values are named constants |

**Post-design re-check**: no change.

## Project Structure

### Documentation (this feature)

```text
specs/012-mis-viajes/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── trip-port.md                  # new port
│   ├── credential-summary-port.md    # new port + status/storage addendum
│   ├── trips-home-ui.md              # action table, card, strip, empty state
│   └── analytics-events.md           # new events
├── assets/12-mis-viajes.png
└── tasks.md                          # /speckit-tasks
```

### Source Code (repository root) — additions and changes

```text
lib/
├── app/
│   ├── router.dart                         # CHANGE: ShellRoute (trips, credential, profile), 013 placeholder route
│   ├── home_shell.dart                     # NEW: NavigationBar shell
│   └── composition_root.dart               # CHANGE: two ports + dev credential repository
├── domain/
│   ├── entities/
│   │   ├── credential_status.dart          # CHANGE: ExpiryReason.suspended
│   │   ├── credential_summary.dart         # NEW
│   │   └── trip.dart                       # NEW: Airport, TripStatus, Trip, TripsSnapshot
│   └── repositories/
│       ├── credential_summary_repository.dart  # NEW
│       ├── trip_repository.dart            # NEW
│       └── analytics_emitter.dart          # CHANGE: 5 methods
├── data/
│   ├── dev/
│   │   ├── dev_trip_repository.dart        # NEW
│   │   ├── dev_credential_summary_repository.dart  # NEW
│   │   └── dev_credential_repository.dart  # NEW: 001's launch rule in dev
│   ├── models/
│   │   ├── trips_response.dart             # NEW DTO
│   │   └── credential_status_response.dart # CHANGE: holderName, documentLast4
│   └── services/
│       ├── credential_service.dart         # CHANGE: two keys, write/clear
│       ├── credential_repository_impl.dart # CHANGE: suspended
│       ├── credential_summary_repository_impl.dart  # NEW
│       ├── credential_issuance_repository_impl.dart # CHANGE: store display fields
│       ├── trip_service.dart               # NEW
│       ├── trip_repository_impl.dart       # NEW
│       └── logging_analytics_emitter.dart  # CHANGE
├── features/
│   ├── trips/
│   │   ├── trips_placeholder_view.dart     # REMOVED (replaced)
│   │   ├── trips_home_view.dart            # NEW
│   │   ├── trips_home_viewmodel.dart       # NEW
│   │   ├── trip_time_format.dart           # NEW: departure-local date, Hoy/Mañana
│   │   └── widgets/
│   │       ├── credential_strip.dart       # NEW
│   │       ├── next_trip_card.dart         # NEW
│   │       └── trip_history_list.dart      # NEW
│   ├── profile/profile_placeholder_view.dart        # NEW: withdrawal entry
│   └── trip_verification_placeholder_view.dart      # NEW: stands in for 013
└── l10n/app_es.arb                         # CHANGE

test/
├── contract/
│   ├── trip_repository_contract_test.dart            # NEW
│   ├── credential_summary_repository_contract_test.dart  # NEW
│   └── credential_repository_contract_test.dart      # CHANGE: suspended
├── unit/
│   ├── trips_home_viewmodel_test.dart      # NEW
│   └── trip_time_format_test.dart          # NEW
├── widget/
│   ├── trips_home_view_test.dart           # NEW: incl. goldens
│   └── router_test.dart                    # CHANGE: shell, two-tap withdrawal
└── fakes/
    ├── fake_trip_repository.dart           # NEW
    ├── fake_credential_summary_repository.dart  # NEW
    └── fake_analytics_emitter.dart         # CHANGE
```

**Structure Decision**: the feature-first layout of 001–011. The home screen stays under
`features/trips/`, where its placeholder lived, so 001's route and 008's "Ver mis viajes" need no
change.

## Complexity Tracking

*No violations. Cross-feature changes, each specified with tests:*

- *001's status mapping gains `suspended`.*
- *008's issuance also stores the two display fields.*
- *The router gains a shell.*

*One limitation is flagged rather than solved: repeat use measured by count, pending an amendment
decision (research.md §9).*
