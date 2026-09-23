# Contract: analytics events (FR-015, FR-016)

These are new methods on `AnalyticsEmitter`, implemented in `LoggingAnalyticsEmitter` and
`FakeAnalyticsEmitter`. Every payload is enums, booleans and integers only (Principle VII).

| Method | Event name | Payload | Emitted by |
|---|---|---|---|
| `technicalErrorShown({failureClass, stage, jobTerminal})` | `technical_error_shown` | enum, enum or null when nothing was recorded, bool | Screen 11 ViewModel, once on open |
| `technicalErrorStatusShown({documentScan, selfie, issuance})` | `technical_error_status_shown` | three `StepHealth` names | Screen 11 ViewModel, on the first successful status read |
| `technicalErrorRetry({destination, arrival})` | `technical_error_retry` | `verification` or `selfie`; int | Screen 11 ViewModel, when a retry is taken |
| `technicalErrorExit()` | `technical_error_exit` | none | Screen 11 ViewModel, on "Salir" |
| `technicalErrorResolved({elapsedSeconds})` | `technical_error_resolved` | int | 007 ViewModel, on activation after an earlier technical error in this run |

## Measuring FR-016's rate

The occurrence rate is `technical_error_shown` sessions divided by sessions with the existing
enrollment-start event, keyed to the anonymous session id. No new instrumentation is needed.

## Test

A unit test lists every new method's payload keys and asserts they contain no field from
Principle VII's forbidden list. `FakeAnalyticsEmitter` records the snake_case names above.
