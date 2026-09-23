---

description: "Task list for Credential Activated (08 Identidad activa)"
---

# Tasks: Credential Activated (08 Identidad activa)

**Input**: Design documents from `/specs/008-identidad-activa/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md (all
present). Builds on 001–006's shipped code. Adds a new screen, an issue-only credential port, an
in-memory hand-off and a screen-capture port, and changes three shipped pieces: 001's
`CredentialService`, 002's `ConsentRepositoryImpl.withdraw()`, and 006's verification-progress
placeholder. No new package dependency.

**Tests**: Included, and written before implementation. This feature decides which credential state
the app displays and writes the credential itself, which is Constitution Principle IV's
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

**Purpose**: route names and copy that every later phase references.

- [X] T001 Add `credentialActivated = '/enrollment/credential-activated'`,
      `credentialDetail = '/credential'` and
      `credentialNotActive = '/enrollment/credential-not-active'` to `AppRoutes` in
      `lib/app/router.dart`, without wiring any `GoRoute` yet (research.md §5, §11)
- [X] T002 [P] Add every screen 08 and placeholder string to `lib/l10n/app_es.arb`: title "Tu
      identidad digital está activa"; the qualified subtitle from research.md §10; card label
      "IDENTIDAD DIGITAL"; "Creada el {date}"; "Válida hasta {date}"; badge "ACTIVA"; the masked
      document semantics label "Documento terminado en {last4}, {country}"; actions "Ir a mis
      viajes" and "Ver mi identidad"; the trips empty-state copy from research.md §11; and short
      placeholder copy for the credential detail and not-active routes. Then run `flutter gen-l10n`

---

## Phase 2: Foundational (blocking prerequisites)

**Purpose**: the domain types, ports, hand-off and fakes that both P1 stories build on.

**⚠️ CRITICAL**: no user story work begins until this phase is complete.

- [X] T003 [P] Create the `CredentialLifecycleStatus` enum (`active`, `expired`, `revoked`,
      `suspended`, `withdrawn`) in `lib/domain/entities/credential_lifecycle_status.dart`
      (data-model.md)
- [X] T004 [P] Create the `freezed` `ActivatedCredential` (`holderName`, `documentLast4`,
      `issuingCountry`, `issuedAt`, `validUntil`, with no `status` and no `token` field) in
      `lib/domain/entities/activated_credential.dart` (data-model.md)
- [X] T005 Create the sealed `IssuanceOutcome` (`activated(ActivatedCredential)`,
      `notActive(CredentialLifecycleStatus)`, `incomplete()`) plus the `IssuanceOutcomeKind` enum
      (`activated`, `notActive`, `incomplete`, `transportError`) in
      `lib/domain/entities/issuance_outcome.dart` (depends on: T003, T004)
- [X] T006 [P] Create the `OnwardRoute` enum (`trips`, `credentialDetail`, `backGestureToTrips`) in
      `lib/domain/entities/onward_route.dart`
- [X] T007 Create the abstract `CredentialIssuanceRepository` with
      `Future<Result<IssuanceOutcome>> requestIssuance()` and the doc comment from
      contracts/credential-issuance-port.md in
      `lib/domain/repositories/credential_issuance_repository.dart` (depends on: T005)
- [X] T008 Add `credentialIssuanceRequested()`,
      `credentialIssuanceOutcome({required IssuanceOutcomeKind kind})`,
      `credentialActivatedShown()` and `credentialActivatedRouteTaken({required OnwardRoute route})`
      to `lib/domain/repositories/analytics_emitter.dart`, and implement all four in
      `lib/data/services/logging_analytics_emitter.dart` with enum-only payloads
      (contracts/analytics-events.md; depends on: T005, T006)
- [X] T009 [P] Implement the four new methods in `test/fakes/fake_analytics_emitter.dart`, recording
      each call and its argument (depends on: T008)
- [X] T010 Create `ActivatedCredentialHandoff` (`current`, `hasCredential`, `set`, `consume`,
      `clear`), an app-process-scoped `ChangeNotifier` mirroring `PendingDocumentController`, in
      `lib/app/activated_credential_handoff.dart` (research.md §4; depends on: T004)
- [X] T011 [P] Create `FakeCredentialIssuanceRepository` with a scriptable next result and a call
      counter in `test/fakes/fake_credential_issuance_repository.dart` (depends on: T007)
- [X] T012 [P] Create the abstract `ScreenCaptureGuard` (`enable`, `disable`) and a no-op
      implementation for iOS in `lib/data/services/screen_capture_guard.dart`
      (contracts/screen-capture-guard-port.md)
- [X] T013 [P] Create `FakeScreenCaptureGuard` recording `enable`/`disable` calls, with an option
      to make `enable` throw, in `test/fakes/fake_screen_capture_guard.dart` (depends on: T012)
- [X] T014 Register `ActivatedCredentialHandoff` and `ScreenCaptureGuard` as providers in
      `lib/app/composition_root.dart`, choosing the no-op guard on iOS for now (depends on: T010,
      T012)

**Checkpoint**: domain types, ports, hand-off and fakes exist; both P1 stories can start.

---

## Phase 3: User Story 1 - A passenger sees that enrollment worked and knows what they now have (Priority: P1) 🎯 MVP

**Goal**: given a confirmed credential in the hand-off, screen 08 shows it correctly, masks the
document, states validity, makes no coverage claim, and offers both onward routes and the back
gesture to trips.

**Independent Test**: set a synthetic `ActivatedCredential` in the hand-off, open the route, and
verify the card's fields, the masked document and its spoken label, the absence of stat tiles and
portrait, both actions, and the back gesture landing on trips.

### Tests for User Story 1 (write first, confirm they fail)

- [X] T015 [P] [US1] Unit tests in `test/unit/credential_activated_viewmodel_test.dart`: consumes the
      hand-off exactly once on creation; formats "•••• 7890 · COL"; builds the spoken label
      "Documento terminado en 7890, Colombia" and falls back to spelling the code for an unmapped
      country; formats both dates with `d MMM y` in `es`; emits `credentialActivatedShown` once;
      each of `goToTrips`, `openCredentialDetail` and `onBackGesture` emits its `OnwardRoute`
      exactly once (research.md §8, §9; contracts/analytics-events.md)
- [X] T016 [P] [US1] Widget tests in `test/widget/credential_activated_view_test.dart`: title,
      qualified subtitle, card fields and "ACTIVA" badge render; no text contains an airport or
      airline count; no image widget sits in the portrait position, only the generic icon;
      "Mateo González Restrepo" with a long surname wraps to at most two lines with an ellipsis
      while its semantics label is the full name; the document line's semantics label is the
      spoken form; no back button is rendered; a system back gesture lands on trips; each action
      navigates to its route; `ScreenCaptureGuard.enable` is called on show and `disable` on
      leave, and a throwing `enable` still renders the screen (FR-002–FR-007, FR-012, FR-014,
      FR-017, FR-018)
- [X] T017 [US1] Golden tests for the settled screen, at default and 200% text scale, in
      `test/widget/credential_activated_view_test.dart` (Constitution Principle IV golden
      requirement; same file as T016, so after it)

### Implementation for User Story 1

- [X] T018 [US1] Implement `CredentialActivatedViewModel` in
      `lib/features/enrollment/credential_activated/credential_activated_viewmodel.dart`: constructor
      takes the hand-off and `AnalyticsEmitter`; consumes the credential;
      exposes the formatted strings, a small `COL` → "Colombia" country map with spelled-out
      fallback, and the three navigation `Command`s (depends on: T015, T010, T008)
- [X] T019 [P] [US1] Build `SuccessMarker` (turquoise circle with a check over the navy header, using
      `lib/core/design/app_colors.dart`) in
      `lib/features/enrollment/credential_activated/widgets/success_marker.dart`
- [X] T020 [P] [US1] Build `CredentialCard` (label, name with `maxLines: 2` and ellipsis wrapped in a
      full-name `Semantics`, masked document with its spoken `Semantics` label, "Creada el",
      "Válida hasta", "ACTIVA" badge, generic silhouette icon) in
      `lib/features/enrollment/credential_activated/widgets/credential_card.dart` (research.md §8)
- [X] T021 [US1] Build `CredentialActivatedView` in
      `lib/features/enrollment/credential_activated/credential_activated_view.dart`: composition
      only; `PopScope(canPop: false)` routing the gesture to `onBackGesture` then
      `context.go(AppRoutes.trips)`; no back button; no stat tiles; calls
      `ScreenCaptureGuard.enable` in `initState` and `disable` in `dispose`, swallowing and
      logging an `enable` failure without personal data (depends on: T018, T019, T020, T014)
- [X] T022 [US1] Add the Android `aeropass/screen_capture` method channel with `setSecure` and
      `clearSecure`, toggling `WindowManager.LayoutParams.FLAG_SECURE`, to
      `android/app/src/main/kotlin/com/aeropass/aeropass_app/MainActivity.kt`, and the Dart
      `PlatformScreenCaptureGuard` calling it in `lib/data/services/screen_capture_guard.dart`;
      select it on Android in `lib/app/composition_root.dart` (research.md §13; depends on: T012,
      T014)
- [X] T023 [P] [US1] Create `CredentialDetailPlaceholderView` in
      `lib/features/credential/credential_detail_placeholder_view.dart`, following
      `TripsPlaceholderView`'s pattern (research.md §11)
- [X] T024 [US1] Wire `GoRoute`s for `AppRoutes.credentialActivated` (building the ViewModel with
      `ChangeNotifierProvider`, like the liveness route) and `AppRoutes.credentialDetail` in
      `lib/app/router.dart`, with no guard yet (depends on: T021, T023)

**Checkpoint**: with a hand-off set by a test, screen 08 is complete. T015–T017 pass.

---

## Phase 4: User Story 2 - The credential's state is the backend's, not the screen's (Priority: P1)

**Goal**: screen 08 opens only after the backend issues an active, complete credential; the
credential is stored before it is shown; non-active and incomplete results go elsewhere; re-entry
never re-shows the screen; withdrawal deletes the stored credential.

**Independent Test**: script the issuance fake to return each outcome and verify only `activated`
reaches screen 08; open the route with an empty hand-off and verify the redirect for each status;
withdraw consent and verify the stored credential is gone and a relaunch lands on welcome.

### Tests for User Story 2 (write first, confirm they fail)

- [X] T025 [P] [US2] Contract tests for all nine cases of contracts/credential-issuance-port.md,
      run against the dev fake and the real implementation (real one with a mocked `dio` and an
      in-memory secure-storage double), in
      `test/contract/credential_issuance_repository_contract_test.dart`
- [X] T026 [P] [US2] Unit tests in `test/unit/verification_progress_viewmodel_test.dart`: requests
      issuance on creation and emits `credentialIssuanceRequested`; on `activated`, sets the
      hand-off, clears `EnrollmentSessionController`, emits the outcome event and targets
      `credentialActivated`; on `notActive` and `incomplete`, leaves the hand-off empty and targets
      `credentialNotActive`; on `Result.error`, shows the failed state and a retry that requests
      again (research.md §1, §7)
- [X] T027 [P] [US2] Router tests in `test/widget/router_test.dart` for every row of research.md §5's
      guard table, including a full hand-off with consent not active (redirect to splash and the
      hand-off cleared)
- [X] T028 [P] [US2] Add the five regression cases of contracts/consent-withdrawal-addendum.md to
      `test/contract/consent_repository_contract_test.dart`, and a hand-off-cleared case to
      `test/unit/withdrawal_viewmodel_test.dart`

### Implementation for User Story 2

- [X] T029 [P] [US2] Create the inbound `CredentialIssuanceResponse` DTO with all fields nullable in
      `lib/data/models/credential_issuance_response.dart`, then run `build_runner`
      (data-model.md)
- [X] T030 [US2] Add `writeCachedCredential({token, validUntil})` and `clearCachedCredential()` to
      `lib/data/services/credential_service.dart`, using the existing `tokenKey` and
      `validUntilKey`, and update its "this screen only ever reads" doc comment
- [X] T031 [US2] Create `CredentialIssuanceService` posting `{ enrollmentAttemptId }` to
      `/v1/credential/issuance` over the pinned `dio` in
      `lib/data/services/credential_issuance_service.dart` (depends on: T029)
- [X] T032 [US2] Implement `CredentialIssuanceRepositoryImpl` in
      `lib/data/services/credential_issuance_repository_impl.dart`: reads the
      `EnrollmentAttemptId` from the local consent record; applies research.md §2's five mapping
      rules in order; on `activated`, writes token and `validUntil` through `CredentialService`
      and returns `Result.error` if the write throws; converts every exception at this boundary
      (depends on: T025, T030, T031)
- [X] T033 [P] [US2] Implement `DevCredentialIssuanceRepository` returning `activated` with holder
      "Mateo González Restrepo", last four "7890", country "COL", issued now and valid five years,
      and writing the same two keys, in `lib/data/dev/dev_credential_issuance_repository.dart`
      (research.md §14; depends on: T030)
- [X] T034 [US2] Wire `CredentialIssuanceRepository` in `lib/app/composition_root.dart`, choosing the
      dev fake when `HappyPathFlags.useFakeVerificationBackend` is on (depends on: T032, T033)
- [X] T035 [US2] Implement `VerificationProgressViewModel` and its sealed
      `VerificationProgressViewState` (`requesting`, `failed`) in
      `lib/features/enrollment/liveness/verification_progress_viewmodel.dart` (depends on: T026,
      T034, T010)
- [X] T036 [US2] Convert `lib/features/enrollment/liveness/verification_progress_placeholder_view.dart`
      to render the ViewModel's state (spinner, or message plus retry) and to act on its
      navigation target with `context.go`, keeping placeholder visuals; update its `GoRoute` in
      `lib/app/router.dart` to build the ViewModel (depends on: T035)
- [X] T037 [P] [US2] Create `CredentialNotActivePlaceholderView` in
      `lib/features/enrollment/credential_activated/credential_not_active_placeholder_view.dart` and
      wire its `GoRoute` in `lib/app/router.dart` (research.md §11)
- [X] T038 [US2] Add the screen 08 guard to `_redirect` in `lib/app/router.dart`, implementing
      research.md §5's table: hand-off plus active consent passes; empty hand-off with a valid or
      last-known-valid status goes to `credentialDetail`; otherwise splash; a full hand-off
      without active consent is cleared and goes to splash (depends on: T027, T024)
- [X] T039 [US2] Change `ConsentRepositoryImpl.withdraw()` in
      `lib/data/services/consent_repository_impl.dart` to call
      `CredentialService.clearCachedCredential()` right after writing the `withdrawalPending`
      record and before backend delivery, returning `Result.error` if clearing throws; inject
      `CredentialService` through the constructor and update `lib/app/composition_root.dart`
      (contracts/consent-withdrawal-addendum.md; depends on: T028, T030)
- [X] T040 [US2] Make `WithdrawalViewModel` clear `ActivatedCredentialHandoff` after a successful
      withdrawal in `lib/features/account/withdrawal_viewmodel.dart`, and pass the hand-off at its
      route in `lib/app/router.dart` (depends on: T028, T010)

**Checkpoint**: the offline demo walks from liveness to screen 08 through the fake backend; every
re-entry and withdrawal rule holds. T025–T028 pass.

---

## Phase 5: User Story 3 - A newly enrolled passenger with no trip yet still has somewhere to go (Priority: P2)

**Goal**: the primary route's destination explains how a trip becomes associated, instead of
developer text (FR-008, not relaxable).

**Independent Test**: open the trips route with no trips and verify the passenger-facing
explanation is shown.

### Tests for User Story 3 (write first, confirm they fail)

- [X] T041 [P] [US3] Widget test in `test/widget/trips_placeholder_view_test.dart` asserting the
      localized "Aún no tienes viajes…" explanation renders and no developer-facing placeholder
      text remains

### Implementation for User Story 3

- [X] T042 [US3] Replace the developer text in `lib/features/trips/trips_placeholder_view.dart` with
      the localized explanation from `lib/l10n/app_es.arb`, and update its doc comment to note it
      now carries FR-008 until spec 012 (depends on: T041, T002)

**Checkpoint**: all three stories work together.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T043 [P] Update the spec's deferral table in `specs/008-identidad-activa/spec.md` so FR-012's
      row reads "iOS only" now that Android blocking ships (research.md §13)
- [X] T044 [P] Trust-boundary audit: confirm by search that `ActivatedCredential(` is constructed
      only in `lib/data/services/credential_issuance_repository_impl.dart`,
      `lib/data/dev/dev_credential_issuance_repository.dart` and tests, and that no analytics
      call in the new code passes a name, digits, country, date or token (FR-001, FR-015,
      SC-001)
- [X] T045 Run `flutter analyze` with zero issues, then the full `flutter test` suite, fixing any
      regression in 001, 002, 004 or 006 tests
- [ ] T046 Walk quickstart.md's manual scenarios 1–8 on an Android device with
      `--dart-define-from-file=env/dev-offline.env`, and record the results in
      `specs/008-identidad-activa/quickstart.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: none.
- **Foundational (Phase 2)**: depends on Setup. Blocks every story.
- **US1 (Phase 3)** and **US2 (Phase 4)**: both depend on Foundational only, and can run in
  parallel. US2's T038 guard also needs US1's T024 route to exist.
- **US3 (Phase 5)**: depends on Setup's T002 only.
- **Polish (Phase 6)**: depends on all three stories.

### User Story Dependencies

- **US1**: testable alone by setting the hand-off in a test. Not walkable end to end without US2.
- **US2**: testable alone through the fakes and router tests. Its end-to-end demo needs US1's
  screen.
- **US3**: independent.

### Within Each User Story

- Tests are written and fail before implementation.
- Domain types before services, services before ViewModels, ViewModels before views, views before
  routes.

## Parallel Opportunities

- Phase 2: T003, T004 and T006 together; then T009, T011, T012 and T013 together.
- US1: T015 and T016 together, then T017; then T019, T020 and T023 together.
- US2: T025, T026, T027 and T028 together; then T029 and T033 alongside T030.
- US3 can proceed entirely in parallel with US1 and US2.

## Parallel Example: User Story 2

```bash
# Tests first, together:
Task: "Contract tests for the issuance port in test/contract/credential_issuance_repository_contract_test.dart"
Task: "Unit tests in test/unit/verification_progress_viewmodel_test.dart"
Task: "Router guard tests in test/widget/router_test.dart"
Task: "Withdrawal regression cases in test/contract/consent_repository_contract_test.dart"

# Then independent implementation files:
Task: "CredentialIssuanceResponse DTO in lib/data/models/credential_issuance_response.dart"
Task: "DevCredentialIssuanceRepository in lib/data/dev/dev_credential_issuance_repository.dart"
```

## Implementation Strategy

### MVP (US1 and US2 together)

The two P1 stories are one deliverable: US1 is the screen, US2 is the only legitimate way to reach
it. Complete Phases 1–4, then stop and walk quickstart scenarios 1–8 in the offline demo.

### Incremental delivery

1. Phases 1–2: foundation.
2. Phase 3: screen 08 verified with a test hand-off.
3. Phase 4: real entry path, guard and withdrawal fix. The flow is now walkable end to end.
4. Phase 5: trips copy.
5. Phase 6: audit, full suite, device walk-through.
