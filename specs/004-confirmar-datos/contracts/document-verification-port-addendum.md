# Contract addendum: `DocumentVerificationRepository` (003, extended by this feature)

This does not replace `specs/003-escanear-documento/contracts/document-verification-port.md` — it
records the one change this feature makes to that already-shipped contract, per research.md §1.

## What changes

```text
// Before (003, as shipped):
const factory CaptureOutcome.accepted() = CaptureOutcomeAccepted;

// After (this feature):
const factory CaptureOutcome.accepted({
  required ExtractionResult extraction,
}) = CaptureOutcomeAccepted;
```

The `submit()` method signature itself is unchanged. `DocumentVerificationResponse` (the DTO) gains a
`fields` array, populated only when `outcome == "accepted"`:

```json
{
  "outcome": "accepted",
  "fields": [
    {"key": "full_name", "value": "Mateo González Restrepo", "confidence": 0.98},
    {"key": "document_number", "value": "CC 1.234.567.890", "confidence": 0.97},
    {"key": "nationality", "value": "Colombiana", "confidence": 0.99},
    {"key": "expiry_date", "value": "2031-03-14", "confidence": 0.95}
  ]
}
```

A field the processor could not read for this document type is either omitted from `fields` (mapped to
`ExtractedField.missing`) or present with an explicit `"missing": true` marker if the processor's real
contract distinguishes "didn't attempt" from "attempted, failed" — this project's own real contract is
not yet defined against a live backend (see spec.md's Dependencies), so
`DocumentVerificationRepositoryImpl._mapResponse` treats any key absent from `fields` as
`ExtractedField.missing`, matching the fake's scriptable behavior below.

## What does NOT change

- `submit()`'s parameters, return type, and rejected-path mapping (`CaptureRejectionReason` etc.) — all
  identical to 003's contract.
- The transport-failure-is-`Error` rule.
- `CaptureViewModel`'s device-side quality gate and rejection handling — untouched by this feature.

## Migration obligations this feature carries

1. `test/fakes/fake_document_verification_repository.dart`: `scriptSubmit` callers that construct
   `CaptureOutcome.accepted()` must be updated to supply an `extraction`. Existing 003 tests that do
   this must be updated as part of this feature's tasks, not left broken.
2. `test/contract/document_verification_repository_contract_test.dart`: contract case 1 ("Submission
   accepted by the processor") must assert on the returned `extraction`, not just the outcome variant.
3. `DocumentVerificationRepositoryImpl._mapResponse`: gains the fields → `ExtractionResult` mapping.

## Contract test additions (this feature)

1. Submission accepted, all four fields present → `Ok(CaptureOutcome.accepted(extraction: ...))` with
   every field as `ExtractedField.present`.
2. Submission accepted, one field absent from the response → that field maps to
   `ExtractedField.missing`, others unaffected.
3. Existing 003 cases 2–7 (rejections, transport failure, unrecognized error code) — unchanged,
   re-run as regression coverage for this modification.
