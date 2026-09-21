---

description: "Task list for Informed Consent Gate (02 Consentimiento)"
---

# Tasks: Informed Consent Gate (02 Consentimiento)

**Input**: Design documents from `/specs/002-consentimiento/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md (all
present). Builds on 001-bienvenida's existing project (FVM, dependencies, `core/`, `app/` — no new
setup beyond this feature's own files).

**Tests**: Included and sequenced before their implementation. Constitution Principle IV names
"consent capture" directly as trust-boundary code, so test tasks are not optional here.

**Organization**: Tasks are grouped by user story (spec.md priorities P1/P2/P3).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an incomplete task)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- File paths are relative to the `AeroPass-App/` repository root

---

## Phase 1: Setup

- [X] T001 Create the new directory skeleton per plan.md's Project Structure
      (`lib/features/enrollment/consent/widgets/`, `lib/features/account/`) at the repository root.
      No new dependencies, l10n infra, or CI changes are needed — 001-bienvenida's setup already
      covers them (plan.md Technical Context).

**Checkpoint**: Ready for foundational work.

---

## Phase 2: Foundational (Blocking Prerequisites)

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T002 [P] Implement sealed `ConsentPointIcon` (`camera`/`clock`/`share`), `ConsentPoint`, and
      `ConsentTextVersion`, per data-model.md, in `lib/domain/entities/consent_text_version.dart`
- [X] T003 [P] Implement sealed `ConsentRecordStatus` (`active`/`withdrawalPending`/`withdrawn`) and
      `ConsentRecord` in `lib/domain/entities/consent_record.dart`
- [X] T004 [P] Implement `EnrollmentAttemptId` (wraps `core/uuid.dart`'s `generateUuidV4()`, per
      research.md §3) in `lib/domain/entities/enrollment_attempt_id.dart`
- [X] T005 [P] Implement sealed `ProcessingScope` (currently only `identityVerification`) in
      `lib/domain/entities/processing_scope.dart`
- [X] T006 Implement the abstract `ConsentRepository` port (`getCurrentText`, `recordConsent`,
      `getLocalRecord`, `withdraw`, `retryPendingWithdrawal`) in
      `lib/domain/repositories/consent_repository.dart` (depends on: T002, T003, T004, T005)
- [X] T007 Write the `ConsentRepository` contract test suite — all 9 cases from
      contracts/consent-repository-port.md, run against both the fake and the real implementation —
      in `test/contract/consent_repository_contract_test.dart`. MUST fail until T008 and T009 exist
      (depends on: T006)
- [X] T008 [P] Implement `FakeConsentRepository` (scripted responses, no network, no secure
      storage) in `test/fakes/fake_consent_repository.dart` (depends on: T006)
- [X] T009 [P] Implement `ConsentService` (certificate-pinned `dio` via the existing
      `buildPinnedDio`, plus `flutter_secure_storage` for the local `ConsentRecord` copy) and
      `ConsentRepositoryImpl` in `lib/data/services/consent_service.dart` and
      `lib/data/services/consent_repository_impl.dart` (depends on: T006; makes T007 pass for the
      non-withdrawal cases — withdrawal's own state-machine behavior is completed in T032)
- [X] T010 Wire `ConsentRepository` into the app composition root via `provider` in
      `lib/app/composition_root.dart` (depends on: T009)

**Checkpoint**: Foundation ready — user story implementation can now begin.

---

## Phase 3: User Story 1 - A passenger gives informed consent and proceeds (Priority: P1) 🎯 MVP

**Goal**: The consent gate fetches and shows the current text, blocks the primary action until the
checkbox is confirmed, and durably records consent — with a fresh `EnrollmentAttemptId` — before the
document-capture route becomes reachable. Offline or a failed recording blocks advancement with a
clear message rather than a silent failure.

**Independent Test**: From the welcome screen, reach the gate, confirm nothing can advance while
consent is unconfirmed, confirm consent, and verify a `ConsentRecord` exists (with its text version
and timestamp) before the document-capture route is reachable.

### Tests for User Story 1

> Write these tests FIRST; confirm they FAIL before implementing this phase.

- [X] T011 [US1] Write `ConsentViewModel` unit tests: text-fetch loading/ready/unavailable states;
      the checkbox gates the primary `Command`'s availability; a successful confirm persists a
      record with `status = active` and a freshly-generated `EnrollmentAttemptId`; an offline or
      failed confirm does not advance and surfaces the blocked-start message (FR-001–FR-008) in
      `test/unit/consent_viewmodel_test.dart`
- [X] T012 [P] [US1] Write `ConsentView` widget tests: the unavailable state, the ready state with
      the primary action disabled-then-enabled as the checkbox is toggled (and its disabled reason
      exposed to semantics), and a successful confirm navigating to the document-capture route, in
      `test/widget/consent_view_test.dart`

### Implementation for User Story 1

- [X] T013 [US1] Implement `ConsentViewModel` core — fetches `ConsentTextVersion`, exposes checkbox
      state and the confirm `Command` — in
      `lib/features/enrollment/consent/consent_viewmodel.dart` (depends on: T006, T010; makes T011
      pass)
- [X] T014 [P] [US1] Implement `ConsentPointTile` widget (icon + heading + body, icon
      ExcludeSemantics per FR-014-style no-icon-only-meaning) in
      `lib/features/enrollment/consent/widgets/consent_point_tile.dart`
- [X] T015 [P] [US1] Implement `ConfirmationCheckbox` widget, unchecked by default (FR-004), in
      `lib/features/enrollment/consent/widgets/confirmation_checkbox.dart`
- [X] T016 [P] [US1] Implement the primary/secondary action widgets, with the primary action's
      disabled state exposed to assistive technology and not signaled by color alone (FR-006), in
      `lib/features/enrollment/consent/widgets/gate_actions.dart`
- [X] T017 [P] [US1] Implement `UnavailableMessage` widget covering both the text-fetch-failed and
      the offline-blocked-recording states (FR-008, Edge Cases) in
      `lib/features/enrollment/consent/widgets/unavailable_message.dart`
- [X] T018 [US1] Implement `ConsentView` composing the sheet shell (rounded top corners, drag
      handle, shadow — reusing 001-bienvenida's `_WelcomeShell` technique per research.md §1),
      the rights/optionality/processor-disclosure sections, and the actions row, in
      `lib/features/enrollment/consent/consent_view.dart` (depends on: T013, T014, T015, T016,
      T017; makes T012 pass)
- [X] T019 [US1] Replace the consent route's builder in `lib/app/router.dart` with a sheet-style
      `pageBuilder` (`CustomTransitionPage`, `opaque: false`, sliding up over the dimmed welcome
      screen, per research.md §1), composing `ConsentViewModel`/`ConsentView` via `Provider`;
      remove the `ConsentPlaceholderView` wiring (depends on: T018)
- [X] T020 [US1] Implement the document-capture placeholder route/view (gated destination stub —
      screen 003 is out of scope) in
      `lib/features/enrollment/document_capture_placeholder_view.dart`, registered in
      `lib/app/router.dart` (depends on: T019)
- [X] T021 [US1] Wire `consent_gate_shown`, `consent_gate_unavailable_shown`, `consent_confirmed`,
      and `consent_confirm_failed` analytics events via `AnalyticsEmitter` in
      `consent_viewmodel.dart` (depends on: T013)
- [X] T022 [P] [US1] Add Spanish copy strings for the gate's chrome (title, subtitle, checkbox
      label, button labels, unavailable/offline messaging) to `lib/l10n/app_es.arb`
- [X] T023 [US1] Delete the now-unused `lib/features/enrollment/consent_placeholder_view.dart`
      (depends on: T019)

**Checkpoint**: User Story 1 is independently functional and testable.

---

## Phase 4: User Story 2 - A passenger declines and leaves without penalty (Priority: P2)

**Goal**: Declining, the system back gesture, and tapping outside the sheet all produce the
identical outcome — return to welcome, no record created, no re-prompt on next launch — with accept
and decline given comparable visual prominence.

**Independent Test**: Reach the gate, exercise every exit (decline, back gesture, barrier tap), and
verify in each case no `ConsentRecord` was created and the passenger lands back on the welcome
screen with the conventional-process message.

### Tests for User Story 2

- [X] T024 [US2] Write `ConsentViewModel` unit tests: the decline `Command` creates no record; the
      dismissal-equivalent path (used by both the back gesture and the barrier tap) also creates no
      record and is never recorded as consent (FR-009–FR-011) in
      `test/unit/consent_viewmodel_test.dart`
- [X] T025 [P] [US2] Write `ConsentView` widget tests: "Ahora no" tap, `PopScope` back-gesture
      interception, and barrier tap all navigate back to welcome with no record created, in
      `test/widget/consent_view_test.dart`

### Implementation for User Story 2

- [X] T026 [US2] Implement decline handling in `ConsentViewModel` as a single `Command` shared by
      all three dismissal vectors (research.md §2) in `consent_viewmodel.dart` (depends on: T013;
      makes T024 pass)
- [X] T027 [US2] Implement `PopScope` back-gesture interception and barrier-tap-to-decline in
      `consent_view.dart`, both invoking the same decline `Command` (depends on: T018, T026; makes
      T025 pass)
- [X] T028 [US2] Wire `consent_declined` and `consent_dismissed` analytics events in
      `consent_viewmodel.dart` (depends on: T021, T026)
- [X] T029 [P] [US2] Add the Spanish copy string for the "conventional airport process remains
      available" decline messaging to `lib/l10n/app_es.arb`

**Checkpoint**: User Stories 1 and 2 both independently functional.

---

## Phase 5: User Story 3 - A passenger withdraws consent, or is asked again after the terms change (Priority: P3)

**Goal**: Withdrawal invalidates the local credential/pass immediately (no network dependency) and
is submitted for backend processing, surviving an offline gap until delivered. A `ConsentRecord`
referencing a superseded text version triggers re-presentation of the gate rather than being treated
as still valid.

**Independent Test**: With consent recorded, withdraw from the placeholder entry point and verify
local invalidation is immediate and offline-safe; then simulate a new consent text version and
verify the gate is presented again rather than skipped.

### Tests for User Story 3

- [X] T030 [US3] Extend `test/contract/consent_repository_contract_test.dart` with the
      withdrawal-specific assertions from contracts/consent-repository-port.md cases 6–9 not
      already covered by T007, and add a `ConsentViewModel` unit test for FR-014's
      superseded-version re-presentation in `test/unit/consent_viewmodel_test.dart`
- [X] T031 [P] [US3] Write a widget test for the withdrawal placeholder route confirming local
      credential/pass invalidation within the local-effect budget with no network dependency
      (SC-005) in `test/widget/withdrawal_placeholder_view_test.dart`

### Implementation for User Story 3

- [X] T032 [US3] Implement `withdraw()`/`retryPendingWithdrawal()` in `ConsentRepositoryImpl` — the
      `active → withdrawalPending → withdrawn` state machine, with the local effect applied
      immediately and backend delivery attempted inline then retried later — in
      `lib/data/services/consent_repository_impl.dart` (depends on: T009; makes the remainder of
      T007/T030's withdrawal cases pass)
- [X] T033 [US3] Wire `retryPendingWithdrawal()` into the existing `_redirect` function in
      `lib/app/router.dart` as an opportunistic, fire-and-forget trigger (research.md §4) (depends
      on: T032)
- [X] T034 [US3] Implement the withdrawal placeholder route/view (a minimal, two-action entry
      point) in `lib/features/account/withdrawal_placeholder_view.dart`, registered in
      `lib/app/router.dart` (depends on: T032; makes T031 pass)
- [X] T035 [US3] Implement FR-014's superseded-version re-presentation in `ConsentViewModel` —
      compare the local record's `textVersionId` against a freshly-fetched `getCurrentText().id` —
      in `consent_viewmodel.dart` (depends on: T013; makes T030's `ConsentViewModel` assertion pass)
- [X] T036 [P] [US3] Add Spanish copy strings for the withdrawal placeholder screen to
      `lib/l10n/app_es.arb`

**Checkpoint**: All three user stories independently functional.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T037 [P] Accessibility pass across all consent widgets — the primary action's disabled state
      and reason announced to assistive technology, AA contrast, dynamic-type-safe scrolling layout
      (FR-006, FR-013, SC-008) — in `lib/features/enrollment/consent/widgets/`
- [X] T038 [P] Add a test asserting FR-007/FR-018's invariant directly: the document-capture
      placeholder route is unreachable without a prior `Ok` from `recordConsent()` — extend
      `test/widget/consent_view_test.dart` or add a focused router-level test
- [X] T039 Run `flutter analyze` and resolve to zero warnings (Constitution Development Workflow
      gate)
- [X] T040 Run the full test suite (`flutter test`) and confirm ≥85% line coverage across
      `ConsentViewModel` and `ConsentRepositoryImpl` (Constitution CI gate)
- [ ] T041 Execute specs/002-consentimiento/quickstart.md's manual validation scenarios 1–3
      end-to-end on the interim minimum-spec baseline (Android 8.0 / iOS 15.0)
- [ ] T042 Measure SC-007 (median ≤30s at the gate) and SC-005 (withdrawal's local effect ≤1s, no
      network dependency) on the minimum-spec baseline device

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies.
- **Foundational (Phase 2)**: Depends on Setup. BLOCKS all user stories.
- **User Stories (Phase 3–5)**: All depend on Foundational. US2 and US3 extend files US1 creates
  (`consent_viewmodel.dart`, `consent_view.dart`, `router.dart`), so — as with 001-bienvenida's
  welcome feature — they're independently *testable* per their own Independent Test but sequenced
  after US1's implementation tasks rather than fully parallel with them.
- **Polish (Phase 6)**: Depends on all three user stories.

### Parallel Opportunities

- Foundational: T002–T005 in parallel; T008 and T009 in parallel once T006 exists.
- Within US1: T014, T015, T016, T017, T022 in parallel once T013 exists.
- Within US2: T025 and T029 in parallel with the sequential T026→T027 chain.
- Within US3: T031 and T036 in parallel with the sequential T032→T033/T034/T035 chain.

---

## Parallel Example: User Story 1

```bash
# After T013 (ConsentViewModel core) is done, these can run together:
Task: "Implement ConsentPointTile widget in lib/features/enrollment/consent/widgets/consent_point_tile.dart"
Task: "Implement ConfirmationCheckbox widget in lib/features/enrollment/consent/widgets/confirmation_checkbox.dart"
Task: "Implement primary/secondary action widgets in lib/features/enrollment/consent/widgets/gate_actions.dart"
Task: "Implement UnavailableMessage widget in lib/features/enrollment/consent/widgets/unavailable_message.dart"
Task: "Add Spanish copy strings to lib/l10n/app_es.arb"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Setup → Foundational (blocks everything).
2. User Story 1 → **STOP and VALIDATE**: quickstart.md scenario 1, independently. This alone
   makes the whole enrollment funnel legally soundable — 001-bienvenida's welcome screen can lead
   somewhere real, and the document-capture route (still a stub) becomes reachable only through a
   genuine, recorded consent.
3. User Story 2 → validate independently (the decline path a coerced-consent audit would check
   first).
4. User Story 3 → validate independently (withdrawal and re-consent-on-change — what makes User
   Story 1's consent lawful on an ongoing basis, not just at the moment it's given).
5. Polish → accessibility, invariant test, analyze/coverage gates, full quickstart pass.

---

## Notes

- [P] tasks touch different files with no incomplete-task dependency.
- Tests are written first and must fail before their implementation task, per Constitution
  Principle IV — enforced by task ordering above.
- `ConsentPlaceholderView` (001-bienvenida) is deleted, not kept alongside the real implementation
  (T023).
- FR-011's legal wording itself remains counsel's deliverable (spec.md Out of Scope) — these tasks
  build the gate's *behavior*, not the final text; `ConsentTextVersion` is fetched from the backend
  at runtime, so no placeholder legal copy needs to ship in this codebase at all (unlike
  001-bienvenida's `terms_placeholder_view.dart`, which does carry placeholder text).
