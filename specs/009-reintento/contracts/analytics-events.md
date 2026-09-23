# Contract: analytics events (09 Reintento)

Per research.md §8. New `AnalyticsEmitter` methods, carrying only the envelope
`LoggingAnalyticsEmitter` adds plus the fields below. **No event carries personal data, and no
event distinguishes attack detection from any other biometric failure** (FR-015, SC-003).

| Method | When | Fields |
|---|---|---|
| `retryGuidanceShown({required RetryGuidanceState state})` | The screen opens and its state is known | `state` |
| `retryGuidanceRetryTaken()` | "Intentar de nuevo" is tapped | none |
| `retryGuidanceAgentRouteTaken({required RetryGuidanceState state})` | "Hablar con un agente" is tapped | `state` |

The failure class FR-015 asks for is carried by `state`, which says whether the failure was the
selfie or the document and whether the limit was reached. The attempt number is not sent, since
it would contradict FR-008's decision not to expose the count anywhere, and 003 and 006 already
record attempt numbers in their own events.

## Deferred

The abandonment event, per the spec's deferral table.

## Tests

Unit tests assert each event fires once per trigger with only the listed fields;
`FakeAnalyticsEmitter` and `LoggingAnalyticsEmitter` implement all three.
