# Data Model: Escalation to a Human Agent (10 Escalar agente)

All types are `freezed` sealed classes or enums (Principle IX). **Nothing new is persisted on the
device.** The escalation case lives on the backend, keyed by the existing `EnrollmentAttemptId`;
chat messages live in memory for the chat screen's lifetime.

## Domain entities (new)

### `EscalationArrival` (enum)

`byChoice`, `afterLimit`. Derived from the attempt counters (research.md §2).

### `AgentChannelKind` (enum)

`module`, `chat`.

### `WaitEstimate`

| Field | Type | Rule |
|---|---|---|
| `minMinutes` | `int` | ≥ 0 |
| `maxMinutes` | `int` | ≥ `minMinutes` |

Present only when the channel's source supplies it (FR-006).

### `AgentChannel`

| Field | Type | Rule |
|---|---|---|
| `kind` | `AgentChannelKind` | |
| `available` | `bool` | From the channel's state, never copy (FR-004) |
| `nextOpensAt` | `DateTime?` | Required when `available` is false (FR-005) |
| `estimatedWait` | `WaitEstimate?` | Chat only; absent when not supplied |
| `hours` | `String` | Operational data, e.g. "Lun–Vie 6:00am–10:00pm · Sáb–Dom 7:00am–9:00pm" |
| `locationName` | `String?` | Module only, required for it: the airport |
| `locationDetail` | `String?` | Module only, required for it: where the module is inside the airport |

### `EscalationCase`

| Field | Type | Rule |
|---|---|---|
| `openedAt` | `DateTime` | Backend clock; the 24-hour window runs from here |
| `arrival` | `EscalationArrival` | As sent on opening |

No identifier is exposed to the app beyond what the backend needs; the attempt id is sent by the
data layer, as in 007 and 008.

### `EscalationOutcome` (sealed)

| Variant | Payload | Meaning |
|---|---|---|
| `credentialIssued` | none | The module agent approved; the backend issued a credential under a manual-review decision. **Carries no credential** (research.md §1) |
| `declined` | none | The module agent declined to verify |
| `attemptsReset` | `AttemptCounterScope scope` | The module agent reset an exhausted limit |

### `EscalationStatus` (sealed)

| Variant | Payload |
|---|---|
| `open` | `EscalationCase escalation`, `List<AgentChannel> channels` |
| `resolved` | `EscalationOutcome outcome` |
| `expired` | none |

## View state (new)

### `EscalationViewState` (sealed)

| Variant | Rendered as |
|---|---|
| `loading` | Neutral spinner while the case is opened or resumed |
| `open` | Title, body by arrival, channel cards, primary action by selection, checkpoint line, "Volver al inicio" |
| `declined` | The decline message with the checkpoint alternative and "Volver al inicio" (FR-013) |
| `expired` | Explains the 24 hours passed, "Abrir nueva solicitud", checkpoint line |
| `unavailable` | The case could not be opened or read: the checkpoint line and a retry |

### `EscalationViewModel`

Holds the derived arrival, the current state, and `selectedChannel`. Exposes `select(kind)`,
`onPrimaryAction()`, `onHome()`, `reopen()`, a one-shot navigation target
(`credentialActivated`, `documentCapture`, `livenessCapture`, `chat`, `home`), and polls
`getStatus()` every `escalationPollInterval`.

## Data layer (new)

### `EscalationStatusResponse` (DTO, inbound only)

`state` (`open`, `resolved`, `expired`), `openedAt`, `arrival`, `channels[]` (each with `kind`,
`available`, `nextOpensAt`, `waitMinMinutes`, `waitMaxMinutes`, `hours`, `locationName`,
`locationDetail`), and `outcome` (`credential_issued`, `declined`, `attempts_reset`) with
`resetScope` (`document`, `selfie`). All fields nullable; unknown values map to the safest reading:
an unknown `state` or outcome is treated as a failed read, a channel
missing `available` as unavailable.

## State transitions

```text
open screen → openOrResume(arrival) → loading → open
  every 5 s: getStatus()
    open(case, channels) → refresh availability; keep the selection valid
    resolved(credentialIssued) → requestIssuance()
        Ok(activated) → hand-off, session cleared → credentialActivated
        otherwise     → keep checking
    resolved(declined) → declined
    resolved(attemptsReset(scope)) → reset local counter → documentCapture | livenessCapture
    expired → expired → "Abrir nueva solicitud" → openOrResume → open
launch, consent active, no credential: getStatus()
    open → this screen · resolved → its outcome · expired or failed read → unchanged 001 rule
```
