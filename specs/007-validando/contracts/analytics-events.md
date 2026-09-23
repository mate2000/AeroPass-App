# Contract: analytics events (07 Validando)

Per research.md §13. New `AnalyticsEmitter` methods. Each carries only the envelope
`LoggingAnalyticsEmitter` adds (per-launch `sessionId`, `timestamp`) plus the fields below. **No
event carries a name, document data, face data, token, or the enrollment attempt id** (FR-015,
Constitution Principle VII).

| Method | When | Fields |
|---|---|---|
| `verificationStepEntered()` | The screen opens | none |
| `verificationStageReached({required VerificationStage stage, required StageStatus status})` | A stage becomes `running`, `passed` or `failed` | `stage`, `status` |
| `verificationSlowNoticeShown()` | The 10-second notice appears | none |
| `verificationHelpOpened()` | "Ayuda" is tapped | none |
| `verificationTimedOut()` | The 30-second limit is reached | none |
| `verificationOutcome({required VerificationOutcomeKind kind, required int elapsedSeconds})` | Once, when the screen routes onward | `kind`, `elapsedSeconds` (rounded, from screen open) |

`kind` uses `biometricRejected` for face mismatch, liveness and attack detection alike, so no
event isolates attack detection.

008's `credentialIssuanceRequested` and `credentialIssuanceOutcome` keep firing from the issuance
stage, unchanged.

## Deferred

Recovery-after-relaunch events, with FR-010.

## Tests

Unit tests assert each event fires exactly once per trigger, with only the listed fields.
`FakeAnalyticsEmitter` and `LoggingAnalyticsEmitter` implement every new method.
