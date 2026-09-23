# Data Model: Trips Home (12 Mis viajes)

## Persisted (within the constitution's allowlist)

| Key (secure storage) | Content | Why it is allowed |
|---|---|---|
| `aeropass.credential.token`, `aeropass.credential.valid_until` | Existing (008) | Credential token and validity window |
| `aeropass.credential.holder_name` | New: the holder's name as issued | Display-only identity field already shown on confirmation (004) and activation (008) |
| `aeropass.credential.document_last4` | New: four digits | Display-only subset; the full number is never stored |

The two new keys are written with the token and cleared with it, including on consent withdrawal.
**No trip, itinerary or history is persisted** (CONFLICT-005).

## Domain

### `ExpiryReason` (change)

Adds `suspended`.

### `CredentialSummary` (new, freezed, `lib/domain/entities/credential_summary.dart`)

| Field | Type | Rule |
|---|---|---|
| `holderName` | `String?` | Null when never received; the strip then shows no name |
| `documentLast4` | `String?` | Four digits; rendered as "•••• 1234" |
| `state` | `CredentialDisplayState` | `active`, `expired`, `revoked` or `suspended` |
| `confirmed` | `bool` | True only when this read reached the backend |

`showsActive` is `state == active && confirmed`. It is the only path to "ACTIVA".

### `Airport` (new, `lib/domain/entities/trip.dart`)

It has a `code` (IATA, three letters) and a `city` (display name, which is also what is announced).

### `TripStatus` (new enum)

`onTime`, `delayed`, `cancelled`, `departed`, `unknown`.

### `Trip` (new, freezed)

| Field | Type | Rule |
|---|---|---|
| `id` | `String` | Opaque. It never reaches an event |
| `origin`, `destination` | `Airport` | Required |
| `flightNumber` | `String` | For example "AV 9201". Display only, never an event |
| `departureUtc` | `DateTime` | The instant |
| `departureOffset` | `Duration` | The departure airport's UTC offset on that date |
| `status` | `TripStatus` | Unknown values map to `unknown` |
| `live` | `bool` | False means the airline has no live integration (FR-006) |
| `gate`, `seat` | `String?` | Shown only when present and `live` |
| `connectsTo` | `Airport?` | Set when this segment continues on a connection |

`departureLocal` is `departureUtc + departureOffset`, and it is what is displayed.
`tripWindowOpensAt` is `departureUtc − 24 h`.

### `TripsSnapshot` (new, freezed)

It has `next` (`Trip?`), `history` (`List<Trip>`, newest first, domestic only, at most 90 days old)
and `fetchedAt` (`DateTime`).

## Ports

| Port | Method | Returns |
|---|---|---|
| `CredentialSummaryRepository` (new) | `getSummary()` | `Result<CredentialSummary>`. An error only when nothing at all is known |
| `TripRepository` (new) | `getTrips()` | `Result<TripsSnapshot>` |
| | `TripsSnapshot? get lastKnown` | The last good snapshot this app session, in memory |

## `TripsHomeViewModel` state

| Field | Source |
|---|---|
| `greeting` | `morning`, `afternoon` or `evening`, from the device hour |
| `firstName` | The first word of `holderName` |
| `credential` | `CredentialSummary?` |
| `trips` | `TripsSnapshot?`, the latest good snapshot |
| `tripsStale` | True when the last read failed and `trips` came from `lastKnown` |
| `tripsUnavailable` | True when there has been no good snapshot this session |
| `action` | `TripAction`: `start`, or `unavailable(reason)` with the reasons of research.md §7, in precedence order |
| `pendingNavigation` | `startTrip` or `welcome`; one shot |

### Transitions

- **Open, foreground, and every 60 s**: read the summary and the trips in parallel, then recompute
  `action`.
- **Summary is `NoCredential`**: navigate to welcome (consent withdrawn or credential gone).
- **Every 1 minute**: recompute `action`, so the trip window opens on time.
- **Iniciar viaje**: only when `action` is `start`. Emits `trip_started` and navigates.
- **Dispose**: cancel the timers and the lifecycle listener.
