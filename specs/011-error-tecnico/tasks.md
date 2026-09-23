---

description: "Task list for Service Failure (11 Error técnico)"
---

# Tasks: Service Failure (11 Error técnico)

**Input**: Design documents from `/specs/011-error-tecnico/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md (all
present). This feature replaces the technical-error placeholder that 007 routes to. It changes 007's
failure routing, the job and issuance repositories, the launch redirect and `SentryConfig`. No new
package dependency.

**Tests**: Included, and written before implementation. The entry classification, the attempt-counter
invariance, the retry destinations and the launch resume sit on the trust boundary (Constitution
Principle IV).

**Organization**: Tasks are grouped by user story: spec.md US1 (P1), US2 (P1) and US3 (P2).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an incomplete task)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- File paths are relative to the `AeroPass-App/` repository root
- Run `dart run build_runner build --delete-conflicting-outputs` after any task that adds or changes
  a `freezed` or `json_serializable` type

---

## Phase 1: Setup

- [X] T001 Add screen 11 strings to `lib/l10n/app_es.arb`, then run `flutter gen-l10n`:
      - "Ayuda".
      - The three title, subtitle and guidance sets from research.md §10:
        - service: "No pudimos completar la validación" / "Es un problema nuestro, no tuyo." /
          "Nuestro equipo ya fue notificado.";
        - connectivity: "No pudimos conectarnos" / "Parece que se perdió la conexión a internet." /
          "Revisa tu conexión y vuelve a intentarlo.";
        - undetermined: "No pudimos completar la validación" / "No fue por algo que hayas hecho.".
      - "Puedes reintentar a las {hora}.".
      - The two preservation sentences: "Tus datos del documento quedaron guardados. Al reintentar,
        solo tendrás que tomarte una nueva selfie." and "Tus datos del documento quedaron guardados.
        Al reintentar, revisaremos tu validación sin repetir fotos.".
      - The window line "Puedes retomar tu registro durante las próximas 24 horas.".
      - The card header "Estado del servicio" and step labels "Escaneo de documento", "Selfie",
        "Emisión de tu identidad".
      - Health labels "Operativo", "Con fallas", "No disponible".
      - "Reintentar", "Reintentar en {segundos} s", the held-button semantics label "Reintentar no
        disponible por {segundos} segundos", and "Salir".
- [X] T002 [P] Add `slate` and `slateTile` to `lib/core/design/app_colors.dart`. They are the neutral
      treatment of research.md §11, and each gets a doc comment saying it is neither amber nor red
      (FR-001)

---

## Phase 2: Foundational (blocking prerequisites)

**⚠️ CRITICAL**: no user story work begins until this phase is complete.

- [X] T003 [P] Create the domain types, then run `build_runner`:
      - `lib/domain/entities/transport_failure.dart`: sealed `TransportFailure` with `connectivity(cause)`
        and `service(cause)`.
      - `lib/domain/entities/service_failure.dart`: enum `ServiceFailureClass` and freezed
        `ServiceFailure` with `failureClass`, `stage`, `jobTerminal` and `occurredAt`.
      - `lib/domain/entities/service_status.dart`: enums `JourneyStep` and `StepHealth`, and freezed
        `ServiceStatus` with `steps`, `retryAfter` and a `worst` getter.
      All follow data-model.md.
- [X] T004 [P] Add optional `DateTime? resumableUntil` (default null) to both variants of
      `VerificationJobStatus` in `lib/domain/entities/verification_job_status.dart` and run
      `build_runner`. Confirm every existing test still compiles unchanged
- [X] T005 Create the ports, with doc comments taken from their contracts:
      - `ServiceStatusRepository` in `lib/domain/repositories/service_status_repository.dart`;
      - `OperationalAlertReporter` in `lib/domain/repositories/operational_alert_reporter.dart`, with
        `canClaimNotification` and `reportServiceFailure({stage})`.
      (depends on: T003)
- [X] T006 Add the five methods of contracts/analytics-events.md to
      `lib/domain/repositories/analytics_emitter.dart`. Implement them in
      `lib/data/services/logging_analytics_emitter.dart` and in `test/fakes/fake_analytics_emitter.dart`,
      with the snake_case names (depends on: T003)
- [X] T007 [P] Create the test fakes:
      - `test/fakes/fake_service_status_repository.dart`: scripted results, a `callCount`, and an error
        when nothing is scripted;
      - `test/fakes/fake_operational_alert_reporter.dart`: a settable `canClaimNotification` and a
        recorded list of stages.
      (depends on: T005)
- [X] T008 Write `test/unit/technical_error_controller_test.dart` first, per data-model.md:
      - `record` replaces any previous record;
      - `takeReportable` is true once for a `service` record and never for the other classes;
      - `registerArrival` returns 0, 15, 30, 60 and 60 s;
      - `resolve` returns the elapsed time since the first failure, or null if there was none, and
        then resets the count and clears the record.
      Use a controllable clock
- [X] T009 Implement `TechnicalErrorController` in `lib/app/technical_error_controller.dart` until
      T008 passes. Name the pacing steps as constants (Principle X) (depends on: T003, T008)

**Checkpoint**: foundation ready; user story work can begin.

---

## Phase 3: User Story 1 - A passenger learns the failure is not theirs and keeps their progress (Priority: P1) 🎯 MVP

**Goal**: A known service failure reaches a neutral screen 11 that blames the service, says exactly
what was kept, consumes no attempt, retries to the right place, and lets the passenger leave and
resume.

**Independent Test**: Script the job to complete with `serviceFailure`. Check that:

- the screen shows the service wording, the neutral tile, and the new-selfie preservation sentence;
- neither attempt counter changed;
- "Reintentar" lands on the selfie;
- "Salir" stays on welcome;
- a cold launch within `resumableUntil` lands on 007 with `identityConfirmed`.

### Tests for User Story 1 (write first, confirm they fail)

- [X] T010 [P] [US1] Extend `test/unit/verification_progress_viewmodel_test.dart`:
      - a job `completed(serviceFailure)` records `ServiceFailure(service, <running stage>,
        jobTerminal: true)` in the controller before navigating to `technicalError`;
      - neither attempt counter is incremented;
      - on `IssuanceActivated` after an earlier record, `resolve` is called and
        `technicalErrorResolved` is emitted with the elapsed seconds;
      - with no earlier record, nothing is emitted.
- [X] T011 [P] [US1] Write `test/unit/technical_error_viewmodel_test.dart` for US1:
      - the class comes from the record, and is `undetermined` when nothing is recorded;
      - `needsNewSelfie` follows `jobTerminal`;
      - `showPreservation` follows the session's `identityConfirmed`;
      - "Reintentar" targets `selfie` when `jobTerminal` and `verification` otherwise;
      - "Salir" targets `welcome` and leaves the session and record intact;
      - the entry event carries the class, stage and `jobTerminal`, and the retry and exit events
        are emitted;
      - the ViewModel never calls `CaptureAttemptCounterRepository`.
- [X] T012 [P] [US1] Write `test/widget/technical_error_view_test.dart` for US1:
      - the service wording shows;
      - the slate tile renders, with no `AppColors.amber` and no red in the tree;
      - the right preservation sentence shows for each `jobTerminal` value, the preservation tile is
        absent without `identityConfirmed`, and the 24-hour line always shows;
      - "Reintentar" and "Salir" navigate to stub routes;
      - the back gesture does not pop;
      - "Ayuda" pushes help and returning leaves the screen unchanged;
      - the title and cause are announced on open, checked with mocked `SystemChannels.accessibility`;
      - goldens `technical_error.png` and `technical_error_text_2x.png` in `test/widget/goldens/`.
      Let the tree own the ViewModel through `ChangeNotifierProvider(create:)`
- [X] T013 [P] [US1] Extend `test/widget/router_test.dart` with cases 1–9 of
      contracts/launch-routing-addendum.md. Cases 7 and 8 are the two regressions: `go(welcome)` stays
      on welcome with an open escalation, and with a resumable job. Add
      `Provider<TechnicalErrorController>` to the harness. Every existing router test must stay
      unchanged
- [X] T014 [P] [US1] Add a `resumeAfterVerification` test to the existing enrollment-session
      controller unit test. With no session, it creates one at `selfieCapture` with
      `identityConfirmed: true`. With an existing session, it is a no-op

### Implementation for User Story 1

- [X] T015 [US1] Add `resumeAfterVerification()` to `lib/app/enrollment_session_controller.dart`
      (research.md §9) (depends on: T014)
- [X] T016 [US1] In `lib/features/enrollment/verification/verification_progress_viewmodel.dart`,
      inject `TechnicalErrorController`:
      - record `ServiceFailure(service, stage, jobTerminal: true)` on `VerificationServiceFailure`
        before `_fail`;
      - call `resolve` on `IssuanceActivated` and emit `technicalErrorResolved` when it returns a
        duration.
      Keep every other 007 routing rule as it is (depends on: T009, T010)
- [X] T017 [US1] Implement `TechnicalErrorViewModel` in
      `lib/features/enrollment/technical_error/technical_error_viewmodel.dart`, per data-model.md,
      without the status poll and pacing (US2). Its dependencies are the controller, the session
      controller, the alert reporter, the analytics emitter and the `Clock`. It has
      `pendingNavigation` and `consumeNavigation()`, and imports no `material.dart` (depends on: T011,
      T016)
- [X] T018 [US1] Implement `TechnicalErrorView` in
      `lib/features/enrollment/technical_error/technical_error_view.dart`, as composition only. It
      has:
      - a top bar with "Ayuda";
      - the slate tile with `Icons.home_repair_service_outlined`;
      - the title and subtitle as a header;
      - the guidance line when non-empty;
      - a slot for the status card (US2);
      - the turquoise preservation tile with the 24-hour line;
      - a "Reintentar" `FilledButton` and a "Salir" `TextButton`;
      - `PopScope(canPop: false)`;
      - a one-time announcement of the title and cause.
      (depends on: T017)
- [X] T019 [US1] In `lib/app/router.dart`:
      - point `AppRoutes.technicalError` at `TechnicalErrorView`, with a `ChangeNotifierProvider`
        ViewModel;
      - delete `lib/features/technical_error_placeholder_view.dart` and its import;
      - update the `technicalErrorCheckAgain` usages, and remove the placeholder's strings if nothing
        else uses them.
      (depends on: T018)
- [X] T020 [US1] In `_redirect` in `lib/app/router.dart`, implement contracts/launch-routing-addendum.md:
      - run the escalation resume and the new resumable-job check only when `matchedLocation ==
        AppRoutes.splash`;
      - the job check reads `VerificationJobRepository` and `Clock` before any await;
      - on resume, call `resumeAfterVerification()` and go to `verificationProgress`.
      (depends on: T013, T015)
- [X] T021 [US1] Map `resumableUntil` from the job status response in
      `lib/data/models/` (the existing job status DTO) and
      `lib/data/services/verification_job_repository_impl.dart`. Add
      `test/contract/verification_job_repository_contract_test.dart` case 4 of
      contracts/transport-failure-addendum.md first (depends on: T004)
- [X] T022 [US1] Wire `TechnicalErrorController` in `lib/app/composition_root.dart`, and pass it to
      the 007 route in `lib/app/router.dart` (depends on: T009, T016)
- [X] T023 [US1] Add the `DEV_VERIFICATION_FAILURE` define, with values `service_failure` and `hang`,
      to `lib/data/dev/dev_verification_job_repository.dart`. It only has an effect with the fake
      backend. Document it in `env/` as unset by default (quickstart.md)

**Checkpoint**: US1 works on its own. A known service failure is shown honestly, is retried to the
right place, and is resumable.

---

## Phase 4: User Story 2 - What the screen says about the service is true (Priority: P1)

**Goal**: The status card comes only from a live source in journey vocabulary. The notification
sentence appears only when an alert is real. The retry is paced to match the guidance.

**Independent Test**: Script the status source and check each of these:

- a valid read renders three text lines, including when all are operational;
- a failed or malformed read shows no card;
- a changed read updates the card;
- the alert is reported once, and only for `service`;
- the claim shows only with `canClaimNotification`;
- the second arrival holds 15 s, and a later `retryAfter` extends the hold.

### Tests for User Story 2 (write first, confirm they fail)

- [X] T024 [P] [US2] Write `test/contract/service_status_repository_contract_test.dart`, cases 1–6
      of contracts/service-status-port.md, against the real implementation with
      `FakeHttpClientAdapter`
- [X] T025 [P] [US2] Extend `test/unit/technical_error_viewmodel_test.dart` for US2:
      - status polling every 15 s; a success sets `status`, a failure clears it, and a change
        replaces it;
      - `technicalErrorStatusShown` fires once, on the first success;
      - `reportServiceFailure` is called exactly once for a `service` record, and never for the other
        classes or with no record;
      - `showNotificationClaim` covers all four combinations of class and `canClaimNotification`;
      - pacing cases 4–6 of contracts/technical-error-routing.md, with a controllable clock;
      - both timers are cancelled on dispose.
- [X] T026 [P] [US2] Extend `test/widget/technical_error_view_test.dart` for US2:
      - the card renders the three step labels with text health, and all operational still renders
        the card;
      - no card renders without a status;
      - each health's semantics label is text;
      - the card is a live region;
      - a held button shows "Reintentar en 15 s", is disabled, and has the unavailable semantics
        label;
      - the claim sentence shows only when enabled;
      - add the golden `technical_error_status.png`.
- [X] T027 [P] [US2] Write `test/unit/sentry_before_send_test.dart`. The `beforeSend` function
      strips `user` and `request` from an event tagged `failure_class` and returns untagged events
      unchanged

### Implementation for User Story 2

- [X] T028 [P] [US2] Create the `ServiceStatusResponse` DTO in
      `lib/data/models/service_status_response.dart` with `json_serializable`, and run
      `build_runner` (depends on: T003)
- [X] T029 [US2] Implement `ServiceStatusService` in `lib/data/services/service_status_service.dart`,
      a `GET /v1/service-status` on the pinned `dio` client. Implement `ServiceStatusRepositoryImpl`
      in `lib/data/services/service_status_repository_impl.dart`, with the strict mapping and no
      request without consent. T041 adds the transport mapper later. Continue until T024 passes
      (depends on: T024, T028)
- [X] T030 [P] [US2] Implement `DevServiceStatusRepository` in
      `lib/data/dev/dev_service_status_repository.dart`. It always returns `Result.error` with "no
      status source in development" (depends on: T005)
- [X] T031 [US2] In `lib/core/sentry_config.dart`, add `alertRuleConfirmed`, read from
      `SENTRY_ALERT_RULE_CONFIRMED` and false by default. Add a top-level, testable
      `stripAlertEventPii` used as `options.beforeSend`, and continue until T027 passes. Do **not**
      change `sendDefaultPii`; research.md §7 raises it with the user (depends on: T027)
- [X] T032 [US2] Implement `SentryOperationalAlertReporter` and `NoopOperationalAlertReporter` in
      `lib/data/services/sentry_operational_alert_reporter.dart`, per
      contracts/operational-alert-port.md: the message, level, tags, fingerprint, and an isolated
      scope with no user (depends on: T005, T031)
- [X] T033 [US2] Add the status poll, alert reporting, claim visibility, pacing and `retryAfter` to
      `TechnicalErrorViewModel`, with named constants for the 15 s poll and the 1 s tick. Continue
      until T025 passes (depends on: T017, T025)
- [X] T034 [US2] Create `ServiceStatusCard` in
      `lib/features/enrollment/technical_error/widgets/service_status_card.dart`. It has:
      - the header with a dot in the worst health's color;
      - three rows of step label and health text;
      - `Semantics(liveRegion: true)` on the card, and a text label per row.
      Place it in `TechnicalErrorView`, and render the held countdown and the claim. Continue until
      T026 passes (depends on: T018, T033)
- [X] T035 [US2] Wire `ServiceStatusRepository` in `lib/app/composition_root.dart`: the dev or real
      implementation, chosen by `useFakeVerificationBackend`. Wire `OperationalAlertReporter`: Sentry
      when `SentryConfig.isEnabled`, no-op otherwise. Pass both to the screen 11 route (depends on:
      T029, T030, T032)

**Checkpoint**: US1 and US2 work. Every claim on the screen has a source.

---

## Phase 5: User Story 3 - A connectivity problem is not blamed on the service (Priority: P2)

**Goal**: A lost connection is worded as a connection problem, a timeout without evidence asserts no
cause, and the retry reconciles the same job.

**Independent Test**: Script the job port's polls to fail with `TransportFailure.connectivity` until
the hard timeout, and check the screen shows the connection wording. Script mixed results, and check
the undetermined wording. Script an issuance `TransportFailure.service`, and check the service
wording, `jobTerminal: false`, and a retry to 007 that re-requests issuance, which returns the same
token.

### Tests for User Story 3 (write first, confirm they fail)

- [X] T036 [P] [US3] Write `test/unit/transport_error_mapper_test.dart` for every `DioExceptionType`
      row in contracts/transport-failure-addendum.md, plus a non-`dio` error left unchanged
- [X] T037 [P] [US3] Extend `test/contract/verification_job_repository_contract_test.dart` and
      `test/contract/credential_issuance_repository_contract_test.dart` with cases 1–3 of
      contracts/transport-failure-addendum.md. Case 3 is two issuance requests, the first failing in
      transit, returning the same token, with `requestCount == 2`
- [X] T038 [P] [US3] Extend `test/unit/verification_progress_viewmodel_test.dart` with entry rows 2–6
      of contracts/technical-error-routing.md:
      - issuance `service`, `connectivity` and other errors;
      - a timeout after all-connectivity polls;
      - a timeout after mixed polls.
      Each records the right class with `jobTerminal: false`, and none increments a counter
- [X] T039 [P] [US3] Extend `test/widget/technical_error_view_test.dart`:
      - the connectivity wording shows and never says "problema nuestro";
      - the undetermined wording shows no cause and no guidance;
      - the claim never shows for either class, even with `canClaimNotification: true`.

### Implementation for User Story 3

- [X] T040 [US3] Implement `mapTransportError` in `lib/data/services/transport_error_mapper.dart`
      until T036 passes (depends on: T003, T036)
- [X] T041 [US3] Apply `mapTransportError` in every `catch` of
      `lib/data/services/verification_job_repository_impl.dart`,
      `lib/data/services/credential_issuance_repository_impl.dart` and
      `lib/data/services/service_status_repository_impl.dart`, until T037 passes (depends on: T040,
      T037)
- [X] T042 [US3] In `VerificationProgressViewModel`:
      - track whether every poll since opening failed with `TransportFailure.connectivity`;
      - classify issuance errors and the hard timeout per the entry table;
      - record the failure before `_fail`.
      Continue until T038 passes (depends on: T016, T041, T038)
- [X] T043 [US3] Add the idempotency clause of contracts/transport-failure-addendum.md to
      `specs/008-identidad-activa/contracts/credential-issuance-port.md`, with a note pointing to
      011 (depends on: T037)

**Checkpoint**: all three stories work.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T044 [P] Add a payload test to `test/unit/` asserting that the five new analytics methods'
      payload keys contain no field from Principle VII's forbidden list (contracts/analytics-events.md)
- [X] T045 [P] Extend the existing import-boundary test so that
      `lib/features/enrollment/technical_error/` imports nothing from `lib/data/` and nothing from a
      camera or capture package
- [X] T046 Trust-boundary audit. Confirm by search that:
      - no code in this feature writes a file, cache or secure-storage key, or touches
        `CaptureAttemptCounterRepository` (FR-002, FR-005, SC-001, SC-002);
      - the claim sentence is gated exactly as research.md §7 says (FR-006);
      - no status is rendered from copy (FR-007).
      Record the findings in `specs/011-error-tecnico/checklists/audit.md`
- [X] T047 Run `flutter analyze` with zero issues, then the full `flutter test` suite. Fix any
      regression in 007, 008, 010 or the router tests
- [ ] T048 Walk quickstart.md's manual scenarios 1–8 on an Android device and record the results in
      `specs/011-error-tecnico/quickstart.md`. This needs the user and a device. Also record the
      personal-data release gate (`sendDefaultPii`) as open until the user decides it

---

## Dependencies & Execution Order

- **Setup (Phase 1)** and **Foundational (Phase 2)** come first, and Foundational blocks every story.
- **US1 (Phase 3)**: the screen, the service-failure path, the retry destinations and the launch
  resume. T020 and T021 depend only on Foundational and T013–T015, so they can run alongside the
  view work.
- **US2 (Phase 4)**: extends US1's ViewModel and view (T017, T018). The data-layer tasks T024,
  T028–T032 only need Foundational and can start with US1.
- **US3 (Phase 5)**: T036, T037 and T040 need only Foundational. T041's status-repository part waits
  for T029, and T042 waits for T016.
- **Polish (Phase 6)**: after all stories.

Within each story, tests are written and fail before implementation. Ports come before services,
services before the ViewModel, the ViewModel before the view, and the view before routes.

## Parallel Opportunities

- Phase 1: T001 and T002.
- Phase 2: T003 and T004, then T007 once T005 is done.
- US1: T010–T014 together, then T015 and T021 alongside T016–T018.
- US2: T024–T027 together, then T028, T030 and T031 together.
- US3: T036–T039 together.
- Polish: T044 and T045.

## Parallel Example: User Story 1

```bash
# Tests first, together:
Task: "007 entry recording tests in test/unit/verification_progress_viewmodel_test.dart"
Task: "Screen 11 view-model tests in test/unit/technical_error_viewmodel_test.dart"
Task: "Screen 11 widget tests and goldens in test/widget/technical_error_view_test.dart"
Task: "Launch-resume and regression cases in test/widget/router_test.dart"
Task: "resumeAfterVerification test for the enrollment session controller"

# Then independent files:
Task: "resumeAfterVerification in lib/app/enrollment_session_controller.dart"
Task: "resumableUntil mapping in verification_job_repository_impl.dart"
```

## Implementation Strategy

### MVP (US1)

Phases 1–3. A known service failure reaches an honest, neutral screen 11 that consumes no attempt,
retries to the selfie or to 007, and survives "Salir" and a relaunch. The status card and the claim
are simply absent until US2. Walk quickstart scenarios 1, 2 and 6.

### Incremental delivery

1. Phases 1–2: the foundation and the pacing controller.
2. Phase 3: the screen, the retry destinations, launch resume, and the 010 redirect fix.
3. Phase 4: the live status card, the alert and its claim, and paced retries.
4. Phase 5: connectivity and undetermined wording, error wrapping, and issuance idempotency.
5. Phase 6: the audit, the full suite, and the device walk-through.
