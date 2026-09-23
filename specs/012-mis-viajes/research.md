# Research: Trips Home (12 Mis viajes)

Phase 0 of the plan. The spec's six clarifications leave no open product question. What follows
are the technical decisions, each checked against the code as it stands after 001–011.

## §1 — Where the credential strip's data comes from

**Finding**: today the app stores only the credential token and its validity. That is 008's
`CredentialService.writeCachedCredential`. The holder name and the last four digits reach the app
once, in 008's issuance response, and live only in the in-memory hand-off. After a relaunch there is
nothing to show in the strip.

**Decision**:

- **Online**: the credential status response (`GET /v1/credential/status`, 001) gains optional
  `holderName` and `documentLast4`, so the strip is backend-affirmed on every display.
- **Offline**: the app stores those same two fields in secure storage, next to the token, when 008
  issues the credential and each time a status read returns them. They are cleared with the token.

**Rationale**: the constitution's allowlist includes "a display-only subset of identity fields the
user already saw on the confirmation screen". The holder name and the masked number are exactly that
(004 showed them, and 008 showed them again). No amendment is needed. The full document number is
never stored or shown (FR-002).

**Alternatives considered**: keeping the fields in memory only. Rejected, because the strip would be
blank on every cold start before the first successful read, and blank offline, which breaks FR-013
for the one element the constitution does allow.

## §2 — A credential status the strip can name

**Finding**: `CredentialStatus` has `valid`, `expiredOrRevoked(expired | revoked)`, `noCredential`
and `unreachable(lastKnown)`. The mapping turns any unknown status, including `suspended`, into
`expired`, so a suspended credential would display as "VENCIDA".

**Decision**: add `ExpiryReason.suspended`, and map the wire value `suspended` to it. This is
additive. 001's welcome banner and launch rule treat every `expiredOrRevoked` alike, so they are
unaffected.

A new domain type, `CredentialSummary`, is what the strip reads:

- `holderName`, `documentLast4`;
- `state`: `active`, `expired`, `revoked` or `suspended`;
- `confirmed`: true only when this read reached the backend.

"ACTIVA" is rendered only for `state == active && confirmed` (FR-003). The last known state while
offline is shown as the state with a "sin confirmar" marker, never as "ACTIVA".

**Launch**: 001 sends `ExpiredOrRevoked` to welcome, which offers re-enrollment. That stays. The
strip's non-active states appear when a refresh during the visit returns one. Consent withdrawal
clears the credential, so the next status read is `NoCredential`, and the screen goes to welcome at
once (spec edge case).

## §3 — Development builds and the credential check

**Finding**: in development the credential repository calls `api.dev.aeropass.example`, which does
not exist. Every read is therefore `Unreachable(lastKnown: Valid)`. Under the clarified FR-009, the
strip would never be confirmed and "Iniciar viaje" would always be disabled, so the happy path could
not be walked.

**Decision**: add `DevCredentialRepository`, behind `USE_FAKE_VERIFICATION_BACKEND`. It plays the
backend: if a token is stored, it answers `valid` with the stored display fields; otherwise
`noCredential`. Its affirmation is the fake backend's, which Principle III allows in happy-path mode.
The badge still comes from the repository and never from a constant. The strip's widget test proves
that a non-confirmed read never shows "ACTIVA".

## §4 — The trip source

**Decision**: a new read-only port, `TripRepository.getTrips()`, returning `Result<TripsSnapshot>`
with `next`, `history` and `fetchedAt`. The backend aggregates the airline integration and matches
itineraries on the enrolled document (Clarifications). The request carries only the anonymous
enrollment attempt id, the same key 007 and 010 use.

The mapping is strict, and applied again in the app, not only trusted from the backend:

| Rule | Where |
|---|---|
| Only domestic segments (FR-010) | Backend filter, and the app drops any segment not marked `domestic: true` |
| History only from the last 90 days (FR-012) | Backend filter, and the app drops older rows |
| A segment missing a route, flight or departure is dropped, never guessed | App mapping |
| An unknown status reads as `unknown` and is shown as "Estado no disponible", never as on time | App mapping |
| Gate and seat are shown only if present; `live: false` means "Detalles no disponibles" (FR-006) | App mapping |

**The next trip** is the earliest undeparted segment. A segment that continues on a connection
carries `connectsTo` (an airport code) and says "Conexión a MDE".

## §5 — Times and "Hoy" without a time zone package

**Decision**: the backend sends `departureLocal` as ISO 8601 with its offset, for example
`2026-09-23T14:35:00-05:00`. The app keeps both the UTC instant and the offset: Dart's
`DateTime.parse` keeps the instant, and the offset is parsed from the suffix.

- The **date, time and "Hoy / Mañana"** are computed from UTC plus the offset, that is in the
  departure airport's clock (FR-014).
- When the device's current offset differs, the time is followed by "hora local de Bogotá".
- The **greeting** uses the device's current local hour: 5–11 "Buenos días", 12–18 "Buenas tardes",
  otherwise "Buenas noches".

**Rationale**: an offset per departure is enough for "which calendar day at the airport", and avoids
adding the `timezone` package and its data file (Principle X).

## §6 — Freshness, refresh and offline

**Decision**:

- `TripsHomeViewModel` reads the trips and the credential summary on open, on return to the
  foreground (through an `AppLifecycleListener`), and every **60 s** while visible (Clarifications,
  FR-005).
- A failed trip read keeps the last good snapshot, and marks it "Actualizado hace N min"
  (`fetchedAt`), never as current.
- The last good snapshot lives in the repository instance, in memory, so it survives tab switches
  and screen rebuilds within the app session. It is never written to disk (FR-013, CONFLICT-005).
- On a cold start offline there is no snapshot. The trip area then says it could not load the trips
  and offers "Reintentar". The strip still renders from §1's stored fields.

## §7 — When "Iniciar viaje" is enabled

**Decision**: the action is enabled only when **all** of these hold:

1. the credential summary is `active` and `confirmed` on this display (FR-009, Clarifications);
2. the trip is not `cancelled`;
3. `departure − 24 h ≤ now < departure` (FR-008).

Otherwise the button is replaced by a one-line reason, in this order of precedence:

- "Sin conexión: no pudimos confirmar tu identidad";
- the credential's state ("Tu identidad está suspendida");
- "Vuelo cancelado";
- "Disponible desde el {día} a las {hora}".

The reason is re-evaluated on every refresh and on a 1-minute tick, so it opens on its own. Starting
pushes a placeholder for 013. No pass is produced here.

## §8 — The tabs and the withdrawal entry

**Decision**: a `ShellRoute` with a bottom `NavigationBar` wraps three routes:

- **Viajes**: `/trips`, this screen.
- **Identidad**: `/credential`, the existing credential-detail placeholder from 008.
- **Perfil**: `/profile`, a new placeholder whose one entry is "Retirar consentimiento". It opens
  `/account/withdrawal`, which is two taps from this screen (FR-019, constitution Principle I).

001's redirect still matches `/trips` by path, so launch behavior is unchanged.

## §9 — Events, and measuring repeat use

**Finding**: the constitution requires "repeat use across flights" to be derivable from events alone.
001 made the analytics session id per-launch and never persisted, to keep within the persisted-state
allowlist. An event stream keyed to per-launch ids cannot link one passenger's trips across flights.

**Decision**: `trip_started` carries `completedTripsLast90Days`, an integer count from the history
already on screen. Repeat use is then derivable from events alone, as the share of trip starts with
at least one earlier completed trip. No payload carries a flight number, route, date or seat
(FR-016, SC-010).

**Limitation, recorded for the user**: this measures "trip starts by passengers who travelled
before". It is not a per-passenger cohort, so SC-001's "≥70% return on their next flight" can only be
approximated. A true cohort needs a stable anonymous identifier, and persisting one needs a
constitution amendment. That is flagged, not assumed.

The events are:

| Event | Payload |
|---|---|
| `trips_home_shown` | `hasNextTrip`, `credentialConfirmed` |
| `trip_displayed` | `status`, `live`, `withinWindow` |
| `trip_started` | `completedTripsLast90Days` |
| `trips_history_viewed` | `rowCount`, once per visit, when the section first scrolls into view |
| `trips_empty_shown` | — |

## §10 — Accessibility

**Decision**: the route is read as one Semantics label, for example "De Bogotá a Medellín, vuelo
AV 9201, hoy a las 14:35, puerta D12, asiento 22A". The codes are not spelled out. The disabled
action's reason is its semantics label. The freshness marker is plain text inside the card. History
rows are plain text, with no button role (FR-020).

## §11 — Notes from implementation

- **Unconfirmed badge.** An active credential that the backend did not confirm on this read shows
  "SIN CONFIRMAR", not "ACTIVA · sin confirmar". The word "ACTIVA" appears only when the credential
  is affirmed. Other states keep their name with "· sin confirmar" appended.
- **Departed reason.** A trip whose departure has passed, but which a refresh has not yet moved to
  history, states "Este vuelo ya salió" instead of offering the action.
- **Airline status wins.** A segment the airline reports as `departed` goes to history even if its
  scheduled time is still ahead.
- **Old placeholder test removed.** `trips_placeholder_view_test.dart` from 008 was deleted with
  the placeholder. Its own header said it applied only "until the trips surface (012) exists". The
  empty-state widget tests replace it.
- **Development wiring.** In development, 001's launch check and the summary both use dev
  repositories that read the stored token, behind `USE_FAKE_VERIFICATION_BACKEND` (§3).

