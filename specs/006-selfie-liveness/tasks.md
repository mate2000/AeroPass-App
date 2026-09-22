---

description: "Task list for Liveness Capture (06 Selfie · liveness)"
---

# Tasks: Liveness Capture (06 Selfie · liveness)

**Input**: Design documents from `/specs/006-selfie-liveness/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md (all
present). Builds on 001–005's shipped code — this feature adds substantial new code AND modifies
two already-shipped contracts: 003's `CaptureAttemptCounterRepository` (generalized to serve two
independent steps) and 004's `DocumentConfirmationViewModel` (a new session flag this screen's
reachability guard depends on). No new package dependency.

**Tests**: Included. This screen decides a verification outcome's classification and gates access
via the reachability guard — both squarely within Constitution Principle IV's mandatory
test-first-on-the-trust-boundary requirement, more so than any screen since 003/004.

**Organization**: Tasks are grouped by user story (spec.md priorities P1/P1/P2).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an incomplete task)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- File paths are relative to the `AeroPass-App/` repository root

---

## Phase 1: Setup

**Purpose**: the two cross-cutting fixes to already-shipped 003/004 code this feature's design
requires (research.md §3, §4) — landed first so every later phase builds on the final shape.

- [X] T001 [P] Add the `AttemptCounterScope` enum (`documentCapture`, `selfieLiveness`) to
      `lib/domain/entities/capture_attempt_counter.dart` (research.md §3)
- [X] T002 Add a required `AttemptCounterScope scope` parameter to `CaptureAttemptCounterRepository`'s
      `read`/`increment`/`reset` in `lib/domain/repositories/capture_attempt_counter_repository.dart`
      (depends on: T001)
- [X] T003 Update `CaptureAttemptCounterService` to derive its secure-storage key pair from `scope`,
      keeping the `documentCapture` keys byte-identical to 003's existing
      `aeropass.capture.document.*` keys, in `lib/data/services/capture_attempt_counter_service.dart`
      (depends on: T001; contracts/attempt-counter-port-addendum.md)
- [X] T004 Update `CaptureAttemptCounterRepositoryImpl` to forward `scope` to the service in
      `lib/data/services/capture_attempt_counter_repository_impl.dart` (depends on: T002, T003)
- [X] T005 [P] Update `FakeCaptureAttemptCounterRepository` to be scope-aware (independent counters
      per scope) in `test/fakes/fake_capture_attempt_counter_repository.dart` (depends on: T002)
- [X] T006 Update `test/contract/capture_attempt_counter_repository_contract_test.dart` for the new
      signature — re-run 003's existing 4 cases once per scope, plus the 2 new
      scope-independence cases from contracts/attempt-counter-port-addendum.md (depends on: T004,
      T005)
- [X] T007 Update `CaptureViewModel`'s 3 attempt-counter call sites to pass
      `AttemptCounterScope.documentCapture` in
      `lib/features/enrollment/capture/capture_viewmodel.dart`, and update
      `test/unit/capture_viewmodel_test.dart`'s assertions accordingly (depends on: T002; regression
      coverage for 003)
- [X] T008 [P] Add `identityConfirmed` (`@Default(false) bool`) to `EnrollmentSession` in
      `lib/domain/entities/enrollment_session.dart` (research.md §4)
- [X] T009 Add `markIdentityConfirmed()` to `EnrollmentSessionController` in
      `lib/app/enrollment_session_controller.dart` (depends on: T008)
- [X] T010 Inject `EnrollmentSessionController` into `DocumentConfirmationViewModel` and call
      `markIdentityConfirmed()` in `_confirm()`'s success branch, alongside the existing
      `_pendingDocumentController.clear()`, in
      `lib/features/enrollment/confirmation/document_confirmation_viewmodel.dart`; update the
      `documentConfirmation` route's ViewModel construction in `lib/app/router.dart` to supply it
      (depends on: T009)
- [X] T011 Update `test/unit/document_confirmation_viewmodel_test.dart` to assert
      `markIdentityConfirmed()` is called on a successful confirm and NOT called on a failed one
      (depends on: T010; regression coverage for 004)

**Checkpoint**: Ready for foundational work.

---

## Phase 2: Foundational (Blocking Prerequisites)

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T012 [P] Implement `LivenessInstruction` (sealed) and `LivenessPhase` in
      `lib/domain/entities/liveness_phase.dart` (data-model.md)
- [X] T013 [P] Implement `LivenessOutcome` (sealed) and `LivenessQualityReason` in
      `lib/domain/entities/liveness_outcome.dart`
- [X] T014 [P] Implement `LivenessSampleOutcome` (sealed: `inProgress`/`completed`) in
      `lib/domain/entities/liveness_sample_outcome.dart` (depends on: T012, T013)
- [X] T015 Implement the abstract `LivenessVerificationRepository` port (`startSession`,
      `submitSample`) in `lib/domain/repositories/liveness_verification_repository.dart` (depends
      on: T014)
- [X] T016 [P] Implement the abstract `LivenessCameraService` port (`start`/`stop`/`controller`/
      `sampleFrame`) in `lib/data/services/liveness_camera_service.dart` (contracts/liveness-camera
      -service-port.md)
- [X] T017 Write the `LivenessVerificationRepository` contract test suite — all 8 cases from
      contracts/liveness-verification-port.md — in
      `test/contract/liveness_verification_repository_contract_test.dart`. MUST fail until T020 and
      T022 exist (depends on: T015)
- [X] T018 Write the `LivenessCameraService` contract test suite — all 6 cases from
      contracts/liveness-camera-service-port.md — in
      `test/contract/liveness_camera_service_contract_test.dart`. MUST fail until T016's real
      implementation (T023) exists (depends on: T016)
- [X] T019 [P] Implement `FakeLivenessVerificationRepository` in
      `test/fakes/fake_liveness_verification_repository.dart` (depends on: T015)
- [X] T020 [P] Implement `liveness_sample_response.dart` (inbound DTO), `LivenessVerificationService`
      (certificate-pinned `dio`), and `LivenessVerificationRepositoryImpl` — owning the processor's
      phase/instruction/outcome-code → domain-vocabulary mapping, with the "unrecognized code falls
      back to `unclassifiedFailure`" guard — in `lib/data/models/liveness_sample_response.dart`,
      `lib/data/services/liveness_verification_service.dart`, and
      `lib/data/services/liveness_verification_repository_impl.dart` (depends on: T015; makes T017
      pass)
- [X] T021 [P] Implement `FakeLivenessCameraService` in
      `test/fakes/fake_liveness_camera_service.dart` (depends on: T016)
- [X] T022 [P] Implement `FrontCameraLivenessService` (front-lens `camera` plugin wrapper,
      `startImageStream`-backed `sampleFrame()`) in `lib/data/services/liveness_camera_service.dart`
      (same file as T016's abstract class, mirroring `camera_capture_service.dart`'s own precedent)
      (depends on: T016; makes T018 pass)
- [X] T023 [P] Implement `DevLivenessVerificationRepository` (always succeeds after a fixed 4-phase
      scripted sequence, ignores `frameBytes`, gated by `HappyPathFlags.useFakeVerificationBackend`)
      in `lib/data/dev/dev_liveness_verification_repository.dart` (research.md §10, depends on:
      T015)
- [X] T024 [P] Implement `DevLivenessCameraService` (no real camera, scripted frames) in
      `lib/data/dev/dev_liveness_camera_service.dart` (depends on: T016)
- [X] T025 Add 7 new methods to `AnalyticsEmitter` — `livenessStepEntered`, `livenessPhaseReached`,
      `livenessOutcome`, `livenessAttemptCount`, `livenessAttemptLimitReached`, `livenessStalled`,
      `livenessStepAbandoned` — in `lib/domain/repositories/analytics_emitter.dart`, and implement
      them in `lib/data/services/logging_analytics_emitter.dart` and
      `test/fakes/fake_analytics_emitter.dart` (contracts/analytics-events.md)
- [X] T026 Add `AppRoutes.verificationProgress` and register `VerificationProgressPlaceholderView`
      (007 stub — the success destination) in `lib/app/router.dart`, implemented in
      `lib/features/enrollment/liveness/verification_progress_placeholder_view.dart`
- [X] T027 Wire `LivenessVerificationRepository`, `LivenessCameraService` (dev vs. real per
      `HappyPathFlags.useFakeVerificationBackend`, mirroring 004's existing pattern) into
      `lib/app/composition_root.dart`, and add the reachability guard — redirect to
      `AppRoutes.documentCapture` when `EnrollmentSessionController.current?.identityConfirmed` is
      not `true` — to `lib/app/router.dart`'s `_redirect` for the liveness route (research.md §4;
      depends on: T020, T022, T023, T024)

**Checkpoint**: Foundation ready — user story implementation can now begin.

---

## Phase 3: User Story 1 - A passenger completes the liveness capture hands-free (Priority: P1) 🎯 MVP

**Goal**: The front camera opens automatically with no shutter, the passenger is guided by a
changing instruction and a phase indicator that only advances, progress reflects the capture's real
state, and a successful attempt advances to verification with no frame surviving on the device.

**Independent Test**: From the instructions screen, complete a capture in good light (the
always-succeeding dev fake) and verify the capture proceeds without any touch, progress is
displayed continuously and never regresses, the flow advances to the verification-progress stub,
and no frame survives afterward.

### Tests for User Story 1

> Write these tests FIRST; confirm they FAIL before implementing this phase.

- [X] T028 [US1] Write `LivenessCaptureViewModel` unit tests: the sample loop calls `startSession()`
      then repeatedly `submitSample()`; each `inProgress` response updates phase/progress (index
      only ever increases); a terminal `success` outcome resets the selfie-liveness attempt counter
      and sets navigation to verification progress; no frame is retained after any exit — in
      `test/unit/liveness_capture_viewmodel_test.dart`
- [X] T029 [P] [US1] Write `LivenessCaptureView` widget tests: the camera surface renders with the
      oval overlay and no shutter control; the instruction text and phase dots update as the
      ViewModel's state changes; the progress badge reflects `phase.index/totalPhases`, never a
      visible timer; tapping/touching the capture surface has no effect; a successful outcome
      navigates to the verification-progress route — in
      `test/widget/liveness_capture_view_test.dart`

### Implementation for User Story 1

- [X] T030 [US1] Implement `LivenessCaptureViewState` (sealed: at least `loading`/`running`/
      `outcome`) in `lib/features/enrollment/liveness/liveness_capture_view_state.dart`
- [X] T031 [US1] Implement `LivenessCaptureViewModel` core — owns `LivenessCameraService` lifecycle,
      runs the `startSession`/`submitSample` loop on a fixed sampling interval, tracks
      `LivenessAttempt` (data-model.md), announces each instruction change via
      `SemanticsService.announce` + `HapticFeedback` (research.md §6) — in
      `lib/features/enrollment/liveness/liveness_capture_viewmodel.dart` (depends on: T015, T016,
      T025, T027; makes T028 pass)
- [X] T032 [P] [US1] Implement `LivenessOvalOverlay` widget (oval frame + turquoise progress arc,
      `CustomPainter`) in `lib/features/enrollment/liveness/widgets/liveness_oval_overlay.dart`
- [X] T033 [P] [US1] Implement `PhaseIndicator` widget (dots sized to `totalPhases`, index-only-
      advances) in `lib/features/enrollment/liveness/widgets/phase_indicator.dart`
- [X] T034 [P] [US1] Implement `LivenessInstructionBanner` widget (dynamic instruction text) in
      `lib/features/enrollment/liveness/widgets/liveness_instruction_banner.dart`
- [X] T035 [US1] Implement `LivenessCaptureView` composing the top bar ("‹ Atrás"/"Ayuda"), shared
      `StepIndicator(currentStep: .selfie)`, the camera surface with `LivenessOvalOverlay`, the
      progress percentage badge, `LivenessInstructionBanner`, `PhaseIndicator`, and the automatic-
      capture footer text — absorbing all touch input on the capture surface (FR-018) — in
      `lib/features/enrollment/liveness/liveness_capture_view.dart` (depends on: T031, T032, T033,
      T034; makes T029 pass)
- [X] T036 [US1] Replace the liveness-capture route's placeholder builder with the real
      `LivenessCaptureViewModel`/`LivenessCaptureView` in `lib/app/router.dart` (depends on: T035)
- [X] T037 [P] [US1] Add Spanish copy strings (footer, progress badge format, phase-1 instructions)
      to `lib/l10n/app_es.arb`
- [X] T038 [US1] Delete the now-unused
      `lib/features/enrollment/selfie/liveness_capture_placeholder_view.dart` (005's stub) (depends
      on: T036)

**Checkpoint**: User Story 1 is independently functional and testable.

---

## Phase 4: User Story 2 - A capture that cannot be completed ends cleanly, without coaching an attacker (Priority: P1)

**Goal**: A quality failure shows specific, actionable guidance; an unclassified failure and a
detected attack render the exact same generic message; every outcome's specific classification
reaches the selfie-liveness attempt counter and local analytics; the 3rd failure routes to retry
guidance; no failure ever leaves the passenger with no forward action.

**Independent Test**: Script quality failures and verify each returns specific guidance; script an
unclassified failure and an attack-detected outcome and verify their rendered output is byte-for-
byte identical; verify the attempt counter increments independently of document capture's; verify
the 3rd failure routes to retry guidance.

### Tests for User Story 2

- [X] T039 [US2] Extend `LivenessCaptureViewModel` unit tests: a `qualityFailure(reason)` outcome
      surfaces the specific message key for that reason; `unclassifiedFailure` and `attackDetected`
      outcomes both surface the identical shared generic message key; each non-success outcome
      increments the `selfieLiveness`-scoped attempt counter (leaving `documentCapture`'s untouched);
      the 3rd such increment routes to retry guidance and resets the counter — in
      `test/unit/liveness_capture_viewmodel_test.dart`
- [X] T040 [P] [US2] Extend `LivenessCaptureView` widget tests: the specific quality-failure message
      renders distinctly per reason; the unclassified-failure and attack-detected states render
      pixel-for-pixel the same widget tree (compare via `find` assertions on the exact same text/
      widget type, never a reason-specific string); a retry affordance is present below the limit;
      the screen is never left with no forward action — in
      `test/widget/liveness_capture_view_test.dart`
- [X] T041 [P] [US2] Add a dedicated regression test asserting `LivenessOutcome.unclassifiedFailure()`
      and `LivenessOutcome.attackDetected()` are distinct domain values even though the view
      collapses them to the same message (guards research.md §7's "the port itself MUST still
      report the true classification" invariant) — in `test/unit/liveness_capture_viewmodel_test.dart`

### Implementation for User Story 2

- [X] T042 [US2] Extend `LivenessCaptureViewModel` with outcome handling — the
      `qualityFailure`/`unclassifiedFailure`/`attackDetected` branches, attempt-counter
      increment/reset (`AttemptCounterScope.selfieLiveness`), and attempt-limit routing to retry
      guidance — in `liveness_capture_viewmodel.dart` (depends on: T031; makes T039, T041 pass)
- [X] T043 [P] [US2] Implement `LivenessFailureMessage` widget — one branch for
      `qualityFailure(reason)` (specific copy per reason), one shared branch for
      `unclassifiedFailure`/`attackDetected` (identical copy and styling, sourced from the same
      widget construction, not two near-duplicate ones) — in
      `lib/features/enrollment/liveness/widgets/liveness_failure_message.dart`
- [X] T044 [US2] Wire `LivenessFailureMessage` and a retry action into `LivenessCaptureView`'s
      failure state, and the retry-guidance route (existing 009 stub) for the attempt-limit case, in
      `liveness_capture_view.dart` (depends on: T035, T042, T043; makes T040 pass)
- [X] T045 [US2] Wire `liveness_outcome`, `liveness_attempt_count`, and
      `liveness_attempt_limit_reached` analytics events — `liveness_outcome` carrying the full
      classification including `attackDetected` (research.md §8) — in `liveness_capture_viewmodel.dart`
      (depends on: T025, T042)
- [X] T046 [P] [US2] Add Spanish copy strings for each `LivenessQualityReason` and the single shared
      generic-failure message to `lib/l10n/app_es.arb`

**Checkpoint**: User Stories 1 and 2 both independently functional.

---

## Phase 5: User Story 3 - A passenger stops, is interrupted, or cannot be captured at all (Priority: P2)

**Goal**: Backgrounding, device lock, an incoming call, or back navigation all abort the capture and
discard every held frame; the enrollment session survives as incomplete; help reaches the agent
path; a stalled capture ends with an explanation instead of continuing indefinitely.

**Independent Test**: Interrupt a capture by backgrounding, by simulating an incoming call, and by
navigating back; verify in each case that held frames are discarded, the session survives as
incomplete, and a route to help remains available. Separately, let an attempt stall past the time
limit and verify it ends with an explanation.

### Tests for User Story 3

- [X] T047 [US3] Extend `LivenessCaptureViewModel` unit tests: `onBackNavigation()` aborts the
      capture, discards the held session id/frame, and preserves the enrollment session as
      incomplete; a stall timer firing after 45s with no terminal outcome surfaces FR-013's
      explanation state; `onAppBackgrounded()` stops the camera and discards held data — in
      `test/unit/liveness_capture_viewmodel_test.dart`
- [X] T048 [P] [US3] Extend `LivenessCaptureView` widget tests: "Atrás" pops the route and discards
      held state; "Ayuda" reaches the agent-escalation route (not a retry loop); a simulated
      lifecycle-paused event stops the camera preview — in `test/widget/liveness_capture_view_test.dart`

### Implementation for User Story 3

- [X] T049 [US3] Implement the 45-second stall `Timer` (research.md §9) — cancelled on any terminal
      outcome, firing the stall explanation state otherwise — in `liveness_capture_viewmodel.dart`
      (depends on: T031; makes T047's stall case pass)
- [X] T050 [US3] Implement `onAppBackgrounded()`/`onAppResumed()` on the ViewModel and
      `WidgetsBindingObserver` wiring in the view (mirrors 003's `CaptureView` exactly) in
      `liveness_capture_viewmodel.dart`/`liveness_capture_view.dart` (depends on: T031, T035; makes
      T047's backgrounding case and T048's lifecycle case pass)
- [X] T051 [US3] Implement `onBackNavigation()` (abort, discard, preserve session as incomplete) and
      wire it via `PopScope`, mirroring 003/004/005's identical pattern, in
      `liveness_capture_viewmodel.dart`/`liveness_capture_view.dart` (depends on: T031, T035; makes
      T047's back-navigation case and T048's "Atrás" case pass)
- [X] T052 [US3] Wire "Ayuda" to the existing help route, confirming it leads onward to the
      agent-escalation route rather than back into this screen's retry loop, in
      `liveness_capture_view.dart` (depends on: T035; makes T048's "Ayuda" case pass)
- [X] T053 [US3] Wire `liveness_stalled` and `liveness_step_abandoned` analytics events in
      `liveness_capture_viewmodel.dart` (depends on: T025, T049, T051)
- [X] T054 [P] [US3] Add Spanish copy strings for the stall explanation to `lib/l10n/app_es.arb`

**Checkpoint**: All three user stories independently functional.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T055 [P] Accessibility pass: confirm every instruction change is announced via
      `SemanticsService.announce` and accompanied by haptic feedback (FR-005/SC-009), and that the
      specific and shared-generic failure states are conveyed by text, never color alone, across
      `lib/features/enrollment/liveness/widgets/`
- [X] T056 Run `flutter analyze` and resolve to zero warnings (Constitution Development Workflow
      gate)
- [X] T057 Run the full test suite (`flutter test`) and confirm no regression in 003's and 004's
      suites after the attempt-counter generalization (T001–T007) and the `identityConfirmed`
      addition (T008–T011) — per quickstart.md's explicit regression list
- [X] T058 Execute specs/006-selfie-liveness/quickstart.md's manual validation scenarios 1–3 and the
      reachability-guard check end-to-end on a real device (depends on: all user stories)
- [X] T059 Verify SC-005 on a device that has completed this step: zero frames, images, or
      biometric templates found on disk, in caches, in logs, or in crash reports
- [X] T060 Verify SC-006 by reviewing the complete passenger-facing message set for this screen and
      confirming none discloses an attack-detection signal (the `LivenessFailureMessage` widget's
      shared branch is the single point to review)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies. Lands the two cross-feature fixes 003/004 need before this
  feature's own code can be built against their final shape.
- **Foundational (Phase 2)**: Depends on Setup. BLOCKS all user stories.
- **User Stories (Phase 3–5)**: All depend on Foundational. US2 and US3 extend files US1 creates
  (`liveness_capture_viewmodel.dart`, `liveness_capture_view.dart`), so — matching 003/004/005's
  precedent — they're independently *testable* per their own Independent Test but sequenced after
  US1's implementation tasks.
- **Polish (Phase 6)**: Depends on all three user stories.

### Parallel Opportunities

- Setup: T001 and T008 in parallel (independent files); T005 in parallel with T003/T004's chain
  once T002 exists.
- Foundational: T012/T013 in parallel; T016 independent of T012–T015; T019/T020 in parallel once
  T015 exists; T021/T022 in parallel once T016 exists; T023/T024 in parallel with everything else
  in this phase.
- Within US1: T032, T033, T034, T037 in parallel once T031 exists.
- Within US2: T040/T041 in parallel with each other; T043 and T046 in parallel with the
  T042→T044 chain.
- Within US3: T048 in parallel with T047; T054 in parallel with the T049→T051 chain.

---

## Parallel Example: Foundational Phase

```bash
# Once T015 (LivenessVerificationRepository port) exists, these can run together:
Task: "Implement FakeLivenessVerificationRepository in test/fakes/fake_liveness_verification_repository.dart"
Task: "Implement LivenessVerificationService + LivenessVerificationRepositoryImpl in lib/data/services/"

# Independently, once T016 (LivenessCameraService port) exists:
Task: "Implement FakeLivenessCameraService in test/fakes/fake_liveness_camera_service.dart"
Task: "Implement FrontCameraLivenessService in lib/data/services/liveness_camera_service.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Setup → Foundational (blocks everything; this is the phase where the attempt-counter
   generalization, the `identityConfirmed` session flag, both new ports, and their dev/fake/real
   implementations all land).
2. User Story 1 → **STOP and VALIDATE**: quickstart.md scenario 1, with the always-succeeding dev
   fake.
3. User Story 2 → validate independently (the failure taxonomy that enforces this screen's
   zero-false-accept, no-attacker-coaching objective).
4. User Story 3 → validate independently (the interruption/exit paths that keep this screen from
   ever stranding a passenger or outliving a frame past the moment it was taken).
5. Polish → accessibility pass, analyze/coverage gates, the two prior features' regression suites,
   full quickstart pass, the SC-005 on-device audit, the SC-006 message-set review.

---

## Notes

- [P] tasks touch different files with no incomplete-task dependency.
- Tests are written first and must fail before their implementation task, per Constitution
  Principle IV — mandatory here, not just expected, since this screen decides a verification
  outcome's classification.
- T001–T011 are this feature's two deliberate touches of already-shipped 003/004 code
  (research.md §3, §4) — each called out individually so the regression risk is tracked
  task-by-task rather than folded silently into new-feature work (verified in T057).
- T038 deletes 005-instrucciones-selfie's placeholder, not kept alongside the real implementation,
  same pattern as every prior feature's own stub-deletion task.
- T041's regression test exists specifically to prevent a future refactor from "simplifying" the
  domain model by merging `unclassifiedFailure`/`attackDetected` into one value — they must stay
  distinct at the port/domain level even though the view deliberately renders them identically.
