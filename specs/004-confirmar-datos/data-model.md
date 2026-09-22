# Data Model: Extracted Data Confirmation (04 Confirmar datos)

## FieldKey (enum)

`fullName`, `documentNumber`, `nationality`, `expiryDate` — the four fields spec.md's UI Reference
names. Shared by `ExtractedField`, `FieldCorrection`, and `ConfirmedField` below, so there is exactly
one vocabulary for "which field," never a per-layer re-encoding.

## ExtractedField (sealed) / ExtractionResult

The processor's per-field read, per research.md §2.

| Variant | Fields | Notes |
|---|---|---|
| `ExtractedField.present` | `key: FieldKey`, `value: String`, `confidence: double` | `value` is the raw/canonical form — ISO-8601 (`yyyy-MM-dd`) for `expiryDate` (research.md §3), the literal string otherwise. `confidence` is `0.0`–`1.0`. |
| `ExtractedField.missing` | `key: FieldKey` | The processor attempted this document type's field set and could not read this one (FR-009's explicit gap — never represented as an empty string). |

```text
ExtractionResult
 └─ fields: List<ExtractedField>   // one entry per field the processor's contract defines for
                                    // this document type; order not significant
```

`ExtractionResult` also exposes `parsedExpiryDate` (`DateTime?`, a getter — not a stored field): parses
the `expiryDate` field's ISO string if present via `DateTime.parse`, else `null`. Held for the session
only (never persisted) — see `PendingDocumentController` below.

## DocumentValidity (derived, not a stored entity)

Computed by `DocumentConfirmationViewModel` from `ExtractionResult.parsedExpiryDate` and the injected
`Clock`:

- `expired`: `parsedExpiryDate != null && parsedExpiryDate.isBefore(clock.now())` → FR-008 blocks
  confirmation.
- `missingRequiredField`: any `ExtractedField.missing` present in `fields` → FR-009 blocks confirmation
  and offers re-scan.

Not modeled as a `freezed` type of its own — it's a pure function of already-modeled data, computed
fresh each time the view needs it, per Constitution Principle X (KISS: no entity for a value that's
just a read of two existing fields).

## FieldReverificationOutcome (sealed)

The result of `FieldReverificationRepository.reverify(...)` (research.md §4).

| Variant | Notes |
|---|---|
| `FieldReverificationOutcome.confirmed` | The automated re-read of this field, from the retained image, agrees with the passenger's edited value. |
| `FieldReverificationOutcome.disagreed` | It does not. Treated identically to a transport `Error` by the ViewModel (research.md §6). |

## FieldCorrectionState (view-model-local, not persisted, not a domain entity)

One per `FieldKey`, held in `DocumentConfirmationViewModel`'s state for the duration of this screen.

| Field | Type | Notes |
|---|---|---|
| `key` | `FieldKey` | |
| `originalValue` | `String?` | `null` if the field was `ExtractedField.missing`. |
| `originalConfidence` | `double?` | `null` if missing. |
| `currentValue` | `String` | Starts equal to `originalValue`; updated as the passenger edits. |
| `status` | `FieldCorrectionStatus` (sealed: `unedited` \| `validating` \| `invalid(reason)` \| `acceptedLowConfidence` \| `reverifying` \| `acceptedReverified` \| `unresolved`) | Drives FR-007's "confirmation unavailable while any field is invalid/unresolved." |

A field is **passenger-corrected** in the eventual `IdentityRecord` iff `currentValue != originalValue`
and `status` is `acceptedLowConfidence` or `acceptedReverified` — never `unresolved` (an unresolved
field cannot be confirmed at all, per FR-007).

## Correction-attempt cap (session-scoped, in-memory — research.md §6)

A plain `int` on `DocumentConfirmationViewModel`, not a repository-backed entity (unlike 003's durable
`CaptureAttemptCounter`). Incremented once per edit that reaches `FieldCorrectionStatus.unresolved`.
Limit: 3 (FR-019). Reset implicitly on re-scan (the whole ViewModel, and the `PendingDocumentController`
it reads from, is torn down and rebuilt fresh).

## IdentityRecord / ConfirmedField / FieldSource

What confirmation produces (FR-002, FR-004, SC-002).

```text
FieldSource: machineRead | passengerCorrected

ConfirmedField
 ├─ key: FieldKey
 ├─ value: String                  // the confirmed value — original or corrected
 ├─ source: FieldSource
 ├─ originalValue: String?         // present only when source == passengerCorrected; the
 │                                 // machine-extracted value before correction (SC-002's audit trail)
 └─ reverified: bool               // true if source == passengerCorrected and an automated
                                   // re-check (not just a low-confidence pass-through) confirmed it

IdentityRecord
 └─ fields: List<ConfirmedField>
```

Submitted in full to `IdentityRecordRepository.confirm(...)`. Per research.md §5, only a **display-only
subset** — `key`+`value` pairs, no `source`/`originalValue`/`reverified` — is cached locally in secure
storage after a successful confirm; the full `IdentityRecord` (including the audit distinction SC-002
requires) exists only in memory and on the backend.

## PendingDocumentController (app-singleton, in-memory only — research.md §1)

Mirrors `EnrollmentSessionController`'s shape and lifecycle rules exactly.

| Field | Type | Notes |
|---|---|---|
| `documentImageBytes` | `Uint8List?` | Set by `CaptureViewModel` on `CaptureOutcome.accepted`; read by `DocumentConfirmationView` for the thumbnail (FR-001). |
| `extraction` | `ExtractionResult?` | Set alongside the image bytes. |

Methods: `set(bytes, extraction)`, `clear()`. **Never persisted, never logged** (FR-011, FR-002's "no
field retained that isn't displayed" — this controller is exactly the retained set, and it is memory-
only). Cleared on: confirmation recorded (success), re-scan, explicit back navigation, and app
termination (implicitly — nothing here survives process death, same rule as `EnrollmentSession`).

If `DocumentConfirmationViewModel` loads and finds this controller empty (e.g., a deep link straight
into this route, or the process was killed and relaunched), it redirects back to document capture —
the same defensive pattern 003's router already applies to the consent gate.

## Relationships

```text
CaptureViewModel (003, modified)
 └─ on CaptureOutcome.accepted(extraction) -> PendingDocumentController.set(bytes, extraction)
      -> navigates to documentConfirmation

DocumentConfirmationViewModel (new)
 ├─ reads PendingDocumentController.current (image bytes + ExtractionResult)
 │    └─ empty -> redirect to document capture (defensive, mirrors 003's consent-gate guard)
 ├─ derives DocumentValidity (expired / missingRequiredField) from ExtractionResult + Clock
 │    ├─ expired -> confirmation blocked, "conventional airport process" message (FR-008)
 │    └─ missingRequiredField -> gap shown per field, re-scan offered (FR-009)
 ├─ holds one FieldCorrectionState per FieldKey
 │    └─ on edit: validate format (FR-006)
 │         ├─ invalid -> FieldCorrectionStatus.invalid, confirmation blocked for this field
 │         └─ valid
 │              ├─ originalConfidence < 0.95 -> acceptedLowConfidence (no re-check)
 │              └─ originalConfidence >= 0.95 -> FieldReverificationRepository.reverify(...)
 │                   ├─ confirmed -> acceptedReverified
 │                   └─ disagreed / Error -> unresolved, correction-attempt cap += 1
 │                        └─ cap reaches 3 -> discard extraction + edits, route to capture (FR-019)
 ├─ on confirm (all fields resolved, not expired, no gap):
 │    IdentityRecordRepository.confirm(IdentityRecord) -> Result
 │         ├─ Ok -> cache display-only subset locally, PendingDocumentController.clear(),
 │         │        advance to selfie instructions (005)
 │         └─ Error -> confirmation not recorded, flow does not advance, passenger told why (FR-017)
 └─ on re-scan or back navigation: PendingDocumentController.clear(), navigate to document capture
```

No entity here is written to disk except the post-confirmation display-only subset
(`ConfirmedField.key`+`value` pairs only) — `ExtractionResult`, `PendingDocumentController`'s held
bytes, `FieldCorrectionState`, and the full `IdentityRecord` (with its audit-trail fields) are all
transient, matching FR-011 and Constitution Principle I.
