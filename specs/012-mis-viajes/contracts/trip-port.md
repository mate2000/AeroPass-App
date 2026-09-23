# Contract: Trip port

`TripRepository` in `lib/domain/repositories/trip_repository.dart` (FR-004–FR-013; research.md §4–§6).

## Wire format

`GET /v1/trips?enrollmentAttemptId=<id>` over the pinned `dio` client. The request carries no
personal data.

```json
{
  "segments": [
    {
      "id": "seg-1",
      "origin": { "code": "BOG", "city": "Bogotá" },
      "destination": { "code": "MDE", "city": "Medellín" },
      "flightNumber": "AV 9201",
      "departureLocal": "2026-09-23T14:35:00-05:00",
      "status": "on_time",
      "live": true,
      "gate": "D12",
      "seat": "22A",
      "connectsTo": null,
      "domestic": true
    }
  ]
}
```

## Mapping rules (the real implementation)

| Input | Result |
|---|---|
| `domestic` not `true` | Segment dropped (FR-010) |
| A missing or blank `origin`, `destination`, `flightNumber` or `departureLocal`, or a departure without an offset | Segment dropped |
| `status` `on_time`, `delayed`, `cancelled` or `departed` | Mapped; anything else is `unknown` |
| `live` missing | `false` |
| `gate` or `seat` present while `live` is false | Kept in the entity, but the card shows "Detalles no disponibles" |
| An undeparted segment whose status is not `departed` | A candidate for `next`; the earliest one wins |
| A departed segment within the last 90 days of `now` | Goes to `history`, newest first |
| A departed segment older than 90 days | Dropped (FR-012) |
| A transport failure | `Result.error(TransportFailure…)`, and `lastKnown` is unchanged |
| No consent record | `Result.error`, and no request is sent |

A successful read sets `lastKnown` to the new snapshot, with `fetchedAt` taken from the injected
`Clock`.

## Implementations

| Implementation | Behavior |
|---|---|
| `TripRepositoryImpl` | The mapping above; keeps `lastKnown` in memory only |
| `DevTripRepository` | A fixed domestic next trip, BOG → MDE, "AV 9201", departing 3 h after the first read in -05:00, gate "D12", seat "22A", `live: true`; plus three history rows 20, 36 and 49 days back (BOG→MDE, MDE→CTG, BOG→CLO) |
| `FakeTripRepository` (tests) | Scripted results, and a settable `lastKnown` |

## Contract tests (the real implementation against `FakeHttpClientAdapter`)

1. A valid body maps next, history and every field. The offset is kept, and `departureLocal` equals
   14:35.
2. An international segment is dropped, in next and in history.
3. A segment missing any required field is dropped. The others still map.
4. An unknown status maps to `unknown`, and a missing `live` maps to `false`.
5. The earliest undeparted segment is `next`. Departed segments go to history, newest first.
6. A departed segment 91 days old is dropped; one 89 days old is kept.
7. A transport failure gives an error, with `lastKnown` still the previous snapshot. No consent gives
   an error with zero requests sent.
8. The request carries the attempt id as a query parameter and has no body.
