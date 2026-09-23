# Implementation Plan: Escalation to a Human Agent (10 Escalar agente)

**Branch**: `010-escalar-agente` | **Date**: 2026-09-23 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/010-escalar-agente/spec.md`

## Summary

The screen a passenger reaches when automatic verification did not confirm them, by choice or at
the limit. It opens — or resumes — a backend escalation case keyed by the enrollment attempt id,
shows the airport module (preselected, named, with its hours) and an informational chat, each with
availability taken from channel data, and checks the case's status every few seconds. An agent's
decision at the module arrives as one of three outcomes: approval, which the app turns into 008's
normal credential flow by asking the issuance port; a decline; or an attempt reset, which returns
the passenger to the exhausted capture. Approval never carries a credential, so no escalation path
can open 008 on its own. The chat has no attachment control and produces no outcome. At launch, an
open escalation takes precedence over the welcome screen.

## Technical Context

**Language/Version**: Dart / Flutter, the same pinned stable channel (3.47.5) as 001–009.

**Primary Dependencies**: Reuses `provider`, `go_router`, `freezed`, `json_serializable`, `dio`
(pinned), `mocktail`. **No new package dependency**; the module's location is shown in the app
rather than in a maps application (research.md §7).

**Storage**: none new. The escalation lives on the backend, keyed by the existing
`EnrollmentAttemptId`; chat messages live in memory. An agent reset mirrors into the existing local
attempt counters until FR-006's backend counter replaces them.

**Testing**: `flutter_test`, `mocktail`, golden tests. This is the path the spec names as the most
likely route to a false accept, so Principle IV's test-first ordering applies to the outcome
routing and the launch redirect in particular.

**Target Platform**: Android 8.0 / iOS 15.0. Unchanged.

**Project Type**: Mobile app (Flutter, feature-first). Adds two screens (escalation, chat) and two
ports; changes 001's launch redirect.

**Performance Goals**: status checks every 5 seconds while the screen is open.

**Constraints**: No credential from an escalation except through the issuance port (FR-011); no
outcome from the chat (FR-021); no attachments (FR-014); availability and waits only from channel
data (FR-004–FR-006); a forward action and the checkpoint alternative in every state (FR-008);
amber, never red (FR-002).

**Scale/Scope**: Two screens, one location sheet, two ports with dev, fake and real
implementations, five analytics events, one cross-feature redirect change.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design; no change.*

Evaluated against constitution **v1.4.0**.

| Principle | Status | Notes |
|---|---|---|
| I. Consent and Data Minimization | **PASS** | Nothing new persisted; no attachments; chat in memory only. The document-number lookup (FR-023) is entirely agent-side and never passes through the app. |
| II. The Verification Provider Is an Adapter | **PASS** | Both ports normalize backend codes at the data boundary; unknown outcomes are never read as outcomes. |
| III. Every Flow Has a Failure Path | **PASS** | Open, declined, expired and unreachable states each have a forward action and the checkpoint line. Deferrals listed by identifier in the spec. |
| IV. Test-First on the Trust Boundary | **PASS (mandatory here)** | Outcome routing, the no-credential-without-issuance rule, and the launch redirect are tested first; goldens for the screen. |
| V. Airport-Grade Experience Constraints | **PASS** | The escalation agent path is one tap from 009; the checkpoint alternative is always stated. |
| VI. Accessibility Is a Gate | **PASS** | Channels are a single choice group with availability and selection announced; title and body announced on entry. |
| VII. Observability Without PII | **PASS** | Enum, boolean and integer payloads only. |
| VIII. Architecture | **PASS** | Ports under `domain/repositories/`; screens under `features/enrollment/escalation/`. |
| IX. Mandated Code Patterns | **PASS** | `Result<T>`, sealed status and outcome types, no optimistic state: an approval shows nothing until issuance returns `activated`. |
| X. Craft Standards | **PASS** | Reuses 008's issuance port and hand-off; no new dependency. |

No unjustified gate failures.

## Project Structure

### Documentation (this feature)

```text
specs/010-escalar-agente/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── escalation-port.md             # new port
│   ├── agent-chat-port.md             # new port
│   ├── launch-routing-addendum.md     # change to 001
│   └── analytics-events.md            # new events
├── assets/10-escalar-agente.png
└── tasks.md                           # /speckit-tasks
```

### Source Code (repository root) — additions and changes

```text
lib/
├── app/
│   ├── router.dart                        # CHANGE: escalation and chat routes; launch redirect
│   └── composition_root.dart              # CHANGE: wire both ports (dev/real)
├── domain/
│   ├── entities/
│   │   ├── escalation.dart                # NEW: arrival, channel kind, wait, channel, case,
│   │   │                                  #   outcome, status
│   └── repositories/
│       ├── escalation_repository.dart     # NEW
│       ├── agent_chat_repository.dart     # NEW
│       └── analytics_emitter.dart         # CHANGE: 5 new methods
├── data/
│   ├── dev/
│   │   ├── dev_escalation_repository.dart # NEW: static channels, stays open
│   │   └── dev_agent_chat_repository.dart # NEW: echo
│   ├── models/escalation_status_response.dart  # NEW DTO
│   └── services/
│       ├── escalation_service.dart        # NEW: pinned dio
│       ├── escalation_repository_impl.dart     # NEW: mapping
│       ├── agent_chat_service.dart        # NEW
│       ├── agent_chat_repository_impl.dart     # NEW
│       └── logging_analytics_emitter.dart # CHANGE
├── features/
│   ├── agent_escalation_placeholder_view.dart  # REMOVED (replaced)
│   └── enrollment/escalation/
│       ├── escalation_view.dart           # NEW
│       ├── escalation_viewmodel.dart      # NEW
│       ├── agent_chat_view.dart           # NEW
│       ├── agent_chat_viewmodel.dart      # NEW
│       └── widgets/
│           ├── channel_card.dart          # NEW: choice-group card
│           └── module_location_sheet.dart # NEW
└── l10n/app_es.arb                        # CHANGE

test/
├── contract/escalation_repository_contract_test.dart  # NEW: fake AND real
├── unit/
│   ├── escalation_viewmodel_test.dart     # NEW
│   └── agent_chat_viewmodel_test.dart     # NEW
├── widget/
│   ├── escalation_view_test.dart          # NEW: incl. goldens
│   ├── agent_chat_view_test.dart          # NEW
│   └── router_test.dart                   # CHANGE: launch addendum
└── fakes/
    ├── fake_escalation_repository.dart    # NEW
    ├── fake_agent_chat_repository.dart    # NEW
    └── fake_analytics_emitter.dart        # CHANGE
```

**Structure Decision**: the feature-first layout 001–009 use. The escalation screen and its chat are
feature-private under `features/enrollment/escalation/`; the ports are domain-owned.

## Complexity Tracking

*No entries. The Constitution Check passes with no violations. The launch-redirect change to 001 is
specified, with regression tests, in contracts/launch-routing-addendum.md.*
