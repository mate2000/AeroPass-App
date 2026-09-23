# Contract: analytics events (FR-016, FR-017)

These are new methods on `AnalyticsEmitter`. The payloads are enums, booleans and integers only.
No flight number, route, airport, date, seat or trip id appears (Principle VII, SC-010).

| Method | Event | Payload |
|---|---|---|
| `tripsHomeShown({hasNextTrip, credentialConfirmed})` | `trips_home_shown` | bool, bool |
| `tripDisplayed({status, live, withinWindow})` | `trip_displayed` | `TripStatus` name, bool, bool |
| `tripStarted({completedTripsLast90Days})` | `trip_started` | int |
| `tripsHistoryViewed({rowCount})` | `trips_history_viewed` | int; once per visit |
| `tripsEmptyShown()` | `trips_empty_shown` | none |

Repeat use (FR-017, constitution Principle VII) is the share of `trip_started` events with
`completedTripsLast90Days ≥ 1`. research.md §9 records that this approximates SC-001 rather than
measuring a cohort, and why.

A test asserts that every payload key and value fits these types, and that no value matches a flight
number, an IATA code or a date.
