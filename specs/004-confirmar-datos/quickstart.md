# Quickstart: Extracted Data Confirmation (04 Confirmar datos)

Validation guide once implemented. Unlike 003, this feature has no camera/hardware dependency of its
own — it can be fully exercised in a pure widget-test/no-device environment, including the "arrives via
a real capture" path, by driving `CaptureViewModel` through a fake `DocumentVerificationRepository`
first.

## Automated validation (run first)

```bash
fvm flutter analyze
fvm flutter test test/unit                # DocumentConfirmationViewModel + CaptureViewModel (updated)
fvm flutter test test/widget              # DocumentConfirmationView states
fvm flutter test test/contract            # DocumentVerificationRepository (updated), FieldReverificationRepository,
                                           # IdentityRecordRepository — fake AND real
fvm flutter test test/architecture        # import-boundary rule, unaffected but must stay green
```

Confirm 003's own suite is still green after this feature's `CaptureOutcome` change (research.md §1):

```bash
fvm flutter test test/unit/capture_viewmodel_test.dart
fvm flutter test test/contract/document_verification_repository_contract_test.dart
```

## Manual validation scenarios

Each maps to an Acceptance Scenario in spec.md. Requires a prior successful capture
(003-escanear-documento) — or the `USE_FAKE_CONSENT_BACKEND`/fake verification wiring used in earlier
features' manual testing, if no backend is reachable yet.

1. **Clean confirmation (User Story 1)**
   - Complete a capture that the processor accepts → confirm this screen shows the captured document
     thumbnail, the "✓ Capturado" badge, and all four fields with the same labels as the physical
     document.
   - Confirm the notice ("Verifica que los datos coincidan...") is visible before the fields.
   - Tap "Los datos son correctos" → confirm the flow advances to the selfie-instructions stub and the
     step indicator still shows "Documento" (this step is still part of the document stage).
   - Confirm (via a device file-system check, as in 003) no document image exists anywhere after
     advancing.

2. **Correcting a field (User Story 2)**
   - Using a fixture/fake extraction with one low-confidence field, edit it to a different value →
     confirm it's accepted immediately, marked passenger-corrected.
   - Using a fixture/fake extraction with a high-confidence field, edit it to a materially different
     value → confirm the automated re-check runs (observable via the fake
     `FieldReverificationRepository`'s call count) and:
     - if scripted to confirm, the field is accepted as re-verified;
     - if scripted to disagree, confirmation is blocked for that field and re-scan is offered, but a
       second and third distinct unresolved attempt are still possible before the flow is forced to
       re-scan (Acceptance Scenario 6) — confirm the 3rd attempt discards the extraction and returns to
       capture.
   - Confirm an invalid-format edit (e.g., a document number with no digits) shows an inline problem
     before confirmation is possible.
   - Tap "Escanear de nuevo" mid-edit → confirm all edits and the extraction are discarded and capture
     re-opens.

3. **Unusable document caught here (User Story 3)**
   - Using a fixture extraction with an expiry date in the past → confirm this screen opens directly to
     the blocked state naming the reason, with no path to confirm, directing to the conventional
     airport process.
   - Using a fixture extraction missing a required field → confirm the gap is shown explicitly (not a
     blank field) and re-scan is offered.

## Accessibility checks

- With a screen reader, confirm every field's value is announced in full, and that the document number
  specifically can be requested character-by-character (FR-015).
- Confirm the blocked (expired) and gap (missing-field) states are distinguishable without color alone.

## Analytics checks

- Walk each scenario above once with a logging `AnalyticsEmitter` and confirm the events in
  contracts/analytics-events.md fire in the expected order, with a `field` key on
  `confirmation_field_edited`/`confirmation_field_reverified` and never a value.
