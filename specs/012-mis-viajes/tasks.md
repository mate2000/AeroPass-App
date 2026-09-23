---

description: "Task list for Trips Home (12 Mis viajes)"
---

# Tasks: Trips Home (12 Mis viajes)

**Input**: Design documents from `/specs/012-mis-viajes/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md (all
present). This feature replaces the trips placeholder inside a new three-tab shell. It changes 001's
status mapping, 008's credential storage and the router. No new package dependency.

**Tests**: Included, and written before implementation. The badge rule, the trip-action table, the
domestic and 90-day filters, and the departure-time arithmetic are on the trust boundary
(Constitution Principle IV).

**Organization**: Tasks are grouped by user story: spec.md US1 (P1), US2 (P1) and US3 (P2).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an incomplete task)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- File paths are relative to the `AeroPass-App/` repository root
- Run `dart run build_runner build --delete-conflicting-outputs` after any task that adds or changes
  a `freezed` or `json_serializable` type

---

## Phase 1: Setup

- [X] T001 Add the screen 12, shell, Perfil and 013-placeholder strings to `lib/l10n/app_es.arb`,
      then run `flutter gen-l10n`. Remove the old `tripsEmpty*` keys once T025 deletes the placeholder that uses them.
      The strings are:
      - **Greetings**: "Buenos días," / "Buenas tardes," / "Buenas noches,".
      - **Strip**: "•••• {last4}"; badges "ACTIVA", "VENCIDA", "REVOCADA", "SUSPENDIDA"; the
        "sin confirmar" suffix.
      - **Section headings**: "PRÓXIMO VIAJE", "VIAJES RECIENTES".
      - **Trip card**: "Hoy · {hora}", "Mañana · {hora}", "{fecha} · {hora}", "(hora local de
        {ciudad})"; "Puerta {gate}", "Asiento {seat}", "Detalles no disponibles"; "Retrasado",
        "Vuelo cancelado", "Estado no disponible"; "Conexión a {ciudad}"; "Actualizado hace {min}
        min".
      - **Action**: "Iniciar viaje", "Sin conexión: no pudimos confirmar tu identidad", "Tu
        identidad está vencida / revocada / suspendida", "Disponible desde el {día} a las {hora}".
      - **Route semantics**: "De {origen} a {destino}, vuelo {vuelo}…".
      - **Empty state and history**: the empty-state title and body from
        contracts/trips-home-ui.md; "Mostramos tus viajes de los últimos 90 días."; "No pudimos
        cargar tus viajes" with "Reintentar".
      - **Tabs**: "Viajes", "Identidad", "Perfil".
      - **Perfil**: "Retirar consentimiento".
      - **013 placeholder**: "Validación automática" and its one-line body.

---

## Phase 2: Foundational (blocking prerequisites)

**⚠️ CRITICAL**: no user story work begins until this phase is complete.

- [X] T002 [P] Add `ExpiryReason.suspended` to `lib/domain/entities/credential_status.dart`. Then
      map the wire value `suspended` to it in `lib/data/services/credential_repository_impl.dart`,
      after adding the case to `test/contract/credential_repository_contract_test.dart` first.
      Confirm 001's welcome banner still compiles; add a `suspended` case if its switch is
      exhaustive
- [X] T003 [P] Create the domain types, then run `build_runner`:
      - `lib/domain/entities/credential_summary.dart`: `CredentialDisplayState` and freezed
        `CredentialSummary`, with `showsActive`.
      - `lib/domain/entities/trip.dart`: `Airport`, `TripStatus`, freezed `Trip` (with
        `departureLocal` and `tripWindowOpensAt`) and freezed `TripsSnapshot`.
      All follow data-model.md.
- [X] T004 Create the ports, with doc comments from their contracts (depends on: T003):
      - `CredentialSummaryRepository` in
        `lib/domain/repositories/credential_summary_repository.dart`, with a `NoCredentialFailure`
        error type;
      - `TripRepository` in `lib/domain/repositories/trip_repository.dart`, with `getTrips()` and
        `lastKnown`.
- [X] T005 Add the five methods of contracts/analytics-events.md to
      `lib/domain/repositories/analytics_emitter.dart`, implemented in
      `lib/data/services/logging_analytics_emitter.dart` and `test/fakes/fake_analytics_emitter.dart`
      (depends on: T003)
- [X] T006 [P] Create the test fakes, `test/fakes/fake_credential_summary_repository.dart` and
      `test/fakes/fake_trip_repository.dart`. Both are scripted, and the trip fake has a settable
      `lastKnown` (depends on: T004)
- [X] T007 Write `test/unit/trip_time_format_test.dart` first. It covers:
      - the departure-local date and time from UTC plus offset;
      - "Hoy" versus "Mañana" for a 00:30 departure in -05:00 while the device is in UTC, and at
        23:59 on the day before;
      - the "(hora local de …)" suffix only when the device's offset differs;
      - the greeting boundaries at 5, 12 and 19 hours.
      Then implement `lib/features/trips/trip_time_format.dart` until it passes. It is a pure
      function file with no `material.dart` import (depends on: T003)

**Checkpoint**: foundation ready; user story work can begin.

---

## Phase 3: User Story 1 - An enrolled passenger opens the app and starts their trip (Priority: P1) 🎯 MVP

**Goal**: A cold launch with a valid credential lands on Mis viajes inside the tab shell. The screen
shows a backend-affirmed strip, the next domestic trip, and an "Iniciar viaje" that is enabled only
when it may be used and leads to the 013 placeholder.

**Independent Test**: With a confirmed active summary and a trip departing in 3 h, "ACTIVA",
"•••• 4821", BOG → MDE and an enabled "Iniciar viaje" are all visible with no navigation, and the tap
opens the 013 placeholder. With the departure 30 h away, the button is replaced by "Disponible
desde…". With an unconfirmed summary, the button is replaced by the connection reason, and "ACTIVA"
is absent.

### Tests for User Story 1 (write first, confirm they fail)

- [X] T008 [P] [US1] Write `test/contract/credential_summary_repository_contract_test.dart`, cases 1–6
      of contracts/credential-summary-port.md, against the real implementation with
      `FakeHttpClientAdapter` and `FakeSecureStoragePlatform`. Include the dev implementation's two
      cases
- [X] T009 [P] [US1] Write `test/contract/trip_repository_contract_test.dart`, cases 1, 2, 3, 5, 7
      and 8 of contracts/trip-port.md: the mapping, the domestic filter, dropped malformed segments,
      next selection, errors and the request shape
- [X] T010 [P] [US1] Write `test/unit/trips_home_viewmodel_test.dart` for US1:
      - every row of the action table in contracts/trips-home-ui.md, in its precedence order;
      - `NoCredentialFailure` navigates to welcome;
      - `firstName` is the first word of the holder name;
      - "Iniciar viaje" emits `trip_started` with `completedTripsLast90Days`, and is ignored unless
        the action is `start`;
      - `trips_home_shown` and `trip_displayed` are emitted with only the contract's fields.
- [X] T011 [P] [US1] Write `test/widget/trips_home_view_test.dart` for US1:
      - the greeting and first name;
      - the strip shows initials, the full name and "•••• 4821";
      - "ACTIVA" appears only for a confirmed active summary; "SUSPENDIDA sin confirmar" and the
        other badges appear otherwise;
      - no `Image` widget anywhere in the tree;
      - the next-trip card shows codes, cities, the flight, "Hoy · 14:35", "Puerta D12 · Asiento
        22A";
      - "Iniciar viaje" opens the 013 stub; each disabled reason is its semantics label;
      - the route semantics read "De Bogotá a Medellín…";
      - golden `trips_home.png`.
      Let the tree own the ViewModel through `ChangeNotifierProvider(create:)`
- [X] T012 [P] [US1] Extend `test/widget/router_test.dart`:
      - a valid credential at launch lands on Mis viajes inside the shell, with three tabs;
      - Identidad opens the credential placeholder;
      - Perfil, then "Retirar consentimiento", reaches the withdrawal screen in two taps;
      - every existing launch case still passes.
      Provide the two new ports in the harness

### Implementation for User Story 1

- [X] T013 [US1] In `lib/data/services/credential_service.dart`, add the `holder_name` and
      `document_last4` keys. `writeCachedCredential` takes them as optional parameters,
      `readCachedCredential` returns them, and `clearCachedCredential` deletes all four keys. Add
      `holderName` and `documentLast4` to `lib/data/models/credential_status_response.dart`, then run
      `build_runner`
- [X] T014 [US1] Pass `holderName` and `documentLast4` from the issuance response into
      `writeCachedCredential` in `lib/data/services/credential_issuance_repository_impl.dart` and
      `lib/data/dev/dev_credential_issuance_repository.dart`. Extend the issuance contract test to
      assert both are stored (depends on: T013)
- [X] T015 [US1] Implement `CredentialSummaryRepositoryImpl` in
      `lib/data/services/credential_summary_repository_impl.dart`, and `DevCredentialSummaryRepository`
      in `lib/data/dev/dev_credential_summary_repository.dart`, until T008 passes (depends on: T008,
      T013)
- [X] T016 [P] [US1] Implement `DevCredentialRepository` in
      `lib/data/dev/dev_credential_repository.dart`, per research.md §3. A stored token gives
      `valid`; none gives `noCredential` (depends on: T013)
- [X] T017 [P] [US1] Create the `TripsResponse` DTO in `lib/data/models/trips_response.dart`, with
      nullable fields and `json_serializable`, and run `build_runner` (depends on: T003)
- [X] T018 [US1] Implement `TripService` in `lib/data/services/trip_service.dart`, a
      `GET /v1/trips` on the pinned `dio` client. Implement `TripRepositoryImpl` in
      `lib/data/services/trip_repository_impl.dart`: the strict mapping, the offset parsing, the
      domestic filter, next selection, an in-memory `lastKnown`, `mapTransportError` and the injected
      `Clock`. Continue until T009 passes (depends on: T009, T017)
- [X] T019 [P] [US1] Implement `DevTripRepository` in `lib/data/dev/dev_trip_repository.dart`: the
      fixed domestic trip and history of contracts/trip-port.md, relative to its first read
      (depends on: T004)
- [X] T020 [US1] Implement `TripsHomeViewModel` in `lib/features/trips/trips_home_viewmodel.dart`
      for US1:
      - the parallel reads on open;
      - the sealed `TripAction`;
      - `greeting` and `firstName`;
      - `startTrip()`;
      - `pendingNavigation` and `consumeNavigation()`;
      - the events.
      It has no `material.dart` import. Leave refresh and staleness to US2. Continue until the US1
      part of T010 passes (depends on: T007, T010)
- [X] T021 [P] [US1] Create `CredentialStrip` in `lib/features/trips/widgets/credential_strip.dart`.
      It has the navy gradient, an initials circle, the name, "•••• last4" and the badge. The badge
      is turquoise only for `showsActive`; otherwise it is neutral and carries its state text. There
      is no image (FR-018) (depends on: T003)
- [X] T022 [P] [US1] Create `NextTripCard` in `lib/features/trips/widgets/next_trip_card.dart`. It
      has the codes and cities, the flight over an arrow, the departure-local time line, the detail
      row, and the action slot: the button or the reason text. The route is one `Semantics` label
      (depends on: T007)
- [X] T023 [US1] Implement `TripsHomeView` in `lib/features/trips/trips_home_view.dart`, as
      composition only. It has the greeting header with a neutral avatar, the strip, "PRÓXIMO VIAJE"
      and the card. Continue until the US1 part of T011 passes (depends on: T020, T021, T022)
- [X] T024 [P] [US1] Create `lib/app/home_shell.dart`, a `Scaffold` with a bottom `NavigationBar`
      (Viajes, Identidad, Perfil) wrapping the shell child. Create
      `lib/features/profile/profile_placeholder_view.dart`, whose single entry "Retirar
      consentimiento" pushes `AppRoutes.withdrawal`. Create
      `lib/features/trip_verification_placeholder_view.dart`, which stands in for 013 with a back
      action
- [X] T025 [US1] In `lib/app/router.dart`:
      - add `AppRoutes.profile = '/profile'` and `AppRoutes.tripVerification = '/trip/verification'`;
      - wrap `trips`, `credentialDetail` and `profile` in a `ShellRoute` built with `HomeShell`;
      - point `trips` at `TripsHomeView` with a `ChangeNotifierProvider` ViewModel;
      - delete `lib/features/trips/trips_placeholder_view.dart`.
      Continue until T012 passes (depends on: T012, T023, T024)
- [X] T026 [US1] Wire the two ports in `lib/app/composition_root.dart`: the dev or real
      implementations, chosen by `useFakeVerificationBackend`. Replace the credential repository with
      `DevCredentialRepository` under the same flag (depends on: T015, T016, T018, T019)

**Checkpoint**: US1 works on its own: launch, the strip, the next trip, and a gated start.

---

## Phase 4: User Story 2 - Flight details shown are current, or visibly are not (Priority: P1)

**Goal**: The card refreshes on foreground and every 60 s. It keeps and marks the last snapshot when a
refresh fails, states when there is no live detail, and surfaces delays and cancellations.

**Independent Test**: Script a snapshot, then a gate change, and see it within one 60 s tick. Script a
failure, and see the same trip with "Actualizado hace 1 min". Script `live: false`, and see
"Detalles no disponibles". Script `cancelled`, and see "Vuelo cancelado" with no action.

### Tests for User Story 2 (write first, confirm they fail)

- [X] T027 [P] [US2] Extend `test/contract/trip_repository_contract_test.dart` with case 4 of
      contracts/trip-port.md, unknown status and missing `live`. Add a failed read that leaves
      `lastKnown` unchanged
- [X] T028 [P] [US2] Extend `test/unit/trips_home_viewmodel_test.dart`:
      - the 60 s refresh with a controllable interval;
      - a refresh on `AppLifecycleState.resumed`;
      - a failed trip read keeps the snapshot and sets `tripsStale`, with minutes derived from
        `fetchedAt`;
      - no snapshot this session sets `tripsUnavailable`, and "Reintentar" reads again;
      - the 1-minute tick opens the window on time;
      - a summary that becomes unconfirmed disables the action, and it re-enables after a confirmed
        read;
      - dispose cancels everything.
- [X] T029 [P] [US2] Extend `test/widget/trips_home_view_test.dart`:
      - "Actualizado hace N min" appears only when stale;
      - "Detalles no disponibles" appears for `live: false` even when gate and seat are present;
      - "Retrasado", "Vuelo cancelado" and "Estado no disponible" chips;
      - "Conexión a Medellín";
      - "No pudimos cargar tus viajes" with "Reintentar";
      - the "(hora local de Bogotá)" suffix with a device in another zone;
      - golden `trips_home_stale.png`.

### Implementation for User Story 2

- [X] T030 [US2] Complete `TripRepositoryImpl`'s status and `live` mapping until T027 passes
      (depends on: T018, T027)
- [X] T031 [US2] Add the refresh behavior to `TripsHomeViewModel`:
      - the 60 s `Timer.periodic`;
      - an `AppLifecycleListener` for resume;
      - the 1-minute action tick;
      - the stale and unavailable flags, and `retryTrips()`.
      Name the constants. Continue until T028 passes (depends on: T020, T028)
- [X] T032 [US2] Render the status chip, the connection line, the "Detalles no disponibles" rule,
      the freshness marker and the unavailable state in `NextTripCard` and `TripsHomeView`. Continue
      until T029 passes (depends on: T022, T023, T031)

**Checkpoint**: US1 and US2 work. No flight data is presented as current unless it was just read.

---

## Phase 5: User Story 3 - A passenger with no trip understands what to do (Priority: P2)

**Goal**: With no next trip, the screen explains that the airline adds flights booked with the same
document. The strip stays visible. History shows only the last 90 days, as plain rows, with the limit
stated. It is absent when empty.

**Independent Test**: With no next trip and no history, the empty-state text and the strip are shown,
and no history section appears. With history, three plain rows appear with the 90-day line, a row 91
days old is gone, and `trips_history_viewed` fires once when the section scrolls into view.

### Tests for User Story 3 (write first, confirm they fail)

- [X] T033 [P] [US3] Extend `test/contract/trip_repository_contract_test.dart` with case 6 of
      contracts/trip-port.md: 91 days dropped, 89 kept, and history newest first
- [X] T034 [P] [US3] Extend `test/unit/trips_home_viewmodel_test.dart`:
      - `trips_empty_shown` fires when there is no next trip;
      - `onHistoryVisible()` emits `trips_history_viewed` with `rowCount` once per visit.
- [X] T035 [P] [US3] Extend `test/widget/trips_home_view_test.dart`:
      - the empty-state title and body, with the strip still shown;
      - no history section when history is empty;
      - history rows are plain text, with no `InkWell`, `GestureDetector` or chevron icon, and no
        button semantics;
      - the 90-day line;
      - the history event when scrolled into view;
      - goldens `trips_home_empty.png` and `trips_home_text_2x.png`.

### Implementation for User Story 3

- [X] T036 [US3] Add the 90-day history filter and newest-first order to `TripRepositoryImpl`, until
      T033 passes (depends on: T018, T033)
- [X] T037 [US3] Add `onHistoryVisible()` and the empty event to `TripsHomeViewModel`, until T034
      passes (depends on: T031, T034)
- [X] T038 [US3] Create `TripHistoryList` in `lib/features/trips/widgets/trip_history_list.dart`,
      with plain rows and the 90-day line. Render the empty state in `TripsHomeView`, and detect when
      the history section first becomes visible, for example with a scroll listener or
      `VisibilityDetector`-free geometry. Continue until T035 passes (depends on: T032, T037)

**Checkpoint**: all three stories work.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T039 [P] Add `test/unit/trips_analytics_payload_test.dart`. It asserts that every new payload is
      bool or int or a status name, and that no value matches a flight number (`[A-Z]{2} ?\d+`), an
      IATA code or a date (FR-016, SC-010)
- [X] T040 [P] Extend `test/architecture/import_boundary_test.dart` so that `lib/features/trips/`
      and `lib/features/profile/` import nothing from `lib/data/`, and nothing that writes files or
      preferences
- [X] T041 Trust-boundary audit. Confirm by search that:
      - no trip, itinerary or history is written to storage (CONFLICT-005);
      - "ACTIVA" is rendered only behind `showsActive` (FR-003);
      - no full document number and no image appear (FR-002, FR-018);
      - the trip action never produces a pass (FR-009).
      Record the findings in `specs/012-mis-viajes/checklists/audit.md`
- [X] T042 Run `flutter analyze` with zero issues, then the full `flutter test`. Fix any regression
      in 001, 008 or the router tests
- [ ] T043 Walk quickstart.md's manual scenarios 1–7 on an Android device, and record the results in
      `specs/012-mis-viajes/quickstart.md`. This needs the user and a device

---

## Dependencies & Execution Order

- **Setup (Phase 1)** and **Foundational (Phase 2)** come first. Foundational blocks every story.
- **US1 (Phase 3)**: the screen, the strip, the next trip, the gated start, the shell and the
  storage changes.
- **US2 (Phase 4)** extends US1's ViewModel, card and view (T020, T022, T023).
- **US3 (Phase 5)** extends the same files after US2 (T031, T032). T033 and T036, the repository
  filter, depend only on T018.
- **Polish (Phase 6)**: after all stories.

Within each story, tests come first and fail before implementation. Ports come before services,
services before the ViewModel, the ViewModel before the view, and the view before routes.

## Parallel Opportunities

- Phase 2: T002 and T003, then T006 once T004 is done.
- US1: T008–T012 together; then T016, T017, T019, T021, T022 and T024 together.
- US2: T027–T029 together.
- US3: T033–T035 together.
- Polish: T039 and T040.

## Parallel Example: User Story 1

```bash
# Tests first, together:
Task: "Credential summary contract tests in test/contract/credential_summary_repository_contract_test.dart"
Task: "Trip contract tests in test/contract/trip_repository_contract_test.dart"
Task: "View-model tests in test/unit/trips_home_viewmodel_test.dart"
Task: "Widget tests and golden in test/widget/trips_home_view_test.dart"
Task: "Shell and two-tap withdrawal in test/widget/router_test.dart"

# Then independent files:
Task: "DevCredentialRepository in lib/data/dev/dev_credential_repository.dart"
Task: "TripsResponse DTO in lib/data/models/trips_response.dart"
Task: "DevTripRepository in lib/data/dev/dev_trip_repository.dart"
Task: "CredentialStrip and NextTripCard widgets"
Task: "HomeShell, Perfil placeholder, 013 placeholder"
```

## Implementation Strategy

### MVP (US1)

Phases 1–3. A returning passenger lands on Mis viajes and sees a backend-affirmed strip and the next
domestic trip. They can start it only when that is allowed. Walk quickstart scenarios 1–3 and 5.

### Incremental delivery

1. Phases 1–2: foundation and time arithmetic.
2. Phase 3: the screen, the shell, storage, and the gated start.
3. Phase 4: freshness, staleness, and flight status.
4. Phase 5: the empty state and the 90-day history.
5. Phase 6: the audit, the full suite, and the device walk-through.
