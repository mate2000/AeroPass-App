# Feature Specification: Verification Retry (09 Reintento)

**Feature Branch**: `009-reintento`

**Created**: 2026-09-23

**Status**: Draft

**Input**: User description: "Screen 09 Reintento — shown when verification could not confirm the
passenger. Explains what happened, shows the attempt count, gives targeted advice, and offers a
retry or a human agent."

**Note on sequence**: this screen replaces the retry-guidance placeholder that 003, 006 and 007
already route to. Its entry points are therefore fixed by those specifications (see Assumptions):
a selfie that failed verification (007), and any capture step whose attempt limit was just reached
(003, 006, 007).

## Delivery Mode: Happy Path First

Same section as specifications 005 through 008; it governs build order here too (constitution
Principle III, "Happy-Path Development Mode").

The current priority is a working end-to-end flow. Development runs in happy-path mode: the flow
must be walkable from welcome to pass without the edge-case handling, gating, and hardening
described below. Nothing here removes a requirement — each relaxation defers one, by identifier.

**Relaxable during happy-path mode**, each recorded as a deferred requirement:

- Tailoring the advice to the specific failure; a single generic tip set may stand in.
- Offline and connectivity handling.
- Timing budgets.
- Analytics completeness — events that exist must already carry no personal data.
- Backend integrations, served by fakes implementing the real contract.

**Deferred requirements, by identifier** (the constitution requires this list; a deferral not
written here is not a deferral):

| Requirement | What is deferred | What still holds in happy-path mode |
|---|---|---|
| FR-004 (tailoring) | Advice specific to the processor's reason for the failure | Advice always matches the capture that failed; no document advice after a selfie failure |
| FR-006, SC-004 | The backend-owned attempt counter | The local counter already used by 003 and 006 stands in. **Not deferrable past the first real integration** |
| FR-012, SC-007 | Carrying enrollment context into a real agent handoff (screen 010) | The agent route exists from the first failure and preserves the session |
| FR-015 | Abandonment event and complete event set | Any event that is emitted carries no personal data and no detection detail |
| Edge case: offline | Detecting connectivity before a retry | — |
| Backend integration | Served by a fake implementing the real contract | — |

**Specific to this screen**: the attempt counter may be held locally against a fake backend so the
screen is demonstrable. **What may not be deferred past the first real integration is where the
count lives** — see FR-006. A counter the client owns is a counter a reinstall resets, and
rebuilding that later means rebuilding the retry policy with it.

**Not relaxable, in any mode**:

- No real personal data; synthetic identities only.
- No persistence of images or biometric samples — nothing on this screen reintroduces them.
- No personal data in logs, events, or crash reports.
- **No message that names an attack-detection signal, in any build** (FR-003).
- A route to a person is always available (FR-009).
- Every relaxation lives behind a build flag that cannot be enabled in a release build.

**Exit from happy-path mode**: every deferred requirement is implemented or explicitly accepted as
out of scope, in writing, before any build reaches a real passenger — the airport pilot
integration (constitution Principle III).

## UI Reference

The authoritative visual reference is [`assets/09-reintento.png`](./assets/09-reintento.png),
copied from `C:\Users\Usuario\Pictures\Screenshots\Captura de pantalla 2026-09-23 103906.png`. It is
the source of truth for layout, content order, and styling, except where the conflicts below
override its copy.

| Element | Content in the reference |
|---|---|
| Top bar | "Ayuda" (right). No back control. |
| Status icon | Amber warning triangle on an amber tile — deliberately not red |
| Title | "No pudimos confirmar que eres tú" |
| Body | "La foto de tu selfie no coincide lo suficiente con la de tu documento. ¡Sin problema, inténtalo otra vez!" |
| Attempt chip | "Intento 1 de 3" |
| Advice card | "Consejos para el siguiente intento:" |
| Tip 1 | "Busca un lugar con mejor iluminación, de preferencia natural." |
| Tip 2 | "Quita gafas, gorras, audífonos u otros accesorios." |
| Tip 3 | "Sostén el documento sin reflejos ni dedos sobre la foto." |
| Primary action | "Intentar de nuevo" |
| Secondary action | "Hablar con un agente" |

Behaviors the reference establishes: failure is presented as recoverable rather than as an error,
the passenger is told how many attempts remain, advice is offered before the retry, and a human
route exists alongside the retry from the first failure rather than only at the end.

### Conflicts raised by the reference

- **CONFLICT-001 — the message states the matching result.** "No coincide lo suficiente con la de
  tu documento" tells the passenger what the comparison concluded, and "lo suficiente" implies a
  threshold that can be approached by iteration. **Resolved from precedent**: specification 007
  already routes face mismatch, liveness rejection and attack detection to this screen, identically
  (007 FR-012, outcome-routing rows R7–R9). The screen is therefore shared, and its wording must be
  safe for all three. The body becomes generic, for example "No logramos verificar tu identidad con
  esta selfie. ¡Sin problema, inténtalo otra vez!", naming no comparison and no threshold (FR-003).
- **CONFLICT-002 — the tips do not match the failure.** **Resolved from precedent**: "Intentar de
  nuevo" re-runs the **selfie only**. Specification 007 sends a document rejection back to
  document capture directly, not here; a document failure reaches this screen only once its limit
  is reached, when no retry is offered at all. The document tip is removed from the selfie advice
  (FR-004).
- **CONFLICT-003 — "Quita gafas, gorras, audífonos u otros accesorios" repeats screen 005's
  problem.** **Resolved with 005's wording**: the tip states what the capture needs, "Asegúrate de
  que tu rostro esté descubierto y visible por completo", matching 005's "Rostro descubierto y
  visible por completo". It never asks a passenger to remove glasses or a religious head covering
  (FR-005).
- **CONFLICT-004 — the attempt count is disclosed.** "Intento 1 de 3" is honest and reduces
  abandonment, which is the right trade for legitimate passengers, but it also tells someone
  attempting a presentation attack exactly how much room they have. **Resolved** (Clarifications):
  the screen never shows an attempt count. The attempt chip is removed; the limit is explained only
  when it is reached (FR-008).
- **CONFLICT-005 — the shipped counters reset themselves at the limit.** Found while writing this
  spec: when document capture (003), the liveness capture (006) and verification (007) reach the
  limit, each resets its own counter before routing here. As built, the limit is never "in force":
  the next attempt starts again at one, so User Story 3 cannot pass. **Resolved** with the retry
  policy (Clarifications): both counters reset only on a verification match at 007, or when an
  agent resets an exhausted limit. Neither reaching the limit nor passing a capture step resets
  them (FR-017). Found alongside: 003 and 006 also reset their counter on every accepted capture,
  which happens on every retry, so verification rejections could never add up to the limit.

## Clarifications

### Session 2026-09-23

- Q: Should the screen show the attempt count, and in what form? → A: **Never.** Revised by the
  user from "only on the last attempt": no attempt count or remaining-attempts chip appears in any
  state. When the limit is reached, the screen explains the limit instead (CONFLICT-004, FR-008).
- Q: Does an exhausted limit reset after a period, or only through an agent? → A: **Only through an
  agent.** The limit stays in force until an agent resets it after helping the passenger; there is
  no time-based reset. The limit state says "Habla con un agente para volver a intentarlo" and that
  the regular document check at the checkpoint remains available (US3, FR-013, FR-017).
- Q: What counts as the "success" that resets an attempt counter? → A: **Only a verification match
  at 007**, which resets both the document and the selfie counter. Passing document capture (003)
  or the liveness check (006) no longer resets anything, because both happen on every retry and
  would wipe the count the limit depends on. An agent can still reset an exhausted limit.
- Q: Does "Intentar de nuevo" go straight to the selfie camera or through the selfie instructions
  first? → A: **Straight to the selfie camera (006).** The advice on this screen replaces screen
  005's instructions for a retry.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A legitimate passenger retries and succeeds (Priority: P1)

The verification did not confirm the passenger — the light was poor, something obscured their
face, they moved. The screen tells them plainly that it did not work, that it is not a problem, and
what to change. They read short tips, tap to retry, and this time it works.

**Why this priority**: the product's reliability commitment allows a false-rejection rate of up to
1% of validations, which on the target volume is hundreds of passengers a month per airport. Every
one of them arrives here, and whether they recover or abandon is decided by this screen. It is also
the screen standing between a recoverable failure and an agent handoff, which is the self-service
rate the business case is priced on.

**Independent Test**: force a non-matching verification, verify the screen states what happened and
what to change, retry, and verify the flow re-enters the selfie capture with the attempt count
already incremented and the enrollment session intact.

**Acceptance Scenarios**:

1. **Given** a verification that did not confirm the passenger, **When** this screen opens,
   **Then** it states that confirmation failed and frames it as recoverable, and shows no attempt
   count.
2. **Given** the screen is displayed, **When** the passenger reads the advice, **Then** each tip
   addresses the selfie capture, and none addresses the document.
3. **Given** the screen is displayed, **When** the passenger retries, **Then** the flow goes
   straight to the selfie camera (006), skipping the selfie instructions (005), with the enrollment
   session and the confirmed identity record intact.
4. **Given** a retry succeeds, **When** verification confirms, **Then** enrollment continues to the
   credential as it would have on a first attempt, with no residue of the failed attempts visible
   to the passenger.
5. **Given** any failure presentation, **When** it is shown, **Then** it is conveyed by text and
   iconography rather than by color alone, and does not use the visual language of a hard error.
6. **Given** the failure was a face mismatch, a liveness rejection or a detected attack, **When**
   this screen opens, **Then** all three show exactly the same title, body, advice and actions.
7. **Given** exactly one attempt remains before the limit, **When** this screen opens, **Then** it
   looks exactly as it does after the first failure, with no count or warning chip.

---

### User Story 2 - A passenger who will not succeed reaches a human before running out of patience (Priority: P1)

Some passengers will not pass, whatever the lighting: a facial difference, an old document photo, a
condition that affects how they hold still. For them the retry loop is a slow way to arrive at the
same place, and the agent route must be available from the first failure — not only after three.

**Why this priority**: it shares P1 because a retry screen without a human exit is a dead end for
the passengers most likely to need help, and because the whole rejection block exists to make sure
the app is never the reason someone cannot travel. The reference already places the agent route on
the first failure, which is the right call.

**Independent Test**: from the first failure, take the agent route and verify it leads to the
escalation path with the session preserved; then exhaust the attempt limit and verify the passenger
is shown the limit state, with the agent route and no fourth retry.

**Acceptance Scenarios**:

1. **Given** the first failure, **When** the passenger chooses to speak with an agent, **Then** the
   agent path opens with the enrollment session preserved.
2. **Given** the attempt limit is reached, **When** this screen opens, **Then** the retry action is
   not offered, the screen explains why, states how or when the passenger may try again, and
   offers the agent route.
3. **Given** the limit was reached on document capture, **When** this screen opens, **Then** its
   title and explanation refer to the document, not the selfie.
4. **Given** the passenger is routed to an agent, **When** they arrive, **Then** the enrollment
   session is preserved so it can be completed rather than restarted.
5. **Given** an agent has reset an exhausted limit, **When** the passenger retries, **Then** the
   capture starts with a fresh count.
6. **Given** any state of this screen, **When** the passenger looks for a way forward, **Then** at
   least one route leads to a person.

---

### User Story 3 - The retry policy cannot be reset by the passenger (Priority: P2)

Attempt limits exist to bound both cost and abuse. Each verification is a paid validation, and a
limit that resets when someone reinstalls the app or clears its data bounds neither.

**Why this priority**: it protects the unit economics and the zero-false-accept objective at once,
and it is cheap to get right at the start and awkward to retrofit. It ranks below the
passenger-facing stories because it is invisible when it works.

**Independent Test**: exhaust the attempts, reinstall the app or clear its data, and verify the
limit is still in force.

**Acceptance Scenarios**:

1. **Given** an exhausted attempt limit, **When** the app is reinstalled or its data cleared,
   **Then** the limit remains in force.
2. **Given** an attempt that failed for a service reason rather than the passenger, **When** the
   count is evaluated, **Then** that attempt is not counted against them.
3. **Given** an exhausted attempt limit, **When** the passenger tries the same capture again,
   **Then** they reach the limit state again rather than a fresh count (CONFLICT-005).
4. **Given** the limit is in force, **When** the passenger returns later, **Then** they are told
   they can try again after speaking with an agent, and that the regular document check at the
   checkpoint remains available.
5. **Given** a passenger whose selfie was rejected by verification, **When** they retry and pass
   the liveness capture again, **Then** the selfie counter keeps its count; only a verification
   match resets it.

---

### Edge Cases

- The failure was the document, not the selfie. This screen then appears only in its limit state,
  with document wording (US2 scenario 3); a document rejection below the limit goes straight back
  to document capture, per 007.
- The passenger abandons here and returns days later. The attempt count and the enrollment session
  must still be coherent; with the counter on the backend (FR-006), the count is whatever the
  backend holds.
- Connectivity is lost on this screen. Retry cannot proceed; the passenger is told, and no attempt
  is consumed. (Deferred in happy-path mode.)
- The passenger reaches the limit at an airport, minutes before a flight. The limit state states
  plainly that they can use the regular document check at the checkpoint, alongside the agent
  route — not only a chat queue.
- A screen reader user encounters the screen. The failure statement and the tips are all
  announced, and in the limit state, the explanation of the limit; the amber icon carries no information of its own.
- The passenger retries immediately, repeatedly. No minimum interval is enforced: each selfie
  attempt already takes the time of a full capture, and the advice sits between attempts (see
  Assumptions).
- The same passenger enrolls on a different device after exhausting attempts on the first. With
  the counter on the backend and keyed to the enrollment, the limit follows the enrollment, not the
  device.
- The passenger presses back. There is no back control; the system back gesture does nothing, so
  the passenger does not return into a finished verification.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The screen MUST state that verification did not confirm the passenger, in language
  that presents the outcome as recoverable rather than as an accusation or a hard error.
- **FR-002**: The presentation MUST NOT use the visual language of a terminal error (no red error
  styling), and MUST convey its state through text and iconography rather than color alone.
- **FR-003**: The message MUST NOT name an attack-detection signal, and MUST NOT describe the
  comparison in terms that imply an approachable threshold, in any build or mode. Face mismatch,
  liveness rejection and attack detection MUST produce identical screens.
- **FR-004**: The advice shown MUST correspond to the capture that failed and, where the
  verification contract supplies a reason, MUST be tailored to it. Advice about a capture that did
  not fail MUST NOT be shown. *(Tailoring to the reason is deferred in happy-path mode.)*
- **FR-005**: Advice about the face MUST describe what the capture requires — an unobstructed,
  fully visible face — rather than enumerating garments, and MUST NOT ask a passenger to remove
  glasses or a religious head covering. The wording MUST stay consistent with screen 005.
- **FR-006**: The attempt count MUST be authoritative on the backend and MUST survive reinstallation
  or clearing of the app's data. *(Local stand-in allowed in happy-path mode; not deferrable past
  the first real integration.)*
- **FR-007**: Only passenger-attributable failures MUST count as attempts. Service and technical
  failures MUST NOT.
- **FR-008**: The screen MUST NOT show an attempt count or a remaining-attempts indication in any
  state. At the limit it MUST explain that the limit was reached.
- **FR-009**: A route to a human agent MUST be available from the first failure, not only after the
  limit is reached.
- **FR-010**: On reaching the attempt limit, the retry action MUST NOT be offered, and the screen
  MUST explain why and offer the agent route.
- **FR-011**: The retry MUST go straight to the selfie camera (006), not through the selfie
  instructions (005), and MUST NOT re-run document capture. Both the retry and the agent route
  MUST preserve the enrollment session and the confirmed identity record, so neither restarts the
  passenger.
- **FR-012**: The agent route MUST carry the enrollment context, so the passenger does not repeat
  information already given. *(Deferred until screen 010 exists.)*
- **FR-013**: When the limit is in force, the screen MUST tell the passenger that they can try
  again after speaking with an agent, and that the regular document check at the checkpoint remains
  available.
- **FR-014**: The screen MUST NOT display personal data, document numbers, or facial images.
- **FR-015**: The screen MUST emit events for entry, failure class, attempt number, retry taken,
  agent route taken, and abandonment — carrying no personal data and no detection detail. The
  failure class in events MUST NOT distinguish attack detection from other biometric failures.
- **FR-016**: The failure's specific classification MUST be recorded in the audit trail even where
  the passenger-facing message is generic, consistent with specification 006.
- **FR-017**: A counter MUST NOT reset because its limit was reached, and MUST NOT reset because a
  capture step (003's document capture, 006's liveness check) succeeded. Both counters reset only
  on a verification match at 007, or when an agent resets an exhausted limit. There is no
  time-based reset. This changes the shipped behaviour of 003, 006 and 007 (CONFLICT-005).
- **FR-018**: The screen MUST offer "Ayuda" in the top bar and MUST NOT offer a back control; the
  system back gesture MUST NOT return the passenger into the verification.

### Key Entities

- **Failure outcome**: the classified reason verification did not confirm the passenger. Drives the
  advice shown and the routing; its passenger-facing form is deliberately coarser than its
  recorded form.
- **Failed capture**: which step the failure belongs to — selfie or document. Decides the wording
  and advice.
- **Attempt counter**: the number of passenger-attributable failures within the enrollment for one
  capture step, owned by the backend and not resettable from the device.
- **Retry policy**: a limit of three passenger-attributable attempts per capture step; service
  failures do not count; no time-based expiry; both counters reset only on a verification match
  or by an agent.
- **Escalation context**: what accompanies a passenger into the agent path so the handoff does not
  restart them.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: ≥80% of passengers who reach this screen complete enrollment within the same session,
  by retry or through an agent.
- **SC-002**: ≥60% of passengers who retry succeed on the following attempt — the measure of
  whether the advice is doing any work.
- **SC-003**: Zero passenger-facing messages on this screen disclose an attack-detection signal,
  verified by review of the complete message set.
- **SC-004**: The attempt limit survives reinstallation in 100% of tested cases.
- **SC-005**: Zero service failures are counted as passenger attempts.
- **SC-006**: 100% of passengers reaching the attempt limit see a route to a person and the
  checkpoint alternative, with no terminal state offering no forward action.
- **SC-007**: Escalations arriving from this screen require the passenger to repeat no information
  already captured, verified with the agent workflow.
- **SC-008**: Average paid validations consumed per completed enrollment stays at or below 1.3.
- **SC-009**: With assistive technology, the failure statement and the advice, or in the limit
  state its explanation, are announced without interaction.
- **SC-010**: In 100% of tested cases, an exhausted limit is still in force on the next attempt of
  the same capture (CONFLICT-005).

## Assumptions

- **Entry points are fixed by earlier specifications.** This screen replaces the retry-guidance
  placeholder, reached from: 007 after a face mismatch, liveness rejection or attack detection
  (retry offered while below the limit); 007 after a document rejection at the limit; 003 when
  document capture reaches its limit; and 006 when the liveness capture reaches its limit. The
  screen is told which capture failed and whether the limit is reached.
- **The attempt is already counted when this screen opens.** 003, 006 and 007 increment the counter
  before routing here, so this screen reads the count and never increments it.
- **Counters are per capture step, not shared.** Specification 006 resolved this: document capture
  and selfie each keep their own counter, with a limit of three.
- Each verification attempt consumes a paid validation, which is why SC-008 treats retries as a
  cost rather than as free robustness.
- The verification contract supplies a reason specific enough to tailor advice. Where it does not,
  FR-004 falls back to the capture's general tip set.
- **No minimum interval between attempts.** A selfie attempt already takes the time of a full
  capture, and a cooldown would read as a punishment to a legitimate passenger. Abuse is bounded by
  the limit itself (FR-006, FR-017).
- The agent path is staffed and reachable during airport operating hours; what "hablar con un
  agente" offers out of hours is a question for specification 010. Until 010 exists, the existing
  agent-escalation placeholder is the destination.
- Copy is in Spanish (Colombia), matching the reference and specifications 001–008.

## Dependencies

- The verification outcome routing of 007, including the distinction between passenger-attributable
  and service failures.
- A backend-owned attempt counter, for FR-006.
- The capture steps (003, 006) as origins, the selfie capture (006) as the retry destination, and
  the agent escalation (010) as the human route.
- The face-visibility wording shared with screen 005.
- The retry policy as clarified: three attempts per step, reset only on a verification match or by
  an agent.
- An agent-side action to reset an exhausted counter, delivered with specification 010 and the
  backend counter; until then, a passenger at the limit reaches the agent placeholder and the
  checkpoint alternative, with no in-app reset.
- Changes to 003, 006 and 007 so that neither reaching the limit nor passing a capture step resets
  a counter, and 007 resets both counters on a match (FR-017).

## Out of Scope

- The agent escalation experience itself, specified with 010.
- The technical-error path, specified with 011.
- The verification algorithms, their thresholds, and how a reason is derived.
- Fraud investigation and any account-level blocking that follows repeated attack detections.
