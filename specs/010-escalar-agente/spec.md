# Feature Specification: Escalation to a Human Agent (10 Escalar agente)

**Feature Branch**: `010-escalar-agente`

**Created**: 2026-09-23

**Status**: Draft

**Input**: User description: "Screen 10 Escalar agente — offered when automatic verification is
exhausted or declined. Presents the available human channels with their availability and hands the
passenger off to one."

**Note on sequence**: this screen replaces the agent-escalation placeholder that 009 already routes
to. It is reached two ways: by the passenger's choice from the first failure on 009, and from 009's
limit state. It also owns the agent-side reset of an exhausted attempt limit, which 009's
clarifications assigned here.

## Delivery Mode: Happy Path First

Same section as specifications 005 through 009; it governs build order here too (constitution
Principle III, "Happy-Path Development Mode").

The current priority is a working end-to-end flow. Development runs in happy-path mode: the flow
must be walkable from welcome to pass without the edge-case handling, gating, and hardening
described below. Nothing here removes a requirement — each relaxation defers one, by identifier.

**Relaxable during happy-path mode**, each recorded as a deferred requirement:

- Live availability and wait-time data; static values may stand in while the queue integration does
  not exist.
- Location awareness for the in-person option.
- Offline and connectivity handling.
- Analytics completeness — events that exist must already carry no personal data.
- The agent channels themselves, served by fakes. A stub chat that echoes is enough to walk the flow.

**Deferred requirements, by identifier** (the constitution requires this list; a deferral not
written here is not a deferral):

| Requirement | What is deferred | What still holds in happy-path mode |
|---|---|---|
| FR-004, FR-006, SC-004, SC-005 | Live availability and wait data | Static stand-in values come from the fake channel source, never from copy in the screen; no wait is shown unless the source supplies one |
| FR-007 (relevance) | Telling the passenger whether the in-person location is near them | The location is always named |
| FR-009, FR-015 | A real handoff carrying the enrollment context | The stub receives the same context shape the real channel will |
| FR-017, FR-018 | The complete event set and resolution-time measurement | Any event that is emitted carries no personal data |
| Edge case: offline | Detecting connectivity before a handoff | — |
| Agent channels | A stub chat that echoes, and a fake agent outcome | **The outcome still arrives as a backend-issued credential under a recorded manual-review decision, or as a decline, or as a reset** — never as a client-side flag (FR-011) |

**Specific to this screen**: the handoff may terminate in a stub. **What may not be stubbed, even
once, is the shape of the outcome** — an agent's decision reaches the app as a backend-issued
credential under a recorded manual-review decision, never as a client-side "agent approved" flag.
See FR-011. This is the single most likely path to a false accept in the entire product, and a
development shortcut here becomes the production design.

**Not relaxable, in any mode**:

- No real personal data; synthetic identities only.
- No persistence of images or biometric samples, including anything exchanged with an agent.
- No personal data in logs, events, or crash reports.
- **No credential issued on the app's own authority following an escalation** (FR-011).
- A forward action exists in every state, including when every channel is closed (FR-008).
- Every relaxation lives behind a build flag that cannot be enabled in a release build.

**Exit from happy-path mode**: every deferred requirement is implemented or explicitly accepted as
out of scope, in writing, before any build reaches a real passenger — the airport pilot
integration (constitution Principle III).

## UI Reference

The authoritative visual reference is [`assets/10-escalar-agente.png`](./assets/10-escalar-agente.png),
copied from `C:\Users\Usuario\Pictures\Screenshots\Captura de pantalla 2026-09-23 113556.png`. It is
the source of truth for layout, content order, and styling, except where the conflicts below
override it.

| Element | Content in the reference |
|---|---|
| Top bar | "Ayuda" (right). No back control. |
| Status icon | Red circle with an exclamation mark, on a rose tile |
| Title | "Necesitamos verificarte en persona" |
| Body | "Agotaste los intentos de verificación automática. Un agente puede ayudarte a completar el proceso." |
| Option 1 (selected) | "Chat con un agente" · badge "Disponible ahora" · "Espera estimada: 2–5 minutos" |
| Option 2 | "Módulo AeroPass en el aeropuerto" · "Lun–Vie 6:00am–10:00pm · Sáb–Dom 7:00am–9:00pm" |
| Primary action | "Iniciar chat" |
| Secondary action | "Volver al inicio" |

Behaviors the reference establishes: escalation is a choice between channels rather than a single
queue, each channel states its availability, one is preselected, and the primary action follows the
selection.

### Conflicts raised by the reference

- **CONFLICT-001 — the title contradicts the recommended option.** "Necesitamos verificarte en
  persona" announces an in-person requirement, while the preselected and most available option is
  a chat. A passenger reading the title will conclude they must travel to the airport when they may
  not need to. **Resolved** (Clarifications): only the airport module can verify. The title
  "Necesitamos verificarte en persona" is therefore accurate and stays; the module is preselected;
  the chat is offered for questions and directions only, and says so (FR-003, FR-021).
- **CONFLICT-002 — red signals blame at the moment of help.** **Resolved from 009's precedent**:
  the screen uses the same amber treatment as the retry screen, never red (FR-002). Escalation is
  the route to resolution, not a harder error.
- **CONFLICT-003 — availability is asserted, not observed.** **Resolved in the requirements**:
  availability and wait come from the channel's state, or are absent (FR-004–FR-006). In
  happy-path mode a fake source stands in, but the screen still renders only what the source says.
- **CONFLICT-004 — which airport?** **Resolved in the requirements**: the in-person option names
  the airport and where the module is inside it, taken from operational data rather than copy
  (FR-007).
- **CONFLICT-005 — "Agotaste los intentos" is false for half the arrivals.** Found while writing
  this spec: 009 offers "Hablar con un agente" from the first failure, not only at the limit. A
  passenger who chose help after one failure has not exhausted anything. **Resolved**: the body
  depends on how the passenger arrived — at the limit, it says automatic verification could not
  confirm them; by choice, it says an agent can help them finish without saying they ran out of
  attempts (FR-001).

## Clarifications

### Session 2026-09-23

- Q: Can a remote agent complete verification, or is the airport module required? → A: **Only the
  airport module can verify.** Every agent decision — approving with a manual-review credential,
  declining, or resetting an exhausted attempt limit — is made at the module. The chat is
  informational: it answers questions and tells the passenger how to reach the module, and states
  that it cannot complete verification. The title stays "Necesitamos verificarte en persona" and the
  module is preselected (CONFLICT-001).
- Q: Does leaving the screen abandon the escalation? → A: **No. It stays open for 24 hours.** A
  passenger who leaves via "Volver al inicio", or closes the app, returns to the same open
  escalation, and the module can still find their case, until 24 hours after it opened. After that
  it closes; the enrollment session, identity record and attempt count still survive, and a new
  escalation can be opened.
- Q: Does the chat accept attachments? → A: **No.** The chat blocks every attachment and explains
  that identity documents are never sent through chat; they are checked in person at the module.
  The transcript therefore never holds identity data (FR-014).
- Q: How does the module agent find the passenger's case? → A: **By document number.** The agent
  types the number from the passenger's physical document into the agent tool, which finds the open
  escalation for it. The app shows no case code. Because this makes the agent tool a lookup by
  personal data, it is limited to open escalations and every lookup is recorded (FR-023).
- Q: How does the app learn the outcome after the module agent decides? → A: **By checking the
  escalation's status with the backend** every few seconds while this screen is open, and once at
  launch while an escalation is open. A credential goes to 008 through the existing hand-off, a
  decline to the decline message on this screen, and a reset to the exhausted capture (FR-024).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A passenger reaches a person and completes enrollment (Priority: P1)

Automatic verification did not work for this passenger. Rather than being told to give up, they are
offered a human: the AeroPass module at the airport, where an agent completes the verification in
person, and a chat for questions before they go. They go to the module, and the enrollment they
started is completed there rather than restarted.

**Why this priority**: this is the screen that makes the product's central promise survivable —
that the app is never the reason someone cannot travel. It is also the release valve for the
false-rejection rate the product tolerates; without it, every rejected passenger is simply lost.

**Independent Test**: exhaust the attempts, reach this screen, verify the module is preselected and
named, and that a fake module decision returns the passenger to a completed enrollment rather than
to the beginning; select the chat and verify it offers help without any verification outcome.

**Acceptance Scenarios**:

1. **Given** a passenger who reached this screen from 009's limit state, **When** this screen
   opens, **Then** it explains that automatic verification could not confirm them and presents
   every channel currently capable of helping.
2. **Given** a passenger who chose help from 009 before reaching the limit, **When** this screen
   opens, **Then** the body does not say they ran out of attempts.
3. **Given** the channels are displayed, **When** the passenger reads each one, **Then** its
   availability and what it requires of them are stated accurately.
4. **Given** the passenger reaches the module, **When** the agent types the document number from
   their physical document, **Then** the agent finds their open escalation, with the enrollment
   context, so they do not repeat what they have already done.
5. **Given** a module agent completes the verification, **When** the outcome returns, **Then** the
   passenger's credential is issued by the backend and they arrive at the activated-credential
   state (008) without re-enrolling.
6. **Given** a module agent resets an exhausted attempt limit, **When** the outcome returns,
   **Then** the passenger is taken back to the capture that was exhausted with a fresh count.
7. **Given** the passenger selects the chat, **When** they read it, **Then** it states that the chat
   answers questions and cannot complete verification, and no chat interaction produces an
   outcome.
8. **Given** the passenger is on this screen, **When** they read the title and the options,
   **Then** the module is preselected, consistent with the title.

---

### User Story 2 - Availability shown is availability that exists (Priority: P1)

A passenger at 3am, or during a queue surge, or on a public holiday, must not be told an agent is
available now. A promise of a two-to-five-minute wait that turns into forty is worse than no
promise, because the passenger made a decision on it — often a decision about whether to leave for
the airport.

**Why this priority**: it shares P1 because a channel list that lies is worse than a channel list
that is absent, and because this screen is reached by passengers who are frequently already at an
airport with a departure time. It also determines whether the escalation resolution targets mean
anything.

**Independent Test**: with the queue closed, verify the chat option is presented as unavailable and
cannot be selected; with the queue congested, verify the stated wait reflects the real one or is
withheld rather than guessed.

**Acceptance Scenarios**:

1. **Given** a channel that is not currently available, **When** this screen opens, **Then** it is
   shown as unavailable with when it will be available, and it cannot be selected as if it were
   open.
2. **Given** live wait data is unavailable, **When** the chat option is displayed, **Then** no wait
   time is stated rather than a fabricated one.
3. **Given** no channel is available at all, **When** this screen opens, **Then** the passenger is
   told plainly what to do now — including that the conventional airport process remains available
   — rather than being shown options that lead nowhere.
4. **Given** the in-person option is displayed, **When** the passenger reads it, **Then** it names
   the airport and where the module is.
5. **Given** the preselected channel becomes unavailable while the passenger is on this screen,
   **When** its state changes, **Then** the selection moves to an available channel or clears, and
   the primary action follows it.

---

### User Story 3 - An agent's decision is auditable and cannot manufacture a false accept (Priority: P1)

An agent resolves the case. Whatever they decide, the decision is attributable to them, recorded
with its basis, and results in a credential issued by the backend under a manual-review decision —
not in the app deciding that verification succeeded because a conversation ended well.

**Why this priority**: it shares P1 because this is the one path in the product where a human can
override a biometric rejection, which makes it the most likely route to a false accept. The
product's commitment on that number is zero, and it is enforced here or nowhere.

**Independent Test**: complete an agent-assisted enrollment and verify the resulting credential
carries a manual-review decision identifying the agent, the basis, and the time; then verify no
client-side path can produce an active credential without one.

**Acceptance Scenarios**:

1. **Given** an agent approves an enrollment, **When** the credential is issued, **Then** the
   issuance records that it was a manual review, who decided it, on what basis, and when.
2. **Given** an agent-assisted flow, **When** the app receives the outcome, **Then** it displays a
   credential only because the backend issued one, never because the escalation concluded.
3. **Given** an agent declines to verify, **When** the outcome returns, **Then** the passenger is
   told plainly, and the conventional airport process is stated as available.
4. **Given** any agent-assisted outcome, **When** it is recorded, **Then** it is distinguishable in
   the audit trail from an automatic verification.
5. **Given** a chat that ends, whatever was said in it, **When** the passenger returns to the app,
   **Then** no credential is shown and the passenger is back on this screen or 009, never at 008.
6. **Given** the passenger relaunches the app while an escalation is open, **When** the app starts,
   **Then** it checks the escalation's status and shows its outcome, or this screen if it is still
   open.

---

### Edge Cases

- The passenger is not at the airport when the in-person option is offered, which is the common case
  for enrollment at home. The module is still the only way to complete verification; the screen
  names it, its hours and how to get there, and the escalation stays open for 24 hours so they can
  go later.
- The passenger is at a different airport from the one with a module. The named location makes this
  visible; location awareness (FR-007's relevance) is deferred.
- The chat queue closes while the passenger is waiting in it. The passenger is told, and returns to
  this screen with the chat shown as unavailable.
- The passenger leaves via "Volver al inicio". The escalation stays open for 24 hours (Clarifications);
  returning within that time shows the same open escalation. The enrollment session, the confirmed
  identity record, and the attempt count survive either way.
- The passenger returns after the 24 hours. The escalation has closed; the screen offers a new one,
  with the enrollment still intact.
- The passenger tries to send a photo of their document into the chat. The chat blocks every
  attachment and explains that documents are checked in person at the module, never through chat
  (Clarifications, FR-014).
- The agent needs to see something the app already discarded. Capture frames are gone by this point
  by design; the escalation cannot assume they are retrievable, and nothing on this screen
  re-captures them.
- The passenger has a flight in twenty minutes and cannot reach the module in time. The
  conventional airport process is always stated alongside the channels, so the passenger can choose
  it without asking.
- A screen reader user selects a channel. The selection state, availability, and wait are all
  announced; the option cards are reachable as a single choice group.
- Both options are unavailable and the passenger has already been told the app cannot verify them.
  This is the true terminal state of the enrollment flow and it still offers a forward action: the
  conventional airport process, and when each channel next opens.
- The passenger presses back. There is no back control; the system back gesture returns to 009 when
  this screen was pushed from it, since 009 is still underneath.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The screen MUST explain why the passenger is here, in terms that attribute the outcome
  to the verification not succeeding rather than to the passenger failing. The body MUST depend on
  how the passenger arrived: from 009's limit state, or by choice before the limit (CONFLICT-005).
- **FR-002**: The visual treatment MUST NOT signal greater severity than the retry screen: the same
  amber treatment as 009, never red.
- **FR-003**: The title and body MUST NOT assert a requirement that the offered channels contradict.
  Since only the module can verify, the title states that verification is in person, and the module
  is the preselected channel whenever it is available.
- **FR-004**: Each channel MUST state its current availability, and availability MUST be derived from
  the channel's actual state rather than presented as static text.
- **FR-005**: A channel that is unavailable MUST be shown as unavailable, with when it next opens, and
  MUST NOT be selectable as though it were open.
- **FR-006**: An estimated wait MUST be shown only when live data supports it. Where it does not, no
  estimate MUST be shown.
- **FR-007**: The in-person channel MUST name the airport and where the module is within it, from
  operational data rather than copy, and MUST make clear whether it is relevant to where the
  passenger currently is. *(Relevance deferred in happy-path mode; naming the location is not.)*
- **FR-008**: When no channel is available, the screen MUST tell the passenger what to do now and MUST
  state that the conventional airport process remains available. The conventional process MUST be
  stated in every state, not only this one.
- **FR-009**: The handoff MUST carry the enrollment context, so the passenger does not repeat
  information already given.
- **FR-010**: The enrollment session, the confirmed identity record, and the attempt count MUST survive
  the escalation and any departure from this screen, so the passenger resumes rather than restarts.
- **FR-011**: An agent-assisted verification MUST result in a credential issued by the backend under a
  recorded manual-review decision. The app MUST NOT treat the conclusion of an escalation as
  verification, in any build or mode. The only outcomes the app accepts from an escalation are: a
  backend-issued credential, a decline, or a reset of an exhausted attempt limit — and each is
  decided at the airport module, never through the chat.
- **FR-012**: Every agent decision MUST be recorded with the deciding agent's identity, the basis,
  and the time, and MUST be distinguishable in the audit trail from an automatic verification.
- **FR-013**: An agent declining to verify MUST be communicated plainly, with the conventional airport
  process stated as available.
- **FR-014**: The escalation channel MUST NOT become a store of identity documents or biometric data.
  The chat MUST block every attachment and explain that documents are checked in person at the
  module.
- **FR-015**: The agent MUST receive only the data required to resolve the case, consistent with the
  data-minimization rules governing the rest of the flow.
- **FR-016**: Channel selection MUST be announced to assistive technology as a choice group, including
  each option's availability and selection state.
- **FR-017**: The screen MUST emit events for entry (with how the passenger arrived), channels offered
  and their availability, channel selected, handoff started, outcome, and abandonment — carrying no
  personal data.
- **FR-018**: Time from arriving at this screen to resolution MUST be measurable, so escalation
  performance can be reported against the product's reliability targets.
- **FR-019**: An agent reset of an exhausted attempt limit MUST be a backend decision recorded like
  any other agent decision (FR-012), and MUST return the passenger to the capture that was
  exhausted with a fresh count. This is the reset path 009 depends on.
- **FR-020**: The primary action MUST follow the selected channel ("Cómo llegar al módulo" for the
  module, "Iniciar chat" for the chat), and MUST be disabled when no available channel is selected.
- **FR-021**: The chat option MUST state that it answers questions and cannot complete
  verification. No chat interaction MUST produce, or be treated as, an escalation outcome.
- **FR-022**: An escalation MUST stay open for 24 hours from when it was opened, across the passenger
  leaving the screen or closing the app. Within that window the passenger returns to the same open
  escalation, and the module can find the case; after it, the escalation closes and a new one can be
  opened, with the enrollment intact.
- **FR-023**: At the module, the agent MUST find the passenger's open escalation by the document number
  on the physical document. The lookup MUST return only open escalations, MUST be restricted to
  authorized module agents, and every lookup MUST be recorded with the agent and the time. The app
  MUST NOT display a case code or the document number for this purpose.
- **FR-024**: While this screen is open, the app MUST check the escalation's status with the backend
  on a short fixed interval, and MUST check once at launch while an escalation is open. It MUST
  route a backend-issued credential to 008 through the existing hand-off, a decline to the decline
  message on this screen, and a reset to the capture that was exhausted. The backend status is the
  only source of an outcome (FR-011).

### Key Entities

- **Escalation case**: the enrollment handed to a human, carrying its context, how the passenger
  arrived, when it opened, its state, and its outcome. Open for 24 hours from opening.
- **Agent channel**: one route to a person — remote or in person — with its availability, its
  operating hours, its location where applicable, and its current wait when known.
- **Escalation outcome**: one of a backend-issued credential under a manual-review decision, a
  decline, or an attempt-limit reset, each decided at the module. Nothing else counts as an
  outcome, and nothing in the chat produces one.
- **Manual-review decision**: an agent's determination, attributable to them, with its basis and
  time. The only thing that can produce a credential on this path.
- **Escalation context**: the subset of enrollment data an agent receives, bounded by the same
  minimization rules as the rest of the product.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: ≥70% of passengers who reach this screen complete enrollment through a human channel
  rather than abandoning.
- **SC-002**: Zero credentials are issued on this path without a recorded manual-review decision
  identifying the deciding agent. A single exception is a critical finding.
- **SC-003**: 100% of agent-assisted enrollments are distinguishable from automatic ones in the audit
  trail.
- **SC-004**: Stated availability matches actual availability in ≥99% of displays, sampled against
  channel state.
- **SC-005**: Where a wait is stated, the actual wait is within the stated range in ≥90% of cases.
- **SC-006**: Zero identity documents or biometric samples are retained in escalation transcripts,
  verified by audit.
- **SC-007**: Zero passengers reach a state on this screen with no forward action, including when all
  channels are closed.
- **SC-008**: 100% of escalated passengers resume their enrollment rather than restarting it.
- **SC-009**: Escalation resolution time is measurable end to end and reported against the product's
  reliability targets.
- **SC-010**: Zero passengers who chose help before the limit are told they ran out of attempts,
  verified by review of both body variants.
- **SC-011**: Zero escalation outcomes originate from the chat, verified by test and audit.
- **SC-012**: 100% of passengers who return within 24 hours find their escalation still open.

## Assumptions

- Escalation is reached from the retry screen (009), either by the passenger's choice from the first
  failure or from its limit state; 009 pushes this screen, so it remains underneath.
- Only the airport module can verify (Clarifications). A passenger enrolling at home must travel to
  the module to complete an escalated enrollment; the chat helps them prepare, not finish.
- The airport module exists at the contracted airport and is staffed during the hours displayed. Its
  hours and location are operational data, not copy.
- Enrollment captures have already been discarded, so an agent cannot review the original images.
  What an agent can review is a question for the escalation workflow, not for this screen.
- An agent-approved credential reaches the app through the same backend issuance and hand-off that
  008 uses for an automatic verification, so 008 needs no second path.
- Agent staffing and its cost sit within the outsourced-services budget rather than being unbounded —
  which is why the self-service rate, and not this screen, is the primary lever on escalation
  volume.
- Copy is in Spanish (Colombia), matching the reference and specifications 001–009.

## Dependencies

- The retry screen (009) as the origin, carrying how the passenger arrived.
- A live availability and queue-state source for each channel, for FR-004 through FR-006.
- An agent workflow capable of recording an attributable manual-review decision and an attempt
  reset, for FR-011, FR-012 and FR-019.
- Backend credential issuance under manual review.
- The activated-credential state (008) as the success destination.
- The backend-owned attempt counter 009 requires, which an agent reset writes to.
- An escalation case the backend keeps open for 24 hours, for FR-022, that the agent tool can find by
  document number with restricted, recorded lookups, for FR-023.

## Out of Scope

- The agent-side tooling and the review procedure itself.
- The chat transport and its implementation.
- Staffing, rostering, and the operating hours of the airport module.
- Fraud handling for cases where an agent identifies a deliberate attempt.
