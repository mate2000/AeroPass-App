# Data Model: Verification Retry (09 Reintento)

Nothing new is persisted. The screen reads the two existing attempt counters (003's
`documentCapture` and 006's `selfieLiveness` scopes of `CaptureAttemptCounterRepository`), already
on the constitution's persisted-state allowlist.

## View state (new)

### `RetryGuidanceState` (enum)

| Value | When (research.md §1) | Retry offered | Advice |
|---|---|---|---|
| `selfieRetry` | Neither counter at the limit | Yes | Selfie tips |
| `selfieLimit` | `selfieLiveness` at the limit, `documentCapture` below | No | None |
| `documentLimit` | `documentCapture` at the limit | No | None |

`documentLimit` wins when both counters are at the limit. A counter read that fails yields
`selfieLimit`, which offers no retry and keeps the agent route.

Also the analytics payload for this screen's events.

### `RetryGuidanceViewModel`

| Member | Meaning |
|---|---|
| `RetryGuidanceState? state` | `null` while the counters are being read; then fixed for the screen's lifetime |
| `bool get canRetry` | `state == selfieRetry` |
| `void onRetry()` | Emits `retryGuidanceRetryTaken`; the view then goes to the selfie camera |
| `void onAgentRoute()` | Emits `retryGuidanceAgentRouteTaken` |

No `material.dart` import; the view owns navigation, as on every other screen.

## Retry policy (changed across 003, 006, 007)

```text
failure attributable to the passenger → increment that step's counter (unchanged)
service or technical failure          → no increment (unchanged)
passing a capture step (003, 006)     → no reset            (was: reset)
reaching the limit                    → no reset            (was: reset)
verification match (007, `matched`)   → reset BOTH counters (was: selfie only, on `activated`)
agent reset                           → deferred to 010
entering 003 or 006 at the limit      → route to retry guidance, camera never opens (new)
```

## State transitions

```text
007 R7–R9, below limit ──► retry guidance: selfieRetry
                              ├─ "Intentar de nuevo" ──► go(livenessCapture)
                              ├─ "Hablar con un agente" ──► push(agentEscalation)
                              └─ "Ayuda" ──► push(help)

003 / 006 / 007 at limit ──► retry guidance: documentLimit | selfieLimit
                              ├─ "Hablar con un agente" ──► push(agentEscalation)
                              └─ "Ayuda" ──► push(help)

003 or 006 entered at limit ──► retry guidance (limit state), camera not opened
```
