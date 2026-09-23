---

description: "Task list for Dynamic QR Pass (14 QR Pase)"
---

# Tasks: Dynamic QR Pass (14 QR Pase)

**Input**: Design documents from `/specs/014-qr-pase/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md (all
present).

**Governance gate**: phase B (on-device derivation and the stored pass secret) is **blocked until the
user ratifies** contracts/constitution-amendment-proposal.md. Every task marked **⛔ BLOCKED** stays
unchecked until then. No code that stores the secret or derives codes offline may be written before
it (plan.md, Constitution Check).

**Tests**: Included, and written before implementation. Validity, rotation, clock trust, device
posture and the release gate are on the trust boundary (Constitution Principle IV).

**Organization**: Tasks are grouped by user story. spec.md's US1, US2 and US3 are all P1.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an incomplete task)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- File paths are relative to the `AeroPass-App/` repository root
- Run `dart run build_runner build --delete-conflicting-outputs` after any task that adds or changes
  a `freezed` or `json_serializable` type

---

## Phase 1: Setup

- [X] T001 Add the `qr` package (a pure-Dart encoder) to `pubspec.yaml` and run `flutter pub get`.
      Add a comment citing research.md §3's justification
- [X] T002 [P] Add the pass strings to `lib/l10n/app_es.arb`, then run `flutter gen-l10n`:
      - "Atrás", "Ayuda", "Asiento {seat}";
      - the stepper labels "Seguridad" and "Embarque";
      - "Se actualiza en {mm:ss}", "Código actualizado";
      - the footers "Presenta este código en el lector de seguridad" and "…de embarque";
      - the checkpoint line;
      - "Abordaje confirmado" and "Buen viaje";
      - every unavailable message and action in contracts/pass-ui.md;
      - "Simular expirado";
      - "Continuar a tu pase" and "Ver pase".

---

## Phase 2: Foundational (blocking prerequisites)

**⚠️ CRITICAL**: no user story work begins until this phase is complete.

- [X] T003 [P] Create `lib/domain/entities/pass.dart`, then run `build_runner`. It holds, per
      data-model.md:
      - `Checkpoint` (`security`, `boarding`);
      - freezed `Pass` and `PassCode`;
      - sealed `PassState` and `ClockTrust`;
      - `PassUnavailableReason`;
      - the named constants `passRotation` (30 s), `passStatusPollInterval` (5 s),
        `passMaxOfflineValidity` (24 h) and `clockTolerance` (30 s).
- [X] T004 Create the ports in `lib/domain/repositories/`: `pass_repository.dart`,
      `pass_code_source.dart`, `pass_display_guard.dart` and `device_posture_checker.dart`, with
      doc comments from the contracts (depends on: T003)
- [X] T005 Add the six methods of contracts/analytics-events.md to
      `lib/domain/repositories/analytics_emitter.dart`, `lib/data/services/logging_analytics_emitter.dart`
      and `test/fakes/fake_analytics_emitter.dart` (depends on: T003)
- [X] T006 [P] Create the test fakes: `test/fakes/fake_pass_repository.dart`,
      `fake_pass_code_source.dart`, `fake_pass_display_guard.dart` (counts enter and exit) and
      `fake_device_posture_checker.dart` (depends on: T004)
- [X] T007 Write `test/unit/clock_trust_monitor_test.dart` first:
      - an offset of 30 s or less is trusted, and 31 s or more is untrusted (drift);
      - a wall-clock change of more than 30 s against the monotonic elapsed time is untrusted
        (jump);
      - `serverNow()` applies the offset;
      - a new trusted observation restores trust.
      Then implement `lib/app/clock_trust_monitor.dart`, with an injected `Clock` and an injected
      monotonic `Stopwatch` factory (depends on: T003)
- [X] T008 Implement the release gate (contracts/release-gate.md):
      - add `devPassControls` (`DEV_PASS_CONTROLS`) to `lib/core/happy_path_flags.dart` and to
        `assertReleaseSafe`'s list;
      - create `tool/check_release_env.dart`;
      - write `test/unit/release_env_check_test.dart` first, covering a fixture env with the flag
        failing, `env/prod.env` passing, and `assertReleaseSafe` throwing;
      - add the "Release env has no development flags" step to `.github/workflows/ci.yaml`.

**Checkpoint**: foundation ready; user story work can begin.

---

## Phase 3: User Story 1 - A passenger presents the pass and clears the checkpoint (Priority: P1) 🎯 MVP

**Goal**: From 013's placeholder, the passenger sees a backend-issued pass bound to them, their
flight, their seat and the next checkpoint. It rotates every 30 s with a visible countdown, with
brightness raised and capture blocked. The stepper advances only on a validation the backend
reports, and after boarding the screen says "Buen viaje".

**Independent Test**: With the fake backend, open the pass and check each of these:

- the header, "Asiento 22A", the Seguridad and Embarque stepper, the QR and the footer are shown;
- the payload changes at the 30 s boundary;
- pass mode is entered;
- scripting the status `validated: [security]` checks Seguridad and switches the footer to
  Embarque;
- scripting `boarded` removes the QR and shows "Abordaje confirmado · Buen viaje".

### Tests for User Story 1 (write first, confirm they fail)

- [X] T009 [P] [US1] Write `test/contract/pass_repository_contract_test.dart`, contracts/pass-port.md
      cases 1, 2 and 4, against the real implementation with `FakeHttpClientAdapter`
- [X] T010 [P] [US1] Write `test/unit/pass_viewmodel_test.dart` for US1:
      - issue on open, or reuse `activePassFor`;
      - rotation exactly at window boundaries, with `pass_rotated`;
      - `secondsLeft` from the clock;
      - the stepper only from status;
      - the footer checkpoint follows `nextCheckpoint`;
      - `boarded` leads to the boarded state, `forget` and a stop to polling;
      - `pass_validated.secondsSinceOpened`;
      - pass mode entered only while showing a code, and exited on dispose, pause and back.
      Use a controllable clock
- [X] T011 [P] [US1] Write `test/widget/pass_view_test.dart` for US1:
      - the header, the chip ("Asiento", never "Fila") and the stepper, with no "Sala";
      - a QR rendered by the painter;
      - "Se actualiza en 00:26";
      - the footer per checkpoint;
      - the checkpoint line;
      - the boarded state has no QR;
      - "Atrás" pops;
      - "Ayuda" pushes help;
      - goldens `pass.png`, `pass_boarded.png` and `pass_text_2x.png`.
- [X] T012 [P] [US1] Extend `test/widget/router_test.dart`: "Continuar a tu pase" on the 013
      placeholder opens `/trip/pass`

### Implementation for User Story 1

- [X] T013 [P] [US1] Create the DTOs in `lib/data/models/pass_responses.dart`, then run
      `build_runner` (depends on: T003)
- [X] T014 [US1] Implement `PassService` in `lib/data/services/pass_service.dart`, for issue, code and
      status on the pinned `dio` client. Implement `PassRepositoryImpl` in
      `lib/data/services/pass_repository_impl.dart`, with the strict mapping, the 24 h clamp,
      `serverTime` handed to the clock monitor, an in-memory `activePassFor`, and `forget`.
      Continue until T009 passes (depends on: T009, T013, T007)
- [X] T015 [P] [US1] Implement `BackendPassCodeSource` in
      `lib/data/services/backend_pass_code_source.dart` (phase A). Offline, it returns an error and
      never a stale payload (depends on: T004)
- [X] T016 [P] [US1] Implement `DevPassRepository` and `DevPassCodeSource` in `lib/data/dev/`. They
      issue a synthetic pass valid until 3 h after the dev trip's departure and at most 24 h, and a
      payload `AP1-DEV.<window>`. They expose `expireNow()` for the dev control, and a scriptable
      validation sequence (depends on: T004)
- [X] T017 [P] [US1] Create the widgets in `lib/features/pass/widgets/`:
      - `qr_code_painter.dart`, which uses `qr` with error correction level H, draws the AeroPass
        mark at the centre, and has no semantics besides "Código de tu pase";
      - `rotation_ring.dart`, the progress arc;
      - `journey_stepper.dart`, with Seguridad and Embarque, done only from `validated`, and text
        labels.
      (depends on: T001, T003)
- [X] T018 [US1] Implement `PassViewModel` in `lib/features/pass/pass_viewmodel.dart` for US1. It has
      the sealed `PassViewState`, a 1 s tick, the 5 s status poll, pass-mode calls, the lifecycle
      listener and the events. It has no `material.dart` import. Continue until T010 passes (depends
      on: T010, T007, T014)
- [X] T019 [US1] Implement `PassView` in `lib/features/pass/pass_view.dart`, as composition only.
      Continue until T011 passes (depends on: T011, T017, T018)
- [X] T020 [US1] Add the `aeropass/pass_display` channel, per contracts/pass-display-and-posture.md:
      - `enterPassMode` and `exitPassMode` in
        `android/app/src/main/kotlin/com/aeropass/aeropass_app/MainActivity.kt`: brightness,
        `FLAG_KEEP_SCREEN_ON`, `FLAG_SECURE`;
      - the same in `ios/Runner/AppDelegate.swift`: brightness and the idle timer;
      - `PlatformPassDisplayGuard` in `lib/data/services/platform_pass_display.dart`.
- [X] T021 [US1] Add `AppRoutes.pass = '/trip/pass'` to `lib/app/router.dart`, with a
      `ChangeNotifierProvider` ViewModel. Add "Continuar a tu pase" to
      `lib/features/trip_verification_placeholder_view.dart`. Wire every new port in
      `lib/app/composition_root.dart`: dev or real under `useFakeVerificationBackend`, and the
      platform display guard. Continue until T012 passes (depends on: T012, T019, T020, T015, T016)

**Checkpoint**: US1 works online: present, rotate, advance and board.

---

## Phase 4: User Story 2 - The pass works when the network does not (Priority: P1)

**Goal**: The phase A part is this: with the network gone, the screen never shows a stale or guessed
code, and a clock the backend would not trust shows no code. "Ver pase" on Mis viajes reopens a
pass. The phase B part, blocked on ratification, is full offline rotation, including after
reopening.

**Independent Test (phase A)**:

- with the code source failing offline, the screen shows "Necesitas conexión…" with the checkpoint
  line and no QR;
- a 31 s offset shows "La hora de tu teléfono no coincide";
- a 2-minute wall-clock jump while showing hides the QR;
- a pause then a resume recomputes the code;
- with a pass issued, the Mis viajes card offers "Ver pase".

**Independent Test (phase B)**: after issuance, turn the network off. The code rotates through
several windows, from derivation alone. It survives a cold restart offline, and stops at
`validUntil`.

### Tests for User Story 2 (write first, confirm they fail)

- [X] T022 [P] [US2] Extend `test/unit/pass_viewmodel_test.dart`:
      - offline without a code gives `offlineWithoutPass`;
      - clock drift and a clock jump give `untrustedClock`, with no QR, and trust recovering on the
        next contact;
      - passing `validUntil` offline gives `expired`;
      - a resume recomputes the window and never shows the pre-pause payload.
- [X] T023 [P] [US2] Extend `test/unit/trips_home_viewmodel_test.dart` and
      `test/widget/trips_home_view_test.dart`. With `activePassFor(nextTrip)` set, the action is
      "Ver pase", enabled even when the credential is unconfirmed, and it opens the pass route.
      Without a pass, 012's rules still apply

### Implementation for User Story 2

- [X] T024 [US2] Add the offline, clock and resume handling of T022 to `PassViewModel`, until T022
      passes (depends on: T018, T022)
- [X] T025 [US2] Add `TripActionViewPass` to `lib/features/trips/trips_home_viewmodel.dart`, and
      "Ver pase" to `lib/features/trips/widgets/next_trip_card.dart`, from
      `PassRepository.activePassFor`. Inject the port in the trips route. Continue until T023 passes
      (depends on: T023, T014)

### Phase B — ⛔ BLOCKED until the constitution amendment is ratified

- [ ] T026 [US2] ⛔ **User decision**: ratify or reject contracts/constitution-amendment-proposal.md.
      If ratified, apply it to `.specify/memory/constitution.md` as version 1.5.0, with its Sync
      Impact Report, and update plan.md's Constitution Check to compliant. If rejected, drop T027–T031
      and record in spec.md that US2 is online-only
- [ ] T027 [P] [US2] ⛔ BLOCKED on T026. Write `test/unit/derived_pass_code_source_test.dart` first:
      - a fixed test vector;
      - the same window gives the same payload, and the next window gives a different one;
      - it refuses past `validUntil` and under an untrusted clock;
      - the checkpoint is bound into the MAC.
- [ ] T028 [US2] ⛔ BLOCKED on T026. Implement `lib/data/services/pass_secret_store.dart`: one
      secure-storage entry holding the secret, `validUntil`, `issuedAtServer` and the offset. Delete
      it at expiry, on `forget`, on consent withdrawal (002's path) and on credential revocation
      (012's summary). Write its tests first
- [ ] T029 [US2] ⛔ BLOCKED on T026. Implement `lib/data/services/derived_pass_code_source.dart`
      (HMAC-SHA256 with `crypto`), until T027 passes. The issuance response's `secret` goes straight
      to the store and never into any other object (depends on: T027, T028)
- [ ] T030 [US2] ⛔ BLOCKED on T026. In `lib/app/composition_root.dart`, wire
      `DerivedPassCodeSource` for the real backend. Make `activePassFor` read the store, so "Ver
      pase" survives a cold restart offline. Add the "before issuance" clock check (research.md §5)
      (depends on: T029)
- [ ] T031 [US2] ⛔ BLOCKED on T026. Write the offline tests: a pass issued, then the network off,
      rotates through three windows, survives a restart, and stops at `validUntil`. Also
      `test/unit/pass_secret_audit_test.dart`: no secret remains after expiry, boarding, withdrawal
      or revocation (SC-010)

**Checkpoint**: phase A offline behavior is honest. Phase B makes the pass work offline, after
ratification.

---

## Phase 5: User Story 3 - An expired or unusable pass has an honest recovery (Priority: P1)

**Goal**: The screen never shows a code the reader will refuse, and always gives a way forward.
This covers:

- an expired pass, with a new code requestable;
- a revoked credential or withdrawn consent;
- a changed or cancelled flight;
- a failed reissue;
- a compromised device, which goes to an agent.

**Independent Test**: Script each of `expired`, `revoked`, `flightChanged(cancelled)`, a failed
reissue and a compromised posture. Each shows its message, its action and the checkpoint line, and
no QR. A compromised device never calls `issue`. With `DEV_PASS_CONTROLS` on, "Simular expirado"
expires the pass through the fake backend; with it off, the control is absent.

### Tests for User Story 3 (write first, confirm they fail)

- [X] T032 [P] [US3] Extend `test/unit/pass_viewmodel_test.dart`:
      - every row of contracts/pass-ui.md's unavailable table;
      - `requestNewPass` success and failure, with `pass_reissue_requested`;
      - a compromised posture never calling `issue` and offering escalation;
      - `pass_expired.reason`.
- [X] T033 [P] [US3] Extend `test/widget/pass_view_test.dart`:
      - no QR in any unavailable state;
      - each message and action;
      - "Hablar con un agente" opens the escalation stub;
      - no "Simular expirado" with the flag off, the test default;
      - golden `pass_expired.png`.
- [X] T034 [P] [US3] Extend `test/contract/pass_repository_contract_test.dart` with contracts/pass-port.md
      case 5, `forget` (phase A: the memory is cleared)

### Implementation for User Story 3

- [X] T035 [US3] Implement `DevicePostureChecker`. Add `devicePosture` to the channel in
      `MainActivity.kt` and `AppDelegate.swift`, with the signals of research.md §8. Create
      `PlatformDevicePostureChecker` in `lib/data/services/platform_pass_display.dart`, and
      `DevDevicePostureChecker` (always trusted, behind the fake flag) in `lib/data/dev/`
- [X] T036 [US3] Add the unavailable states, reissue, posture refusal and events to `PassViewModel`
      and `PassView`, until T032 and T033 pass. The dev control is rendered only under
      `if (HappyPathFlags.devPassControls)` and calls `DevPassRepository.expireNow()` (depends on:
      T032, T033, T035)

**Checkpoint**: all three stories work online. Offline completeness waits on phase B.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T037 [P] Add `test/unit/pass_analytics_payload_test.dart`. It asserts that the payloads are
      enums, booleans and integers only, and that no value matches `AP1`, a flight number or a date
      (FR-015)
- [X] T038 [P] Extend `test/architecture/import_boundary_test.dart`: `lib/features/pass/` imports
      nothing from `lib/data/`, and no `developer.log` or `print` call in the pass feature or the pass
      data files takes a payload or secret argument (grep test)
- [X] T039 Trust-boundary audit, recorded in `specs/014-qr-pase/checklists/audit.md`. Confirm that:
      - no code is shown in any unavailable state;
      - no client-side expiry flag exists;
      - the dev control is flag-gated, and `assertReleaseSafe` covers it;
      - no payload or secret is logged;
      - phase A stores nothing.
- [X] T040 Run `flutter analyze` (zero issues), `dart run tool/check_release_env.dart env/prod.env`
      and the full `flutter test`, fixing any regression in 012 or the router tests
- [ ] T041 Walk quickstart.md's scenarios 1–9 on an Android device, and record the results. This
      needs the user and a device. Scenarios for offline rotation wait on phase B

---

## Dependencies & Execution Order

- **Setup (Phase 1)** and **Foundational (Phase 2)** come first. The release gate (T008) is
  foundational because the dev control depends on it.
- **US1 (Phase 3)**: the online pass end to end.
- **US2 (Phase 4)**: phase A tasks T022–T025 follow US1's ViewModel. **Phase B tasks T026–T031 wait
  on the user's ratification (T026)**; everything else can finish without them.
- **US3 (Phase 5)**: extends US1's ViewModel and view. T035, the posture channel, can run alongside
  US1.
- **Polish (Phase 6)**: after all non-blocked tasks.

## Parallel Opportunities

- Phase 1: T001 and T002.
- Phase 2: T003, then T006 alongside T007 and T008.
- US1: T009–T012 together; then T013, T015, T016 and T017 together.
- US2: T022 and T023 together. In phase B, after ratification, T027 and T028 together.
- US3: T032–T034 together, with T035 in parallel.
- Polish: T037 and T038.

## Parallel Example: User Story 1

```bash
# Tests first, together:
Task: "Pass repository contract tests in test/contract/pass_repository_contract_test.dart"
Task: "PassViewModel tests in test/unit/pass_viewmodel_test.dart"
Task: "Pass widget tests and goldens in test/widget/pass_view_test.dart"
Task: "013 placeholder -> pass route in test/widget/router_test.dart"

# Then independent files:
Task: "Pass DTOs in lib/data/models/pass_responses.dart"
Task: "BackendPassCodeSource"
Task: "DevPassRepository and DevPassCodeSource"
Task: "QR painter, rotation ring, journey stepper"
```

## Implementation Strategy

### MVP (US1)

Phases 1–3. The pass is issued, rotates, advances on validation, and ends at boarding, online, with
the release gate in place. Walk quickstart scenarios 1–5.

### Incremental delivery

1. Phases 1–2: foundation, clock trust and the release gate.
2. Phase 3: the online pass.
3. Phase 4, phase A: honest offline and clock states, and "Ver pase".
4. Phase 5: expired, revoked, flight change, reissue and device posture.
5. Phase 6: the audit and the full suite.
6. **After ratification**: Phase 4, phase B, for offline rotation.
