# Data Model: Identity Document Capture (03 Escanear documento)

## DocumentImage (in-memory only — never persisted, never logged)

Not a `freezed` value type deliberately — it wraps raw bytes and is handled as narrowly as possible,
passed directly from `CameraCaptureService` to `DocumentQualityAssessor`/
`DocumentVerificationRepository` and discarded (reference dropped, no copy retained) immediately
after each use. Does not appear in `domain/entities/` as a modeled type; it's `Uint8List` at the
boundary, by design, so there is nothing resembling a reusable "document image" model that a future
feature might be tempted to hold onto.

## QualityAssessment / QualityRejectionReason (sealed)

The on-device judgement, per data-model requirements in spec.md's Key Entities.

| Variant | Notes |
|---|---|
| `QualityAssessment.usable` | Passes all on-device checks; eligible for submission. |
| `QualityAssessment.rejected(reason: QualityRejectionReason)` | Failed on-device; never submitted (FR-006). |

`QualityRejectionReason` (sealed, shared with `CaptureOutcome` below per research.md §4):
`blur`, `glare`, `framing` (cropped/out-of-frame), `wrongDocument`, `lowResolution`.

## CaptureOutcome (sealed)

The result of submitting a `usable`-assessed capture to the verification processor.

| Variant | Fields | Notes |
|---|---|---|
| `CaptureOutcome.accepted` | — | Advances to data confirmation (004 stub). |
| `CaptureOutcome.rejected` | `reason: CaptureRejectionReason` | Returned to this screen with the reason. |

`CaptureRejectionReason` extends the same vocabulary as `QualityRejectionReason` plus one
processor-only variant: `blur`, `glare`, `framing`, `wrongDocument`, `lowResolution`, `unreadable`
(processor-only — whatever it rejected that the device heuristics didn't catch, mapped from its
error taxonomy at the service boundary, per research.md §4). No other value is representable — a
processor error the mapping doesn't recognize is a defect to fix in the mapping, not something the
UI has to handle generically.

## CaptureAttempt

Not persisted itself (only the aggregate counter below is) — an in-memory record of one activation
of the capture control, used to drive the UI's current state and decide whether to submit.

| Field | Type | Notes |
|---|---|---|
| `qualityAssessment` | `QualityAssessment` | Set immediately after on-device assessment. |
| `outcome` | `CaptureOutcome?` | Set only if `qualityAssessment.usable` and submission completed; null otherwise. |

## CaptureAttemptCounter (persisted — the one new persisted entity, per the amended Constitution Principle I)

| Field | Type | Notes |
|---|---|---|
| `count` | `int` | Failed attempts since the last reset. Incremented on any `rejected` outcome (device- or processor-side); NOT incremented on `accepted`. |
| `lastResetAt` | `DateTime` | Set on successful completion of this step or explicit routing to retry guidance (research.md §3). |

**Limit**: 3 (FR-009). On `count` reaching 3, `CaptureViewModel` routes to the retry-guidance stub
and resets the counter (a fresh future attempt, whenever it happens, starts clean — the limit
protects a single continuous run of attempts, not a lifetime ban).

## Relationships

```text
CaptureViewModel
 ├─ reads local ConsentRecord (via ConsentRepository, 002) — gates camera access (FR-001)
 ├─ owns CameraCaptureService lifecycle (start/stop/dispose, torch toggle)
 ├─ on capture: DocumentQualityAssessor.assess(bytes) -> QualityAssessment
 │    ├─ rejected -> increments CaptureAttemptCounter, shows inline error, discards bytes
 │    └─ usable -> DocumentVerificationRepository.submit(bytes) -> Result<CaptureOutcome>
 │         ├─ accepted -> advances to data confirmation, resets CaptureAttemptCounter
 │         └─ rejected -> increments CaptureAttemptCounter, shows inline error, discards bytes
 └─ reads/writes CaptureAttemptCounter (via CaptureAttemptCounterRepository)
```

No entity here is written to disk except `CaptureAttemptCounter` — `DocumentImage`,
`QualityAssessment`, and `CaptureOutcome` are all transient, matching FR-010 and Principle I.
