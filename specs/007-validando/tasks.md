---

description: "Task list for Verification In Progress (07 Validando)"
---

# Tasks: Verification In Progress (07 Validando)

**Input**: Design documents from `/specs/007-validando/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md (all
present). Builds on 001–008's shipped code. Replaces 008's verification-progress placeholder while
keeping its hand-off, extends the shared `StepIndicator` and `EnrollmentSessionController`, and
adds one read-only port. No new package dependency.

**Tests**: Included, and written before implementation. This screen decides which outcome a
passenger sees and whether an identity is declared created, which is Constitution Principle IV's
mandatory test-first territory. Each test task must fail before its implementation task starts.

**Organization**: Tasks are grouped by user story (spec.md: US1 P1, US2 P1, US3 P2).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an incomplete task)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- File paths are relative to the `AeroPass-App/` repository root
- Run `dart run build_runner build --delete-conflicting-outputs` after any task that adds or changes
  a `freezed` or `json_serializable` type

---

## Phase 1: Setup

**Purpose**: route names and copy every later phase references.

- [X] T001 Add `technicalError = '/enrollment/technical-error'` to `AppRoutes` in
      `lib/app/router.dart`, without wiring a `GoRoute` yet (research.md §10)
- [X] T002 [P] Add screen 07 and technical-error strings to `lib/l10n/app_es.arb`, then run
      `flutter gen-l10n`: header "Verificando"; title "Estamos validando tu identidad"; subtitle
      "Esto toma unos segundos. No cierres la aplicación."; stage labels "Verificando documento" /
      "Documento verificado", "Comparando rostro" / "Rostro verificado", "Creando identidad
      digital" / "Identidad digital creada"; the generic failure line "No pudimos completar la
      verificación"; the slow notice "Está tardando más de lo habitual"; actions "Seguir
      esperando" and "Ayuda"; technical-error copy stating the problem is not the passenger's and
      that the regular document check at the checkpoint is available; action "Consultar de nuevo"

---

## Phase 2: Foundational (blocking prerequisites)

**Purpose**: domain types, the port, fakes, analytics and the session change every story builds on.

**⚠️ CRITICAL**: no user story work begins until this phase is complete.

- [X] T003 [P] Create `VerificationStage` (`documentCheck`, `faceComparison`, `issuance`) and
      `StageStatus` (`pending`, `running`, `passed`, `failed`) enums in
      `lib/domain/entities/verification_stage.dart` (data-model.md)
- [X] T004 [P] Create the sealed `VerificationOutcome` (`matched`, `documentRejected`,
      `faceMismatch`, `livenessRejected`, `attackDetected`, `serviceFailure`) and the
      `VerificationOutcomeKind` enum (`activated`, `notActive`, `documentRejected`,
      `biometricRejected`, `serviceFailure`, `timedOut`) in
      `lib/domain/entities/verification_outcome.dart`
- [X] T005 Create the sealed `VerificationJobStatus` (`inProgress(documentCheck, faceComparison)`,
      `completed(outcome, documentCheck, faceComparison)`) in
      `lib/domain/entities/verification_job_status.dart` (depends on: T003, T004)
- [X] T006 Create the abstract `VerificationJobRepository` with
      `Future<Result<VerificationJobStatus>> getStatus()` and the doc comment from
      contracts/verification-job-port.md in
      `lib/domain/repositories/verification_job_repository.dart` (depends on: T005)
- [X] T007 Add the six methods of contracts/analytics-events.md to
      `lib/domain/repositories/analytics_emitter.dart` (exporting `VerificationStage`,
      `StageStatus` and `VerificationOutcomeKind`), and implement them with enum and integer
      payloads in `lib/data/services/logging_analytics_emitter.dart` (depends on: T003, T004)
- [X] T008 [P] Implement the six methods in `test/fakes/fake_analytics_emitter.dart` (depends on: T007)
- [X] T009 [P] Create `FakeVerificationJobRepository` returning a scripted sequence of results, the
      last repeating, with a call counter, in `test/fakes/fake_verification_job_repository.dart`
      (depends on: T006)
- [X] T010 Add `returnToDocumentCapture()` to `lib/app/enrollment_session_controller.dart`: set
      `stepReached` to document capture and `identityConfirmed` to `false`, and a unit test for it
      in `test/unit/enrollment_session_controller_test.dart` (research.md §11)

**Checkpoint**: types, port, fakes and analytics exist; all three stories can start.

---

## Phase 3: User Story 1 - A passenger waits through a successful verification (Priority: P1) 🎯 MVP

**Goal**: the screen polls the job, advances each stage only when reported, completes the last
stage only on a confirmed issuance, and opens screen 08 through the existing hand-off.

**Independent Test**: with the job fake scripted through running and passed stages to `matched`
and the issuance fake returning `activated`, verify the stages advance in order and never early,
Listo stays pending, and screen 08 opens.

### Tests for User Story 1 (write first, confirm they fail)

- [X] T011 [P] [US1] Contract tests for all ten cases of contracts/verification-job-port.md, the
      real implementation with a mocked `dio` and a seeded consent fake, and cases 1–3 against the
      dev fake with an injected clock, in
      `test/contract/verification_job_repository_contract_test.dart`
- [X] T012 [P] [US1] Unit tests in `test/unit/verification_progress_viewmodel_test.dart`, rewriting
      008's file: emits `verificationStepEntered`; polls on the injected interval; maps
      `inProgress` reports to stage statuses and never moves a stage backwards; on `matched` marks
      face comparison passed and issuance running, then calls `requestIssuance()` once; row R1 of
      contracts/outcome-routing.md (hand-off set, session cleared, selfie counter reset, target
      `credentialActivated`, issuance `passed`); issuance is never `passed` in any other case; a
      single failed poll changes nothing and the next tick polls again
- [X] T013 [P] [US1] Step-indicator tests for the three addendum cases in
      `test/widget/step_indicator_test.dart` (contracts/step-indicator-addendum.md)
- [X] T014 [P] [US1] Widget tests in `test/widget/verification_progress_view_test.dart`: header,
      title, subtitle and three stage rows render; stage labels switch to their completed wording
      only when passed; the indicator shows Listo pending; no personal data, document number or
      image appears; the system back gesture does nothing; stage changes call
      `SemanticsService.sendAnnouncement`; the view navigates to `credentialActivated` on R1;
      goldens at default and 200% text scale in `test/widget/goldens/`

### Implementation for User Story 1

- [X] T015 [P] [US1] Create the inbound `VerificationJobResponse` DTO with all fields nullable
      strings in `lib/data/models/verification_job_response.dart`, then run `build_runner`
- [X] T016 [US1] Create `VerificationJobService` issuing
      `GET /v1/verification/jobs/current?enrollmentAttemptId=` over the pinned `dio` in
      `lib/data/services/verification_job_service.dart` (depends on: T015)
- [X] T017 [US1] Implement `VerificationJobRepositoryImpl` in
      `lib/data/services/verification_job_repository_impl.dart`: read the attempt id from
      `ConsentRepository` (error without a request if absent); map `state`, stage statuses and
      outcome codes per data-model.md, unknown values to their safe defaults; convert every
      exception to `Result.error` (depends on: T011, T016)
- [X] T018 [P] [US1] Implement `DevVerificationJobRepository` with an injected clock: document
      running then passed at about 1.5 s after the first poll, face passed at about 3 s, then
      `completed(matched)`, in `lib/data/dev/dev_verification_job_repository.dart` (research.md §14)
- [X] T019 [US1] Wire `VerificationJobRepository` in `lib/app/composition_root.dart`, choosing the
      dev fake when `HappyPathFlags.useFakeVerificationBackend` is on (depends on: T017, T018)
- [X] T020 [US1] Add `currentStepReached` and `onLightSurface` to `StepIndicator` in
      `lib/core/design/step_indicator.dart`, both defaulting to today's behaviour, and update its
      semantics label for a pending current step (depends on: T013)
- [X] T021 [US1] Move and rewrite `VerificationProgressViewModel` from
      `lib/features/enrollment/liveness/verification_progress_viewmodel.dart` to
      `lib/features/enrollment/verification/verification_progress_viewmodel.dart`: constructor adds
      the job port, attempt counter, pending-document controller and `Clock`, plus injectable
      `pollInterval`, `slowNoticeAfter`, `hardTimeoutAfter` and `failureDisplayPause`; sealed
      `VerificationProgressViewState` (`waiting`, `failed`) per data-model.md; polling loop,
      forward-only stage updates, and the success path R1 reusing 008's issuance and hand-off;
      extend `VerificationNavigationTarget` with `documentCapture`, `retryGuidance`,
      `technicalError` (depends on: T012, T019)
- [X] T022 [P] [US1] Build `VerificationChecklist` (three rows: pending dimmed, running spinner,
      passed filled check, failed icon; each row's label from its status) in
      `lib/features/enrollment/verification/widgets/verification_checklist.dart`
- [X] T023 [P] [US1] Build `VerificationIllustration` (document card, arrow, face, inside a ring
      whose filled fraction is passed stages ÷ 3, excluded from semantics) in
      `lib/features/enrollment/verification/widgets/verification_illustration.dart`
- [X] T024 [US1] Build `VerificationProgressView` in
      `lib/features/enrollment/verification/verification_progress_view.dart`: "Verificando" header,
      `StepIndicator(currentStep: done, currentStepReached: false, onLightSurface: true)`,
      illustration, title, subtitle, checklist; `PopScope(canPop: false)`; announcements on stage
      changes; acts on the view model's one-shot navigation with `context.go` only while its route
      is current (depends on: T014, T020, T021, T022, T023)
- [X] T025 [US1] Point the verification `GoRoute` in `lib/app/router.dart` at the new view and view
      model with all its dependencies; delete
      `lib/features/enrollment/liveness/verification_progress_placeholder_view.dart` and the old
      view model file (depends on: T024)

**Checkpoint**: the offline demo walks from the selfie through three real stages to screen 08.
T011–T014 pass.

---

## Phase 4: User Story 2 - A verification that fails is routed to the right place (Priority: P1)

**Goal**: every terminal result shows the generic failure briefly on the failed stage, charges the
right counter or none, and routes to its destination.

**Independent Test**: script each job outcome and issuance result in turn and verify rows R2–R10 of
contracts/outcome-routing.md: failed stage, line, pause, counter and destination.

### Tests for User Story 2 (write first, confirm they fail)

- [X] T026 [P] [US2] Add unit tests for rows R2–R10 to
      `test/unit/verification_progress_viewmodel_test.dart`: each shows `failed` on the right
      stage, waits the injected pause, then targets the right destination; R5 calls
      `returnToDocumentCapture()` and clears the pending document; R5/R6 increment
      `documentCapture` and R6 resets it at the limit; R7–R9 increment `selfieLiveness`; R2–R4 and
      R10 increment nothing; R7, R8 and R9 produce identical state and analytics `kind`
      (`biometricRejected`); `verificationOutcome` fires once with `elapsedSeconds`
- [X] T027 [P] [US2] Widget tests in `test/widget/verification_progress_view_test.dart`: a failure
      shows the failure icon on the failed stage and "No pudimos completar la verificación",
      announces that line, and navigates after the pause; face mismatch and attack detection
      render identically
- [X] T028 [P] [US2] Router test in `test/widget/router_test.dart` that the technical-error route
      renders its placeholder and "Consultar de nuevo" returns to the verification route

### Implementation for User Story 2

- [X] T029 [US2] Implement the routing table of contracts/outcome-routing.md (rows R2–R10) in one
      switch in `lib/features/enrollment/verification/verification_progress_viewmodel.dart`,
      including counter increments, the limit check against `captureAttemptLimit`, the failure
      state, the pause and the outcome event (depends on: T026, T010)
- [X] T030 [US2] Render the `failed` state in
      `lib/features/enrollment/verification/verification_progress_view.dart` and
      `widgets/verification_checklist.dart`: failure icon on the failed row, the generic line below
      the checklist, one announcement (depends on: T027, T029)
- [X] T031 [P] [US2] Create `TechnicalErrorPlaceholderView` with the not-your-fault copy, the
      checkpoint line and "Consultar de nuevo" (`context.go(AppRoutes.verificationProgress)`) in
      `lib/features/technical_error_placeholder_view.dart`, and wire its `GoRoute` in
      `lib/app/router.dart` (research.md §10; depends on: T028)

**Checkpoint**: every failure class lands on its destination. T026–T028 pass.

---

## Phase 5: User Story 3 - The wait is interrupted, stalls, or outlives the screen (Priority: P2)

**Goal**: the notice at 10 seconds with "Seguir esperando" and help, the technical-error outcome at
30 seconds, outcomes held while help is open, and a correct resume from the background.

**Independent Test**: with injected short durations, verify the notice, its two actions, the
timeout routing with no attempt counted, the held outcome while help is open, and the elapsed-time
check on resume.

### Tests for User Story 3 (write first, confirm they fail)

- [X] T032 [P] [US3] Unit tests in `test/unit/verification_progress_viewmodel_test.dart`: the
      notice sets `slowNoticeVisible` and emits `verificationSlowNoticeShown` at `slowNoticeAfter`;
      `dismissSlowNotice()` hides it without stopping polling; at `hardTimeoutAfter` row R11 routes
      to `technicalError` with no counter touched and emits `verificationTimedOut`; `onAppResumed()`
      polls immediately and fires the timeout at once when the clock shows 30 s have passed
- [X] T033 [P] [US3] Widget tests in `test/widget/verification_progress_view_test.dart`: no control
      appears before the notice; the notice shows "Seguir esperando" and "Ayuda"; "Ayuda" pushes
      the help route and emits `verificationHelpOpened`; an outcome arriving while help is open does
      not navigate until help is closed, then does

### Implementation for User Story 3

- [X] T034 [US3] Implement the slow-notice timer, `dismissSlowNotice()`, the hard timeout (R11),
      `onAppResumed()` with the clock-based elapsed check, and `onHelpOpened()` in
      `lib/features/enrollment/verification/verification_progress_viewmodel.dart` (depends on: T032)
- [X] T035 [P] [US3] Build `SlowNotice` ("Está tardando más de lo habitual", "Seguir esperando",
      "Ayuda") in `lib/features/enrollment/verification/widgets/slow_notice.dart`
- [X] T036 [US3] In `lib/features/enrollment/verification/verification_progress_view.dart`, show
      `SlowNotice` when visible, `push` help and re-check pending navigation when it returns, and
      forward app-lifecycle resume to `onAppResumed()` (depends on: T033, T034, T035)

**Checkpoint**: all three stories work together.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T037 [P] Update the deferral table in `specs/007-validando/spec.md`: FR-008 and FR-009 are
      built, so remove their rows; keep FR-010 (relaunch recovery) and its events, and note that it
      needs no constitution amendment (research.md §1, §15)
- [X] T038 [P] Trust-boundary audit: confirm by search that no code in `lib/features/enrollment/verification/`
      or the job port submits samples or creates a job (SC-004); that `StageStatus.passed` is
      assigned to the issuance stage only in the `IssuanceActivated` branch (FR-005, SC-010); and
      that no new event payload carries personal data or isolates attack detection (FR-015, SC-007)
- [X] T039 Run `flutter analyze` with zero issues, then the full `flutter test` suite, fixing any
      regression in 003–008 tests
- [ ] T040 Walk quickstart.md's manual scenarios 1–6 on an Android device with
      `--dart-define-from-file=env/dev-offline.env`, and record the results in
      `specs/007-validando/quickstart.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: none.
- **Foundational (Phase 2)**: depends on Setup. Blocks every story.
- **US1 (Phase 3)**: depends on Foundational.
- **US2 (Phase 4)** and **US3 (Phase 5)**: depend on US1's T021 (the rewritten view model) and
  T024 (the view), since they extend both files.
- **Polish (Phase 6)**: depends on all three stories.

### User Story Dependencies

- **US1**: independent after Foundational; the minimum walkable flow.
- **US2**: extends US1's view model and view; testable alone through scripted fakes.
- **US3**: extends US1's view model and view; independent of US2.

### Within Each User Story

- Tests are written and fail before implementation.
- Domain types before services, services before the view model, the view model before the view,
  the view before routes.

## Parallel Opportunities

- Phase 2: T003 and T004 together; then T008 and T009 together.
- US1: T011, T012, T013 and T014 together; then T015, T018, T022 and T023 together.
- US2: T026, T027 and T028 together; T031 alongside T029.
- US3: T032 and T033 together; T035 alongside T034.
- US2 and US3 can run in parallel once T024 is done, coordinating on the shared view-model file.

## Parallel Example: User Story 1

```bash
# Tests first, together:
Task: "Contract tests in test/contract/verification_job_repository_contract_test.dart"
Task: "View-model unit tests in test/unit/verification_progress_viewmodel_test.dart"
Task: "Step-indicator tests in test/widget/step_indicator_test.dart"
Task: "View widget tests in test/widget/verification_progress_view_test.dart"

# Then independent files:
Task: "VerificationJobResponse DTO in lib/data/models/verification_job_response.dart"
Task: "DevVerificationJobRepository in lib/data/dev/dev_verification_job_repository.dart"
Task: "VerificationChecklist in lib/features/enrollment/verification/widgets/verification_checklist.dart"
Task: "VerificationIllustration in lib/features/enrollment/verification/widgets/verification_illustration.dart"
```

## Implementation Strategy

### MVP (US1)

Phases 1–3 make the flow walkable end to end with real stages and the unchanged 008 hand-off.
Stop and walk quickstart scenarios 1–5.

### Incremental delivery

1. Phases 1–2: foundation.
2. Phase 3: successful wait, screen 08 reached.
3. Phase 4: every failure routed and counted correctly.
4. Phase 5: notice, timeout, help, resume.
5. Phase 6: spec update, audit, full suite, device walk-through.
