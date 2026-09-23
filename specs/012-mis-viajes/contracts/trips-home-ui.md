# Contract: Trips home behavior

This contract covers `TripsHomeViewModel`, `TripsHomeView` and the shell (FR-001, FR-003–FR-020;
research.md §5–§10).

## Trip action (research.md §7)

| Credential | Trip | Now | Result |
|---|---|---|---|
| active and confirmed | on time, delayed, unknown | from departure − 24 h to departure | **Iniciar viaje** |
| active and confirmed | any not cancelled | before departure − 24 h | "Disponible desde el {día} a las {hora}" |
| active and confirmed | cancelled | any | "Vuelo cancelado" |
| not confirmed | any | any | "Sin conexión: no pudimos confirmar tu identidad" |
| expired, revoked or suspended (confirmed) | any | any | "Tu identidad está vencida / revocada / suspendida" |
| — | no next trip | — | Empty state, no action |

The disabled reasons take precedence from the top of the table down. "Iniciar viaje" pushes
`AppRoutes.tripVerification`, the 013 placeholder, and emits `trip_started`.

## Card content

- The route is shown as codes and cities, with the flight number, and "Hoy · 14:35", "Mañana · 00:30"
  or "23 sep · 14:35", all in departure-local time. "(hora local de Bogotá)" is added when the
  device's offset differs.
- The detail row shows "Puerta D12 · Asiento 22A" when `live` and present. It shows "Detalles no
  disponibles" when not `live`, and omits the part that is absent.
- Status: "Retrasado" and "Vuelo cancelado" are shown as a chip. "Estado no disponible" is shown for
  `unknown`.
- A connecting segment shows "Conexión a {city}".
- Freshness is shown as "Actualizado hace N min" only when stale.

## Strip

It shows initials in a neutral circle, the full holder name, "•••• 1234", and a badge. "ACTIVA"
appears only when `showsActive`. An unconfirmed active credential reads "SIN CONFIRMAR". The other
badges are "VENCIDA", "REVOCADA" and "SUSPENDIDA", each with "· sin confirmar" appended when
`confirmed` is false. No image is shown (FR-018).

## Empty state

"Aún no tienes viajes" is followed by "Cuando reserves un vuelo nacional con el mismo documento con
el que te registraste, tu aerolínea lo agregará aquí. No tienes que hacer nada." With no history,
the history section is absent. With history, it reads "Mostramos tus viajes de los últimos 90 días."

## Test-first cases

**ViewModel**:

- every row of the action table;
- the 60 s refresh, the foreground refresh and the 1-minute tick;
- a stale snapshot is kept and marked;
- `NoCredential` goes to welcome;
- "Hoy" and "Mañana" around midnight in -05:00 with a device in UTC;
- the greeting boundaries;
- the event payloads carry no flight, route, date or seat.

**Widget**:

- "ACTIVA" is never rendered for an unconfirmed summary;
- a masked number only;
- no `Image` widget in the tree;
- history rows have no arrow and no tap handler;
- route semantics read city names;
- goldens for the next trip, empty, offline and stale, and text at 200%.

**Router**:

- a valid credential lands on `/trips` inside the shell;
- Perfil then "Retirar consentimiento" reaches withdrawal in two taps.
