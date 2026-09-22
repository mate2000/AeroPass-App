# Implementation Plan: Extracted Data Confirmation (04 Confirmar datos)

**Branch**: `004-confirmar-datos` | **Date**: 2026-09-21 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/004-confirmar-datos/spec.md`

## Summary

The passenger reviews the four fields the processor extracted from their just-captured document
(003-escanear-documento) alongside a thumbnail of the document itself, corrects any field the machine
misread, and confirms. A correction to a field the processor read with ≥0.95 confidence is never
accepted on the passenger's word alone — it is automatically re-verified against the retained document
image, with no agent-escalation fallback; an edit that cannot be confirmed this way blocks confirmation
and, after 3 such unresolved attempts in the session, forces a re-scan. An expired document blocks
confirmation outright; a field the processor could not read is shown as an explicit gap. Confirmation
submits the full record (durably, backend-first) and advances to the selfie step; only a display-only
subset of the confirmed fields is cached on-device afterward, per the constitution's existing Principle
I allowlist. This feature also extends 003's `CaptureOutcome.accepted` to carry the extraction result
it previously had no way to convey (research.md §1) — the one piece of already-shipped code this
feature must modify, not just add to.

## Technical Context

**Language/Version**: Dart / Flutter, the same FVM-pinned stable channel (3.47.5) as 001–003 — no
change.

**Primary Dependencies**: Reuses `provider`, `go_router`, `freezed`, `flutter_secure_storage`, `dio`
(pinned), `mocktail`, and `intl` (already a transitive dependency of `flutter_localizations`, used here
for the first time directly, for `es`-locale expiry-date display formatting — research.md §3). **No new
package dependency.**

**Storage**: `flutter_secure_storage`, extended with one new key: a display-only subset of the
confirmed identity fields (key+value pairs only, no source/original/audit data), written only after
`IdentityRecordRepository.confirm()` succeeds — the exact persisted-state category already named in the
constitution's Principle I allowlist ("a display-only subset of identity fields the user already saw on
the confirmation screen"). No constitution amendment required (unlike 003). No document image,
extraction result, or correction audit trail is ever persisted.

**Testing**: `flutter_test`, `mocktail`. Principle IV applies to this screen doubly: it decides
identity-record content (a named trust-boundary category) and it is the enforcement point for the
zero-false-accepts budget on passenger corrections.

**Target Platform**: Android 8.0 / iOS 15.0 — unchanged app-wide baseline. No new platform capability
(no camera, no new permission) — this screen only reads the image bytes 003 already captured.

**Project Type**: Mobile app (Flutter, feature-first) — extends the existing project; also modifies one
piece of already-shipped 003 code (research.md §1).

**Performance Goals**: ≥95% of passengers complete the step within 30s at p90 (SC-005); the automated
field re-check (FR-005) is a network call and must not stall the UI — it runs behind the same
`Command`-based running/error state pattern every other async ViewModel action in this app already
uses.

**Constraints**: No field is retained in the eventual record that isn't displayed (FR-002); the
document image and extraction result exist only in `PendingDocumentController`, in memory, discarded on
confirm/re-scan/back-navigation (FR-011); confirmation is unavailable while any field is invalid or
unresolved (FR-007); a high-confidence field's edit is never accepted without automated re-verification,
with no agent-escalation fallback (FR-005, Clarifications); an expired document blocks confirmation
outright (FR-008); screenshots are explicitly NOT blocked on this screen, consistent with 003's
precedent (FR-018).

**Scale/Scope**: One screen (`DocumentConfirmationView`) with states for normal review, expired-blocked,
missing-field-gap, and per-field edit/reverifying/unresolved; two new domain ports
(`FieldReverificationRepository`, `IdentityRecordRepository`) with real+fake implementations and
contract tests; one modification to an existing 003 port (`CaptureOutcome.accepted`); one new
app-singleton (`PendingDocumentController`); one shared widget relocation (`StepIndicator`, unchanged,
moved to the common module).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design — no changes below between
the two passes; design did not surface a new violation.*

| Principle | Status | Notes |
|---|---|---|
| I. Consent and Data Minimization | **PASS** | The only new persisted state — the display-only field subset — is already named in the allowlist (research.md §5); no amendment needed. Document image, extraction result, and the full audit-trail `IdentityRecord` (source/original/reverified) are in-memory only, discarded on every exit path (FR-011), extending 003's raw-artifact discipline to this screen's own retained data rather than relaxing it. |
| II. The Verification Provider Is an Adapter | **PASS** | `FieldReverificationRepository` and `IdentityRecordRepository` are both domain-owned ports with fake implementations driving the full contract-test suite, no network, no provider SDK type crossing into `DocumentConfirmationViewModel`. The modification to `DocumentVerificationRepository`'s DTO stays inside `lib/data/` (research.md §1). |
| III. Every Flow Has a Failure Path | **PASS** | States: loading (reading `PendingDocumentController`) → ready / expired-blocked / missing-field-gap; per-field edit → validating → (accepted-low-confidence \| reverifying → accepted-reverified \| unresolved); confirm → confirmed \| confirm-failed (offline, FR-017). Every failure names its recovery (re-scan, retry the edit, wait/retry confirm) — never a snackbar. |
| IV. Test-First on the Trust Boundary | **PASS (governs task ordering)** | This screen decides identity-record content and enforces the false-accept boundary on corrections — both trust-boundary categories per Principle IV's own examples. Contract tests for both new ports, unit tests for `DocumentConfirmationViewModel`'s field-resolution state machine, and the updated `CaptureOutcome`/`DocumentVerificationRepository` contract tests, all written first. |
| V. Airport-Grade Experience Constraints | **PASS** | Primary/secondary actions in the bottom half of the screen per the UI reference; no auto-advance timer (confirmation is always an explicit tap, FR-007); the field re-check network call runs behind a `Command`'s own loading state rather than blocking input elsewhere on the screen. |
| VI. Accessibility Is a Gate, Not a Polish Pass | **PASS** | FR-015's character-level document-number announcement; the expired/gap states are conveyed by text, not the red-frame-alone pattern 003 already established; dynamic type and grayscale-distinguishable states apply identically. |
| VII. Observability Without PII | **PASS** | contracts/analytics-events.md's events carry `FieldKey` (which field) but never a field's value, an image, or the extraction/record content — same discipline as 003's `AnalyticsEmitter` additions. |
| VIII. Architecture Follows the Flutter App Architecture Guide | **PASS** | `features/enrollment/confirmation/`; the two new ports live under `domain/repositories/` (not confirmation-private) since `IdentityRecordRepository` in particular is a natural dependency for a future credential/pass feature reading the same record. `StepIndicator` moves to `lib/core/design/` — the common module — since it now has two real, identical-output call sites (research.md §7). |
| IX. Mandated Code Patterns | **PASS** | `Result<T>` from both new repositories; edit/reverify/confirm/re-scan exposed as `Command`s; `FieldCorrectionStatus`, `FieldReverificationOutcome`, and `ExtractedField` are sealed types, not booleans; constructor injection throughout; no optimistic state — the identity record is only ever shown as confirmed after a real `Ok` from `IdentityRecordRepository.confirm()`. |
| X. Craft Standards Apply to Every Line | **PASS (enforced at review)** | The one deliberate cross-feature edit (003's `CaptureOutcome`) is documented, not silently done (research.md §1) — this is the Boy Scout Rule applied to a contract that shipped one field short, not unrelated refactoring smuggled into this PR. |

No unresolved gate failures.

## Project Structure

### Documentation (this feature)

```text
specs/004-confirmar-datos/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md         # Phase 1 output (/speckit-plan command)
├── quickstart.md         # Phase 1 output (/speckit-plan command)
├── contracts/            # Phase 1 output (/speckit-plan command)
│   ├── document-verification-port-addendum.md   # change to 003's existing port
│   ├── field-reverification-port.md              # new port
│   ├── identity-record-repository-port.md        # new port
│   └── analytics-events.md                       # new events
└── tasks.md              # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root) — additions/changes to the existing project

```text
lib/
├── app/
│   ├── router.dart                              # CHANGE: real DocumentConfirmationView at
│   │                                             #   AppRoutes.documentConfirmation; guard redirects
│   │                                             #   to documentCapture when PendingDocumentController
│   │                                             #   is empty; help route wiring (research.md §8)
│   ├── composition_root.dart                     # CHANGE: wire FieldReverificationRepository,
│   │                                             #   IdentityRecordRepository, PendingDocumentController
│   └── pending_document_controller.dart          # NEW: in-memory holder (image bytes + extraction),
│                                                  #   mirrors EnrollmentSessionController
├── domain/
│   ├── entities/
│   │   ├── capture_outcome.dart                  # CHANGE: CaptureOutcome.accepted gains
│   │   │                                         #   required extraction: ExtractionResult
│   │   ├── extraction_result.dart                # NEW: ExtractionResult, ExtractedField (sealed),
│   │   │                                         #   FieldKey
│   │   ├── field_reverification_outcome.dart     # NEW: sealed confirmed/disagreed
│   │   └── identity_record.dart                  # NEW: IdentityRecord, ConfirmedField, FieldSource
│   └── repositories/
│       ├── field_reverification_repository.dart  # NEW: abstract port
│       └── identity_record_repository.dart       # NEW: abstract port
├── data/
│   ├── models/
│   │   ├── document_verification_response.dart   # CHANGE: add `fields` array (contracts addendum)
│   │   ├── field_reverification_response.dart     # NEW DTO
│   │   └── identity_record_confirmation_request.dart  # NEW DTO (outbound)
│   └── services/
│       ├── document_verification_repository_impl.dart  # CHANGE: map `fields` -> ExtractionResult
│       ├── field_reverification_service.dart             # NEW: dio (pinned) call
│       ├── field_reverification_repository_impl.dart     # NEW
│       ├── identity_record_service.dart                  # NEW: dio (pinned) call +
│       │                                                 #   flutter_secure_storage local write
│       └── identity_record_repository_impl.dart          # NEW
└── features/
    └── enrollment/
        └── confirmation/
            ├── document_confirmation_view.dart           # NEW: replaces the 003-era placeholder
            ├── document_confirmation_viewmodel.dart       # NEW
            ├── document_confirmation_view_state.dart      # NEW
            └── widgets/
                ├── document_thumbnail_card.dart            # NEW: navy card, thumbnail, "✓ Capturado",
                │                                          #   country marker
                ├── field_row.dart                           # NEW: read-only display + edit affordance
                ├── field_edit_field.dart                    # NEW: the in-place editor (text or date)
                ├── missing_field_notice.dart                # NEW: FR-009's explicit gap
                └── expired_document_message.dart            # NEW: FR-008's blocked state

lib/core/design/
└── step_indicator.dart    # MOVED (unchanged) from features/enrollment/capture/widgets/ —
                            #   research.md §7; capture_view.dart's import updated accordingly

test/
├── contract/
│   ├── document_verification_repository_contract_test.dart  # CHANGE: extend for extraction (see
│   │                                                         #   contracts addendum)
│   ├── field_reverification_repository_contract_test.dart   # NEW: fake AND real
│   └── identity_record_repository_contract_test.dart        # NEW: fake AND real
├── unit/
│   ├── capture_viewmodel_test.dart                # CHANGE: update accepted-path assertions
│   └── document_confirmation_viewmodel_test.dart   # NEW
├── widget/
│   └── document_confirmation_view_test.dart        # NEW
└── fakes/
    ├── fake_document_verification_repository.dart  # CHANGE: scriptSubmit call sites need extraction
    ├── fake_field_reverification_repository.dart    # NEW
    └── fake_identity_record_repository.dart         # NEW
```

**Structure Decision**: Same feature-first layout 001–003 already establish. `FieldReverificationRepository`
and `IdentityRecordRepository` live under `domain/repositories/` (shared, not confirmation-private) —
`IdentityRecordRepository` in particular because a future credential/pass feature will read the same
record. The confirmation *screen* is feature-private under `features/enrollment/confirmation/`.
`StepIndicator` moves out of `capture/widgets/` into `lib/core/design/`, the module Principle VIII
already designates for cross-feature UI primitives, now that it has a second real, identical-output
consumer (research.md §7).

## Complexity Tracking

*No entries — the Constitution Check passes with no unjustified violations. The one cross-feature
change (003's `CaptureOutcome.accepted`) is not a constitutional deviation; it is documented in
research.md §1 and the contracts addendum as a scoped, mechanical extension of an existing contract,
with its own migration obligations and regression coverage.*
