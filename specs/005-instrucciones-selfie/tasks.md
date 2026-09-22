---

description: "Task list for Selfie Instructions (05 Instrucciones selfie)"
---

# Tasks: Selfie Instructions (05 Instrucciones selfie)

**Input**: Design documents from `/specs/005-instrucciones-selfie/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md (all
present). Builds on 001–004's shipped code — this feature relocates two prior features' dev-flag
constants (research.md §4) and adds one required parameter to a shared widget two prior features
already call (research.md §2). No new dependency.

**Tests**: Included. This screen sits outside Constitution Principle IV's mandatory trust-boundary
ordering (it decides no identity state, credential validity, or verification outcome), but tests
are still written first here as the project's general craft standard — and the
`HappyPathFlags.assertReleaseSafe` guard is exactly the kind of small, easy-to-get-backwards logic
worth testing rigorously, since it's the mechanism the constitution's v1.4.0 amendment depends on.

**Organization**: Tasks are grouped by user story (spec.md priorities P1/P2).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an incomplete task)
- **[Story]**: Which user story this task belongs to (US1, US2)
- File paths are relative to the `AeroPass-App/` repository root

---

## Phase 1: Setup

- [X] T001 [P] Create `HappyPathFlags` (`useFakeConsentBackend`, `useFakeVerificationBackend`,
      `assertReleaseSafe({bool releaseMode = kReleaseMode})`) in
      `lib/core/happy_path_flags.dart`, relocating the two constants currently private to
      `composition_root.dart` (research.md §4, contracts/happy-path-flags-contract.md)
- [X] T002 Update `lib/app/composition_root.dart` to read `_useFakeConsentBackend`/
      `_useFakeVerificationBackend` from `HappyPathFlags` instead of its own private constants,
      removing the now-duplicate declarations (depends on: T001)
- [X] T003 Call `HappyPathFlags.assertReleaseSafe()` as the first statement in `lib/main.dart`,
      before `runApp` (depends on: T001)
- [X] T004 [P] Add the `EnrollmentProgressStep` enum (`document`, `selfie`, `done`) and a required
      `currentStep` parameter to `StepIndicator`, computing each segment's complete/active/upcoming
      state by ordinal comparison (data-model.md), in `lib/core/design/step_indicator.dart`
      (research.md §2)
- [X] T005 Update `lib/features/enrollment/capture/capture_view.dart`'s `StepIndicator` call site
      to pass `currentStep: EnrollmentProgressStep.document` (depends on: T004)
- [X] T006 Update `lib/features/enrollment/confirmation/document_confirmation_view.dart`'s
      `StepIndicator` call site to pass `currentStep: EnrollmentProgressStep.document` (depends
      on: T004)

**Checkpoint**: Ready for foundational work.

---

## Phase 2: Foundational (Blocking Prerequisites)

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T007 [P] Write the `HappyPathFlags.assertReleaseSafe` test suite — all 4 cases from
      contracts/happy-path-flags-contract.md — in `test/unit/happy_path_flags_test.dart` (depends
      on: T001)
- [X] T008 Add 4 new methods to `AnalyticsEmitter` — `selfieInstructionsStepEntered()`,
      `selfieInstructionsAdvanced()`, `selfieInstructionsHelpOpened()`,
      `selfieInstructionsStepAbandoned()` — in `lib/domain/repositories/analytics_emitter.dart`
- [X] T009 [P] Implement the 4 new methods in `lib/data/services/logging_analytics_emitter.dart`
      (depends on: T008)
- [X] T010 [P] Implement the 4 new methods in `test/fakes/fake_analytics_emitter.dart` (depends
      on: T008)
- [X] T011 Add `AppRoutes.livenessCapture` and register `LivenessCapturePlaceholderView` (006
      stub — the success destination) in `lib/app/router.dart`

**Checkpoint**: Foundation ready — user story implementation can now begin.

---

## Phase 3: User Story 1 - A passenger arrives at the capture knowing what is expected (Priority: P1) 🎯 MVP

**Goal**: The screen states why a facial capture is needed and the three conditions as positive
actions, previews the capture framing, shows the step indicator as document-complete/selfie-active,
and a single action advances to the (stubbed) liveness capture step — with no camera activated and
nothing gated.

**Independent Test**: Reach the screen from data confirmation, verify the purpose and the three
conditions are present and legible, and verify the single action advances to liveness capture with
no camera ever active on this screen.

### Tests for User Story 1

> Write these tests FIRST; confirm they FAIL before implementing this phase.

- [X] T012 [US1] Write `SelfieInstructionsViewModel` unit tests: construction calls
      `EnrollmentSessionController.advanceTo(EnrollmentStep.selfieCapture())` and emits
      `selfie_instructions_step_entered`; `advance` command completion emits
      `selfie_instructions_advanced`; the ViewModel makes no repository or camera call of any kind
      — in `test/unit/selfie_instructions_viewmodel_test.dart`
- [X] T013 [P] [US1] Write `SelfieInstructionsView` widget tests: title, subtitle, and all three
      conditions are visible; the step indicator shows "Documento" complete and "Selfie" active;
      tapping "Tomar selfie" navigates to the liveness-capture placeholder route; no
      `CameraPreview`/camera widget is ever present on this screen — in
      `test/widget/selfie_instructions_view_test.dart`

### Implementation for User Story 1

- [X] T014 [US1] Implement `SelfieInstructionsViewModel` — advances the enrollment session on
      construction, emits entry analytics, and exposes `advance` as a `Command0<void>` with no
      precondition (research.md §5) — in
      `lib/features/enrollment/selfie/selfie_instructions_viewmodel.dart` (depends on: T008, T011;
      makes T012 pass)
- [X] T015 [P] [US1] Implement `SelfieFramePreview` widget (dashed-oval `CustomPainter` + a
      centered face glyph, `ExcludeSemantics`, per FR-006/research.md §3) in
      `lib/features/enrollment/selfie/widgets/selfie_frame_preview.dart`
- [X] T016 [P] [US1] Implement `CaptureConditionsList` widget (three hardcoded rows pulling `l10n`
      strings, mirroring `EnrollmentStepsList`'s precedent — data-model.md's "not modeled as a
      type") in `lib/features/enrollment/selfie/widgets/capture_conditions_list.dart`
- [X] T017 [US1] Implement `SelfieInstructionsView` composing the top bar ("‹ Atrás"/"Ayuda"),
      `StepIndicator(currentStep: EnrollmentProgressStep.selfie)`, `SelfieFramePreview`,
      title/subtitle, `CaptureConditionsList`, and the primary action — listening to `advance`'s
      completion to push the liveness-capture route (research.md §5, mirroring
      `ConsentView._onConfirmChanged`) — in
      `lib/features/enrollment/selfie/selfie_instructions_view.dart` (depends on: T004, T014,
      T015, T016; makes T013 pass)
- [X] T018 [US1] Replace the `selfieInstructions` route's placeholder builder with the real
      `SelfieInstructionsViewModel`/`SelfieInstructionsView` in `lib/app/router.dart` (depends on:
      T017)
- [X] T019 [P] [US1] Add Spanish copy strings — title ("Ahora una selfie"), subtitle, and the three
      conditions phrased as positive actions (rule 2 states what must be visible — an unobstructed
      face — never a list of garments to remove; CONFLICT-001, resolved in spec.md) — and the
      primary action label ("Tomar selfie") to `lib/l10n/app_es.arb`
- [X] T020 [US1] Delete the now-unused
      `lib/features/enrollment/confirmation/selfie_instructions_placeholder_view.dart` (004's
      stub) (depends on: T018)

**Checkpoint**: User Story 1 is independently functional and testable.

---

## Phase 4: User Story 2 - A passenger who cannot meet a condition still has a route (Priority: P2)

**Goal**: Help is reachable without losing the enrollment session; the conditions never ask for a
religious head covering to be removed; back navigation returns to data confirmation with the
confirmed record intact; nothing on this screen ever blocks progress.

**Independent Test**: From this screen, verify help is reachable and returns with the session
intact, verify back navigation returns to data confirmation with its confirmed fields still shown,
and verify the rendered condition text contains no removal instruction for a head covering.

### Tests for User Story 2

- [X] T021 [US2] Extend `SelfieInstructionsViewModel` unit tests: `onHelpOpened()` emits
      `selfie_instructions_help_opened` without marking the step as advanced;
      `onBackNavigation()` emits `selfie_instructions_step_abandoned` only if `advance` never
      completed — in `test/unit/selfie_instructions_viewmodel_test.dart`
- [X] T022 [P] [US2] Extend `SelfieInstructionsView` widget tests: tapping "Ayuda" opens the
      existing help route and returns to this screen with the session intact; "Atrás" pops to data
      confirmation with its previously confirmed fields still displayed (004's retained state, not
      re-fetched); the rendered rule-2 text does not contain "gafas", "gorra", or "mascarilla" (or
      any other removal instruction) — in `test/widget/selfie_instructions_view_test.dart`

### Implementation for User Story 2

- [X] T023 [US2] Implement `onHelpOpened()` and `onBackNavigation()` on
      `SelfieInstructionsViewModel`, wiring the corresponding analytics events (mirrors
      003/004's `onBackNavigation` shape exactly) in `selfie_instructions_viewmodel.dart` (depends
      on: T014; makes T021 pass)
- [X] T024 [US2] Wire "Ayuda" (`onHelpOpened()` then `context.push(AppRoutes.help)`) and "Atrás"
      (`onBackNavigation()` via `PopScope.onPopInvokedWithResult`, mirroring 003/004's exact
      pattern) into `SelfieInstructionsView` (depends on: T017, T023; makes T022 pass)

**Checkpoint**: User Stories 1 and 2 both independently functional.

---

## Phase 5: Polish & Cross-Cutting Concerns

- [X] T025 [P] Accessibility pass: confirm the title, subtitle, and all three conditions remain
      legible and unclipped at the platform's maximum text size (FR-011/SC-006), and that the
      illustration is never announced as meaningful, across
      `lib/features/enrollment/selfie/widgets/`
- [X] T026 Run `flutter analyze` and resolve to zero warnings (Constitution Development Workflow
      gate)
- [X] T027 Run the full test suite (`flutter test`) and confirm no regression in 002's, 003's, and
      004's suites after the `HappyPathFlags` relocation (T001/T002) and the `StepIndicator`
      parameterization (T004–T006) — per quickstart.md's explicit regression list
      (`consent_view_test.dart`, `document_confirmation_view_test.dart`, `router_test.dart`)
- [X] T028 Execute specs/005-instrucciones-selfie/quickstart.md's manual validation scenarios 1–2
      end-to-end (depends on: both user stories)
- [X] T029 Verify the release-safety mechanism end-to-end: confirm
      `test/unit/happy_path_flags_test.dart`'s release-mode-plus-flag case throws, and confirm a
      plain `flutter build apk --release` with no `--dart-define` flags succeeds unaffected

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies.
- **Foundational (Phase 2)**: Depends on Setup. BLOCKS all user stories.
- **User Stories (Phase 3–4)**: All depend on Foundational. US2 extends the same files US1 creates
  (`selfie_instructions_viewmodel.dart`, `selfie_instructions_view.dart`), so — matching
  003/004's precedent — it's independently *testable* per its own Independent Test but sequenced
  after US1's implementation tasks.
- **Polish (Phase 5)**: Depends on both user stories.

### Parallel Opportunities

- Setup: T001 and T004 in parallel (independent files); T002/T003 in parallel once T001 exists;
  T005/T006 in parallel once T004 exists.
- Foundational: T007 in parallel with T008's chain; T009/T010 in parallel once T008 exists; T011
  independent of everything else in this phase.
- Within US1: T015, T016, T019 in parallel once T014 exists.
- Within US2: T022 is written in parallel with T023 (both depend only on already-complete US1
  code), though T024 (implementation) still waits on T023.

---

## Parallel Example: Foundational Phase

```bash
# Once T008 (AnalyticsEmitter's 4 new methods) exists, these can run together:
Task: "Implement the 4 new methods in lib/data/services/logging_analytics_emitter.dart"
Task: "Implement the 4 new methods in test/fakes/fake_analytics_emitter.dart"

# Independently, once T001 (HappyPathFlags) exists:
Task: "Write the HappyPathFlags.assertReleaseSafe test suite in test/unit/happy_path_flags_test.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Setup → Foundational (blocks everything; this is the phase where the release-safety module,
   the step-indicator parameterization, and the new analytics methods all land).
2. User Story 1 → **STOP and VALIDATE**: quickstart.md scenario 1.
3. User Story 2 → validate independently (help reachability, non-gating, and the CONFLICT-001
   wording guard).
4. Polish → accessibility pass, analyze/coverage gates, the two prior features' regression suites,
   full quickstart pass, the release-safety build check.

---

## Notes

- [P] tasks touch different files with no incomplete-task dependency.
- T001–T006 are this feature's one deliberate touch of already-shipped 002/003/004 code
  (research.md §2, §4) — relocations/extensions with no behavior change, called out individually
  so the regression risk is tracked rather than folded silently into new-feature work (verified in
  T027).
- T020 deletes 004-confirmar-datos's placeholder, not kept alongside the real implementation, same
  pattern as 004's own T031 deleting 003's stub.
