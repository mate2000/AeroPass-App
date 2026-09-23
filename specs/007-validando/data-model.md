# Data Model: Verification In Progress (07 Validando)

All new domain types are `freezed` sealed classes or plain enums (Constitution Principle IX).
**Nothing new is persisted**: the job is identified by the existing `EnrollmentAttemptId` in the
consent record (research.md §1), and every value below lives in memory for the screen's lifetime.

## Domain entities (new)

### `StageStatus` (enum)

`pending`, `running`, `passed`, `failed`. What one checklist stage shows. Only the backend's report
can move a stage to `passed` or `failed` (FR-003).

### `VerificationStage` (enum)

`documentCheck`, `faceComparison`, `issuance`. Always displayed in this order.

### `VerificationOutcome` (sealed)

The job's terminal result, normalized at the data boundary (research.md §4).

| Variant | Meaning |
|---|---|
| `matched` | Document and face both passed; issuance may be requested |
| `documentRejected` | The document check failed |
| `faceMismatch` | The face did not match the document |
| `livenessRejected` | The backend rejected liveness after capture |
| `attackDetected` | A presentation attack was detected. Distinct for audit, identical for the passenger |
| `serviceFailure` | The service failed, or returned a code the app does not recognize |

### `VerificationJobStatus` (sealed)

What one `getStatus()` call returns, inside `Result<VerificationJobStatus>`.

| Variant | Payload |
|---|---|
| `inProgress` | `StageStatus documentCheck`, `StageStatus faceComparison` |
| `completed` | `VerificationOutcome outcome`, plus the final `documentCheck` and `faceComparison` statuses |

Invariant, enforced by the mapping: a stage reported `passed` never returns to `pending` or
`running` in a later poll; the view model ignores any report that would move a stage backwards.

### `VerificationOutcomeKind` (enum, analytics only)

`activated`, `notActive`, `documentRejected`, `biometricRejected`, `serviceFailure`, `timedOut`.
`biometricRejected` covers face mismatch, liveness and attack detection together, so analytics
payloads never isolate attack detection (research.md §13; 006's own analytics keeps its separate,
already-reviewed classification).

## View state (new)

### `VerificationProgressViewState` (sealed; replaces 008's two-state version)

| Variant | Payload | Rendered as |
|---|---|---|
| `waiting` | `Map<VerificationStage, StageStatus> stages`, `bool slowNoticeVisible` | Checklist, plus the slow notice with "Seguir esperando" and "Ayuda" when visible |
| `failed` | `VerificationStage failedStage` | The failed stage marked, the generic line, for `failureDisplayPause` |

### `VerificationNavigationTarget` (enum; extended from 008)

`credentialActivated`, `credentialNotActive` (from 008), plus `documentCapture`, `retryGuidance`,
`technicalError`.

## App-layer changes

### `EnrollmentSessionController` (changed)

New `returnToDocumentCapture()`: `stepReached` becomes document capture and `identityConfirmed`
becomes `false` (research.md §11).

## Data layer (new)

### `VerificationJobResponse` (DTO, inbound only)

| Wire field | Maps to |
|---|---|
| `state` | `"in_progress"` or `"completed"`; anything else maps to `completed(serviceFailure)` |
| `documentCheck` | `StageStatus` (`pending`, `running`, `passed`, `failed`); unknown maps to `pending` |
| `faceComparison` | Same |
| `outcome` | Present when completed: `matched`, `document_rejected`, `face_mismatch`, `liveness_rejected`, `attack_detected`, `service_failure`; anything else maps to `serviceFailure` |

All fields are nullable strings, so malformed data maps to a safe value instead of throwing. The
DTO never leaves `lib/data/`.

## State transitions

```text
screen opens (t = 0)
  waiting: all stages pending → poll every 1 s
    ├─ inProgress           → update stages (never backwards), keep polling
    ├─ completed(matched)   → faceComparison passed, issuance running → requestIssuance()
    │     ├─ Ok(activated)  → issuance passed → hand-off, session cleared → credentialActivated
    │     ├─ Ok(notActive | incomplete)       → failed(issuance) → pause → credentialNotActive
    │     └─ Error          → failed(issuance) → pause → technicalError
    ├─ completed(documentRejected)            → failed(documentCheck) → count → pause → documentCapture | retryGuidance
    ├─ completed(faceMismatch | livenessRejected | attackDetected)
    │                       → failed(faceComparison) → count → pause → retryGuidance
    ├─ completed(serviceFailure)              → failed(running stage) → pause → technicalError
    └─ Error (one poll)     → ignored, next tick polls again
  t = 10 s → slowNoticeVisible = true ("Seguir esperando" hides it)
  t = 30 s → failed(running stage) → pause → technicalError (no attempt counted)
```
