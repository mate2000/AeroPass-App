---

description: "Task list for Extracted Data Confirmation (04 Confirmar datos)"
---

# Tasks: Extracted Data Confirmation (04 Confirmar datos)

**Input**: Design documents from `/specs/004-confirmar-datos/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md (all
present). Builds on 003-escanear-documento's shipped code — this feature both adds new code and
modifies one already-shipped 003 contract (`CaptureOutcome.accepted`, research.md §1). No new
dependency (`intl` is already transitive via `flutter_localizations`).

**Tests**: Included and sequenced before their implementation. Constitution Principle IV names
"identity state" and "the classification of a verification outcome" as trust-boundary code; this
screen decides identity-record content and enforces the false-accept boundary on corrections, so test
tasks are not optional here.

**Organization**: Tasks are grouped by user story (spec.md priorities P1/P1/P2).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an incomplete task)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- File paths are relative to the `AeroPass-App/` repository root

---

## Phase 1: Setup

- [X] T001 [P] Move `StepIndicator` (unchanged) from
      `lib/features/enrollment/capture/widgets/step_indicator.dart` to
      `lib/core/design/step_indicator.dart` and update `capture_view.dart`'s import (research.md §7)

**Checkpoint**: Ready for foundational work.

---

## Phase 2: Foundational (Blocking Prerequisites)

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T002 [P] Implement `FieldKey` enum and sealed `ExtractedField`/`ExtractionResult` (with a
      `parsedExpiryDate` getter, per data-model.md) in
      `lib/domain/entities/extraction_result.dart`
- [X] T003 [P] Implement sealed `FieldReverificationOutcome` (`confirmed`/`disagreed`) in
      `lib/domain/entities/field_reverification_outcome.dart`
- [X] T004 [P] Implement `FieldSource` enum and `ConfirmedField`/`IdentityRecord` in
      `lib/domain/entities/identity_record.dart`
- [X] T005 Extend `CaptureOutcome.accepted` to require `extraction: ExtractionResult` in
      `lib/domain/entities/capture_outcome.dart` (depends on: T002) — the one modification to
      already-shipped 003 code (research.md §1, contracts/document-verification-port-addendum.md)
- [X] T006 [P] Implement the abstract `FieldReverificationRepository` port (`reverify`) in
      `lib/domain/repositories/field_reverification_repository.dart` (depends on: T002, T003)
- [X] T007 [P] Implement the abstract `IdentityRecordRepository` port (`confirm`) in
      `lib/domain/repositories/identity_record_repository.dart` (depends on: T004)
- [X] T008 [P] Write the `FieldReverificationRepository` contract test suite — all 4 cases from
      contracts/field-reverification-port.md — in
      `test/contract/field_reverification_repository_contract_test.dart`. MUST fail until T011 and
      T012 exist (depends on: T006)
- [X] T009 [P] Write the `IdentityRecordRepository` contract test suite — all 3 cases from
      contracts/identity-record-repository-port.md, including the local display-only-cache assertion
      — in `test/contract/identity_record_repository_contract_test.dart`. MUST fail until T013 and
      T014 exist (depends on: T007)
- [X] T010 Extend the `DocumentVerificationRepository` contract test for the `extraction` payload —
      contracts/document-verification-port-addendum.md's 2 new cases, plus re-running 003's existing
      rejection/transport-failure cases as regression coverage — in
      `test/contract/document_verification_repository_contract_test.dart`. MUST fail until T015 and
      T016 exist (depends on: T005)
- [X] T011 [P] Implement `FakeFieldReverificationRepository` in
      `test/fakes/fake_field_reverification_repository.dart` (depends on: T006)
- [X] T012 [P] Implement `FieldReverificationService` (certificate-pinned `dio` via the existing
      `buildPinnedDio`) and `FieldReverificationRepositoryImpl` in
      `lib/data/services/field_reverification_service.dart` and
      `lib/data/services/field_reverification_repository_impl.dart` (depends on: T006; makes T008
      pass)
- [X] T013 [P] Implement `FakeIdentityRecordRepository`, exposing a way to read back whatever it
      wrote to its local display-only cache, in `test/fakes/fake_identity_record_repository.dart`
      (depends on: T007)
- [X] T014 [P] Implement `IdentityRecordService` (certificate-pinned `dio` + `flutter_secure_storage`
      for the local display-only write) and `IdentityRecordRepositoryImpl` in
      `lib/data/services/identity_record_service.dart` and
      `lib/data/services/identity_record_repository_impl.dart` (depends on: T007; makes T009 pass)
- [X] T015 Add the `fields` array to `DocumentVerificationResponse` and extend
      `DocumentVerificationRepositoryImpl._mapResponse` to map it into `ExtractionResult` (an absent
      key maps to `ExtractedField.missing`, per contracts addendum) in
      `lib/data/models/document_verification_response.dart` and
      `lib/data/services/document_verification_repository_impl.dart` (depends on: T005; makes T010
      pass)
- [X] T016 Update `FakeDocumentVerificationRepository` and every existing
      `CaptureOutcome.accepted()` construction in 003's own tests to supply an `extraction` argument,
      in `test/fakes/fake_document_verification_repository.dart` and
      `test/unit/capture_viewmodel_test.dart` (depends on: T005; makes T010 pass; regression-safety
      obligation from research.md §1)
- [X] T017 [P] Implement `PendingDocumentController` (in-memory `documentImageBytes`/`extraction`,
      `set`/`clear`), mirroring `EnrollmentSessionController`, in
      `lib/app/pending_document_controller.dart` (depends on: T002)
- [X] T018 Update `CaptureViewModel._registerAccepted` to receive the just-captured frame bytes and
      the outcome's `ExtractionResult`, and call `PendingDocumentController.set(...)` before
      navigating to data confirmation, extending `capture_viewmodel_test.dart`'s accepted-path
      assertions accordingly, in `lib/features/enrollment/capture/capture_viewmodel.dart` (depends
      on: T005, T017)
- [X] T019 Wire `FieldReverificationRepository`, `IdentityRecordRepository`, and
      `PendingDocumentController` into `lib/app/composition_root.dart` (depends on: T012, T014, T017)

**Checkpoint**: Foundation ready — user story implementation can now begin.

---

## Phase 3: User Story 1 - A passenger confirms correctly extracted data (Priority: P1) 🎯 MVP

**Goal**: The screen shows the captured document thumbnail and every extracted field read-only;
confirming submits the record durably and advances to the selfie step with the image discarded.

**Independent Test**: Complete a capture the processor accepts, verify the extracted fields display
alongside the image, confirm, and verify the identity record carries exactly those values and the
flow advances.

### Tests for User Story 1

> Write these tests FIRST; confirm they FAIL before implementing this phase.

- [X] T020 [US1] Write `DocumentConfirmationViewModel` unit tests: loading from
      `PendingDocumentController` (including the empty-controller redirect-to-capture case),
      building read-only field state for a clean extraction, and the confirm happy path
      (`IdentityRecordRepository.confirm` → `Ok` clears the controller and advances) in
      `test/unit/document_confirmation_viewmodel_test.dart`
- [X] T021 [P] [US1] Write `DocumentConfirmationView` widget tests: thumbnail + "✓ Capturado" badge +
      country marker, all four fields read-only with document-matching labels, the notice visible
      before the fields, and a successful confirm navigating onward, in
      `test/widget/document_confirmation_view_test.dart`

### Implementation for User Story 1

- [X] T022 [US1] Implement `DocumentConfirmationViewState` (sealed: at least `loading`/`ready`/
      `confirming`) in
      `lib/features/enrollment/confirmation/document_confirmation_view_state.dart`
- [X] T023 [US1] Implement `DocumentConfirmationViewModel` core — read
      `PendingDocumentController.current`, redirect-if-empty, build per-field read-only state, and a
      `confirm` Command calling `IdentityRecordRepository.confirm` (success clears the controller and
      sets navigation to the selfie stub; failure surfaces FR-017's not-recorded state) — in
      `lib/features/enrollment/confirmation/document_confirmation_viewmodel.dart` (depends on: T007,
      T017, T019; makes T020 pass)
- [X] T024 [P] [US1] Implement `DocumentThumbnailCard` widget (navy card, in-memory-bytes thumbnail,
      "✓ Capturado" badge, country marker) in
      `lib/features/enrollment/confirmation/widgets/document_thumbnail_card.dart`
- [X] T025 [P] [US1] Implement `FieldRow` widget (read-only value display + edit affordance, label
      matching the physical document's vocabulary) in
      `lib/features/enrollment/confirmation/widgets/field_row.dart`
- [X] T026 [US1] Implement `DocumentConfirmationView` composing the top bar ("‹ Atrás"/"Ayuda"), the
      shared `StepIndicator`, the notice text, the thumbnail card, the four `FieldRow`s, and the
      primary/secondary actions, in
      `lib/features/enrollment/confirmation/document_confirmation_view.dart` (depends on: T001,
      T023, T024, T025; makes T021 pass)
- [X] T027 [US1] Replace the `documentConfirmation` route's placeholder builder with
      `DocumentConfirmationView` in `lib/app/router.dart`, adding the guard that redirects to
      `documentCapture` when `PendingDocumentController` is empty (mirrors 003's consent-gate guard)
      (depends on: T026)
- [X] T028 [US1] Implement the selfie-instructions placeholder route/view (005 stub — the success
      destination) in
      `lib/features/enrollment/confirmation/selfie_instructions_placeholder_view.dart`, registered in
      `lib/app/router.dart` (depends on: T027)
- [X] T029 [US1] Wire `confirmation_step_entered`, `confirmation_confirmed`, and
      `confirmation_confirm_failed` analytics events via `AnalyticsEmitter` in
      `document_confirmation_viewmodel.dart` (depends on: T023)
- [X] T030 [P] [US1] Add Spanish copy strings for this screen's chrome (notice, field labels,
      primary/secondary action labels) to `lib/l10n/app_es.arb`
- [X] T031 [US1] Delete the now-unused
      `lib/features/enrollment/capture/document_confirmation_placeholder_view.dart` (003's stub)
      (depends on: T027)

**Checkpoint**: User Story 1 is independently functional and testable.

---

## Phase 4: User Story 2 - A passenger corrects a field the machine read wrong (Priority: P1)

**Goal**: Any field can be edited; a low-confidence edit is accepted immediately as
passenger-corrected; a high-confidence edit is automatically re-verified with no agent fallback; an
unresolved edit blocks confirmation for that field; the 3rd unresolved attempt in the session forces
a re-scan; an invalid-format edit is caught inline; re-scan discards everything.

**Independent Test**: Produce an extraction with a wrong field, correct it, and verify the correction
is recorded as passenger-supplied and re-checked against the document rather than accepted on trust,
and that an unsubstantiated correction never silently becomes the record.

### Tests for User Story 2

- [X] T032 [US2] Extend `DocumentConfirmationViewModel` unit tests: a low-confidence edit is accepted
      immediately; a high-confidence edit triggers `FieldReverificationRepository.reverify` and both
      the `confirmed` and `disagreed`/transport-`Error` outcomes are handled correctly; a
      format-invalid edit blocks with an inline error; the 3rd unresolved attempt in the session
      discards the extraction and routes to capture — in
      `test/unit/document_confirmation_viewmodel_test.dart`
- [X] T033 [P] [US2] Extend `DocumentConfirmationView` widget tests: the edit affordance opens the
      editor, a reverifying field shows a running state, an unresolved field disables the primary
      action, and an inline validation message appears before confirmation is possible, in
      `test/widget/document_confirmation_view_test.dart`

### Implementation for User Story 2

- [X] T034 [US2] Implement the per-field correction state machine (`FieldCorrectionState`/
      `FieldCorrectionStatus` per data-model.md) and the `editField` Command — format validation
      (FR-006), the confidence-based branch (accept immediately vs. call `reverify`), reverify-outcome
      handling, reverting an edit back to the original value, and the session-scoped 3-attempt cap
      routing to re-scan (FR-019) — in `document_confirmation_viewmodel.dart` (depends on: T006,
      T023; makes T032 pass)
- [X] T035 [P] [US2] Implement `FieldEditField` widget (in-place text/date editor with an inline
      validation message) in
      `lib/features/enrollment/confirmation/widgets/field_edit_field.dart`
- [X] T036 [US2] Wire `FieldEditField` into `FieldRow`/`DocumentConfirmationView` for the edit/
      reverifying/unresolved states, and disable the primary action while any field is invalid or
      unresolved (FR-007), in `document_confirmation_view.dart` (depends on: T026, T034, T035; makes
      T033 pass)
- [X] T037 [US2] Implement the "Escanear de nuevo" action: discard `PendingDocumentController` and all
      correction state, navigate to document capture, in
      `document_confirmation_viewmodel.dart`/`document_confirmation_view.dart` (depends on: T034)
- [X] T038 [US2] Wire `confirmation_field_edited`, `confirmation_field_reverified`,
      `confirmation_correction_attempt_limit_reached`, and `confirmation_rescanned` analytics events
      in `document_confirmation_viewmodel.dart` (depends on: T029, T034, T037)
- [X] T039 [P] [US2] Add Spanish copy strings for the edit affordance, inline validation messages, and
      the unresolved-correction messaging to `lib/l10n/app_es.arb`

**Checkpoint**: User Stories 1 and 2 both independently functional.

---

## Phase 5: User Story 3 - A document that cannot be used is caught before the biometric step (Priority: P2)

**Goal**: An expired document blocks confirmation with a plain-language reason and the conventional-
process direction; a field the processor could not extract is shown as an explicit gap with re-scan
offered.

**Independent Test**: Present extractions that are expired and missing a required field, and verify
each is stopped on this screen with an explanation and a next step rather than being confirmable.

### Tests for User Story 3

- [X] T040 [US3] Extend `DocumentConfirmationViewModel` unit tests: an expired `parsedExpiryDate`
      blocks confirmation and surfaces the reason; an `ExtractedField.missing` entry renders as an
      explicit gap and offers re-scan, in `test/unit/document_confirmation_viewmodel_test.dart`
- [X] T041 [P] [US3] Extend `DocumentConfirmationView` widget tests: the expired-blocked message
      replaces the normal field list, and a missing-field gap renders distinctly from a normal field,
      in `test/widget/document_confirmation_view_test.dart`

### Implementation for User Story 3

- [X] T042 [US3] Compute document validity (expired / missing required field) from `ExtractionResult`
      and the injected `Clock` on load, branching `DocumentConfirmationViewState` to the blocked/gap
      states before rendering fields, in `document_confirmation_viewmodel.dart` (depends on: T002,
      T023; makes T040 pass)
- [X] T043 [P] [US3] Implement `ExpiredDocumentMessage` widget (reason + conventional-airport-process
      direction) in
      `lib/features/enrollment/confirmation/widgets/expired_document_message.dart`
- [X] T044 [P] [US3] Implement `MissingFieldNotice` widget (explicit gap, re-scan offered) in
      `lib/features/enrollment/confirmation/widgets/missing_field_notice.dart`
- [X] T045 [US3] Wire both widgets into `DocumentConfirmationView`'s blocked/gap states (depends on:
      T026, T042, T043, T044; makes T041 pass)
- [X] T046 [US3] Wire the `confirmation_blocked_unusable_document` analytics event (`reason: expired`
      \| `missingRequiredField`) in `document_confirmation_viewmodel.dart` (depends on: T029, T042)
- [X] T047 [P] [US3] Add Spanish copy strings for the expired-document and missing-field messages to
      `lib/l10n/app_es.arb`

**Checkpoint**: All three user stories independently functional.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T048 [P] Implement back-navigation handling — discard `PendingDocumentController` state,
      preserve the enrollment session as incomplete rather than confirmed (FR-013), and emit
      `confirmation_step_abandoned` when no outcome was recorded — in
      `document_confirmation_viewmodel.dart`/`document_confirmation_view.dart`
- [X] T049 [P] Accessibility pass: full-value announcement for every field, character-by-character
      reading of the document number on request (FR-015), and confirm the expired/gap states are
      distinguishable without color alone, across
      `lib/features/enrollment/confirmation/widgets/`
- [X] T050 Run `flutter analyze` and resolve to zero warnings (Constitution Development Workflow gate)
- [X] T051 Run the full test suite (`flutter test`) and confirm ≥85% line coverage across
      `DocumentConfirmationViewModel`, `FieldReverificationRepositoryImpl`, and
      `IdentityRecordRepositoryImpl` (Constitution CI gate); also re-run
      `test/unit/capture_viewmodel_test.dart` and
      `test/contract/document_verification_repository_contract_test.dart` to confirm no regression
      from T005/T015/T016/T018
- [ ] T052 Execute specs/004-confirmar-datos/quickstart.md's manual validation scenarios 1–3
      end-to-end (depends on: all user stories) — **blocked**: no backend is deployed for this
      feature yet (`IdentityRecordRepository`/`FieldReverificationRepository` have no dev/fake
      wiring in `composition_root.dart`, matching 003's own precedent for
      `DocumentVerificationRepository`), so the real end-to-end path cannot be exercised on-device
      in this environment. A physical device is attached (`T704SP`, Android 15), but an
      `assembleDebug` build failed on a pre-existing Gradle/Kotlin toolchain cache issue in this
      environment, unrelated to this feature's Dart code (`flutter analyze`/`flutter test` are both
      fully green). Automated coverage (T020–T051) exercises every scenario headlessly via fakes.
- [ ] T053 Verify SC-006 on a device that has completed enrollment: zero document images found on
      disk, in caches, or in logs after this step — **blocked** for the same reason as T052.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies.
- **Foundational (Phase 2)**: Depends on Setup. BLOCKS all user stories.
- **User Stories (Phase 3–5)**: All depend on Foundational. US2 and US3 extend files US1 creates
  (`document_confirmation_viewmodel.dart`, `document_confirmation_view.dart`), so — matching 003's
  precedent — they're independently *testable* per their own Independent Test but sequenced after
  US1's implementation tasks.
- **Polish (Phase 6)**: Depends on all three user stories.

### Parallel Opportunities

- Foundational: T002, T003, T004 in parallel; T006/T007 in parallel once their entity dependencies
  exist; T008/T009 in parallel once T006/T007 exist; T011/T012 in parallel once T006 exists; T013/T014
  in parallel once T007 exists; T017 independent of everything except T002.
- Within US1: T024, T025, T030 in parallel once T023 exists.
- Within US2: T035 and T039 in parallel with the T034→T036 chain.
- Within US3: T043 and T044 in parallel with the T042→T045 chain.

---

## Parallel Example: Foundational Phase

```bash
# Once T006 (FieldReverificationRepository port) exists, these can run together:
Task: "Implement FakeFieldReverificationRepository in test/fakes/fake_field_reverification_repository.dart"
Task: "Implement FieldReverificationService + FieldReverificationRepositoryImpl in lib/data/services/"

# Independently, once T007 (IdentityRecordRepository port) exists:
Task: "Implement FakeIdentityRecordRepository in test/fakes/fake_identity_record_repository.dart"
Task: "Implement IdentityRecordService + IdentityRecordRepositoryImpl in lib/data/services/"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Setup → Foundational (blocks everything; this is the phase where 003's `CaptureOutcome` contract
   is extended, both new ports and the in-memory controller land).
2. User Story 1 → **STOP and VALIDATE**: quickstart.md scenario 1.
3. User Story 2 → validate independently (the correction/trust-boundary path that protects the
   zero-false-accepts budget).
4. User Story 3 → validate independently (the expired/gap paths that keep an unusable document from
   reaching the biometric step).
5. Polish → back navigation, accessibility, analyze/coverage gates (including 003's own regression
   suite), full quickstart pass, SC-006's on-device audit.

---

## Notes

- [P] tasks touch different files with no incomplete-task dependency.
- Tests are written first and must fail before their implementation task, per Constitution
  Principle IV.
- T005/T015/T016/T018 are this feature's one deliberate touch of already-shipped 003 code
  (research.md §1) — each is called out individually so the regression risk is tracked task-by-task
  rather than folded silently into new-feature work.
- T031 deletes 003-escanear-documento's placeholder, not kept alongside the real implementation, same
  pattern as 003's own T030 deleting 002-consentimiento's stub.
