---

description: "Task list for Welcome & Enrollment Entry Point (01 Bienvenida)"
---

# Tasks: Welcome & Enrollment Entry Point (01 Bienvenida)

**Input**: Design documents from `/specs/001-bienvenida/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md (all present)

**Tests**: Included and sequenced before their implementation. Constitution Principle IV
("Test-First on the Trust Boundary") makes this non-negotiable for this feature — `WelcomeViewModel`
classifies credential validity, which is trust-boundary code — so test tasks are not optional here.

**Organization**: Tasks are grouped by user story (spec.md priorities P1/P2/P3) to enable independent
implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an incomplete task)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- File paths are relative to the `AeroPass-App/` repository root (plan.md's Project Structure)

---

## Phase 1: Setup

**Purpose**: Project initialization and shared tooling

- [X] T001 Create the Flutter project skeleton per plan.md's Project Structure
      (`lib/app/`, `lib/core/`, `lib/domain/entities/`, `lib/domain/repositories/`,
      `lib/data/services/`, `lib/data/models/`, `lib/features/enrollment/welcome/widgets/`,
      `lib/l10n/`, `test/contract/`, `test/unit/`, `test/widget/`, `test/fakes/`) at the repository
      root
- [X] T002 [P] Pin the Flutter/Dart SDK via FVM: add `.fvmrc` at the repository root per
      research.md §1
- [X] T003 [P] Add primary dependencies to `pubspec.yaml`: `provider`, `go_router`, `freezed`,
      `freezed_annotation`, `json_serializable`, `build_runner`, `flutter_localizations`, `intl`,
      `flutter_secure_storage`, `dio`, `mocktail`
- [X] T004 [P] Configure `analysis_options.yaml` for the zero-warning CI gate: exhaustive-switch
      enforcement, unused-result on `Result` returns, and an import-boundary rule that fails a
      `lib/features/**/*_view.dart` file importing from `lib/data/` or `lib/domain/repositories/`
      directly (Constitution Development Workflow)
- [X] T005 [P] Configure `lib/l10n/l10n.yaml` and seed `lib/l10n/app_es.arb` (default locale) for
      `gen-l10n`, per research.md §5
- [X] T006 [P] Add a CI workflow (`.github/workflows/ci.yaml`) running `flutter analyze` and
      `flutter test`, failing the build on any generated-code diff, per Constitution Development
      Workflow CI gates

**Checkpoint**: Tooling and project skeleton ready.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core domain types, the `CredentialRepository` port (and its contract test), and app
wiring that every user story depends on.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T007 [P] Implement sealed `Result<T>` (`Ok`/`Error`) in `lib/core/result.dart`
- [X] T008 [P] Implement `Command<T>` (running/completed/error state wrapper for view actions) in
      `lib/core/command.dart`
- [X] T009 [P] Implement sealed `CredentialStatus` (`NoCredential`, `Valid`, `ExpiredOrRevoked`,
      `Unreachable`) and the `Credential` entity, per data-model.md, in
      `lib/domain/entities/credential_status.dart` and `lib/domain/entities/credential.dart`
- [X] T010 [P] Implement the `DeviceCapability` entity in
      `lib/domain/entities/device_capability.dart`
- [X] T011 [P] Implement the in-memory `EnrollmentSession` entity (sealed `EnrollmentStep`:
      `consent`, `documentCapture`, `selfieCapture`) in
      `lib/domain/entities/enrollment_session.dart`
- [X] T012 Implement the abstract `CredentialRepository` port (`getStatus() -> Result<CredentialStatus>`)
      in `lib/domain/repositories/credential_repository.dart` (depends on: T009)
- [X] T013 Write the `CredentialRepository` contract test suite — all 6 cases from
      contracts/credential-status-port.md, parametrized to run against both the fake and the real
      implementation — in `test/contract/credential_repository_contract_test.dart`. MUST fail until
      T014 and T015 exist (depends on: T012)
- [X] T014 [P] Implement `FakeCredentialRepository` (scripted responses, no network, no secure
      storage) in `test/fakes/fake_credential_repository.dart` (depends on: T012)
- [X] T015 [P] Implement `CredentialService` (`flutter_secure_storage` read + certificate-pinned
      `dio` call, per research.md §4) and `CredentialRepositoryImpl` in
      `lib/data/services/credential_service.dart` and
      `lib/data/services/credential_repository_impl.dart` (depends on: T012; makes T013 pass)
- [X] T016 [P] Implement the `AnalyticsEmitter` port, an in-memory per-launch
      `AnalyticsSessionId` generator, and a test fake, per contracts/analytics-events.md, in
      `lib/domain/repositories/analytics_emitter.dart`, `lib/core/analytics_session.dart`, and
      `test/fakes/fake_analytics_emitter.dart`
- [X] T017 Implement `EnrollmentSessionController` — app-process-scoped, in-memory holder
      enforcing "exactly one session" under repeated/concurrent activation (FR-004) — in
      `lib/app/enrollment_session_controller.dart` (depends on: T011)
- [X] T018 Implement the app composition root, wiring `CredentialRepository`, `AnalyticsEmitter`,
      and `EnrollmentSessionController` via `provider`, in `lib/app/composition_root.dart`
      (depends on: T015, T016, T017)
- [X] T019 Implement the `go_router` skeleton with routes for splash, welcome, consent-stub,
      trips-stub, recovery-stub, and terms-stub, plus deep-link entry handling, in
      `lib/app/router.dart` (depends on: T018)
- [X] T020 Wire `MaterialApp`, theme, and localization delegates in `lib/app/app.dart` (depends
      on: T019, T005)

**Checkpoint**: Foundation ready — user story implementation can now begin.

---

## Phase 3: User Story 1 - A first-time passenger decides to enroll (Priority: P1) 🎯 MVP

**Goal**: A passenger with no credential opens the app, sees the value proposition, the three
enrollment steps, and the "free" statement, with no permission requested and no data sent, and can
advance into consent with exactly one enrollment session created.

**Independent Test**: Fresh install / cleared app data → launch → confirm the welcome content
(benefit, steps, free, single primary action) renders without scrolling on the minimum supported
screen size, no camera permission is requested, and tapping the primary action advances to the
consent route.

### Tests for User Story 1

> Write these tests FIRST; confirm they FAIL before implementing this phase.

- [X] T021 [US1] Write `WelcomeViewModel` unit tests: renders `first_run` content for
      `NoCredential`, requests no permission and transmits no data prior to action, and creates
      exactly one `EnrollmentSession` under repeated/concurrent primary-action activation
      (FR-001–FR-004) in `test/unit/welcome_viewmodel_test.dart`
- [X] T022 [P] [US1] Write `WelcomeView` widget tests: loading/splash state, populated `first_run`
      state, and primary-action tap navigating to the consent route, in
      `test/widget/welcome_view_test.dart`

### Implementation for User Story 1

- [X] T023 [US1] Implement `WelcomeViewModel` core — loads `CredentialStatus` via
      `CredentialRepository` and `DeviceCapability`, exposes `first_run` content state and the
      primary-action `Command` — in `lib/features/enrollment/welcome/welcome_viewmodel.dart`
      (depends on: T009, T010, T012, T017; makes T021 pass)
- [X] T024 [P] [US1] Implement `BenefitSummary` widget (benefit + three steps + "free" copy from
      l10n) in `lib/features/enrollment/welcome/widgets/benefit_summary.dart`
- [X] T025 [P] [US1] Implement `EnrollmentStepsList` widget in
      `lib/features/enrollment/welcome/widgets/enrollment_steps_list.dart`
- [X] T026 [P] [US1] Implement `PrimaryActionButton` widget, reachable one-handed within the
      bottom half of the screen with no scrolling (FR-015), in
      `lib/features/enrollment/welcome/widgets/primary_action_button.dart`
- [X] T027 [US1] Implement `WelcomeView` composing the splash/loading and `first_run` states and
      wiring `PrimaryActionButton` to the ViewModel's `Command`, in
      `lib/features/enrollment/welcome/welcome_view.dart` (depends on: T023, T024, T025, T026;
      makes T022 pass)
- [X] T028 [US1] Implement the device-unsupported branch (FR-012): `DeviceCapability` failure
      surfaces messaging directing the passenger to the conventional airport process instead of an
      action that would fail, in `welcome_viewmodel.dart` and `welcome_view.dart` (depends on:
      T023, T027)
- [X] T029 [US1] Wire `welcome_screen_shown(first_run)` and
      `welcome_primary_action_tapped(first_run)` analytics events via `AnalyticsEmitter` in
      `welcome_viewmodel.dart` (depends on: T016, T023)
- [X] T030 [P] [US1] Add Spanish (default) copy strings for the benefit, steps, free messaging,
      and device-unsupported messaging to `lib/l10n/app_es.arb` (depends on: T005)

**Checkpoint**: User Story 1 is independently functional and testable (fresh install → welcome →
consent).

---

## Phase 4: User Story 2 - An enrolled passenger returns for their next flight (Priority: P2)

**Goal**: A passenger with a valid credential never sees the welcome screen and lands directly on
trips; a passenger with a revoked/expired credential sees an explained re-enrollment prompt, not the
first-run pitch; a passenger with no credential on a new device can reach account recovery instead
of fresh enrollment.

**Independent Test**: Seed a valid credential → launch → confirm the welcome screen never appears
and trips renders within 3 seconds. Flip the credential to revoked → relaunch → confirm the
`reenrollment_required` variant, not `first_run`. From a device with no credential, tap the
secondary action → confirm it opens credential recovery, not enrollment.

### Tests for User Story 2

- [X] T031 [US2] Write `WelcomeViewModel` unit tests: `Valid` status bypasses welcome content
      entirely; `ExpiredOrRevoked` renders `reenrollment_required` copy distinct from `first_run`;
      `Unreachable` presents the last known state with an unrefreshed indicator rather than
      treating the passenger as unenrolled (FR-005–FR-007) in
      `test/unit/welcome_viewmodel_test.dart`
- [X] T032 [P] [US2] Write a `WelcomeView` widget test: the secondary action navigates to the
      credential-recovery route, in `test/widget/welcome_view_test.dart`

### Implementation for User Story 2

- [X] T033 [US2] Implement router redirect logic that checks `CredentialStatus` before allowing
      the welcome route, routing `Valid` straight to the trips-stub route, in
      `lib/app/router.dart` (depends on: T012, T019)
- [X] T034 [P] [US2] Implement a minimal trips-surface placeholder route/view (navigation target
      only — the trips-and-pass feature itself is out of scope for this spec) in
      `lib/features/trips/trips_placeholder_view.dart`
- [X] T035 [US2] Extend `WelcomeViewModel` with the `reenrollment_required` and
      unreachable-last-known-state branches and their copy selection, in
      `welcome_viewmodel.dart` (depends on: T023; makes T031 pass)
- [X] T036 [P] [US2] Implement `SecondaryActionButton` widget, routing to the credential-recovery
      stub, in `lib/features/enrollment/welcome/widgets/secondary_action_button.dart`
- [X] T037 [US2] Implement a minimal credential-recovery placeholder route/view (entry point only,
      per spec.md Out of Scope) in
      `lib/features/enrollment/welcome/recovery_placeholder_view.dart` (depends on: T019; makes
      T032 pass)
- [X] T038 [US2] Wire `welcome_screen_shown(reenrollment_required)` and
      `welcome_secondary_action_tapped` analytics events in `welcome_viewmodel.dart` (depends on:
      T016, T035)
- [X] T039 [P] [US2] Add Spanish copy strings for the re-enrollment explanation, the
      unrefreshed-state indicator, and the secondary-action label to `lib/l10n/app_es.arb`
      (depends on: T005)

**Checkpoint**: User Stories 1 and 2 both independently functional.

---

## Phase 5: User Story 3 - A privacy-cautious passenger evaluates before committing (Priority: P3)

**Goal**: A passenger can reach a plain-language data-handling statement from the welcome screen
before any capture begins, and return to the welcome screen with no state lost and no enrollment
started.

**Independent Test**: From the welcome screen, open the privacy/data-handling terms route, confirm
plain-language coverage of what's collected/who verifies/retention/revocation, navigate back, and
confirm the welcome screen is unchanged with no `EnrollmentSession` created.

### Tests for User Story 3

- [X] T040 [US3] Write a `WelcomeView` widget test: the privacy-terms link navigates to the terms
      route, and back navigation returns to the welcome screen with no state lost, in
      `test/widget/welcome_view_test.dart`
- [X] T041 [P] [US3] Write a `WelcomeViewModel` unit test: opening the privacy terms does not
      create an `EnrollmentSession`, in `test/unit/welcome_viewmodel_test.dart`

### Implementation for User Story 3

- [X] T042 [P] [US3] Implement `PrivacyTermsLink` widget in
      `lib/features/enrollment/welcome/widgets/privacy_terms_link.dart`
- [X] T043 [US3] Implement the terms/data-handling placeholder route + view (plain-language
      statement; placeholder link per FR-011's blocking dependency on published legal URLs) in
      `lib/features/enrollment/welcome/terms_placeholder_view.dart` (depends on: T019; makes T040
      pass)
- [X] T044 [US3] Wire the `welcome_privacy_terms_opened` analytics event in
      `welcome_viewmodel.dart` (depends on: T016, T023; makes T041 pass)
- [X] T045 [P] [US3] Add Spanish copy strings for the privacy summary and terms-link label to
      `lib/l10n/app_es.arb` (depends on: T005)

**Checkpoint**: All three user stories independently functional.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Behaviors that span all three stories, plus the constitution's release gates.

- [X] T046 [US1] Implement the mid-enrollment resume banner (FR-008: process-alive only, backed by
      `EnrollmentSessionController`) with the `resume_offered` variant and its analytics event, in
      `welcome_viewmodel.dart` and `welcome_view.dart` (depends on: T017, T023, T029)
- [X] T047 [P] Verify and enforce fully offline rendering (FR-009): `WelcomeView`'s static content
      renders with no network dependency, across `lib/features/enrollment/welcome/`
- [X] T048 [P] Accessibility pass across all welcome widgets — semantic labels, AA contrast,
      dynamic-type-safe layout, no color-only state signaling (FR-014, SC-007) — in
      `lib/features/enrollment/welcome/widgets/`
- [X] T049 Run `flutter analyze` and resolve to zero warnings (Constitution Development Workflow
      gate)
- [X] T050 Run the full test suite (`flutter test`) and confirm ≥85% line coverage across
      `WelcomeViewModel` and `CredentialRepositoryImpl` (Constitution CI gate)
- [ ] T051 Execute specs/001-bienvenida/quickstart.md's manual validation scenarios 1–6 end-to-end
      on the interim minimum-spec baseline (Android 8.0 / iOS 15.0)
- [ ] T052 Measure and record cold-start splash-to-interactive timing against SC-003 (≤2s p90) and
      enrolled-launch-to-trips timing against SC-004 (≤3s) on the minimum-spec baseline device

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately.
- **Foundational (Phase 2)**: Depends on Setup completion. BLOCKS all user stories.
- **User Stories (Phase 3–5)**: All depend on Foundational completion. US1, US2, and US3 each build
  on `welcome_viewmodel.dart`/`welcome_view.dart` created in US1, so while they are independently
  *testable* (per their Independent Test above), US2 and US3's tasks are sequenced after US1's
  implementation tasks rather than fully parallel with them.
- **Polish (Phase 6)**: Depends on all three user stories being complete.

### User Story Dependencies

- **User Story 1 (P1)**: No dependency on other stories. This is the MVP slice.
- **User Story 2 (P2)**: Extends the `WelcomeViewModel`/`WelcomeView` files US1 creates; still
  independently testable per its own Independent Test.
- **User Story 3 (P3)**: Extends the same files; independently testable per its own Independent
  Test.

### Within Each User Story

- Tests are written and MUST fail before implementation (Constitution Principle IV).
- Domain/ViewModel logic before widgets; widgets before view composition.
- Story complete and checkpointed before the next priority begins (recommended sequential order,
  given the shared-file dependency above).

### Parallel Opportunities

- All Setup tasks marked [P] (T002–T006) after T001.
- All Foundational tasks marked [P] (T007–T011, T014, T016) can run in parallel; T012 depends on
  T009; T013 depends on T012; T015 depends on T012; T017 depends on T011; T018 depends on
  T015+T016+T017; T019 depends on T018; T020 depends on T019+T005.
- Within US1: T024, T025, T026, T030 are parallel (different files).
- Within US2: T034, T036, T039 are parallel (different files).
- Within US3: T042, T045 are parallel (different files).

---

## Parallel Example: User Story 1

```bash
# After T023 (WelcomeViewModel core) is done, these can run together:
Task: "Implement BenefitSummary widget in lib/features/enrollment/welcome/widgets/benefit_summary.dart"
Task: "Implement EnrollmentStepsList widget in lib/features/enrollment/welcome/widgets/enrollment_steps_list.dart"
Task: "Implement PrimaryActionButton widget in lib/features/enrollment/welcome/widgets/primary_action_button.dart"
Task: "Add Spanish copy strings to lib/l10n/app_es.arb"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup.
2. Complete Phase 2: Foundational (blocks all stories).
3. Complete Phase 3: User Story 1.
4. **STOP and VALIDATE**: run quickstart.md scenario 1 independently.
5. Demonstrable to an airport client at this point (per spec.md's stated rationale for US1's
   priority).

### Incremental Delivery

1. Setup + Foundational → foundation ready.
2. User Story 1 → validate independently → MVP.
3. User Story 2 → validate independently (protects the recurrence target).
4. User Story 3 → validate independently (privacy-cautious conversion).
5. Polish → accessibility, offline, resume, analyze/coverage gates, full quickstart pass.

---

## Notes

- [P] tasks touch different files with no incomplete-task dependency.
- [Story] labels trace each task to its user story for independent delivery.
- Tests are written first and must fail before their implementation task per Constitution
  Principle IV — this is enforced by task ordering above, not left to convention.
- Commit after each task or logical group.
- FR-011's legal terms are a documented blocking dependency (see spec.md Dependencies) — T043 ships
  against a placeholder link; swapping in the real URLs when legal delivers them is a follow-up, not
  part of this task list.
