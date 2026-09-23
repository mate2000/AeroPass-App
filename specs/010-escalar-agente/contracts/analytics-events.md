# Contract: analytics events (10 Escalar agente)

Per research.md §9. New `AnalyticsEmitter` methods, carrying only the envelope plus the fields
below. **No event carries personal data**, and nothing about the agent's document-number lookup
(FR-023) passes through the app (FR-017).

| Method | When | Fields |
|---|---|---|
| `escalationShown({required EscalationArrival arrival})` | The case is open and shown | `arrival` |
| `escalationChannelsOffered({required bool moduleAvailable, required bool chatAvailable})` | The first time channels are shown, and when either availability changes | both flags |
| `escalationChannelSelected({required AgentChannelKind channel})` | The passenger selects a channel | `channel` |
| `escalationHandoffStarted({required AgentChannelKind channel})` | The primary action is tapped | `channel` |
| `escalationOutcome({required EscalationOutcomeKind kind, required int elapsedSeconds})` | Once, when an outcome or expiry is shown | `kind`: `credentialIssued`, `declined`, `attemptsReset`, `expired`; `elapsedSeconds` from the screen opening (FR-018) |

## Deferred

The abandonment event.

## Tests

Each event fires once per trigger with only the listed fields; `FakeAnalyticsEmitter` and
`LoggingAnalyticsEmitter` implement all five.
