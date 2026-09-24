# Feature Specification: Credential Activated (08 Identidad activa)

**Feature Branch**: `008-identidad-activa`

**Created**: 2026-09-23

**Status**: Draft

> **Superseded in part by 015** (`specs/015-integracion-backend`): issuance reads `GET /v1/identity/me`. While the biometric provider is a mock, the screen says "Registro completado" and never "activa" (FR-020).

**Input**: User description: "Screen 08 Identidad activa — the end of enrollment. Confirms the
digital identity is active, presents the credential card, and routes the passenger onward to their
trips."

**Note on sequence**: this is screen 08. Screen 07 (Validando) is not yet specified; it is the
progress surface between the liveness capture and this outcome, and the number `007` is reserved
for it. Nothing here depends on that spec existing, but the pair should be written before either
is planned, since 07 owns the waiting state and this screen owns only the settled one.

## Delivery Mode: Happy Path First

Same section as specifications 005 and 006; it governs build order for this specification too
(constitution Principle III, "Happy-Path Development Mode").

The current priority is a working end-to-end flow. Development runs in happy-path mode: the flow
must be walkable from welcome to pass without the edge-case handling, gating, and hardening
described below. Nothing here removes a requirement — each relaxation defers one, by identifier.

**Relaxable during happy-path mode**, each recorded as a deferred requirement:

- Offline and connectivity handling. (Credential-state refresh on later visits moved to the
  persistent credential surface when this screen became one-time; see FR-009.)
- The full set of non-active credential states; development may assume activation succeeded.
- Timing and performance budgets.
- Analytics completeness — events that exist must already carry no personal data.
- Backend integrations, served by fakes implementing the real contract.
- Screen-capture blocking and device-posture checks.

**Deferred requirements, by identifier** (the constitution requires this list; a deferral not
written here is not a deferral):

| Requirement | What is deferred | What still holds in happy-path mode |
|---|---|---|
| FR-010 | The dedicated outcome screen for non-active or incomplete issuance (not yet specified); a placeholder may stand in | This screen never opens for a non-active or incomplete credential |
| FR-012 | iOS only: hiding the credential while the screen is being recorded (iOS cannot block screenshots) | Android blocks screenshots and recording (`FLAG_SECURE`) in every mode |
| FR-015, FR-016 | Complete funnel events and the fields needed to compute p90 duration and abandonment | Any event that is emitted carries no personal data |
| SC-008 | Computability of enrollment p90 and abandonment from the event stream | — |
| Backend issuance | Served by a fake that implements the real issuance and status contract | The fake is the one that asserts "active"; the screen only reports it |

**Specific to this screen**: the credential may be issued by a fake backend so the flow completes
without a verification account. **What may not be faked is the direction of the assertion — the
app displays an active credential because the backend said so, never because enrollment reached
this screen.** See FR-001.

**Not relaxable, in any mode**:

- No real personal data; synthetic identities only.
- No persistence of images or biometric samples — by this point they should already be gone.
- No personal data in logs, events, or crash reports.
- **No path that presents an active credential without backend affirmation.** This screen is the
  one where that rule is most tempting to break and most expensive to break.
- Consent withdrawal ends the credential's active presentation immediately (FR-011).
- Every relaxation lives behind a build flag that cannot be enabled in a release build.

**Exit from happy-path mode**: every deferred requirement is implemented or explicitly accepted as
out of scope, in writing, before any build reaches a real passenger — the airport pilot
integration (constitution Principle III).

## UI Reference

The authoritative visual reference is
[`assets/08-identidad-activa.png`](./assets/08-identidad-activa.png), copied from
`C:\Users\Usuario\Pictures\Screenshots\Captura de pantalla 2026-09-23 090434.png`. It is the source
of truth for layout, content order, and copy, except where the conflicts below override it. The
holder name and document digits in it are synthetic.

| Element | Content in the reference |
|---|---|
| Success marker | Turquoise circle with a check, over the navy header |
| Title | "Tu identidad digital está activa" |
| Subtitle | "A partir de ahora, pasa seguridad sin mostrar documentos físicos." |
| Credential card | Label "IDENTIDAD DIGITAL"; holder name "Mateo González"; masked document "•••• 4821 · COL"; "Creada el 16 sep 2026"; status badge "• ACTIVA"; portrait placeholder |
| Stat tiles | "220+ Aeropuertos", "48 Aerolíneas", "hoy · Creada" |
| Primary action | "Ir a mis viajes" |
| Secondary action | "Ver mi identidad" |

Behaviors the reference establishes: enrollment ends in a settled, positive state; the credential
is shown as an object the passenger now owns; the document number is masked rather than shown in
full; and two routes lead onward rather than leaving the passenger on a terminal screen.

### Conflicts raised by the reference

- **CONFLICT-001 — the coverage tiles assert something untrue.** "220+ Aeropuertos" and "48
  Aerolíneas" sit directly beneath a credential that has just been activated, in the position a
  passenger reads as *what my credential does*. The product launches with one contracted airport
  and reaches break-even near five. A passenger who reads this and then presents the credential at
  an airport that never signed a contract has been misled at the exact moment they were asked to
  trust the product with their face. Under Colombian consumer-protection rules this is not merely a
  design choice. **Resolved** (Clarifications, 2026-09-23): the figures were placeholder content,
  and the tiles are removed entirely. This screen makes no coverage or capability claim (FR-005).
- **CONFLICT-002 — the dates disagree.** Resolved: the card's "Creada el …" date stays and the "hoy
  · Creada" tile is dropped, along with the other two tiles (CONFLICT-001). Both describe the
  same fact; the card is the one that carries it (FR-006).
- **CONFLICT-003 — no validity is shown.** Resolved: the card states the credential's validity
  ("Válida hasta …" or equivalent) using the validity window the backend returns with the
  credential. Specification 004 decoupled credential validity from document expiry and left the
  policy to the backend; this screen displays whatever that policy produces and never computes a
  validity of its own (FR-004).
- **CONFLICT-004 — the subtitle overreaches once the tiles are gone.** "A partir de ahora, pasa
  seguridad sin mostrar documentos físicos." reads as unconditional. Resolved: the subtitle is
  qualified to the checkpoints where AeroPass is accepted (for example, "…en los filtros donde
  AeroPass está disponible"), per FR-002. Final wording is a copy decision for planning.

## Clarifications

### Session 2026-09-23

- Q: What were the "220+ Aeropuertos" and "48 Aerolíneas" tiles meant to convey? → A: Placeholder
  content. **All three stat tiles are removed** and nothing replaces them. The screen makes no
  coverage or capability claim, and its copy must not imply the credential works everywhere
  (FR-002, FR-005). Where the credential is accepted is left to other surfaces.
- Q: Is this screen reachable after enrollment, or one-time? → A: **One-time.** It is shown once,
  immediately after the backend confirms issuance. A later link or restored navigation into it
  routes to the persistent credential surface that "Ver mi identidad" opens (relaunch: see the
  re-entry answer below). That
  surface, not this screen, owns refreshing credential state, the "unrefreshed" marking, and the
  returning-visitor wording, and is specified separately.
- Q: Is a portrait displayed on the credential? → A: **No portrait.** The card shows a generic
  silhouette icon in the portrait position, as the reference's placeholder does. No face image is
  requested, stored, or displayed, so no retained biometric and no constitution amendment are
  involved.
- Q: Until screen 07 exists, which part of the app obtains the backend's issuance confirmation and
  hands it to this screen? → A: **The existing verification-progress placeholder.** It requests
  the issued credential from the backend (or the fake, in happy-path mode), opens this screen only
  on a confirmed issuance, and passes the confirmed credential along. This screen never requests
  issuance itself and has no waiting state. Screen 07 later replaces the placeholder under the
  same hand-off.
- Q: If the issuance response is not a usable active credential (non-active state, or missing
  data such as the validity window), what does the passenger see? → A: **This screen never
  opens.** The passenger is routed to a separate outcome screen, to be specified in its own
  upcoming spec. This screen presents only an active, complete credential.
- Q: With no on-screen back button, what does the system back gesture do on this screen? → A:
  **It goes to the trips surface**, the same destination as "Ir a mis viajes", and is recorded as
  its own onward-route event. It never returns into the capture or verification steps.
- Q: Where does a passenger land on returning to this screen after it has been shown? → A: **A
  relaunch follows specification 001** (a valid credential opens the trips surface). **A link or
  restored navigation into this screen** lands on the persistent credential surface, served by a
  placeholder until that surface is specified.
- Q: How does the card display a holder name too long for its width? → A: **It wraps to at most
  two lines, then ends with an ellipsis.** Assistive technology always announces the full name.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A passenger sees that enrollment worked and knows what they now have (Priority: P1)

The passenger has just finished a document scan and a facial capture. This screen tells them,
without ambiguity, that it worked: their digital identity is active, here is the credential, and
here is what to do next. They leave the flow understanding that they no longer need to present
documents at the checkpoints where AeroPass is accepted.

**Why this priority**: it is the payoff for every step before it and the moment the product's
promise becomes concrete. An enrollment that succeeds but ends ambiguously produces a passenger who
queues in the manual lane anyway, which costs the airport the benefit it is paying for.

**Independent Test**: complete an enrollment and verify that the screen states the credential is
active, displays it with the holder's name and a masked document number, and offers a route
onward; then verify the credential displayed matches what the backend issued.

**Acceptance Scenarios**:

1. **Given** a backend-confirmed credential issuance, **When** this screen opens, **Then** it
   states the identity is active and displays the credential with the holder's name, masked
   document number, country, creation date, validity, and status.
2. **Given** the credential is displayed, **When** the passenger reads the document number,
   **Then** only the masked form is shown; the full number never appears on this screen.
3. **Given** the screen is displayed, **When** the passenger looks for what to do next, **Then** a
   primary route to their trips and a secondary route to the credential detail are both available.
4. **Given** the screen is displayed, **When** the passenger reads it, **Then** it contains no
   airport count, airline count, or other coverage figure, and no wording that implies the
   credential is accepted everywhere.
5. **Given** the screen is displayed, **When** the passenger looks for how long the credential
   lasts, **Then** its validity is stated.
6. **Given** the screen is displayed, **When** the passenger reads the creation date, **Then** it
   appears once, on the card, and nowhere else on the screen.

---

### User Story 2 - The credential's state is the backend's, not the screen's (Priority: P1)

The passenger reaches this screen only because a credential exists. If the backend has not issued
one, or has issued one in a state other than active, this screen must not appear as though it had.
It is shown once, at issuance; afterwards the passenger sees their credential on the persistent
credential surface, which reflects its current state rather than the state it had at enrollment.

**Why this priority**: it shares P1 because this is the screen where an app could most easily
assert something the backend never said. A credential displayed as active on local state alone is
the first step toward a pass displayed as valid on local state alone, which is the failure mode the
product cannot have.

**Independent Test**: block or fail the issuance call and verify this screen is unreachable; have
the fake backend issue a non-active credential and verify it is not shown as active; then complete
an enrollment, leave, and try to re-enter this screen, and verify it routes to the persistent
credential surface instead.

**Acceptance Scenarios**:

1. **Given** issuance has not been confirmed by the backend, **When** the flow would advance,
   **Then** this screen is not shown and the passenger remains in the verification flow.
2. **Given** a direct link or restored navigation into this screen with no backend-confirmed
   credential, **When** it would open, **Then** it does not display a credential and the passenger
   is routed back into the flow.
3. **Given** the backend issues a credential in a state other than active, or without required
   data such as its validity window, **When** the flow would advance, **Then** this screen does
   not open and the passenger is routed to the separate outcome screen instead.
4. **Given** this screen has already been shown for the current credential, **When** the
   passenger re-enters it by link or restored navigation, **Then** they land on the persistent
   credential surface instead, and this screen does not congratulate them again.
5. **Given** this screen has already been shown and the credential is valid, **When** the
   passenger relaunches the app, **Then** they land on the trips surface, per specification 001.
6. **Given** consent is withdrawn while this surface is open, **When** the withdrawal completes,
   **Then** the credential stops presenting as active immediately.

---

### User Story 3 - A newly enrolled passenger with no trip yet still has somewhere to go (Priority: P2)

Many passengers will enroll at home, days before flying, or at the airport after their flight is
already over. "Ir a mis viajes" leads somewhere empty for them. The end of enrollment should still
leave them with a clear expectation of what happens next and when the credential becomes useful.

**Why this priority**: the product's value depends on passengers coming back for their next flight,
which is a named objective. A passenger who finishes enrollment and lands in an empty screen has
been given nothing to return for. It ranks below the two above because it affects the
follow-through rather than the correctness of enrollment.

**Independent Test**: complete enrollment with no associated trip and verify the passenger reaches
a state that explains what happens when a flight is added, rather than an unexplained empty list.

**Acceptance Scenarios**:

1. **Given** a passenger with no upcoming trip, **When** they follow the primary route, **Then**
   the destination explains how a trip becomes associated with their credential rather than
   showing an unexplained empty state.
2. **Given** a passenger with an upcoming trip already known, **When** they follow the primary
   route, **Then** that trip is shown.

---

### Edge Cases

- The passenger returns to this screen later, from a link or restored navigation. This screen is
  one-time, so they are routed to the persistent credential surface rather than congratulated a
  second time (FR-009).
- The credential is revoked or expired by the time the passenger looks again. That later look
  happens on the persistent credential surface, which shows the real state; this screen is never
  shown again to present the enrollment-time "active".
- Consent is withdrawn while this surface is open — the credential must stop presenting as active
  immediately, per specification 002 (FR-011).
- A screenshot or screen recording is attempted. The constitution blocks screen capture on
  credential surfaces; this is one, so the block applies here whatever was decided for the capture
  screens (003, 004, 006 deliberately did not block, because they are not credential surfaces).
- The holder's name is long or contains characters the card cannot render. The name wraps to two
  lines, then ends with an ellipsis, and the full value is always announced (FR-014).
- The device is offline when the screen opens immediately after enrollment. Issuance has just
  succeeded, so the state is fresh and the screen shows it; later visits, and their "unrefreshed"
  marking, belong to the persistent credential surface.
- The app is closed or killed while this screen is open. On relaunch it is not shown again; the
  launch rule of specification 001 applies, so a valid credential opens the trips surface (FR-009).
- Assistive technology reads the masked document number. "•••• 4821" should be announced
  meaningfully (for example, "documento terminado en 4821, Colombia"), not as four bullet
  characters.
- The backend returns a credential without a validity window. The screen does not invent one;
  the response is incomplete, so this screen does not open and the passenger goes to the separate
  outcome screen (FR-010).
- The passenger uses the system back gesture on this screen. Enrollment is complete, so back
  takes them to the trips surface rather than into the capture steps (FR-017).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: This screen MUST be reachable only after the backend has confirmed credential
  issuance. The app MUST NOT present an active credential on the strength of local state, in any
  build or mode — including when the backend is a fake. The confirmed credential MUST be handed to
  this screen by the verification-progress step that obtained it; this screen MUST NOT request
  issuance itself and has no loading or waiting state.
- **FR-002**: The screen MUST state plainly that the digital identity is active and what it now
  allows the passenger to do, qualified to the checkpoints where AeroPass is accepted rather than
  implying acceptance everywhere.
- **FR-003**: The credential MUST display the holder's name, a masked document number, the issuing
  country, the creation date, and the current status. The full document number MUST NOT appear.
- **FR-004**: The screen MUST state the credential's validity period or expiry, as returned by the
  backend. The app MUST NOT derive a validity of its own, from the document's expiry or otherwise.
- **FR-005**: The screen MUST NOT present any coverage or capability figure — airport counts,
  airline counts, or similar. Aspirational, market-size, or placeholder figures MUST NOT appear.
  [Resolved in CONFLICT-001: the stat tiles are removed.]
- **FR-006**: The same fact MUST NOT be presented twice in conflicting forms; the creation date
  appears once, on the card.
- **FR-007**: The screen MUST offer a primary route to the passenger's trips and a secondary route
  to the credential detail.
- **FR-008**: When the passenger has no associated trip, the destination of the primary route MUST
  explain how a trip becomes associated rather than presenting an unexplained empty state.
- **FR-009**: This screen MUST be shown once per issued credential, immediately after the backend
  confirms issuance. A later link or restored navigation into it MUST route to the persistent
  credential surface, which owns refreshing credential state and marking it as unrefreshed when
  the backend cannot be reached. A relaunch MUST follow specification 001's launch rule instead.
- **FR-010**: If the backend issues a credential in any state other than active, or without the
  data this screen requires (FR-003, FR-004), this screen MUST NOT open. The passenger MUST be
  routed to the separate outcome screen for that case, specified on its own. *(That destination
  may be a placeholder in happy-path mode; the rule that this screen never opens is not relaxed.)* *(Distinct presentation per
  state deferred in happy-path mode; a non-active state is never shown as active in any mode.)*
- **FR-011**: Withdrawal of consent MUST immediately end the presentation of this credential as
  active, consistent with specification 002.
- **FR-012**: Screen capture and screen recording MUST be blocked while the credential is
  displayed. *(Deferred in happy-path mode.)*
- **FR-013**: The screen MUST retain only the credential fields it displays, consistent with the
  data the identity record is permitted to hold.
- **FR-014**: The masked document number MUST be announced meaningfully by assistive technology.
  The holder's name MUST wrap to at most two lines on the card and end with an ellipsis beyond
  that, and the full name MUST always be announced by assistive technology.
- **FR-015**: The screen MUST emit funnel events for enrollment completion and for each onward route
  taken, carrying no personal data. *(Completeness deferred in happy-path mode; the no-personal-data
  rule is not.)*
- **FR-016**: Enrollment completion MUST be recorded such that the p90 enrollment duration and the
  abandonment rate can be computed from the event stream alone. *(Deferred in happy-path mode.)*
- **FR-017**: The screen MUST NOT show a back button. The system back gesture MUST take the
  passenger to the trips surface, the same destination as the primary route, and MUST NOT return
  them into the capture or verification steps of a completed enrollment. It is recorded as its own
  onward-route event (FR-015).
- **FR-018**: The card MUST NOT display a portrait or any face image. The portrait position shows
  a generic silhouette icon.

### Key Entities

- **Credential**: the issued digital identity. Carries holder name, masked document reference (last
  four digits), issuing country, creation date, validity, and status. Its state is owned by the
  backend; the app holds only the display subset and the token.
- **Credential status**: active, or one of the non-active states — expired, revoked, suspended,
  withdrawn. What the passenger sees is this value, never an inference.
- **Credential validity**: the window the backend declares for the credential. Displayed, never
  computed.
- **Trip association**: whether a flight is linked to this credential, which determines what the
  primary route leads to.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of credentials displayed as active correspond to a backend-confirmed active
  credential, verified by audit. A single exception is a critical finding.
- **SC-002**: Zero coverage or capability claims appear on this screen, verified at each release.
- **SC-003**: ≥90% of passengers who reach this screen take an onward route (either action, or
  the back gesture to trips) rather than leaving the app from here.
- **SC-004**: ≥70% of passengers who enroll use the credential on their next flight, matching the
  product's recurrence objective — this screen is where that expectation is set.
- **SC-005**: Zero full document numbers appear on this screen, verified by review.
- **SC-006**: 100% of re-entries into this screen after it has been shown land on the persistent
  credential surface instead, verified by test.
- **SC-007**: In usability testing, ≥90% of participants can state, after seeing this screen, that
  their credential is active, until when it is valid, and what to do next.
- **SC-008**: Enrollment duration at p90 and abandonment rate are computable from the event stream
  without additional instrumentation.

## Assumptions

- The credential is issued by the backend on a successful verification; this screen reports that
  outcome and does not participate in the decision.
- The masked document number shows the last four digits and the issuing country, which is the
  display subset the identity record is permitted to retain (constitution Principle I).
- "Ver mi identidad" leads to a persistent credential surface rather than re-entering enrollment.
- No portrait is shown (Clarifications). The capture frames were discarded at screen 006 and
  nothing replaces them; the card's portrait position is a generic icon.
- Whether this screen has been shown for the current credential is tracked without adding to the
  persisted state the constitution allows; planning confirms how (for example, from the
  credential's own issuance record).
- Where the credential is accepted is communicated on other surfaces, not here. Removing the tiles
  leaves this screen without that information, so SC-007 measures what it does carry.
- The validity window comes with the credential from the backend, as the existing credential
  status check already carries a "valid until" date.
- Until the trips surface (012) exists, the primary route's destination is the existing trips
  placeholder; FR-008 is not relaxable, so that placeholder must carry the "how a trip gets
  associated" explanation in the meantime.
- Copy is in Spanish (Colombia), matching the reference and specifications 001–006.

## Dependencies

- Backend credential issuance, including the status model and the validity period.
- The verification progress screen (007) as the origin. Until it exists, the current
  verification-progress placeholder requests issuance and hands the confirmed credential to this
  screen; 07 later replaces it under the same hand-off.
- The trips surface (012) as the primary destination, including its empty variant.
- The persistent credential surface, as the secondary destination and the landing point for any
  re-entry by link or restored navigation. It owns credential-state refresh and the
  "unrefreshed" marking. A placeholder stands in until it is specified.
- The credential-validity policy that specification 004 left to the backend.
- Specification 002's consent withdrawal, for FR-011.
- The separate outcome screen for a non-active or incomplete issuance (FR-010), to be specified in
  its own upcoming spec.

## Out of Scope

- The verification process and its progress display (screen 07). The only exception is the
  placeholder's issuance request and hand-off to this screen (Clarifications).
- The trips surface and the dynamic pass.
- Credential renewal, re-enrollment, and recovery on a new device.
- The consent withdrawal surface, specified with 002.
- The persistent credential surface, including refreshing state on later visits.
- Showing where the credential is accepted.
- Any portrait or face image on the credential.
- The outcome screen for a non-active or incomplete issuance.
