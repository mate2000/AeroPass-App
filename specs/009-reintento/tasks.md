---

description: "Task list for Verification Retry (09 Reintento)"
---

# Tasks: Verification Retry (09 Reintento)

**Input**: Design documents from `/specs/009-reintento/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md (all
present). Replaces the retry-guidance placeholder that 003, 006 and 007 route to, and changes the
retry policy in those three view models. No new package dependency.

**Tests**: Included, and written before implementation. The retry policy decides how many paid
validations a passenger may consume and whether a retry is offered, which is Constitution
Principle IV's test-first territory. Each test task must fail before its implementation task.

**Organization**: Tasks are grouped by user story (spec.md: US1 P1, US2 P1, US3 P2).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an incomplete task)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- File paths are relative to the `AeroPass-App/` repository root

---

## Phase 1: Setup

**Purpose**: copy and colours every later phase references.

- [X] T001 [P] Add screen 09 strings from research.md §5 to `lib/l10n/app_es.arb`, then run
      `flutter gen-l10n`: the selfie-retry title, generic body and advice heading "Consejos para el
      siguiente intento:"; the three selfie tips; the selfie-limit and document-limit titles and
      bodies (each naming the agent and the regular checkpoint); actions "Intentar de nuevo",
      "Hablar con un agente" and "Ayuda"; and a semantics label for the icon
- [X] T002 [P] Add `amber` and `amberTile` named colours to `lib/core/design/app_colors.dart`
      (research.md §6)

---

## Phase 2: Foundational (blocking prerequisites)

**Purpose**: the state type and analytics every story uses.

**⚠️ CRITICAL**: no user story work begins until this phase is complete.

- [X] T003 Create the `RetryGuidanceState` enum (`selfieRetry`, `selfieLimit`, `documentLimit`) in
      `lib/domain/entities/retry_guidance_state.dart` (data-model.md)
- [X] T004 Add `retryGuidanceShown({required RetryGuidanceState state})`,
      `retryGuidanceRetryTaken()` and `retryGuidanceAgentRouteTaken({required RetryGuidanceState state})`
      to `lib/domain/repositories/analytics_emitter.dart` (exporting `RetryGuidanceState`), and
      implement them in `lib/data/services/logging_analytics_emitter.dart`
      (contracts/analytics-events.md; depends on: T003)
- [X] T005 [P] Implement the three methods in `test/fakes/fake_analytics_emitter.dart`
      (depends on: T004)

**Checkpoint**: all three stories can start.

---

## Phase 3: User Story 1 - A legitimate passenger retries and succeeds (Priority: P1) 🎯 MVP

**Goal**: after a biometric failure below the limit, the screen shows the generic failure, three
selfie tips and no count, and "Intentar de nuevo" goes straight to the selfie camera.

**Independent Test**: with both counters below the limit, open the screen and verify its title,
body, tips and actions, the absence of any count or comparison wording, the announcement, and that
retry lands on the selfie camera route.

### Tests for User Story 1 (write first, confirm they fail)

- [X] T006 [P] [US1] Unit tests in `test/unit/retry_guidance_viewmodel_test.dart`: with both
      counters below the limit the state is `selfieRetry` and `canRetry` is true;
      `retryGuidanceShown(state: selfieRetry)` fires once; `onRetry()` fires
      `retryGuidanceRetryTaken` once; `onAgentRoute()` fires `retryGuidanceAgentRouteTaken`
      with the state
- [X] T007 [P] [US1] Widget tests in `test/widget/retry_guidance_view_test.dart` for the
      `selfieRetry` column of contracts/retry-guidance-screen.md: "Ayuda" in the top bar, the amber
      icon, the title and generic body, the advice heading and three selfie tips, "Intentar de
      nuevo" and "Hablar con un agente"; no text contains "coincide", "suficiente", "Intento" or a
      digit; no document tip; no `Colors.red` or error colour in the tree; the back gesture does
      nothing; the title and body are announced; "Intentar de nuevo" navigates to the
      liveness-capture route; goldens at default and 200% text scale in `test/widget/goldens/`

### Implementation for User Story 1

- [X] T008 [US1] Implement `RetryGuidanceViewModel` in
      `lib/features/enrollment/retry/retry_guidance_viewmodel.dart`: constructor takes
      `CaptureAttemptCounterRepository` and `AnalyticsEmitter`; reads both counters on creation
      and derives the state per research.md §1 (a failed read yields `selfieLimit`); exposes
      `state`, `canRetry`, `onRetry()`, `onAgentRoute()`; emits `retryGuidanceShown` once the state
      is known (depends on: T006, T004)
- [X] T009 [P] [US1] Build `AdviceCard` (heading plus a list of tips, each with a decorative icon
      excluded from semantics) in `lib/features/enrollment/retry/widgets/advice_card.dart`
- [X] T010 [US1] Build `RetryGuidanceView` in `lib/features/enrollment/retry/retry_guidance_view.dart`:
      top bar with "Ayuda" (`push` help); amber icon tile; title as a semantics header; body;
      `AdviceCard` in `selfieRetry`; primary "Intentar de nuevo" (`go` liveness capture) and
      secondary "Hablar con un agente" (`push` agent escalation); `PopScope(canPop: false)`;
      announce title and body once the state is known; a neutral loading indicator while
      `state` is null (depends on: T007, T008, T009, T001, T002)
- [X] T011 [US1] Point the retry-guidance `GoRoute` in `lib/app/router.dart` at the new view, building
      the view model with its dependencies, and delete
      `lib/features/retry_guidance_placeholder_view.dart` (depends on: T010)

**Checkpoint**: a biometric failure below the limit shows the real screen and retries straight
into the selfie camera. T006–T007 pass.

---

## Phase 4: User Story 2 - A passenger who will not succeed reaches a human (Priority: P1)

**Goal**: at the limit, the screen explains it for the right capture, offers only the agent route,
and names the checkpoint alternative; the agent route is always one tap away.

**Independent Test**: seed each counter at the limit and verify the matching limit state; from the
retry state and from each limit state, take the agent route and return.

### Tests for User Story 2 (write first, confirm they fail)

- [X] T012 [P] [US2] Add unit tests to `test/unit/retry_guidance_viewmodel_test.dart`: the selfie
      counter at the limit gives `selfieLimit`; the document counter at the limit gives
      `documentLimit`, also when both are at the limit; a failing counter read gives
      `selfieLimit`; `canRetry` is false in both limit states
- [X] T013 [P] [US2] Add widget tests to `test/widget/retry_guidance_view_test.dart` for the two
      limit columns of contracts/retry-guidance-screen.md: the limit title and body for the right
      capture, the checkpoint line, no "Intentar de nuevo" and no advice card, "Hablar con un
      agente" as the primary action; in every state, "Hablar con un agente" pushes the agent route
      and back returns to this screen; every state has at least one route to a person

### Implementation for User Story 2

- [X] T014 [US2] Render the `selfieLimit` and `documentLimit` states in
      `lib/features/enrollment/retry/retry_guidance_view.dart`: their title and body, no advice
      card, and "Hablar con un agente" as the only action (depends on: T012, T013)

**Checkpoint**: every state leads to a person. T012–T013 pass.

---

## Phase 5: User Story 3 - The retry policy cannot be reset by the passenger (Priority: P2)

**Goal**: counters reset only on a verification match; neither passing a capture step nor reaching
the limit resets them; 003 and 006 refuse to open the camera at the limit.

**Independent Test**: exhaust each counter, navigate back into its capture step, and verify the
limit state appears and the camera never starts; verify a match resets both counters.

### Tests for User Story 3 (write first, confirm they fail)

- [X] T015 [P] [US3] Update `test/unit/capture_viewmodel_test.dart` for addendum cases 1–3: an
      accepted photo leaves the document counter unchanged; reaching the limit leaves it at the
      limit; entering with it at the limit targets retry guidance and does not start the camera.
      Remove or rewrite existing assertions that expected a reset
- [X] T016 [P] [US3] Update `test/unit/liveness_capture_viewmodel_test.dart` for addendum cases 4–6,
      the same three rules for the selfie counter, removing assertions that expected a reset
- [X] T017 [P] [US3] Update `test/unit/verification_progress_viewmodel_test.dart` for addendum cases
      7–8: `matched` resets both counters, even when issuance then fails; R6 and R7–R9 at the limit
      leave the counter at the limit. Rewrite R1's "selfie counter reset" assertion to expect both
      counters reset at `matched`

### Implementation for User Story 3

- [X] T018 [US3] In `lib/features/enrollment/capture/capture_viewmodel.dart`, remove the reset in
      `_registerAccepted` and on the limit path, and on creation read the document counter and, at
      the limit, target retry guidance without starting the camera (contracts/retry-policy-addendum.md
      003; depends on: T015)
- [X] T019 [US3] In `lib/features/enrollment/liveness/liveness_capture_viewmodel.dart`, remove the
      reset on liveness success and on the limit path, and on creation read the selfie counter and,
      at the limit, target retry guidance without starting the camera (addendum 006; depends on: T016)
- [X] T020 [US3] In `lib/features/enrollment/verification/verification_progress_viewmodel.dart`,
      reset both counters on `completed(matched)` before requesting issuance, and remove the resets
      in R1, R6 and R7–R9 (addendum 007; depends on: T017)

**Checkpoint**: an exhausted limit stays in force. T015–T017 pass.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T021 [P] Copy audit: confirm by search that no screen 09 string contains "coincide",
      "suficiente", "Intento", a number of attempts or any detection reference; that the face tip
      matches 005's wording; and that `reset(` in 003, 006 and 007 now appears only in 007's
      `matched` branch (SC-003, FR-005, FR-017)
- [X] T022 Run `flutter analyze` with zero issues, then the full `flutter test` suite, fixing any
      regression in 003–008 tests
- [ ] T023 Walk quickstart.md's manual scenarios 1–6 on an Android device, and record the results in
      `specs/009-reintento/quickstart.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: none.
- **Foundational (Phase 2)**: depends on Setup. Blocks every story.
- **US1 (Phase 3)**: depends on Foundational.
- **US2 (Phase 4)**: extends US1's view model tests and view (T008, T010).
- **US3 (Phase 5)**: depends on Foundational only; touches different files from US1 and US2.
- **Polish (Phase 6)**: depends on all three stories.

### User Story Dependencies

- **US1**: independent after Foundational; the minimum walkable screen.
- **US2**: builds on US1's view.
- **US3**: independent of US1 and US2, since it changes 003, 006 and 007 only. Its "limit stays in
  force" behaviour is only visible end to end once US2's limit states exist.

### Within Each User Story

- Tests are written and fail before implementation.
- The view model before the view, the view before the route.

## Parallel Opportunities

- Setup: T001 and T002 together.
- US1: T006 and T007 together; T009 alongside T008.
- US2: T012 and T013 together.
- US3: T015, T016 and T017 together; T018, T019 and T020 touch different files and can also run
  together once their tests are written.
- US3 can run entirely in parallel with US1 and US2.

## Parallel Example: User Story 3

```bash
# Tests first, together:
Task: "Addendum cases 1–3 in test/unit/capture_viewmodel_test.dart"
Task: "Addendum cases 4–6 in test/unit/liveness_capture_viewmodel_test.dart"
Task: "Addendum cases 7–8 in test/unit/verification_progress_viewmodel_test.dart"

# Then the three view models, together:
Task: "Policy change in lib/features/enrollment/capture/capture_viewmodel.dart"
Task: "Policy change in lib/features/enrollment/liveness/liveness_capture_viewmodel.dart"
Task: "Policy change in lib/features/enrollment/verification/verification_progress_viewmodel.dart"
```

## Implementation Strategy

### MVP (US1 and US2)

The two P1 stories together are the screen: the retry state and the limit states with their human
route. Complete Phases 1–4, then walk quickstart scenarios 1–4.

### Incremental delivery

1. Phases 1–2: foundation.
2. Phase 3: the retry state.
3. Phase 4: the limit states.
4. Phase 5: the policy changes that make the limit hold (can run alongside 3–4).
5. Phase 6: copy audit, full suite, device walk-through.
