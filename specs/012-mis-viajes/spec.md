# Feature Specification: Trips Home (12 Mis viajes)

**Feature Branch**: `012-mis-viajes`

**Created**: 2026-09-23

**Status**: Draft

**Input**: User description: "Screen 12 Mis viajes — the home surface for an enrolled passenger. Shows
the credential in compact form, the next trip with its flight details and a way to start it, and
recent trips. Includes an empty variant."

**Note on sequence**: this screen replaces the trips placeholder that 001's launch rule and 008's
"Ver mis viajes" already route to. The placeholder's empty-state copy ("Aún no tienes viajes") is
the starting point for User Story 3. The trip action leads to the automatic re-verification step
(013), which is not yet specified; until it is, the action ends at a placeholder for 013.

## Delivery Mode: Happy Path First

Same section as specifications 005 through 011; it governs build order here too (constitution
Principle III, "Happy-Path Development Mode").

The current priority is a working end-to-end flow. Development runs in happy-path mode: the flow
must be walkable from welcome to pass without the edge-case handling, gating, and hardening
described below. Nothing here removes a requirement — each relaxation defers one, by identifier.

**Relaxable during happy-path mode**, each recorded as a deferred requirement:

- Live flight data; a fixed trip may stand in while the airline integration does not exist.
- Staleness marking and refresh behavior.
- The trip-start availability window of FR-008.
- Offline rendering from local state.
- Analytics completeness — events that exist must already carry no personal data.
- Backend integrations, served by fakes implementing the real contract.

**Deferred requirements, by identifier** (the constitution requires this list; a deferral not
written here is not a deferral):

| Requirement | What is deferred | What still holds in happy-path mode |
|---|---|---|
| FR-005, FR-007, SC-002, SC-003 | Live flight data and change propagation | The fixed trip comes from the fake trip source, never from copy in the screen. Gate and time are shown only because that source supplied them |
| FR-005, SC-004 | Staleness marking and foreground refresh | Nothing is labelled "current" that was not just read |
| FR-008 | The trip-start window | The action still leads only to 013, never to a pass |
| FR-013, SC-009 | Offline rendering | — |
| FR-016, FR-017 | The complete event set and recurrence measurement | Any event that is emitted carries no personal data and no flight number |
| Backend integrations | A real trip source | The fake implements the same contract the real source will |

**Specific to this screen**: a hard-coded trip is acceptable in development. **What may not be
stubbed is the direction of the credential badge and the trip's gate and time** — they are
displayed because a source said so, never because the screen was built that way. A development
build that renders "ACTIVA" as a constant is one edit away from a release that does.

**Not relaxable, in any mode**:

- No real personal data; synthetic identities and synthetic itineraries only.
- No personal data in logs, events, or crash reports — including flight numbers tied to a passenger,
  which are travel patterns.
- **No credential presented as active without backend affirmation** (FR-003).
- **No trip started, and no pass produced, on local state alone** (FR-009).
- Every relaxation lives behind a build flag that cannot be enabled in a release build.

**Exit from happy-path mode**: every deferred requirement is implemented or explicitly accepted as
out of scope, in writing, before any build reaches a real passenger.

## UI Reference

The authoritative visual reference is [`assets/12-mis-viajes.png`](./assets/12-mis-viajes.png),
copied from `C:\Users\Usuario\Pictures\Screenshots\Captura de pantalla 2026-09-23 142543.png`. It is
the source of truth for layout, content order, and styling, except where the conflicts below
override it.

| Element | Content in the reference |
|---|---|
| Greeting | "Buenos días," / "Mateo", with an avatar |
| Credential strip | Portrait, "Mateo González", "•••• 4821", badge "ACTIVA" |
| Section heading | "PRÓXIMO VIAJE" |
| Trip card | "BOG → GRU", flight "AV 8841", "Bogotá" / "São Paulo", "Hoy · 14:35" |
| Trip detail row | "Puerta D12 · Fila 22A" |
| Trip action | "Iniciar viaje" |
| Section heading | "VIAJES RECIENTES" |
| History rows | "BOG → MDE · AV 9201 · 2 sep 2026"; "MDE → CTG · LA 4552 · 18 ago 2026"; "BOG → CLO · AV 8811 · 5 ago 2026" (each with an arrow, which is dropped: rows are not tappable, per Clarifications) |
| Tab bar | Viajes (active), Identidad, Perfil |

Behaviors the reference establishes: the credential is always visible in compact form, exactly one
trip is promoted as next with a single action, history is browsable, and the app has three
top-level destinations.

### Conflicts raised by the reference

- **CONFLICT-001 — the promoted trip is international.** BOG → GRU is Bogotá to São Paulo. The
  product scopes its entry niche to domestic flights without immigration control, and places the full
  migratory process out of scope. A passenger on that route passes immigration, which AeroPass does
  not carry them through, so promoting it as the flagship next trip misrepresents what the credential
  does. The history rows below it are all domestic and consistent with scope. **Resolved**
  (Clarifications): only domestic trips are shown, as the next trip or in history. The reference's
  example is replaced by a domestic trip, for instance BOG → MDE (FR-010).
- **CONFLICT-002 — how a trip becomes associated is unspecified.** Ticket purchase is out of scope,
  so the passenger never tells the app about a flight. Something must link an itinerary to a
  credential. **Resolved** (Clarifications): the airline pushes itineraries, matched on the
  document number the passenger enrolled with. The passenger adds nothing, and the empty state says
  so (FR-011).
- **CONFLICT-003 — "Fila 22A" is a seat, which the product does not own.** Seat and gate come from
  the airline. Displaying them makes AeroPass accountable for their accuracy in the passenger's
  eyes, which is why FR-005 requires staleness to be visible and FR-006 requires absent detail to be
  stated. **Resolved in the requirements**: gate and seat are shown only from the airline source,
  with their freshness.
- **CONFLICT-004 — the strip shows a portrait.** Found while writing this spec. A face on the home
  screen would have to come from somewhere, and enrollment captures are discarded by design
  (constitution Principle I). **Resolved in the requirements**: the strip and the greeting never show
  a facial image. They use a neutral avatar or the holder's initials (FR-018). The reference's
  portraits are generic silhouettes, so the layout is unchanged.
- **CONFLICT-005 — offline rendering needs stored trips, and the constitution does not allow them.**
  Found while writing this spec. FR-013 asks the screen to render from last known local state when
  offline. The constitution limits what the app may persist to the credential token and its
  validity, the display-only identity fields the passenger already saw, the consent record, and the
  attempt counters. Itineraries and travel history are not on that list. **Resolved in the
  requirements, pending an amendment**: offline, the screen renders the credential strip from the
  allowed stored fields, and the trips from what was read earlier in the same app session. It does
  not store itineraries on the device (FR-013). Storing them would take a constitution amendment, not
  a code change.
- **CONFLICT-006 — the tab bar has nowhere to withdraw consent.** Found while writing this spec. The
  constitution requires consent withdrawal to be reachable from the account surface in no more than
  two taps. Today it has a route but no entry point. **Resolved in the requirements**: the Perfil tab
  carries the withdrawal entry, so it is two taps from this screen (FR-019). The rest of Perfil and
  Identidad stay out of scope.

## Clarifications

### Session 2026-09-23

- Q: Are international itineraries shown at all? → A: No. Only domestic flights are shown, as the
  next trip or in history.
- Q: How does a trip become associated with the credential? → A: The airline pushes itineraries,
  matched on the document number the passenger enrolled with.
- Q: How long is travel history kept, and can the passenger delete it? → A: 90 days, with no delete;
  the screen states the limit.
- Q: How often should the screen re-check the flight while it is open, and how quickly must a gate
  or time change appear? → A: Every 60 seconds while the screen is open, plus immediately on return
  to the app; a change is shown within 60 seconds.
- Q: If the app could not confirm the credential with the backend just now, can the passenger still
  tap "Iniciar viaje"? → A: No. The button is disabled with the reason "Sin conexión: no pudimos
  confirmar tu identidad", and it re-enables on its own once the credential is confirmed again.
- Q: What happens when the passenger taps a row in "Viajes recientes"? → A: Nothing. Rows are not
  tappable and carry no arrow; "history opened" means the history section scrolled into view.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - An enrolled passenger opens the app and starts their trip (Priority: P1)

A passenger at the airport opens AeroPass. Without navigating anywhere, they see their credential is
active, the flight they are about to take, its gate and time, and one action to begin. They tap it
and proceed toward their pass. This is the screen they will see more than any other in the product.

**Why this priority**: this is the returning passenger's entire experience of AeroPass, and the
product's recurrence objective is measured on whether they come back to it. Every second here is a
second in a queue.

**Independent Test**: with an active credential and an upcoming trip, launch the app. Verify the
credential state, the trip and the action are all present without navigation, and that the action
leads toward the pass.

**Acceptance Scenarios**:

1. **Given** an enrolled passenger with an upcoming trip, **When** the app launches, **Then** this
   screen is the destination, showing the credential state and the next trip without further
   navigation.
2. **Given** the trip is displayed, **When** the passenger reads it, **Then** the route, flight, date
   and time, and the operational details available are shown.
3. **Given** the trip is within the window in which a pass may be issued, **When** the passenger
   starts the trip, **Then** the flow proceeds toward the pass.
4. **Given** the trip is outside that window, **When** the passenger looks at the card, **Then** the
   action states when it will become available rather than failing after it is tapped.
5. **Given** the screen is displayed, **When** the credential strip is read, **Then** it shows the
   credential's real current state, and the document number appears only in masked form.

---

### User Story 2 - Flight details shown are current, or visibly are not (Priority: P1)

Gates change. A passenger who walks to D12 because AeroPass said so, when the airline moved them to
B7 forty minutes ago, has been sent to the wrong end of a terminal by the product that promised to
make their journey smoother.

**Why this priority**: it shares P1 because the product commits to propagating flight changes within
seconds and to the pass carrying the correct gate and time, and because being confidently wrong
about a gate is more damaging than showing nothing. This screen is where the passenger forms the
habit of trusting these numbers.

**Independent Test**: change the gate and time at the source and verify the screen reflects them
within the committed propagation time. Then block the refresh and verify the screen marks the data
as not refreshed rather than presenting it as current.

**Acceptance Scenarios**:

1. **Given** displayed flight details, **When** the source changes them, **Then** the screen reflects
   the change within 60 seconds while the screen is visible.
2. **Given** the app returns to the foreground, **When** this screen is shown, **Then** the trip
   data is refreshed before it is presented as current.
3. **Given** the refresh fails, **When** the screen is shown, **Then** the data is visibly marked as
   not current, with when it was last updated.
4. **Given** a flight for which no live integration exists, **When** the trip is displayed, **Then**
   the absence of live detail is stated rather than filled with a stale or assumed value.
5. **Given** a cancelled or significantly changed flight, **When** the screen is shown, **Then** that
   status is surfaced on the trip card rather than left to the passenger to discover elsewhere.

---

### User Story 3 - A passenger with no trip understands what to do (Priority: P2)

Someone enrolls at home, days before flying, or has no upcoming flight at all. They open the app to a
screen whose main content is a trip they do not have. The empty state must explain how a trip
appears rather than looking like a failure.

**Why this priority**: it directly serves the recurrence objective — a passenger who enrolls and then
sees nothing has been given no reason to return — and it is the state most newly enrolled passengers
will meet first. It ranks below the two above because it affects follow-through rather than
correctness.

**Independent Test**: with an active credential and no trips, verify the screen explains how a trip
becomes associated and keeps the credential visible.

**Acceptance Scenarios**:

1. **Given** an enrolled passenger with no upcoming trip, **When** this screen opens, **Then** it
   explains that the airline adds the flight when it is booked with the same document, and that
   there is nothing to do.
2. **Given** the empty state, **When** it is displayed, **Then** the credential remains visible and
   its state remains accurate — having no trip does not mean having no identity.
3. **Given** a passenger who has never travelled with AeroPass, **When** the history section would be
   displayed, **Then** it is absent or explained rather than shown as an empty list.

---

### Edge Cases

- **The credential is expired, revoked, or suspended.** The strip shows the real state, and the trip
  action does not offer to start a journey the credential cannot support (FR-009).
- **Consent has been withdrawn.** The credential stops presenting as active immediately, per 002,
  and this screen reflects that.
- **Two trips on the same day, or a multi-leg itinerary with a connection.** Each flight segment is
  its own trip. The next trip is the segment with the earliest scheduled departure that has not yet
  departed. A segment that continues on a connection says so on its card ("Conexión a CLO"), and the
  following segment appears as the next trip once the first has departed.
- **The flight is tomorrow at 00:30, and "Hoy" is ambiguous near midnight.** "Hoy" and "Mañana" are
  computed in the departure airport's time zone (FR-014).
- **The passenger is in a different time zone from the departure airport.** Times are local to the
  departure airport and say so whenever the device's zone differs (FR-014).
- **The greeting is wrong for the hour after a long flight or a time zone change.** The greeting
  follows the device's current local hour.
- **The app is offline at the airport.** The screen renders from the last known state, marked as
  such, within what the constitution allows the app to keep (FR-013, CONFLICT-005). "Iniciar viaje"
  is disabled with the connection reason until the credential is confirmed again (FR-009).
- **Travel history grows long, and it is a record of a person's movements.** History keeps 90 days
  of past trips and says so. The passenger cannot delete individual trips; older trips drop out on
  their own (FR-012, Clarifications).
- **A booking made with a different document.** The airline cannot match it, so it does not appear.
  The empty state names the document to book with (FR-011).
- **An international itinerary exists for the passenger.** It is not shown anywhere on this screen
  (FR-010). A domestic leg of the same journey is shown as its own trip.
- **A screenshot is taken of this screen**, which carries the masked credential and a full itinerary.
  The screen allows screenshots. It shows no full document number and no facial image, and the pass
  itself (014) is where capture protection applies.
- **A screen reader user navigates the trip card.** Route codes are announced as airport names —
  "BOG" is "Bogotá", not three letters to spell — and the action's availability is announced
  (FR-015).
- **The departure has passed.** The trip leaves the "next" slot and moves to history.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: This screen MUST be the launch destination for a passenger holding a credential,
  reachable without navigation.
- **FR-002**: The credential strip MUST display the credential's current state and the masked
  document number. The full document number MUST NOT appear.
- **FR-003**: The credential's state MUST be refreshed from the backend when this screen is
  displayed. Where it cannot be, the last known state MUST be shown and marked as not refreshed.
  "ACTIVA" MUST appear only when the backend affirmed the credential as valid.
- **FR-004**: Exactly one trip MUST be promoted as next, with its route, flight identifier, date and
  time, and the operational detail available for it.
- **FR-005**: Flight details MUST be refreshed immediately when the app returns to the foreground,
  and every 60 seconds while this screen is visible. They MUST be visibly marked as not current
  where a refresh failed, including when they were last updated.
- **FR-006**: Where no live integration exists for a flight, the screen MUST state that the detail
  is unavailable rather than display an assumed or stale value.
- **FR-007**: A cancelled or materially changed flight MUST be surfaced on the trip card.
- **FR-008**: The action that starts a trip MUST be available only within the window in which a pass
  may be issued: from 24 hours before the scheduled departure until the scheduled departure. Outside
  it, the card MUST state when the action becomes available rather than failing on activation.
- **FR-009**: The trip action MUST NOT be offered when the credential is not in a state that supports
  travel, and the reason MUST be stated. Starting a trip MUST lead to the automatic re-verification
  step (013) and MUST NOT produce a pass on its own. The action MUST also be disabled whenever the
  credential's state was not confirmed by the backend on this display, stating "Sin conexión: no
  pudimos confirmar tu identidad". It MUST re-enable on its own when a later refresh confirms the
  credential.
- **FR-010**: Only domestic flight segments MUST be shown, as the next trip or in history.
  International segments MUST NOT appear on this screen, and the trip action MUST NOT be offered for
  them. [See CONFLICT-001.]
- **FR-011**: The empty state MUST explain that the airline adds a flight on its own when it is
  booked with the same document the passenger enrolled with, and that the passenger does not need to
  do anything. It MUST keep the credential visible and accurate. [See CONFLICT-002.]
- **FR-012**: Travel history MUST show only trips from the last 90 days, and the screen MUST state
  that limit. The passenger cannot delete individual trips. Trips older than 90 days MUST no longer
  be shown or returned by the source.
- **FR-013**: When offline, the screen MUST render from the last known state, marked as such, and
  MUST NOT present an empty or error screen in place of known data. The last known trips are those
  read earlier in the same app session. Itineraries MUST NOT be stored on the device unless the
  constitution is amended to allow it. [See CONFLICT-005.]
- **FR-014**: Times MUST be shown in the departure airport's local time, and MUST name that clock
  whenever it differs from the device's. Relative expressions such as "Hoy" and "Mañana" MUST be
  correct in the departure airport's time zone.
- **FR-015**: Route codes, trip status, and the availability of the trip action MUST be announced
  meaningfully by assistive technology.
- **FR-016**: The screen MUST emit events for launch, trip displayed, trip started, history opened
  (the history section first scrolled into view in this visit), and empty state shown. They MUST carry no personal data and no itinerary detail — no flight
  number, route, date or seat.
- **FR-017**: Recurrence MUST be measurable from these events: whether an enrolled passenger returns
  and starts a trip on a subsequent flight.
- **FR-018**: The screen MUST NOT display a facial image. The avatar and the strip use a neutral
  figure or the holder's initials. [See CONFLICT-004.]
- **FR-019**: Consent withdrawal MUST be reachable from this screen in no more than two taps, through
  the Perfil tab (constitution Principle I). [See CONFLICT-006.]

- **FR-020**: History rows MUST NOT be tappable and MUST NOT show an arrow or any other affordance
  suggesting they open something.

### Key Entities

- **Trip**: one flight segment associated with the credential — route, flight identifier, scheduled
  departure in the departure airport's time zone, status, whether it connects onward, and the
  operational details the airline supplies (gate, seat), each with when it was last updated. Owned
  by the airline integration, not by the app.
- **Trip association**: the link between an itinerary and a credential. The airline creates it by
  matching the booking's document number to the enrolled document; the app only reads it.
- **Credential summary**: the compact form of the credential — holder, masked document, current
  state. It is the same object as 008's credential, displayed more briefly.
- **Travel history**: past domestic trips taken with the credential in the last 90 days. Personal
  data with its own retention.
- **Trip window**: the period, 24 hours before departure until departure, during which a trip may be
  started.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: ≥70% of enrolled passengers return and start a trip on their next flight, matching the
  product's recurrence objective.
- **SC-002**: ≥99% of displayed gate and time values match the source at the moment of display,
  consistent with the accuracy the product commits to.
- **SC-003**: A gate or time change at the source is shown within 60 seconds while the screen is
  visible, and on the first refresh after returning to the app, in ≥95% of cases.
- **SC-004**: Zero instances of stale flight data presented as current without a staleness marker.
- **SC-005**: The screen is displayed and interactive within 2 seconds of a cold launch at p90 on the
  minimum supported device.
- **SC-006**: 100% of credential states displayed match the backend's state after refresh.
- **SC-007**: Zero full document numbers, and zero facial images, appear on this screen.
- **SC-008**: In usability testing, ≥90% of passengers with no upcoming trip can state how a trip
  will appear.
- **SC-009**: The screen renders usable content offline in 100% of tested cases where prior data
  exists in the same app session.
- **SC-010**: Zero analytics events carry a flight number, route, date or seat.
- **SC-011**: Zero international segments appear on this screen, and zero history rows are older
  than 90 days.

## Assumptions

- The passenger holds a credential; an unenrolled passenger never reaches this screen (001's launch
  rule).
- Itineraries come from the airline integration, pushed and matched on the document number, since
  ticket purchase and management are out of scope (Clarifications).
- The backend knows whether a segment is domestic, and enforces the 90-day history limit; the app
  applies both again when it displays trips.
- Gate, seat, and status are the airline's data, displayed by AeroPass and therefore attributed to
  AeroPass by the passenger.
- The three tabs are Viajes, Identidad and Perfil. Perfil carries the consent-withdrawal entry
  required by 002 and the constitution; everything else in Identidad and Perfil is a separate
  surface.
- The trip window opens 24 hours before the scheduled departure, in line with typical airline
  check-in, and closes at the scheduled departure. It can be revised when 013 and 014 are
  specified.
- The trip action leads to the automatic re-verification step (013) and then the pass (014). Until
  013 exists, the action ends at a placeholder for it.
- Copy is in Spanish (Colombia), matching the reference and specifications 001–011.

## Dependencies

- The airline integration supplying itineraries, gate, seat, time, and status, and its coverage —
  the product targets live integration for the large majority of flights, and this screen is where a
  gap is visible.
- Airline push of itineraries matched on document number (CONFLICT-002).
- Credential state from the backend, shared with 008 and 001's launch rule.
- The automatic verification step (013) and the pass (014) as the trip action's destination.
- A 90-day travel-history limit, enforced by the backend.
- A constitution amendment, if itineraries are ever to be stored for offline use (CONFLICT-005).

## Out of Scope

- Ticket purchase, change, and cancellation, and adding a booking by hand.
- International itineraries.
- Baggage.
- The Identidad and Perfil tabs, which are separate surfaces, except the withdrawal entry in Perfil
  (FR-019).
- The pass itself and the checkpoint journey.
- Notifications about flight changes outside the app.
