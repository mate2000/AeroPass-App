---

description: "Task list for Identity Document Capture (03 Escanear documento)"
---

# Tasks: Identity Document Capture (03 Escanear documento)

**Input**: Design documents from `/specs/003-escanear-documento/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md (all
present). Builds on 001-bienvenida and 002-consentimiento's existing project — most tooling is
reused; the `camera` package is this feature's one new dependency (plan.md).

**Tests**: Included and sequenced before their implementation. Constitution Principle IV names both
"classification of a verification outcome" and (by direct analogy) on-device document-validity
judgement as trust-boundary code, so test tasks are not optional here.

**Organization**: Tasks are grouped by user story (spec.md priorities P1/P1/P2).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an incomplete task)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- File paths are relative to the `AeroPass-App/` repository root

---

## Phase 1: Setup

- [X] T001 Add the `camera` package dependency via `flutter pub add camera` (research.md §1) — the
      only new dependency this feature introduces.

**Checkpoint**: Ready for foundational work.

---

## Phase 2: Foundational (Blocking Prerequisites)

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T002 [P] Implement sealed `QualityAssessment`/`QualityRejectionReason` and
      `CaptureOutcome`/`CaptureRejectionReason`, per data-model.md, in
      `lib/domain/entities/capture_outcome.dart`
- [X] T003 [P] Implement `CaptureAttemptCounter` (count + lastResetAt) in
      `lib/domain/entities/capture_attempt_counter.dart`
- [X] T004 Implement the abstract `DocumentVerificationRepository` port (`submit`) in
      `lib/domain/repositories/document_verification_repository.dart` (depends on: T002)
- [X] T005 [P] Implement the abstract `DocumentQualityAssessor` port (`assess`, synchronous,
      on-device) in `lib/domain/repositories/document_quality_assessor.dart` (depends on: T002)
- [X] T006 Implement the abstract `CaptureAttemptCounterRepository` port (`read`/`increment`/
      `reset`) in `lib/domain/repositories/capture_attempt_counter_repository.dart` (depends on:
      T003)
- [X] T007 Write the `DocumentVerificationRepository` contract test suite — all 7 cases from
      contracts/document-verification-port.md — in
      `test/contract/document_verification_repository_contract_test.dart`. MUST fail until T009
      and T010 exist (depends on: T004)
- [X] T008 Write the `CaptureAttemptCounterRepository` contract test suite — all 4 cases from
      contracts/capture-attempt-counter-port.md, including the "survives a new instance" case — in
      `test/contract/capture_attempt_counter_repository_contract_test.dart`. MUST fail until T014
      and T015 exist (depends on: T006)
- [X] T009 [P] Implement `FakeDocumentVerificationRepository` in
      `test/fakes/fake_document_verification_repository.dart` (depends on: T004)
- [X] T010 [P] Implement `DocumentVerificationService` (certificate-pinned `dio` via the existing
      `buildPinnedDio`) and `DocumentVerificationRepositoryImpl`, owning the processor-error →
      `CaptureRejectionReason` mapping, in
      `lib/data/services/document_verification_service.dart` and
      `lib/data/services/document_verification_repository_impl.dart` (depends on: T004; makes T007
      pass)
- [X] T011 [P] Implement `FakeDocumentQualityAssessor` in
      `test/fakes/fake_document_quality_assessor.dart` (depends on: T005)
- [X] T012 Add synthetic fixture images to `test/fixtures/` and write the 6-case test suite from
      contracts/quality-assessor-port.md in `test/unit/heuristic_quality_assessor_test.dart`. MUST
      fail until T013 exists (depends on: T005)
- [X] T013 Implement `HeuristicQualityAssessor` (blur/glare/framing/resolution/wrong-document
      heuristics, per research.md §2) in `lib/data/services/heuristic_quality_assessor.dart`
      (depends on: T005; makes T012 pass)
- [X] T014 [P] Implement `FakeCaptureAttemptCounterRepository` in
      `test/fakes/fake_capture_attempt_counter_repository.dart` (depends on: T006)
- [X] T015 [P] Implement `CaptureAttemptCounterService` (`flutter_secure_storage`, reusing the
      existing instance) and `CaptureAttemptCounterRepositoryImpl` in
      `lib/data/services/capture_attempt_counter_service.dart` and
      `lib/data/services/capture_attempt_counter_repository_impl.dart` (depends on: T006; makes
      T008 pass)
- [X] T016 [P] Implement `CameraCaptureService` wrapping the `camera` plugin — preview lifecycle,
      torch toggle, manual still capture returning in-memory bytes with no temp file surviving the
      call (FR-010, research.md §1) — in `lib/data/services/camera_capture_service.dart` (depends
      on: T001)
- [X] T017 Wire `DocumentVerificationRepository`, `DocumentQualityAssessor`, and
      `CaptureAttemptCounterRepository` into the app composition root via `provider` in
      `lib/app/composition_root.dart` (depends on: T010, T013, T015)

**Checkpoint**: Foundation ready — user story implementation can now begin.

---

## Phase 3: User Story 1 - A passenger captures their document on the first attempt (Priority: P1) 🎯 MVP

**Goal**: With a current consent record, the camera opens after permission is granted, the
passenger captures, the image is assessed on-device before anything transmits, an accepted capture
advances to data confirmation with the step indicator updated, and no image survives on the device
afterward.

**Independent Test**: With consent recorded, open the capture step, capture a well-lit fixture
document, and verify the image is accepted, extraction proceeds (via the fake), and no image
reference remains after advancing.

### Tests for User Story 1

> Write these tests FIRST; confirm they FAIL before implementing this phase.

- [X] T018 [US1] Write `CaptureViewModel` unit tests: the consent-currency gate (FR-001), the
      permission-gating states, and the happy path (capture → usable assessment → accepted
      submission → advance, with the attempt counter reset and no image bytes retained afterward)
      in `test/unit/capture_viewmodel_test.dart`
- [X] T019 [P] [US1] Write `CaptureView` widget tests: permission-request/denied-temporary state,
      the live-preview state, and a successful capture navigating to the data-confirmation route
      with the step indicator updated, in `test/widget/capture_view_test.dart`

### Implementation for User Story 1

- [X] T020 [US1] Implement `CaptureViewModel` core — consent-currency check via
      `ConsentRepository`, camera permission flow, capture → assess → submit orchestration, and
      attempt-counter increment/reset — in
      `lib/features/enrollment/capture/capture_viewmodel.dart` (depends on: T004, T005, T006, T017;
      makes T018 pass)
- [X] T021 [P] [US1] Implement `ViewfinderOverlay` widget (turquoise corner brackets, scan line,
      framing guide) in `lib/features/enrollment/capture/widgets/viewfinder_overlay.dart`
- [X] T022 [P] [US1] Implement `TorchToggle` widget, reachable one-handed (FR-005), in
      `lib/features/enrollment/capture/widgets/torch_toggle.dart`
- [X] T023 [P] [US1] Implement `CaptureButton` widget with a single-activation guard regardless of
      repeated/rapid taps (FR-016) in `lib/features/enrollment/capture/widgets/capture_button.dart`
- [X] T024 [P] [US1] Implement `StepIndicator` widget (Documento/Selfie/Listo, reflecting actual
      progress, FR-011) in `lib/features/enrollment/capture/widgets/step_indicator.dart`
- [X] T025 [US1] Implement `CaptureView` composing the camera preview, viewfinder overlay, hint
      text, torch/capture controls, top bar ("‹ Atrás" / "Ayuda"), and step indicator, in
      `lib/features/enrollment/capture/capture_view.dart` (depends on: T020, T021, T022, T023,
      T024; makes T019 pass)
- [X] T026 [US1] Replace the document-capture route's placeholder builder in `lib/app/router.dart`
      with `CaptureView`, and add the consent-currency guard (FR-001: redirect to the consent gate
      when no current consent record exists) to `_redirect` (depends on: T025)
- [X] T027 [US1] Implement the data-confirmation placeholder route/view (004 stub — the success
      destination) in
      `lib/features/enrollment/capture/document_confirmation_placeholder_view.dart`, registered in
      `lib/app/router.dart` (depends on: T026)
- [X] T028 [US1] Wire `capture_step_entered`, `capture_attempted`, and `capture_accepted` analytics
      events via `AnalyticsEmitter` in `capture_viewmodel.dart` (depends on: T020)
- [X] T029 [P] [US1] Add Spanish copy strings for the screen's chrome (instruction, hint, caption,
      permission-rationale) to `lib/l10n/app_es.arb`
- [X] T030 [US1] Delete the now-unused
      `lib/features/enrollment/document_capture_placeholder_view.dart` (002-consentimiento's stub)
      (depends on: T026)

**Checkpoint**: User Story 1 is independently functional and testable.

---

## Phase 4: User Story 2 - A capture is unusable and the passenger is told exactly why (Priority: P1)

**Goal**: Every on-device rejection reason produces a specific, actionable inline message with
immediate retry; a device-rejected capture never reaches verification; a verification rejection is
translated into the same vocabulary; the 3rd failure routes to retry guidance.

**Independent Test**: Deliberately capture blurred/glared/cropped/wrong-document fixtures and
verify each produces its specific message without consuming a verification call; exhaust 3 attempts
and verify routing to retry guidance.

### Tests for User Story 2

- [X] T031 [US2] Write `CaptureViewModel` unit tests: each device-rejection reason increments the
      counter and never calls `DocumentVerificationRepository.submit`; a verification rejection maps
      to the same vocabulary; reaching 3 failures routes to retry guidance and resets the counter
      (FR-006–FR-009) in `test/unit/capture_viewmodel_test.dart`
- [X] T032 [P] [US2] Write `CaptureView` widget tests: the error-state frame plus inline message for
      each rejection reason, retry available immediately, and the error conveyed by text/icon (not
      the red frame alone) in `test/widget/capture_view_test.dart`

### Implementation for User Story 2

- [X] T033 [US2] Extend `CaptureViewModel` with the error-state branches and attempt-limit routing
      in `capture_viewmodel.dart` (depends on: T020; makes T031 pass)
- [X] T034 [P] [US2] Implement `InlineErrorMessage` widget (per-reason text + icon, red frame
      indicator) in `lib/features/enrollment/capture/widgets/inline_error_message.dart`
- [X] T035 [US2] Wire `InlineErrorMessage` into `CaptureView`'s error state in `capture_view.dart`
      (depends on: T025, T034; makes T032 pass)
- [X] T036 [US2] Implement the retry-guidance placeholder route/view (009 stub) in
      `lib/features/retry_guidance_placeholder_view.dart`, registered in `lib/app/router.dart`
      (depends on: T026)
- [X] T037 [US2] Wire `capture_device_rejected`, `capture_verification_rejected`, and
      `capture_attempt_limit_reached` analytics events in `capture_viewmodel.dart` (depends on:
      T028, T033)
- [X] T038 [P] [US2] Add Spanish copy strings for each rejection reason's actionable message to
      `lib/l10n/app_es.arb`

**Checkpoint**: User Stories 1 and 2 both independently functional.

---

## Phase 5: User Story 3 - A passenger who cannot complete the capture gets out cleanly (Priority: P2)

**Goal**: A denied camera permission, an offline submission attempt, "Ayuda," and "Atrás" all end
somewhere useful rather than at a camera that will never work.

**Independent Test**: Deny the camera permission and verify the explanation/settings-route/
conventional-process messaging; exhaust the attempt limit separately; verify both land on a route
with a concrete next step.

### Tests for User Story 3

- [X] T039 [US3] Write `CaptureViewModel` unit tests: temporary vs. permanent permission denial (no
      repeated system prompt after permanent denial), and offline submission blocked with retry
      messaging rather than queued (FR-014, FR-015) in `test/unit/capture_viewmodel_test.dart`
- [X] T040 [P] [US3] Write `CaptureView` widget tests: permission-denied messaging with the
      settings route, "Ayuda" round-tripping with the session intact, and "Atrás" discarding any
      held image while preserving the session as incomplete, in `test/widget/capture_view_test.dart`

### Implementation for User Story 3

- [X] T041 [US3] Implement the permission-denied (temporary/permanent) and offline-blocked branches
      in `CaptureViewModel` in `capture_viewmodel.dart` (depends on: T020; makes T039 pass)
- [X] T042 [P] [US3] Implement `PermissionDeniedMessage` widget (explanation, system-settings
      route, conventional-airport-process statement) in
      `lib/features/enrollment/capture/widgets/permission_denied_message.dart`
- [X] T043 [US3] Wire `PermissionDeniedMessage` into `CaptureView`'s permission-denied state in
      `capture_view.dart` (depends on: T025, T042; makes T040 pass)
- [X] T044 [US3] Implement the help placeholder route/view (round-trips with the enrollment session
      intact) and the agent-escalation placeholder route/view (010 stub — FR-017's alternative
      route for passengers who can't complete a visual capture) in
      `lib/features/help_placeholder_view.dart` and
      `lib/features/agent_escalation_placeholder_view.dart`, registered in `lib/app/router.dart`
      (depends on: T026)
- [X] T045 [US3] Implement back-navigation handling — discard any held image, preserve the
      enrollment session as incomplete rather than cancelled (FR-012) — in
      `capture_viewmodel.dart`/`capture_view.dart` (depends on: T020, T025; makes T040's "Atrás"
      assertion pass)
- [X] T046 [P] [US3] Add Spanish copy strings for permission-denied and offline-blocked messaging to
      `lib/l10n/app_es.arb`

**Checkpoint**: All three user stories independently functional.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T047 [P] Implement camera lifecycle handling — `WidgetsBindingObserver`-driven stop/reinit on
      backgrounding, lock, and interruption, never presenting a frozen frame as live (Edge Cases,
      research.md §5) — in `capture_view.dart`/`capture_viewmodel.dart`
- [X] T048 [P] Accessibility pass: confirm every error state is conveyed by text/icon and not color
      alone, and that the screen-reader/framing edge case routes to the agent-path alternative
      (FR-017) rather than presenting an unusable screen, across
      `lib/features/enrollment/capture/widgets/`
- [X] T049 Run `flutter analyze` and resolve to zero warnings (Constitution Development Workflow
      gate)
- [X] T050 Run the full test suite (`flutter test`) and confirm ≥85% line coverage across
      `CaptureViewModel`, `DocumentVerificationRepositoryImpl`, `HeuristicQualityAssessor`, and
      `CaptureAttemptCounterRepositoryImpl` (Constitution CI gate)
- [ ] T051 Execute specs/003-escanear-documento/quickstart.md's manual validation scenarios 1–3
      end-to-end on a real device/emulator with camera support (Android 8.0 / iOS 15.0 baseline)
- [ ] T052 Verify SC-004 on a device that has completed enrollment: zero document images found in
      the app's own storage/cache/logs/crash reports — explicitly excluding OS-level screenshots,
      per the Clarifications scoping of SC-004

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies.
- **Foundational (Phase 2)**: Depends on Setup. BLOCKS all user stories.
- **User Stories (Phase 3–5)**: All depend on Foundational. US2 and US3 extend files US1 creates
  (`capture_viewmodel.dart`, `capture_view.dart`, `router.dart`), so — matching 001/002's precedent
  — they're independently *testable* per their own Independent Test but sequenced after US1's
  implementation tasks.
- **Polish (Phase 6)**: Depends on all three user stories.

### Parallel Opportunities

- Foundational: T002, T003, T005 in parallel; T009/T010 in parallel once T004 exists; T011 in
  parallel with T012→T013's chain; T014/T015 in parallel once T006 exists; T016 independent of
  everything except T001.
- Within US1: T021, T022, T023, T024, T029 in parallel once T020 exists.
- Within US2: T034 and T038 in parallel with the T033→T035 chain.
- Within US3: T042 and T046 in parallel with the T041→T043 chain.

---

## Parallel Example: Foundational Phase

```bash
# After T004 (DocumentVerificationRepository port) exists, these can run together:
Task: "Implement FakeDocumentVerificationRepository in test/fakes/fake_document_verification_repository.dart"
Task: "Implement DocumentVerificationService + DocumentVerificationRepositoryImpl in lib/data/services/"

# Independently, once T001 (camera dependency) is added:
Task: "Implement CameraCaptureService in lib/data/services/camera_capture_service.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Setup → Foundational (blocks everything; this is the phase where the `camera` dependency, the
   three new ports, and the durable attempt counter all land).
2. User Story 1 → **STOP and VALIDATE**: quickstart.md scenario 1 on a real device.
3. User Story 2 → validate independently (the failure path that keeps the funnel from leaking paid
   verifications).
4. User Story 3 → validate independently (the exits that keep this screen from ever being a dead
   end).
5. Polish → lifecycle handling, accessibility, analyze/coverage gates, full quickstart pass,
   SC-004's on-device audit.

---

## Notes

- [P] tasks touch different files with no incomplete-task dependency.
- Tests are written first and must fail before their implementation task, per Constitution
  Principle IV.
- This is the first feature in the app requiring a physical device or emulator with camera support
  for full validation (T051) — the automated suite (T007, T008, T012, and the unit/widget tests)
  still runs entirely headless.
- T030 deletes 002-consentimiento's placeholder, not kept alongside the real implementation, same
  pattern as 002's own T023 deleting 001-bienvenida's consent stub.
