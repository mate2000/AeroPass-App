# Data Model: Credential Activated (08 Identidad activa)

All new domain types are `freezed` sealed classes or plain enums (Constitution Principle IX). None
of them is serialized to disk. The only persisted values are the two existing credential keys
(research.md §3).

## Domain entities (new)

### `CredentialLifecycleStatus` (enum)

`active`, `expired`, `revoked`, `suspended`, `withdrawn`.

The backend's status for an issued credential. Mapped from the wire value at the data boundary;
an unrecognized wire value never becomes one of these — it becomes `IssuanceOutcome.incomplete()`
(research.md §2).

### `ActivatedCredential`

The display subset of a credential the backend has just issued as active. Constructed only by the
issuance repository, and only when every rule below holds; no other code creates one.

| Field | Type | Rule |
|---|---|---|
| `holderName` | `String` | Non-empty after trimming. Displayed in full to assistive technology, at most two lines visually. |
| `documentLast4` | `String` | Exactly four ASCII digits. The full document number is never part of this type. |
| `issuingCountry` | `String` | ISO 3166-1 alpha-3, upper case, e.g. `COL`. |
| `issuedAt` | `DateTime` (UTC) | Present. Displayed as "Creada el …". |
| `validUntil` | `DateTime` (UTC) | Present and strictly after `issuedAt`. Displayed as "Válida hasta …". |

There is deliberately no `status` field: an `ActivatedCredential` is active by construction, which
is what makes FR-010 structural. There is deliberately no `token` field: the token goes to secure
storage and never reaches the display layer (FR-013).

### `IssuanceOutcome` (sealed)

| Variant | Payload | Leads to |
|---|---|---|
| `activated` | `ActivatedCredential credential` | Hand-off set, session cleared, `go` to screen 08 |
| `notActive` | `CredentialLifecycleStatus status` (never `active`) | `go` to the not-active placeholder |
| `incomplete` | none | `go` to the not-active placeholder |

Returned inside `Result<IssuanceOutcome>`. `Result.error` means a transport or storage failure;
the verification-progress placeholder shows a retry.

### `OnwardRoute` (enum)

`trips`, `credentialDetail`, `backGestureToTrips`. Used only as an analytics payload
(contracts/analytics-events.md).

## App-layer state (new)

### `ActivatedCredentialHandoff` (`lib/app/`)

App-process-scoped `ChangeNotifier`, mirroring `PendingDocumentController` (research.md §4).

| Member | Meaning |
|---|---|
| `ActivatedCredential? current` | The credential waiting to be shown, or `null`. |
| `bool get hasCredential` | `current != null`. Read by the router guard. |
| `void set(ActivatedCredential)` | Called once by `VerificationProgressViewModel` on `activated`. |
| `ActivatedCredential? consume()` | Returns `current` and clears it. Called once by screen 08's ViewModel. |
| `void clear()` | Called on consent withdrawal and by the guard when consent is not active. |

Never persisted, never logged. Empty after any process restart, which is what makes screen 08
one-time without persisted state.

## View state (new)

### `CredentialActivatedViewModel`

Holds the consumed `ActivatedCredential` for the screen's lifetime and exposes:

- the pre-formatted display strings (masked document line, its accessible label, both dates);
- `goToTrips`, `openCredentialDetail`, and `onBackGesture` actions, each emitting its
  `OnwardRoute` event exactly once before navigating.

There is no loading, error or empty state: the route cannot build without a credential (research.md
§5), so the only rendered state is the settled one.

### `VerificationProgressViewState` (sealed, for the changed placeholder)

`requesting` → then either a navigation (on any `Ok`) or `failed` (on `Result.error`, with a retry
`Command`).

## Data layer (new)

### `CredentialIssuanceResponse` (DTO, `json_serializable`, inbound only)

| Wire field | Maps to |
|---|---|
| `status` | `CredentialLifecycleStatus`, or `incomplete` if missing or unknown |
| `token` | Secure storage only |
| `holderName` | `ActivatedCredential.holderName` |
| `documentLast4` | `ActivatedCredential.documentLast4` |
| `issuingCountry` | `ActivatedCredential.issuingCountry` |
| `issuedAt` | `ActivatedCredential.issuedAt` (ISO-8601) |
| `validUntil` | `ActivatedCredential.validUntil` (ISO-8601), and secure storage |

All fields are nullable in the DTO, so a missing field is detected by the mapping rules rather
than thrown by the parser. The DTO never leaves `lib/data/`.

## Persisted state

| Key | Written by | Read by | Cleared by |
|---|---|---|---|
| `aeropass.credential.token` | Issuance repository, on `activated` (new) | `CredentialService` (001) | Consent withdrawal (changed, research.md §6) |
| `aeropass.credential.valid_until` | Same | Same | Same |

Both keys already exist in 001's `CredentialService`; this feature adds the writer and the
deletion. No new key is introduced, so Principle I's allowlist is unchanged.

## State transitions

```text
liveness success (006)
  → verification-progress placeholder: requesting
      ├─ Ok(activated)   → write token + validUntil → hand-off.set → session.clear → go(screen 08)
      ├─ Ok(notActive)   → go(not-active placeholder)
      ├─ Ok(incomplete)  → go(not-active placeholder)
      └─ Error           → failed → retry → requesting

screen 08 (hand-off consumed on creation)
  ├─ "Ir a mis viajes"   → event(trips)              → go(trips)
  ├─ "Ver mi identidad"  → event(credentialDetail)   → go(credential detail placeholder)
  └─ system back         → event(backGestureToTrips) → go(trips)
```
