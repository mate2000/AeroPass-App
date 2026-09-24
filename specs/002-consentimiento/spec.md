# Feature Specification: Informed Consent Gate (02 Consentimiento)

**Feature Branch**: `002-consentimiento`

**Created**: 2026-09-21

**Status**: Draft

> **Superseded in part by 015** (`specs/015-integracion-backend`): the consent text is bundled with the app and the record is kept on the device only (DEC-02), because the backend has no consent endpoint. Withdrawal cannot delete server data.

**Input**: User description: "Screen 02 Consentimiento — the blocking gate between the welcome screen and any capture. Presents the three privacy points and a blocking checkbox; nothing may be captured or transmitted until consent is recorded."

## UI Reference

The authoritative visual reference for this screen is
[`assets/02-consentimiento.png`](./assets/02-consentimiento.png), now present in this feature
directory and verified against the table below — the transcription is accurate, including the
still-incorrect "5 años" retention line and the "nunca con terceros" disclosure line, both already
addressed above. Two additional layout facts visible only in the image, not previously captured:

- The primary button ("Acepto y continúo") renders in a visibly muted/desaturated tone while
  disabled, distinct from its full-color enabled state — this is the reference's own answer to
  FR-006's "more than color alone" requirement, but the muted-color-only signal is not sufficient by
  itself for screen-reader/assistive-tech users; the disabled semantic state (not just the visual
  tone) must also be exposed, which FR-006 already requires.
- A thin horizontal divider separates the three privacy points from the checkbox/actions area.

The reference shows a bottom sheet over a dimmed welcome screen, with a drag handle, containing:

| Element | Content in the reference |
|---|---|
| Title | "Cómo tratamos tus datos" |
| Subtitle | "Tu privacidad es nuestra prioridad. Aquí te explicamos todo." |
| Point 1 — camera icon | **Qué se captura** — "Imagen de tu documento, foto de tu rostro y los datos extraídos. Nunca tu contraseña ni datos bancarios." |
| Point 2 — clock icon | **Tiempo de conservación** — "Tus datos biométricos se almacenan por 5 años o hasta que solicites su eliminación, lo que ocurra primero." |
| Point 3 — share icon | **Con quién se comparte** — "Solo con aerolíneas y aeropuertos donde uses AeroPass. Nunca con terceros con fines comerciales." |
| Confirmation | Unchecked checkbox, "Autorizo el tratamiento de mis datos" |
| Primary action | "Acepto y continúo", disabled until the checkbox is confirmed |
| Secondary action | "Ahora no" |

Behaviors the reference confirms, and which the requirements below assume: the checkbox is
unchecked on presentation (FR-004), the primary action is visibly unavailable until it is checked
(FR-006), and the decline path is present and legible rather than hidden (FR-009, FR-011).

### Conflicts between the reference and the rest of the product

Three conflicts were found between the reference's copy and the product's other binding
commitments (the constitution, and FR-002/FR-003/FR-012 below). Two are resolved here with a
stated default; one remains open as a clarification because no reasonable default exists.

- **Resolved — undisclosed processor.** The reference's "solo con aerolíneas y aeropuertos…
  nunca con terceros" omits that an external verification provider processes the document image
  and facial sample (Constitution Principle II: "OCR, liveness, and face matching are delivered by
  an external SaaS provider"). FR-002 below requires this screen to disclose that a specialized
  external processor performs the verification, consistent with the "un proveedor externo
  especializado" language already used in the 001-bienvenida terms placeholder. The reference's
  copy must not ship as-is; the legally-approved text (see Dependencies) must name this processing
  relationship.
- **Resolved — missing required elements.** The reference carries no link to the full privacy
  policy/terms, no optionality statement, and no statement of the passenger's rights. Rather than
  leaving these open, FR-002, FR-003, and FR-012 below make all three mandatory parts of the gate
  (visible text or a reachable link, per element) — the reference is incomplete, not authoritative,
  on this point.
- **Resolved — retention period.** The real commitment is the constitution's **≤30 days after the
  passenger's last flight**, not the reference's "5 años." The reference's copy is wrong and must
  be corrected before legal approves the final text (see FR-019 and Dependencies).

## Clarifications

### Session 2026-09-21

- Q: Should FR-007's "anonymous session reference" be 001-bienvenida's existing ephemeral, per-launch `AnalyticsSessionId`, or does the durable consent record need a longer-lived identifier that survives a resume across app launches? → A: Introduce a new durable anonymous enrollment-attempt identifier, generated at consent time, persisted with the consent record and referenced by later steps — distinct from the ephemeral per-launch analytics id.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A passenger gives informed consent and proceeds (Priority: P1)

A passenger has decided to try AeroPass and now reaches the point where the product asks for the
two things it cannot work without: an image of their identity document and a biometric sample of
their face. Before either is taken, they are told what will be collected, who will process it, how
long it is kept, and what rights they keep over it. They confirm deliberately, and only then does
the app move toward the camera.

**Why this priority**: this is the legal boundary of the entire product. Under Colombian data
protection law biometric data is sensitive data, and processing it without prior, express and
informed consent is not a product defect but an unlawful act. Every screen after this one depends
on this one having happened correctly, and the airport's willingness to deploy at all depends on it
being auditable.

**Independent Test**: from the welcome screen, reach the consent gate, confirm nothing can advance
while consent is unconfirmed, confirm consent, and verify that a consent record exists — with its
text version and timestamp — before any capture surface is reachable.

**Acceptance Scenarios**:

1. **Given** a passenger arriving from the welcome screen, **When** the consent gate is presented,
   **Then** it states what is collected, the purpose, who processes it, how long it is retained,
   that providing sensitive data is optional, and the rights the passenger keeps — before any
   control that advances the flow.
2. **Given** the consent gate is displayed, **When** the passenger has not confirmed consent,
   **Then** the action that advances the flow is unavailable, and its unavailability is conveyed by
   more than color alone.
3. **Given** the consent gate is displayed, **When** it first appears, **Then** the confirmation
   control is unchecked, and no pre-selected, pre-confirmed, or bundled option exists.
4. **Given** the passenger confirms consent, **When** the flow advances, **Then** a consent record
   containing the identifier and version of the exact text shown, the timestamp, and the scope
   consented to has been durably recorded before the camera is reachable.
5. **Given** the passenger confirms consent, **When** the consent record cannot be stored, **Then**
   the flow does NOT advance and the passenger is told the enrollment cannot start right now.

---

### User Story 2 - A passenger declines and leaves without penalty (Priority: P2)

A passenger reads the consent text and decides against it — they are not comfortable handing over a
face, or they want to read the full policy first, or they simply change their mind. Declining must
be as easy as accepting, must not be punished with a dead end, and must leave the passenger knowing
they can still fly exactly as they always have.

**Why this priority**: consent that cannot be refused easily is not consent, and a coerced
confirmation is both a legal exposure and worthless evidence in an audit. It ranks second only
because the accept path must exist before the refuse path has anything to refuse.

**Independent Test**: reach the consent gate, exercise every exit available (decline, dismiss,
system back gesture), and verify in each case that no capture occurred, no personal data left the
device, and the passenger landed somewhere with a clear next step.

**Acceptance Scenarios**:

1. **Given** the consent gate is displayed, **When** the passenger declines or dismisses it,
   **Then** they return to the welcome screen with no consent recorded, no data transmitted, and a
   plain statement that they can still use the conventional airport process.
2. **Given** the consent gate is displayed, **When** the passenger uses the platform's back or
   dismiss gesture, **Then** the outcome is identical to an explicit decline — dismissal is never
   treated as acceptance.
3. **Given** the passenger declined earlier, **When** they open the app again, **Then** they are not
   re-prompted automatically on launch; the consent gate appears only when they choose to start
   enrollment again.
4. **Given** the consent gate is displayed, **When** the passenger compares the accept and decline
   paths, **Then** neither is hidden, delayed, or given disproportionate visual weight over the
   other.

---

### User Story 3 - A passenger withdraws consent, or is asked again after the terms change (Priority: P3)

Months later a passenger decides they no longer want their face on file, or the company updates the
terms under which it processes biometrics. In the first case the withdrawal must be honored and
must take effect on the credential immediately. In the second, the previous consent no longer
covers the new processing and the passenger must be asked again rather than carried along silently.

**Why this priority**: withdrawal is a legal right and a committed operating target, and re-consent
on material change is what keeps the stored evidence truthful over time. It is third because it has
no subject until passengers have enrolled, but it is not optional — the withdrawal route is what
makes the consent in User Story 1 lawful in the first place.

**Independent Test**: with consent recorded, exercise withdrawal from inside the app and verify the
local credential and any displayed pass become unusable immediately and the withdrawal is
registered for backend processing; then publish a new consent version and verify the passenger is
asked again before the next processing occurs.

**Acceptance Scenarios**:

1. **Given** an enrolled passenger, **When** they withdraw consent, **Then** the local credential and
   any displayed pass are invalidated at once and the withdrawal is submitted for processing.
2. **Given** a withdrawal was submitted while offline, **When** connectivity returns, **Then** the
   withdrawal is delivered without requiring the passenger to repeat it, and the credential remains
   invalid in the meantime.
3. **Given** a passenger whose recorded consent refers to a superseded version of the text, **When**
   any new processing would occur, **Then** the consent gate is presented again showing what
   changed, and the prior consent is not treated as covering the new terms.

---

### Edge Cases

- The consent text cannot be loaded. If the current consent version is fetched rather than shipped
  with the app, an unavailable text must block the gate with an explanation — never fall back to a
  stale or embedded copy that would make the stored evidence wrong.
- The passenger is offline. Consent cannot be recorded durably, so enrollment cannot start. The gate
  must say this plainly rather than accepting a confirmation it cannot preserve.
- The passenger confirms, then immediately backgrounds or kills the app before the record is
  stored. On return, consent is treated as not given.
- The passenger scrolls past the text without reading it. No scroll-to-end gate is required before
  the confirmation control becomes available — see Assumptions; this is a reasoned default, not a
  legal determination, and should be revisited if legal counsel disagrees when the approved text
  arrives.
- The sheet is taller than the screen at large text sizes. The text must remain fully reachable by
  scrolling, and the confirmation control must never be pushed out of reach.
- A screen reader user encounters the gate. The full text, the state of the confirmation control,
  and the reason the advance action is unavailable must all be announced; the gate must not trap
  focus behind a decorative overlay.
- The passenger has already consented and is resuming an incomplete enrollment. The gate is not
  shown again for the same version, but the previously recorded consent must be verified as still
  current before capture resumes.
- The verification provider processes data outside Colombia. Resolved: the provider does not
  process or store data outside Colombia, so no international-transfer disclosure or authorization
  clause is required in the consent text. If a future provider change moves processing abroad, this
  spec's FR-002 disclosure requirement must be revisited before that change ships.
- The passenger is a minor. Resolved: enrollment is offered to adults (18+) only at this release;
  minors are explicitly out of scope (see Out of Scope). A parental/guardian consent path is not
  part of this gate.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The consent gate MUST be presented before any camera access, document capture, or
  biometric sample, and MUST block progress until consent is explicitly confirmed.
- **FR-002**: The gate MUST state, in plain language and before the confirmation control: what data
  is collected (identity document image and facial biometric), the purpose of the processing, the
  identity of the party responsible, that the verification is performed by an external processor,
  the retention period, and the passenger's rights over their data.
- **FR-003**: The gate MUST state that providing sensitive data is optional and that the passenger
  is not obliged to authorize it.
- **FR-004**: The confirmation control MUST be unchecked on presentation. Pre-checked,
  pre-confirmed, implied, or bundled consent is prohibited.
- **FR-005**: Consent for identity verification MUST be recorded separately from consent to any
  other processing. No other purpose may be bundled into the same confirmation. At this release,
  identity verification is the only processing purpose this gate covers — see Assumptions;
  product-analytics or communications consent, if ever added, requires its own confirmation and its
  own amendment to this spec, not reuse of this one.
- **FR-006**: The advance action MUST be unavailable until consent is confirmed, and its unavailable
  state MUST be conveyed to assistive technology and through means other than color.
- **FR-007**: On confirmation, the system MUST durably record the consent before any capture surface
  becomes reachable. The record MUST include the identifier and version of the exact text
  presented, the timestamp, the scope consented to, and an anonymous, durable enrollment-attempt
  identifier (generated at consent time and persisted, distinct from any ephemeral per-launch
  analytics identifier — see Key Entities) so the record can still be correlated with later steps
  (document capture, credential issuance) even if those occur in a subsequent app launch after a
  resume.
- **FR-008**: If the consent record cannot be stored, the flow MUST NOT advance, and the passenger
  MUST be told that enrollment cannot begin now.
- **FR-009**: The gate MUST offer an explicit decline, and declining MUST return the passenger to
  the welcome screen with no data transmitted and a statement that the conventional airport process
  remains available.
- **FR-010**: Dismissal by any means — back gesture, swipe, system navigation — MUST be equivalent
  to declining and MUST NEVER be recorded as consent.
- **FR-011**: Accept and decline MUST be presented with comparable prominence and without delay,
  pre-selection, or repeated re-prompting on subsequent launches.
- **FR-012**: The gate MUST provide access to the full privacy policy and terms without leaving the
  enrollment context, and returning MUST restore the gate with the confirmation state unchanged.
- **FR-013**: The full consent text MUST remain reachable by scrolling at the platform's maximum
  text size, and the confirmation and advance controls MUST remain reachable at all times.
- **FR-014**: When the recorded consent refers to a superseded version of the text, the system MUST
  present the gate again, indicating that the terms changed, before any further processing.
- **FR-015**: Passengers MUST be able to withdraw consent from within the app at any time after
  enrollment, reachable in no more than two actions from the account surface.
- **FR-016**: Withdrawal MUST invalidate the local credential and any displayed pass immediately,
  and MUST be submitted for backend processing; a withdrawal made offline MUST be retained and
  delivered once connectivity returns, without the passenger repeating it.
- **FR-017**: The gate MUST emit funnel events recording presentation, confirmation, decline, and
  abandonment, keyed to an anonymous session identifier and containing no personal data and no
  consent text.
- **FR-018**: The system MUST NOT permit any capture or transmission of document or biometric data
  for which a current, matching consent record does not exist. This invariant MUST be verifiable
  from the audit trail.
- **FR-019**: The retention period stated in the consent text MUST be **≤30 days after the
  passenger's last flight**, matching the constitution's Principle I commitment — not the UI
  reference's "5 años," which is incorrect and must not ship. The consent text, the backend
  deletion job, and the audit criterion MUST all use this same number.

### Key Entities

- **Consent text version**: the exact wording presented, identified by a version that changes
  whenever the wording changes. Consent records reference it; it is never edited in place.
- **Consent record**: evidence that a specific passenger session accepted a specific text version at
  a specific time, for a specific scope. Durable, auditable, and the precondition for all capture.
  References the enrollment attempt identifier below, not the ephemeral per-launch analytics id.
- **Enrollment attempt identifier**: a durable, anonymous identifier generated when consent is
  confirmed and persisted alongside the consent record. Distinct from 001-bienvenida's
  `AnalyticsSessionId` (which is deliberately in-memory/per-launch only and unsuitable for this
  purpose) — this identifier is what lets the consent record, the document capture, and credential
  issuance be tied together as one enrollment attempt even across a resume that spans app launches.
  Carries no personal data itself.
- **Withdrawal request**: a passenger's revocation of a prior consent record, with the time it was
  made, surviving loss of connectivity until delivered.
- **Processing scope**: what the consent covers — identity verification by the external processor —
  distinguishing it from any other purpose that would require its own consent.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of document and biometric captures are preceded by a current, matching consent
  record, verified by audit of the trail. This is an absolute; a single exception is a critical
  finding.
- **SC-002**: 100% of consent records identify the exact text version presented, with no record
  referring to a version that cannot be reproduced.
- **SC-003**: Zero critical findings in the data-protection audit of biometric processing.
- **SC-004**: 100% of consent withdrawals are processed within 24 hours of submission.
- **SC-005**: Withdrawal invalidates the credential on the device within 1 second of the passenger
  confirming it, with no network dependency for the local effect.
- **SC-006**: ≥85% of passengers who reach the consent gate confirm and proceed, with the decline
  rate and its stated reasons tracked rather than suppressed.
- **SC-007**: The median passenger spends ≤30 seconds at this gate, keeping it within the ≤3-minute
  p90 enrollment budget.
- **SC-008**: In accessibility audit, 100% of the consent text and both outcomes are reachable and
  correctly announced by a screen reader at maximum text size.
- **SC-009**: Zero instances in usability testing of a participant believing they had consented when
  they had not, or having consented without being able to state what to.

## Assumptions

- Biometric data is sensitive personal data under Colombian law, so express, prior and informed
  consent is mandatory and cannot be replaced by a terms-of-service acceptance elsewhere in the
  flow.
- Verification is performed by an external processor, and the passenger is told so here rather than
  discovering it later (resolves the reference's undisclosed-processor gap — see UI Reference).
- Consent evidence is stored by the backend; the device holds a copy for display and for deciding
  whether to re-present the gate, but the device is not the system of record. That device-held copy
  includes the enrollment attempt identifier (so later steps can be tagged correctly after a
  relaunch) — this identifier travels as part of the consent record, which the constitution's
  Principle I persisted-state allowlist already permits ("the user's consent record with timestamp
  and version"), so this does not introduce a new category of persisted state or require a
  constitution amendment.
- Enrollment is offered to adults (18+) on domestic flights only; minors are out of scope for this
  release (resolved above).
- The verification provider does not process or store data outside Colombia, so no
  international-transfer disclosure is required in the consent text (resolved above).
- The retention period is ≤30 days after the passenger's last flight, matching the constitution;
  the UI reference's "5 años" was incorrect and is not carried into the requirements (resolved
  above, FR-019).
- The consent wording itself is drafted and approved by legal counsel. This specification governs
  the behavior of the gate and the elements the wording must contain, not the wording.
- No scroll-to-end gate is required before the confirmation control becomes available: the text
  must be fully reachable by scrolling (FR-013), but requiring the passenger to reach the bottom
  before confirming is a UX/legal-strategy choice with reasonable arguments either way and no
  product commitment already forces one; the default here is "available as soon as presented,"
  revisited if legal counsel's approved text says otherwise.
- Identity verification is the only consent-gated processing purpose at this release; no
  product-analytics or marketing consent is bundled here (FR-005).

## Dependencies

- Legally approved consent text, versioned, with a mechanism for the app to know which version is
  current. The text in the UI reference is not yet that text — it must be corrected to state the
  ≤30-day retention period (not "5 años") and must carry the processor-disclosure and
  missing-elements content this spec requires.
- A backend endpoint that durably records consent and returns confirmation before capture is
  permitted.
- A backend path for withdrawal that meets the 24-hour processing commitment.
- Published privacy policy and terms of service, reachable from within the enrollment context (the
  001-bienvenida terms placeholder already exists as an interim destination).
- The welcome screen (001-bienvenida) as the entry point and the decline destination; the document
  capture step (003) as the gated destination — neither exists as a real screen yet beyond
  001-bienvenida's placeholder consent-stub route.

## Out of Scope

- The legal wording of the consent text, which is counsel's deliverable, not this feature's.
- The account surface where withdrawal lives, beyond the requirement that withdrawal be reachable
  from it within two actions.
- Backend retention, deletion, and audit-trail implementation.
- Consent for any processing purpose other than identity verification.
- Any capture, verification, or credential issuance.
