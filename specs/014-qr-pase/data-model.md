# Data Model: Dynamic QR Pass (14 QR Pase)

## Persisted

| Phase | What | Where | Allowed by |
|---|---|---|---|
| A | Nothing new | — | — |
| B | `PassSecret`: passId, secret, validUntil, issuedAtServer, serverOffset | Secure storage, one entry | **Only after ratifying** contracts/constitution-amendment-proposal.md |

## Domain (`lib/domain/entities/pass.dart`)

### `Checkpoint` (enum)

`security` ("Seguridad"), then `boarding` ("Embarque"). There is no "Sala" (Clarifications).

### `Pass` (freezed)

| Field | Type | Rule |
|---|---|---|
| `passId` | `String` | Opaque. Never logged or sent in an event |
| `tripId` | `String` | The 012 trip it belongs to |
| `nextCheckpoint` | `Checkpoint` | Which reader the current code is for (FR-008) |
| `validated` | `Set<Checkpoint>` | Only from the backend status (FR-009) |
| `validUntil` | `DateTime` | Server-defined: at most scheduled departure and 24 h from issuance |
| `rotation` | `Duration` | 30 s |

### `PassCode` (freezed)

`payload` (String, rendered only, never logged), `windowStartsAt` and `windowEndsAt`.

### `PassState` (sealed; the backend's word)

The states are `active(pass)`, `expired`, `revoked`, `boarded` and `flightChanged(status)`.

### `ClockTrust` (sealed)

The states are `trusted(offset)` and `untrusted(reason: drift | jump | beforeIssuance)`.

### `PassUnavailableReason` (enum)

`expired`, `revoked`, `consentWithdrawn`, `flightCancelled`, `flightChanged`, `untrustedClock`,
`compromisedDevice`, `issuanceFailed`, `offlineWithoutPass`.

## Ports

| Port | Methods |
|---|---|
| `PassRepository` | `issue(tripId)` → `Result<Pass>`; `status(passId)` → `Result<PassState>` (with `serverTime`); `activePassFor(tripId)` → `Pass?`; `requestNewPass(tripId)`; `forget(passId)` (deletes the secret in phase B) |
| `PassCodeSource` | `codeAt(Pass, DateTime instant)` → `Result<PassCode>` |
| `PassDisplayGuard` | `enterPassMode()`, `exitPassMode()` |
| `DevicePostureChecker` | `check()` → `DevicePosture` (`trusted` or `compromised(signals)`) |
| `ClockTrustMonitor` (app layer) | `observeServerTime(DateTime)`, `current` → `ClockTrust`, `serverNow()` |

## `PassViewModel` state (sealed `PassViewState`)

| State | Shown |
|---|---|
| `loading` | Spinner. Pass mode is not yet on |
| `showing(pass, code, secondsLeft)` | QR, countdown, the stepper, "Presenta este código en el lector de {checkpoint}", and the checkpoint line |
| `boarded` | "Abordaje confirmado · Buen viaje", with no code |
| `unavailable(reason)` | No code. The reason, "Solicitar nuevo código" where it can help, the checkpoint line, and "Ayuda" |

### Transitions

- **Open**: check device posture. A compromised device goes to `unavailable(compromisedDevice)`,
  with escalation offered. Otherwise take `activePassFor(tripId)` or `issue(tripId)`, then show the
  code.
- **Every second**: recompute `secondsLeft` from the clock. At a window boundary, take
  `codeAt(pass, now)` (rotation) and emit `pass_rotated`.
- **Every 5 s online**: read `status`. On `validated` changes, advance the stepper and emit
  `pass_validated`. `boarded` leads to the boarded state and `forget`. `expired`, `revoked` and
  `flightChanged` lead to `unavailable`.
- **Clock untrusted** leads to `unavailable(untrustedClock)` until trusted again.
- **Past validUntil** leads to `unavailable(expired)`, even offline.
- **Pause** exits pass mode. **Resume** re-enters it, recomputes, and never shows the code from
  before the pause (FR-020).
