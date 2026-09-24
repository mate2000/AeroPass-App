# Feature Specification: Dynamic QR Pass (14 QR Pase)

**Feature Branch**: `014-qr-pase`

**Created**: 2026-09-23

**Status**: Draft

> **Superseded in part by 015** (`specs/015-integracion-backend`): the pass is online-only (DEC-01). Its token is issued by flight code and renewed every `renovar_en_segundos`, and it opens boarding only. Phase B is cancelled.

**Input**: User description: "Screen 14 QR Pase — the pass the passenger presents at a checkpoint. A
rotating QR code with a countdown, the journey's checkpoints, and an expired variant offering a new
code."

**Note on sequence**: screen 13 (Auto-verificado), the brief automatic re-verification between the
trips home (012) and this pass, is not yet specified. Today 012's "Iniciar viaje" ends at a
placeholder for 013. This specification assumes a trip has been started and the passenger
re-verified. What 013 actually verifies, and against what, should be written before either is
planned. The directory is numbered 014 to match the screen, leaving 013 for Auto-verificado.

## Delivery Mode: Happy Path First

Same section as specifications 005 through 012; it governs build order here too (constitution
Principle III, "Happy-Path Development Mode").

The current priority is a working end-to-end flow. Development runs in happy-path mode: the flow
must be walkable from welcome to pass without the edge-case handling, gating, and hardening
described below. Nothing here removes a requirement — each relaxation defers one, by identifier.

**Relaxable during happy-path mode**, each recorded as a deferred requirement:

- Checkpoint progress; the stepper may be static while validation events do not flow back.
- Offline rotation; development may assume the network is present.
- Screen brightness handling and screen-capture blocking.
- Analytics completeness — events that exist must already carry no personal data.
- Backend integrations, served by fakes implementing the real contract.

**Deferred requirements, by identifier** (the constitution requires this list; a deferral not
written here is not a deferral):

| Requirement | What is deferred | What still holds in happy-path mode |
|---|---|---|
| FR-009 | Validation events flowing back from readers | The stepper never marks a step validated on its own; with no events it shows the first checkpoint as current and nothing as done |
| FR-004, FR-005, SC-003 | Offline rotation | The code still comes from the backend (or the fake backend) and never from device-held state alone |
| FR-006, FR-007 | Brightness and screen-capture blocking | — |
| FR-017, FR-018 | The complete event set and time-to-validation | Any event that is emitted carries no personal data and no pass payload |
| Backend integrations | A real pass issuer and validation feed | Fakes implement the same contract the real services will |

**Specific to this screen**: a fake backend may mint codes, and a development affordance may force
expiry. But the reference contains a visible "Simular expirado" control, and that is exactly the
kind of affordance this section exists to govern. **It is a build-flagged development control, it
must be absent from every release build, and the release pipeline must fail if it is present**
(FR-019). A control that manipulates pass validity is not a debug menu item to leave lying around in
an app that authorizes people through a security checkpoint.

**Not relaxable, in any mode**:

- No real personal data; synthetic identities and itineraries only.
- **No pass presented as valid without backend authority.** The countdown is display; validity is
  the backend's (FR-002).
- **No pass minted on the device from device-held state alone.**
- No personal data in logs, events, or crash reports, including the pass payload (FR-015).
- Every relaxation lives behind a build flag that cannot be enabled in a release build.

**Exit from happy-path mode**: every deferred requirement is implemented or explicitly accepted as
out of scope, in writing, before any build reaches a real passenger.

## UI Reference

The authoritative visual reference is [`assets/14-qr-pase.png`](./assets/14-qr-pase.png), copied
from `C:\Users\Usuario\Pictures\Screenshots\Captura de pantalla 2026-09-23 151718.png`. It is the
source of truth for layout, content order, and styling, except where the conflicts below override
it.

| Element | Content in the reference |
|---|---|
| Top bar | "‹ Atrás" (left), "Ayuda" (right) |
| Passenger | "Mateo González" |
| Trip line | "AV 8841 · BOG → GRU · Hoy 14:35" |
| Seat chip | "22A · Fila" |
| Journey stepper | 1 Seguridad (active), 2 Sala, 3 Embarque — reduced to Seguridad and Embarque (Clarifications) |
| Pass | Large QR code with the AeroPass mark at its centre, ringed by a progress arc |
| Countdown | "Se actualiza en 00:26" |
| Development control | "Simular expirado" |
| Footer | "Presenta este código en el lector de seguridad" |

Behaviors the reference establishes: the pass rotates on a visible countdown, the passenger's
position in the airport journey is shown as checkpoints (two, after Clarifications), the pass is the screen's entire
subject, and an expired variant exists offering a new code.

### Conflicts raised by the reference

- **CONFLICT-001 — "Simular expirado" ships a validity control to the passenger.** **Resolved in the
  requirements as a release gate**: the control exists only behind a development flag, and a release
  build containing it fails (FR-019, SC-006).
- **CONFLICT-002 — rotation and offline operation pull against each other.** The product commits to
  the pass working without connectivity once issued, and this screen rotates the code roughly every
  thirty seconds. A code fetched per rotation cannot rotate offline. The usual resolution is a
  short-lived secret issued when the trip starts, from which the device derives time-based codes the
  reader validates independently. That keeps the device from being the authority while still working
  with no network. **It runs into the constitution**: the app may persist only the credential token and
  its validity window, the display-only identity fields, the consent record and the attempt
  counters. A pass secret that must survive the app being closed and reopened offline is not on that
  list. **Resolved** (Clarifications): the pass is derived on the device from a secret the backend
  issues when the trip starts. The secret is stored in secure storage until it expires, so the pass
  survives the app being closed and reopened offline. **This requires a constitution amendment**
  adding "the pass secret and its issued validity window" to the persisted-state allowlist. The
  amendment is a prerequisite: nothing that stores the secret may be built before it is ratified
  (FR-004, FR-021).
- **CONFLICT-003 — "Sala" is not obviously a checkpoint.** Seguridad and Embarque are validation
  points. A lounge or waiting area is not, unless the airport validates entry to it. **Resolved**
  (Clarifications): "Sala" is dropped. The journey is two checkpoints, Seguridad then Embarque, both
  with readers (FR-009).
- **CONFLICT-004 — the itinerary is international again.** BOG → GRU carries the scope question 012
  already answered. **Resolved by 012's clarification**: only domestic trips are shown and started,
  so no international trip reaches this screen. The reference's example is replaced by a domestic
  one, for instance BOG → MDE. The journey shown is the domestic one, with no immigration step
  (FR-010).
- **CONFLICT-005 — "22A · Fila" labels a seat as a row.** Found while writing this spec. "22A" is a
  seat, as 012 labels it ("Asiento 22A"). **Resolved**: the chip reads "Asiento 22A", and only when
  the airline supplies a seat.
- **CONFLICT-006 — "‹ Atrás" and a pass that must stay on screen.** Found while writing this spec.
  Leaving the pass must restore brightness and screen capture, and returning must not show a stale
  code. **Resolved in the requirements**: back returns to Mis viajes, and reopening re-derives or
  re-fetches the current code before showing it (FR-020).

## Clarifications

### Session 2026-09-23

- Q: Is the pass derived on the device from a server-issued secret, or fetched per rotation, and may
  the secret be stored? → A: Derived on the device from a backend-issued secret, stored in secure
  storage until it expires. This requires a constitution amendment to the persisted-state allowlist.
- Q: What marks step 2 "Sala" complete? → A: Nothing: "Sala" is dropped. The journey is two
  checkpoints, Seguridad and Embarque.
- Q: How long may a pass be presented without contacting the backend? → A: Until the flight's
  scheduled departure, at most 24 hours from issuance.
- Q: How far may the phone's clock differ from the backend's before the pass is treated as
  untrustworthy? → A: 30 seconds, one rotation interval. Beyond that, the pass is shown as unusable,
  with a note to set the time automatically.
- Q: Once a pass has been issued, how does the passenger get back to it? → A: While a pass is
  valid, the Mis viajes card replaces "Iniciar viaje" with "Ver pase", which opens the pass directly,
  even offline.
- Q: After the boarding reader (Embarque) accepts the pass, what happens? → A: The code disappears,
  the screen shows "Abordaje confirmado · Buen viaje", the secret is deleted at once, and the trip
  moves to history.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A passenger presents the pass and clears the checkpoint (Priority: P1)

The passenger reaches the security lane, opens the pass, holds the phone to the reader, and is
through. The code is legible on the first present, the screen is bright enough for the scanner, and
the passenger does not have to do anything but hold it steady.

**Why this priority**: this is the moment the entire product exists to produce. Every earlier screen
is preparation for it, and the time saved here is the number the airport is buying.

**Independent Test**: start a trip, open the pass, and verify it renders promptly, rotates on
schedule, is legible to a reader at a realistic distance and angle, and that a successful validation
advances the journey.

**Acceptance Scenarios**:

1. **Given** a started trip within its validity window, **When** the pass opens, **Then** the code
   is displayed with the passenger, flight, and seat it belongs to, and the checkpoint it is for.
2. **Given** the pass is displayed, **When** the screen is shown, **Then** display brightness is
   raised for legibility and restored when the passenger leaves.
3. **Given** the pass is displayed, **When** the 30-second rotation interval elapses, **Then** a new
   code replaces it and the countdown restarts, without the passenger acting.
4. **Given** the code is presented to a reader, **When** it is accepted, **Then** the journey stepper
   advances to the next checkpoint.
5. **Given** the pass is displayed, **When** the passenger reads the footer, **Then** it names which
   reader this code is for.

---

### User Story 2 - The pass works when the network does not (Priority: P1)

The passenger is in a terminal on congested wifi, or in a dead spot, or has no data. The pass must
still render and still rotate. A pass that depends on connectivity fails exactly where it is needed.

**Why this priority**: it shares P1 because the product commits to the pass remaining usable without
network once issued, and because connectivity inside terminals is unreliable in precisely the places
queues form. A passenger who cannot produce a pass at the lane has been given a worse experience
than a paper boarding card.

**Independent Test**: start a trip with connectivity, disable the network, and verify the pass
renders, rotates through several intervals, and remains acceptable to a reader.

**Acceptance Scenarios**:

1. **Given** a pass issued while online, **When** connectivity is lost, **Then** the pass continues
   to render and rotate for the remainder of its issued validity.
2. **Given** an offline pass, **When** its issued validity is exhausted, **Then** the passenger is
   told plainly that connectivity is needed to continue and what to do at the checkpoint meanwhile.
3. **Given** the app is closed and reopened offline, **When** the pass is opened, **Then** it resumes
   correctly rather than requiring a fetch — within what CONFLICT-002's answer allows.
4. **Given** the device clock has drifted or been changed, **When** a code is derived, **Then** the
   system does not present a code the backend would reject, and the passenger is told if the pass
   cannot be trusted.

---

### User Story 3 - An expired or unusable pass has an honest recovery (Priority: P1)

The pass expires — the trip window closed, the validity ran out, the passenger left it too long. Or
the credential was revoked, or the flight changed. The screen must say so rather than continue
displaying a code that will be refused at the lane.

**Why this priority**: it shares P1 because a displayed code that the reader rejects is the most
visible possible failure, in front of a queue and an airport employee. The zero-false-accept
commitment is the reason a stale code must never be displayed as usable.

**Independent Test**: let a pass expire, revoke the credential server-side, and change the flight;
verify each produces an accurate state on this screen with a route forward.

**Acceptance Scenarios**:

1. **Given** an expired pass, **When** the screen is shown, **Then** the code is visibly not usable
   and a new one can be requested.
2. **Given** the credential has been revoked or consent withdrawn, **When** this screen is shown,
   **Then** no pass is displayed and the reason is stated.
3. **Given** the flight has changed materially or been cancelled, **When** this screen is shown,
   **Then** that is surfaced rather than a pass for a flight that will not depart as shown.
4. **Given** a new code is requested, **When** it cannot be issued, **Then** the passenger is told
   what to do at the checkpoint instead, and the conventional process is stated as available.

---

### Edge Cases

- **The phone's battery dies at the lane.** The pass is gone. The passenger needs the conventional
  process, and this screen states that it remains available every time the pass is shown (FR-013).
- **A screenshot of the code is taken and sent to someone else.** Rotation is the mitigation, and
  screen capture is blocked outright on this surface (FR-007).
- **Two passengers try to use one device, or one passenger presents another's screenshot.** The pass
  is bound to one passenger and flight; the reader's independent check, not the app, refuses the
  second use.
- **The device is in a low-power mode** that caps brightness or suspends timers, so the code stops
  rotating while displayed. On resuming, the code and countdown are recomputed from the clock, never
  from a paused timer (FR-006).
- **Auto-lock engages while the passenger waits in the queue with the pass open.** The screen stays
  awake while the pass is shown; after an unlock, the current code is shown, not the one from before
  the lock.
- **The reader is offline while the device is online, or the reverse.** Validation events may arrive
  late; the stepper advances only when one arrives (FR-009).
- **The passenger reaches the gate without passing security.** The stepper does not reorder itself:
  the footer names the next checkpoint in order, and the reader decides acceptance.
- **The trip window closes while the passenger is in the queue.** The pass turns visibly unusable at
  that moment, with the checkpoint alternative stated (FR-011, FR-013).
- **A passenger with low vision, or who cannot hold the phone steady at the reader**, needs
  assistance rather than a brighter screen. "Ayuda" leads to asking checkpoint staff for help
  (FR-016).
- **The system clock is manipulated deliberately to revive an expired code.** The app compares its
  clock with the backend's, and a difference over 30 seconds makes the pass unusable (FR-014). A
  clock moved backwards past the issuance time is untrusted too.
- **The app is reopened hours later with the pass still on screen from a previous session.** The
  code is recomputed before display; an expired pass shows as expired (FR-020). From Mis viajes, a
  still-valid pass is reached through "Ver pase", offline included (FR-022).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The pass MUST be displayed only for a started trip within its validity window, bound to
  the passenger, the flight, and the checkpoint it is presented at.
- **FR-002**: Validity MUST be determined by the backend. The countdown and any on-screen state are
  display only, and the app MUST NOT present a pass as usable on device-held state alone, in any
  build or mode.
- **FR-003**: The code MUST rotate every 30 seconds without passenger action, and the time to the
  next rotation MUST be visible.
- **FR-004**: The pass MUST continue to render and rotate without connectivity for the whole of its
  issued validity, including after the app is closed and reopened offline. The codes are derived on
  the device from the backend-issued secret; the device never creates or extends a secret itself.
- **FR-005**: When the issued validity is exhausted offline, the pass MUST stop presenting as usable
  and MUST state what the passenger should do at the checkpoint.
- **FR-006**: Display brightness MUST be raised while the pass is shown and restored on leaving. The
  screen MUST stay awake while the pass is shown. The code MUST remain legible under the platform's
  low-power constraints, or the passenger MUST be told it cannot.
- **FR-007**: Screen capture and screen recording MUST be blocked on this surface.
- **FR-008**: The screen MUST display the passenger, flight, seat, and the checkpoint the code is
  for, so a passenger never presents a code for the wrong point.
- **FR-009**: The journey stepper MUST show two checkpoints, Seguridad and Embarque, and reflect
  those actually validated, advancing on a confirmed validation rather than on elapsed time or
  navigation. No step without a reader is shown. [See CONFLICT-003.] When Embarque is validated, the
  code MUST disappear and the screen MUST show "Abordaje confirmado · Buen viaje"; no code is
  displayed after boarding.
- **FR-010**: Only domestic journeys reach this screen (012 FR-010). The journey MUST NOT show an
  immigration step or any segment the credential does not cover.
- **FR-011**: An expired pass MUST be visibly unusable, and a new code MUST be requestable.
- **FR-012**: A revoked credential, a withdrawn consent, or a cancelled or materially changed flight
  MUST prevent a pass from being displayed, with the reason stated.
- **FR-013**: Where a new code cannot be issued, the passenger MUST be told what to do at the
  checkpoint, and the conventional process MUST be stated as available. The screen MUST state that
  the conventional process remains available whenever the pass is shown.
- **FR-014**: The system MUST detect a device clock that differs from the backend's by more than 30
  seconds — as observed at issuance and at every later contact — and MUST NOT present a code derived
  from that clock as usable. The passenger MUST be told to set the phone's time automatically.
- **FR-015**: The pass payload MUST NOT appear in logs, analytics, crash reports, or any diagnostic
  output.
- **FR-016**: A route to help MUST be reachable from this screen, leading to assistance at the
  checkpoint for passengers who cannot present the code themselves.
- **FR-017**: The screen MUST emit events for pass displayed, rotation, validation outcome by
  checkpoint, expiry, new code requested, and help taken — carrying no pass payload and no personal
  data.
- **FR-018**: Time from opening this screen to a confirmed validation MUST be measurable, since it is
  the passenger-facing half of the checkpoint transit time the product is sold on.
- **FR-019**: Every development affordance affecting pass validity MUST be behind a build flag absent
  from release builds, and its presence in a release build MUST fail the release. [See
  CONFLICT-001.]
- **FR-020**: Leaving the screen ("Atrás" or the back gesture) MUST return to Mis viajes and restore
  brightness and screen capture. Opening or returning to the screen MUST show the current code, never
  one computed before the passenger left, the device locked, or the app was suspended.
- **FR-022**: While a pass is valid for the next trip, the Mis viajes card (012) MUST offer "Ver
  pase" instead of "Iniciar viaje", opening this screen directly without re-verification and without
  connectivity. When the pass has expired or been deleted, the card returns to "Iniciar viaje".
- **FR-021**: The pass secret MUST be stored only in the platform's secure storage, only until its
  issued validity ends, and MUST be deleted at that point, on a confirmed Embarque validation, on
  consent withdrawal, and on credential revocation. It MUST NOT be stored before the constitution
  amendment is ratified. After boarding, the trip moves to Mis viajes' history and the card no
  longer offers "Ver pase".
- **FR-023** *(constitution, Security & Compliance; added during planning)*: The app MUST detect a
  compromised device posture (root or jailbreak, emulator, hooking framework) and MUST refuse to
  issue or display a pass on one. The refusal MUST route the passenger to the agent-escalation path
  (010) and state the checkpoint alternative, never a dead end.

### Key Entities

- **Pass**: the credential-derived token presented at a checkpoint, bound to passenger, flight, and
  checkpoint, valid for a short interval. Issued under backend authority.
- **Rotation**: the replacement of the displayed code every 30 seconds. Distinct from expiry —
  rotation continues within validity; expiry ends it.
- **Issued validity**: the period for which the device may present passes without contacting the
  backend. The basis of offline operation and the bound on it. It lasts until the flight's
  scheduled departure, and never more than 24 hours from issuance (Clarifications).
- **Checkpoint**: a point in the airport journey where a reader validates a pass. Only points with a
  reader are checkpoints: Seguridad and Embarque.
- **Pass secret**: the backend-issued, short-lived value from which the device derives each code.
  Stored in secure storage until its issued validity ends, then deleted; also deleted on consent
  withdrawal and credential revocation. Never logged or sent anywhere.
- **Validation event**: a reader's confirmed acceptance, which is what advances the journey.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: ≥95% of passes are accepted on first presentation at a reader.
- **SC-002**: The pass renders and is legible within 2 seconds of opening the screen at p90 on the
  minimum supported device.
- **SC-003**: The pass remains usable offline for 100% of its issued validity in tested conditions.
- **SC-004**: Zero passes are displayed as usable when the backend would reject them — expired,
  revoked, or derived from an untrusted clock.
- **SC-005**: Confirmed false accepts at checkpoints are zero. Absolute; one occurrence is a critical
  finding.
- **SC-006**: Zero development affordances affecting pass validity appear in any release build,
  enforced by the release pipeline.
- **SC-007**: Zero pass payloads appear in logs, analytics, or crash reports, verified by audit.
- **SC-008**: Median time from opening this screen to a confirmed validation supports the checkpoint
  transit target the product commits to.
- **SC-009**: Zero passengers reach a state on this screen with no forward action, including expired
  passes, revoked credentials, and failed reissue.
- **SC-010**: Zero pass secrets remain on the device after their issued validity ends, after a
  confirmed boarding, after consent withdrawal, or after credential revocation, verified by audit.

## Assumptions

- The pass is derived from the credential and the trip, and authorizes a specific passenger at a
  specific checkpoint for a specific flight — it is not a general-purpose credential display.
- Validity is short by design, which is what limits the value of a shared screenshot. The rotation
  interval is 30 seconds, matching the reference.
- Readers validate the code independently of the app; the app never reports its own acceptance.
- The conventional airport process remains available at every checkpoint, and no passenger is
  stranded by a device failure.
- The journey has two steps, Seguridad and Embarque, each with a reader (Clarifications).
- Screen 013 has already performed whatever automatic re-verification precedes issuing a pass. Until
  013 exists, the pass is reached from 012's placeholder for it.
- The passenger's name and the seat come from the same sources as 012: the credential summary and the
  airline integration.
- This feature changes 012's trip card: "Ver pase" replaces "Iniciar viaje" while a valid pass
  exists (FR-022).
- Copy is in Spanish (Colombia), matching the reference and specifications 001–012.

## Dependencies

- Backend pass issuance: a secret issued at trip start, valid until scheduled departure and at most
  24 hours, and readers that validate device-derived codes independently.
- Checkpoint readers and the validation events that flow back to advance the journey.
- Credential state and consent state, shared with 002, 008 and 012.
- Flight status from the airline integration, shared with 012.
- The automatic verification step (013) as the origin.
- A build-flag mechanism and a release gate, for FR-019.
- **A ratified constitution amendment** adding the pass secret and its issued validity window to
  Principle I's persisted-state allowlist (CONFLICT-002). It blocks implementation of offline
  storage.

## Out of Scope

- The reader hardware, its software, and the checkpoint-side validation.
- The airport's contingency procedure when AeroPass is unavailable, beyond telling the passenger it
  exists.
- Boarding pass issuance by the airline, and any relationship between this pass and one.
- Immigration and any international process.
- The automatic verification step, specified separately with 013.
