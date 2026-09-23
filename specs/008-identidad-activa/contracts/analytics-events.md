# Contract: analytics events (credential issuance and screen 08)

Per research.md §12. Four new `AnalyticsEmitter` methods. Every event carries only the envelope
`LoggingAnalyticsEmitter` already adds (per-launch `sessionId`, `timestamp`) plus the fields below.
**No event carries a name, document digits, country, date, token, or enrollment attempt id**
(Constitution Principle VII; FR-015, not relaxable).

| Method | Emitted by | When | Fields |
|---|---|---|---|
| `credentialIssuanceRequested()` | `VerificationProgressViewModel` | Each call to `requestIssuance()`, including retries | none |
| `credentialIssuanceOutcome({required IssuanceOutcomeKind kind})` | `VerificationProgressViewModel` | Each result | `kind`: `activated`, `notActive`, `incomplete`, `transportError` |
| `credentialActivatedShown()` | `CredentialActivatedViewModel` | Once, when screen 08 is created | none |
| `credentialActivatedRouteTaken({required OnwardRoute route})` | `CredentialActivatedViewModel` | Once per exit | `route`: `trips`, `credentialDetail`, `backGestureToTrips` |

`notActive` deliberately does not carry which non-active status: that belongs to the not-active
screen's own spec, which can decide whether it is safe to log.

## Deferred

`enrollmentCompleted` with a duration, needed for FR-016 and SC-008, is deferred per the spec's
deferral table (research.md §12).

## Tests

- Unit tests assert each event is emitted exactly once per trigger, with the listed fields only.
- `FakeAnalyticsEmitter` and `LoggingAnalyticsEmitter` both implement the four methods.
