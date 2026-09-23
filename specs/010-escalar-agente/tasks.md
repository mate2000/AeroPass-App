---

description: "Task list for Escalation to a Human Agent (10 Escalar agente)"
---

# Tasks: Escalation to a Human Agent (10 Escalar agente)

**Input**: Design documents from `/specs/010-escalar-agente/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md (all
present). Replaces the agent-escalation placeholder that 009 routes to, adds an informational chat,
and changes 001's launch redirect. No new package dependency.

**Tests**: Included, and written before implementation. The spec names this path as the most
likely route to a false accept, so Constitution Principle IV's test-first ordering applies, above
all to outcome routing and the launch redirect.

**Organization**: Tasks are grouped by user story (spec.md: US1, US2, US3, all P1).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an incomplete task)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- File paths are relative to the `AeroPass-App/` repository root
- Run `dart run build_runner build --delete-conflicting-outputs` after any task that adds or changes
  a `freezed` or `json_serializable` type

---

## Phase 1: Setup

- [X] T001 Add screen 10 and chat strings to `lib/l10n/app_es.arb`, then run `flutter gen-l10n`:
      "Ayuda"; title "Necesitamos verificarte en persona"; two bodies, by choice ("Un agente en el
      módulo AeroPass puede ayudarte a completar tu verificación.") and after the limit ("No pudimos
      confirmar tu identidad automáticamente. Un agente en el módulo AeroPass puede ayudarte a
      completar el proceso."); module and chat card labels; "Disponible ahora", "No disponible",
      "Abre {when}", "Espera estimada: {min}–{max} minutos"; the chat card's "Resuelve tus dudas; la
      verificación se completa en el módulo"; actions "Cómo llegar al módulo", "Iniciar chat",
      "Volver al inicio", "Abrir nueva solicitud", "Reintentar"; the checkpoint line; the decline,
      expired and unavailable messages; the chat notice ("Este chat responde tus dudas. No puede
      completar tu verificación y nunca recibe documentos."), the input hint, "Enviar" and "No
      enviado"

---

## Phase 2: Foundational (blocking prerequisites)

**⚠️ CRITICAL**: no user story work begins until this phase is complete.

- [X] T002 Create the escalation domain types in `lib/domain/entities/escalation.dart` per
      data-model.md: `EscalationArrival`, `AgentChannelKind`, `WaitEstimate`, `AgentChannel`,
      `EscalationCase`, sealed `EscalationOutcome` (`credentialIssued`, `declined`,
      `attemptsReset(scope)`), sealed `EscalationStatus` (`open`, `resolved`, `expired`), and the
      analytics enum `EscalationOutcomeKind`; run `build_runner`
- [X] T003 Create the abstract `EscalationRepository` (`openOrResume`, `getStatus`) in
      `lib/domain/repositories/escalation_repository.dart` and `AgentChatRepository` (`send`) in
      `lib/domain/repositories/agent_chat_repository.dart`, with the doc comments from
      contracts/escalation-port.md and contracts/agent-chat-port.md (depends on: T002)
- [X] T004 Add the five methods of contracts/analytics-events.md to
      `lib/domain/repositories/analytics_emitter.dart` and implement them in
      `lib/data/services/logging_analytics_emitter.dart` (depends on: T002)
- [X] T005 [P] Implement the five methods in `test/fakes/fake_analytics_emitter.dart` (depends on: T004)
- [X] T006 [P] Create `FakeEscalationRepository` (scriptable `openOrResume` result and a queue of
      `getStatus` results, with call counters) in `test/fakes/fake_escalation_repository.dart`,
      and `FakeAgentChatRepository` (scriptable replies, recorded messages) in
      `test/fakes/fake_agent_chat_repository.dart` (depends on: T003)

**Checkpoint**: all three stories can start.

---

## Phase 3: User Story 1 - A passenger reaches a person and completes enrollment (Priority: P1) 🎯 MVP

**Goal**: the screen opens or resumes the escalation, preselects the named module, offers the
chat, and routes an approval or a reset to the right place.

**Independent Test**: with channels open, verify the module is preselected and named, the location
sheet opens, the chat echoes with no attachment control, an approval reaches 008 through issuance,
and a reset returns to the exhausted capture with a fresh count.

### Tests for User Story 1 (write first, confirm they fail)

- [X] T007 [P] [US1] Contract tests for contracts/escalation-port.md cases 1–4, 7 and 9–11 (real
      implementation with a mocked `dio` and seeded consent fake; the dev fake for cases 1–3) in
      `test/contract/escalation_repository_contract_test.dart`
- [X] T008 [P] [US1] Unit tests in `test/unit/escalation_viewmodel_test.dart`: arrival is
      `afterLimit` when a counter is at the limit and `byChoice` otherwise; `openOrResume` is called
      once with it; `escalationShown` fires; the module is preselected when available; status is
      polled on the injected interval; `resolved(credentialIssued)` calls `requestIssuance()` and on
      `Ok(activated)` sets the hand-off, clears the session and targets `credentialActivated`;
      `attemptsReset(documentCapture)` resets that local counter and targets `documentCapture`;
      `attemptsReset(selfieLiveness)` resets the selfie counter and targets `livenessCapture`;
      `escalationOutcome` fires once with `elapsedSeconds`
- [X] T009 [P] [US1] Widget tests in `test/widget/escalation_view_test.dart`: title, the body for
      each arrival (the by-choice body never contains "agotaste"), the amber icon and no red, the
      module card with its airport and location and hours, the chat card with its "resuelve tus
      dudas" line, the checkpoint line; "Cómo llegar al módulo" opens the location sheet; selecting
      the chat switches the primary action to "Iniciar chat" and pushes the chat; "Volver al
      inicio" goes to welcome; the back gesture returns to the previous route; the title and body
      are announced; goldens at default and 200% text scale
- [X] T010 [P] [US1] Widget tests in `test/widget/agent_chat_view_test.dart` and unit tests in
      `test/unit/agent_chat_viewmodel_test.dart`: the notice is shown; there is no attachment
      control; sending a message shows it and the reply; a failed send marks the message "No
      enviado" (contracts/agent-chat-port.md)

### Implementation for User Story 1

- [X] T011 [P] [US1] Create the `EscalationStatusResponse` DTO in
      `lib/data/models/escalation_status_response.dart` (all fields nullable), then run
      `build_runner`
- [X] T012 [US1] Create `EscalationService` (`POST /v1/escalations`,
      `GET /v1/escalations/current`) in `lib/data/services/escalation_service.dart` and
      `EscalationRepositoryImpl` in `lib/data/services/escalation_repository_impl.dart`, mapping per
      data-model.md with safe defaults (depends on: T007, T011)
- [X] T013 [P] [US1] Create `DevEscalationRepository` (opens once and stays open; module available
      at "Aeropuerto Internacional José María Córdova (MDE)", "Terminal nacional, segundo piso,
      junto a la entrada de seguridad", with the reference's hours; chat available with no wait) in
      `lib/data/dev/dev_escalation_repository.dart`
- [X] T014 [P] [US1] Create `AgentChatService` and `AgentChatRepositoryImpl` in
      `lib/data/services/agent_chat_service.dart` and
      `lib/data/services/agent_chat_repository_impl.dart`, and the echoing
      `DevAgentChatRepository` in `lib/data/dev/dev_agent_chat_repository.dart`
- [X] T015 [US1] Wire both ports in `lib/app/composition_root.dart`, choosing the dev fakes when
      `HappyPathFlags.useFakeVerificationBackend` is on (depends on: T012, T013, T014)
- [X] T016 [US1] Implement `EscalationViewModel` in
      `lib/features/enrollment/escalation/escalation_viewmodel.dart` with the sealed
      `EscalationViewState` of data-model.md: derive arrival, `openOrResume`, poll `getStatus`
      every `escalationPollInterval` (5 s, injectable), preselect by research.md §3, route outcomes
      by research.md §5, one-shot navigation targets, analytics (depends on: T008, T015)
- [X] T017 [P] [US1] Build `ChannelCard` (choice-group `Semantics` with `inMutuallyExclusiveGroup`,
      `checked`, and a label joining name, availability and wait) in
      `lib/features/enrollment/escalation/widgets/channel_card.dart`, and `ModuleLocationSheet` in
      `lib/features/enrollment/escalation/widgets/module_location_sheet.dart`
- [X] T018 [US1] Build `EscalationView` in `lib/features/enrollment/escalation/escalation_view.dart`:
      "Ayuda" top bar, amber tile, title, body by arrival, the channel cards, the primary action by
      selection, "Volver al inicio", the checkpoint line; announcements; acts on navigation targets
      (depends on: T009, T016, T017)
- [X] T019 [US1] Implement `AgentChatViewModel` and `AgentChatView` (notice, in-memory message list,
      text field and "Enviar", no attachment control) in
      `lib/features/enrollment/escalation/agent_chat_viewmodel.dart` and
      `lib/features/enrollment/escalation/agent_chat_view.dart` (depends on: T010, T015)
- [X] T020 [US1] Point the `agentEscalation` `GoRoute` in `lib/app/router.dart` at the new view and
      view model, add an `agentChat` route, and delete
      `lib/features/agent_escalation_placeholder_view.dart` (depends on: T018, T019)

**Checkpoint**: from 009, the passenger reaches the module or the chat, and approvals and resets
route correctly. T007–T010 pass.

---

## Phase 4: User Story 2 - Availability shown is availability that exists (Priority: P1)

**Goal**: unavailable channels say when they open and cannot be selected; waits appear only when
supplied; with nothing open, the screen still says what to do now.

**Independent Test**: script each availability combination and verify the cards, the selection,
the primary action and the nothing-open message.

### Tests for User Story 2 (write first, confirm they fail)

- [X] T021 [P] [US2] Add contract cases 5–6 (unavailable channel with `nextOpensAt`; missing
      `available` maps to unavailable) to `test/contract/escalation_repository_contract_test.dart`
- [X] T022 [P] [US2] Add unit tests to `test/unit/escalation_viewmodel_test.dart`: with the module
      closed and chat open, the chat is preselected; with both closed, nothing is selected and the
      primary action is disabled; a selected channel that closes on the next poll falls back by
      research.md §3; `escalationChannelsOffered` fires when availability changes
- [X] T023 [P] [US2] Add widget tests to `test/widget/escalation_view_test.dart`: an unavailable
      card shows "No disponible" and when it opens, and tapping it does not select it; no wait text
      appears when the channel supplies none, and the range appears when it does; with both closed,
      the what-to-do-now message and checkpoint line appear and "Volver al inicio" still works

### Implementation for User Story 2

- [X] T024 [US2] Implement availability handling in `lib/features/enrollment/escalation/escalation_viewmodel.dart`
      and `lib/features/enrollment/escalation/widgets/channel_card.dart`: disabled unavailable
      cards with their next opening, wait shown only when present, selection fallback, the
      nothing-open state in `lib/features/enrollment/escalation/escalation_view.dart` (depends on:
      T021, T022, T023)

**Checkpoint**: no availability is ever asserted without data. T021–T023 pass.

---

## Phase 5: User Story 3 - An agent's decision is auditable and cannot manufacture a false accept (Priority: P1)

**Goal**: an approval opens 008 only through issuance; decline and expiry are shown plainly; the
chat never produces an outcome; an open escalation is found again at launch.

**Independent Test**: script `credentialIssued` with issuance not activated and verify 008 never
opens; script decline and expiry; send chat messages and verify no outcome; relaunch with an open
escalation and verify the screen reappears.

### Tests for User Story 3 (write first, confirm they fail)

- [X] T025 [P] [US3] Add contract case 8 (an unknown outcome is not an outcome) to
      `test/contract/escalation_repository_contract_test.dart`
- [X] T026 [P] [US3] Add unit tests to `test/unit/escalation_viewmodel_test.dart`:
      `credentialIssued` with issuance returning `notActive`, `incomplete` or an error sets no
      hand-off, targets nothing, and keeps polling; `declined` gives the declined state with
      `escalationOutcome(declined)`; `expired` gives the expired state, and `reopen()` calls
      `openOrResume` again; a failed status read changes nothing; no code path sets the hand-off
      without an `IssuanceActivated`
- [X] T027 [P] [US3] Add widget tests: the declined and expired states in
      `test/widget/escalation_view_test.dart` each show the checkpoint line and a forward action;
      in `test/widget/agent_chat_view_test.dart`, sending messages never changes the escalation
      view model's state
- [X] T028 [P] [US3] Add the five cases of contracts/launch-routing-addendum.md to
      `test/widget/router_test.dart`, providing a `FakeEscalationRepository` in its harness

### Implementation for User Story 3

- [X] T029 [US3] Implement the declined, expired and unavailable states and `reopen()` in
      `lib/features/enrollment/escalation/escalation_viewmodel.dart` and
      `lib/features/enrollment/escalation/escalation_view.dart`, and keep polling when an approval's
      issuance is not yet activated (depends on: T025, T026, T027)
- [X] T030 [US3] Add the launch check to the splash/welcome redirect in `lib/app/router.dart` per
      contracts/launch-routing-addendum.md (depends on: T028)

**Checkpoint**: no escalation path can open 008 on its own. T025–T028 pass.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T031 [P] Trust-boundary audit: confirm by search that the escalation feature never constructs
      an `ActivatedCredential` or sets `ActivatedCredentialHandoff` except inside the
      `IssuanceActivated` branch after `requestIssuance()`; that the chat has no attachment control
      and no route to an outcome; that no new event carries personal data (FR-011, FR-014, FR-017,
      SC-002, SC-011)
- [X] T032 Run `flutter analyze` with zero issues, then the full `flutter test` suite, fixing any
      regression in 001–009 tests
- [ ] T033 Walk quickstart.md's manual scenarios 1–6 on an Android device, and record the results in
      `specs/010-escalar-agente/quickstart.md`

---

## Dependencies & Execution Order

- **Setup (Phase 1)** and **Foundational (Phase 2)** first; Foundational blocks every story.
- **US1 (Phase 3)**: the screen, the chat, and the approval and reset routing.
- **US2 (Phase 4)** and **US3 (Phase 5)**: extend US1's view model and view (T016, T018); T028 and
  T030 (launch redirect) depend only on Foundational and can run alongside US1.
- **Polish (Phase 6)**: after all stories.

Within each story, tests are written and fail before implementation; ports before services, services
before the view model, the view model before the view, the view before routes.

## Parallel Opportunities

- Phase 2: T005 and T006 together.
- US1: T007, T008, T009 and T010 together; then T011, T013, T014 and T017 together.
- US2: T021, T022 and T023 together.
- US3: T025, T026, T027 and T028 together.
- The launch-redirect pair (T028, T030) can run in parallel with US1.

## Parallel Example: User Story 1

```bash
# Tests first, together:
Task: "Contract tests in test/contract/escalation_repository_contract_test.dart"
Task: "View-model unit tests in test/unit/escalation_viewmodel_test.dart"
Task: "Escalation widget tests in test/widget/escalation_view_test.dart"
Task: "Chat tests in test/widget/agent_chat_view_test.dart and test/unit/agent_chat_viewmodel_test.dart"

# Then independent files:
Task: "EscalationStatusResponse DTO in lib/data/models/escalation_status_response.dart"
Task: "DevEscalationRepository in lib/data/dev/dev_escalation_repository.dart"
Task: "Chat service, repository and echo fake"
Task: "ChannelCard and ModuleLocationSheet widgets"
```

## Implementation Strategy

### MVP (US1)

Phases 1–3: from 009, the passenger reaches the module or the chat, and an approval reaches 008
through issuance. Walk quickstart scenarios 1–4.

### Incremental delivery

1. Phases 1–2: foundation.
2. Phase 3: the screen, the chat, approval and reset.
3. Phase 4: honest availability.
4. Phase 5: decline, expiry, the no-false-accept rule, relaunch recovery.
5. Phase 6: audit, full suite, device walk-through.
