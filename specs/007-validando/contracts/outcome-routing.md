# Contract: outcome routing and attempt counting

Per research.md §4 and §5. The single table `VerificationProgressViewModel` implements for FR-005,
FR-008, FR-009 and FR-013, and the table its unit tests enumerate (SC-003, SC-006, SC-007, SC-010).

## Routing

| # | Result | Failed stage shown | Destination | Counter incremented |
|---|---|---|---|---|
| R1 | Job `matched`, issuance `Ok(activated)` | none | `credentialActivated`, with 008's hand-off set and the session cleared | none; `selfieLiveness` reset |
| R2 | Job `matched`, issuance `Ok(notActive)` | issuance | `credentialNotActive` | none |
| R3 | Job `matched`, issuance `Ok(incomplete)` | issuance | `credentialNotActive` | none |
| R4 | Job `matched`, issuance `Result.error` | issuance | `technicalError` | none |
| R5 | Job `documentRejected`, counter below limit after increment | documentCheck | `documentCapture`, after `returnToDocumentCapture()` and clearing the pending document | `documentCapture` |
| R6 | Job `documentRejected`, counter at limit after increment | documentCheck | `retryGuidance` | `documentCapture`, then reset |
| R7 | Job `faceMismatch` | faceComparison | `retryGuidance` | `selfieLiveness` |
| R8 | Job `livenessRejected` | faceComparison | `retryGuidance` | `selfieLiveness` |
| R9 | Job `attackDetected` | faceComparison | `retryGuidance`, indistinguishable from R7 | `selfieLiveness` |
| R10 | Job `serviceFailure` | the stage that was running | `technicalError` | none |
| R11 | 30 seconds with no terminal result | the stage that was running | `technicalError` | none |

## Rules every row obeys

- The issuance stage shows `passed` only in R1 (FR-005, SC-010).
- Every failure row shows the same line, "No pudimos completar la verificación", then waits
  `failureDisplayPause` before navigating (FR-013). R7, R8 and R9 are identical on screen and in
  what is announced (FR-012, SC-007).
- No failure row counts an attempt unless the passenger's capture caused it (SC-006).
- A single failed poll routes nowhere (research.md §3).
- Navigation is a one-shot target, acted on only while the screen is the current route (research.md §6).
