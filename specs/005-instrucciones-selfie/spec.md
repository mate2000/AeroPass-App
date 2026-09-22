# Feature Specification: Selfie Instructions (05 Instrucciones selfie)

**Feature Branch**: `005-instrucciones-selfie`

**Created**: 2026-09-21

**Status**: Draft

**Input**: User description: "Screen 05 Instrucciones selfie — prepares the passenger for the
liveness capture: explains why a selfie is needed and states the three conditions that make it
succeed."

## Delivery Mode: Happy Path First

This section applies to this specification and to every specification that follows it in the
enrollment flow. It governs build order, not the target product.

The current priority is a working end-to-end flow. Development therefore runs in happy-path mode:
the flow must be walkable from welcome to pass without the edge-case handling, gating, and
hardening that the requirements below describe. Nothing in this section removes a requirement —
each relaxation defers a requirement, by identifier, to a later increment.

**Relaxable during happy-path mode.** These may be stubbed, hard-coded, or skipped, and each must
be recorded as a deferred requirement rather than silently omitted:

- Attempt limits, retry routing, and escalation destinations. A failure may log and return to the
  same screen instead of routing.
- The full error taxonomy. A single generic failure state may stand in for the specific, actionable
  messages the requirements demand.
- Offline and connectivity handling. Development may assume the network is present.
- Device capability gating and permission-denied paths. Development may assume permissions are
  granted and the device is supported.
- Timing and performance budgets, which are measured once the flow exists rather than enforced
  while it is being assembled.
- Analytics event completeness. Events may be incomplete, but the ones that exist must already
  carry no personal data.
- Backend integrations, which may be served by fakes — provided the fake implements the same
  contract the real one will, so the swap is a configuration change and not a rewrite.

**Not relaxable, in any mode.** These cost little now and are expensive or impossible to retrofit,
and two of them are legal rather than technical:

- No real personal data. Development and testing use synthetic documents and test faces. A real
  passenger's document or face never enters a development environment.
- No persistence of images or biometric samples. Document images, selfie frames, and liveness
  video stay in memory in every mode. A development shortcut that writes one to disk is the exact
  habit that ships.
- No personal data in logs, events, or crash reports, in any mode.
- Consent still gates capture. The consent gate may be backed by a fake recorder, but the flow may
  never reach a camera without having passed through it, because the ordering is what the audit
  examines and it is not something to add afterwards.
- No path that presents a valid credential or pass without backend affirmation. A stub may affirm
  it; the app may never assume it.

Every relaxation lives behind a build flag that cannot be enabled in a release build, and the
release pipeline fails if one is. Relaxations are configuration, never deleted code paths.

**Exit from happy-path mode**: before any build reaches a real passenger, every deferred
requirement is either implemented or explicitly accepted as out of scope for that release, in
writing. A deferred requirement that nobody tracked is the failure this section exists to prevent.

**Named exit milestone**: the airport pilot integration — the first point at which a real
passenger's document or face reaches the app. A working demo (internal, synthetic data only) does
not end happy-path mode; a specific calendar date was rejected as the trigger because the
deferred-requirements review this section requires must gate the milestone, not the other way
around — a date can arrive with the review incomplete, but the milestone cannot start without it
by definition. Before that integration, every deferred requirement listed above (this spec's own
deferrals are enumerated in Assumptions) is either implemented or accepted in writing as
out-of-scope for that release.

## UI Reference

The authoritative visual reference is
[`assets/05-instrucciones-selfie.png`](./assets/05-instrucciones-selfie.png) — not yet copied into
this feature directory; add it from `C:\Users\Usuario\Pictures\Screenshots\Captura de pantalla
2026-09-21 233232.png` before `/speckit-plan` if pixel-level fidelity matters. It is the source of
truth for layout, content order, and copy.

| Element | Content in the reference |
|---|---|
| Top bar | "‹ Atrás" (left), "Ayuda" (right) |
| Step indicator | Documento (complete), Selfie (active), Listo |
| Illustration | A face centred in a dashed turquoise oval, matching the capture frame of the next screen |
| Title | "Ahora una selfie" |
| Subtitle | "Necesitamos confirmar que eres el titular del documento." |
| Rule 1 | "Buena iluminación, de frente a la luz" |
| Rule 2 | "Sin gafas, gorras ni mascarilla" |
| Rule 3 | "Mira directamente a la cámara" |
| Primary action | "Tomar selfie" |

Behaviors the reference establishes: the screen is instructional and blocks nothing, the oval
previews the framing the passenger will meet next, and a single action advances to the capture.

### CONFLICT-001 — "sin gafas, gorras ni mascarilla" treats unlike things alike (resolved)

Prescription glasses, a religious head covering, and a baseball cap are not the same category. A
passenger who wears a hijab must not be instructed to remove it in the same breath as a cap, and a
passenger who cannot see without glasses cannot follow an instruction to remove them and then look
at the camera.

**Resolved**: the rule states what the capture requires — a clear, unobstructed view of the full
face, adequate front lighting, eyes toward the camera — rather than enumerating garments to
remove. A religious head covering that leaves the face unobstructed is never included in a removal
instruction (FR-003). This is the industry-standard tolerance for liveness/face-matching engines
(they need the face, not a bare head), so restating the rule this way costs nothing functionally
and removes a real exclusion risk.

## Clarifications

### Session 2026-09-21

- Q: What milestone ends happy-path mode — a working demo, an airport pilot integration, or a
  specific date? → A: The airport pilot integration (the first point a real passenger's document
  or face reaches the app) — see the Delivery Mode section's "Named exit milestone."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A passenger arrives at the capture knowing what is expected (Priority: P1)

A passenger has just confirmed their document data. Before the camera opens, they are told in one
short screen why a selfie is needed and what makes it work: light in front of them, a clear view of
their face, eyes on the camera. They read it in a few seconds and tap through prepared, which is
the difference between succeeding on the first attempt and cycling through retries.

**Why this priority**: this screen exists to buy down the false-rejection rate at the step that
follows, which is the most fragile moment in enrollment. It is the entire justification for
spending any of the enrollment budget here at all.

**Independent Test**: reach the screen from data confirmation, verify the purpose and the three
conditions are present and legible, and verify the single action advances to liveness capture.

**Acceptance Scenarios**:

1. **Given** a passenger who has confirmed their document data, **When** this screen opens, **Then**
   it states why a facial capture is required — to confirm they are the holder of the document —
   and the conditions for a successful capture.
2. **Given** the screen is displayed, **When** the passenger reads it, **Then** each condition is
   stated as an action they can take, not as a prohibition they must decode.
3. **Given** the screen is displayed, **When** the passenger activates the primary action, **Then**
   the liveness capture opens with the framing the illustration previewed.
4. **Given** the screen is displayed, **When** the passenger is on it, **Then** no camera is active
   and no capture occurs.

---

### User Story 2 - A passenger who cannot meet a condition still has a route (Priority: P2)

A passenger cannot remove their glasses and see the screen, wears a head covering they will not
remove, has a facial difference, or is helping an elderly relative who cannot hold the phone. The
instructions must not read as a wall, and there must be a way onward that does not require them to
violate something they care about.

**Why this priority**: it is where a generic instruction screen quietly becomes an exclusion, and
the product's self-service target depends on not sending these passengers to an agent
unnecessarily. It ranks second because it depends on the instructions existing first.

**Independent Test**: from this screen, verify a passenger can reach help without losing their
enrollment session, and that the conditions distinguish what must be visible from what must be
removed.

**Acceptance Scenarios**:

1. **Given** a passenger who cannot comply with a stated condition, **When** they look for an
   alternative, **Then** help is reachable from this screen and returns them with the session
   intact.
2. **Given** the conditions are displayed, **When** a passenger wears a religious head covering
   that leaves the face unobstructed, **Then** the instructions do not ask them to remove it.
3. **Given** a passenger who proceeds without meeting a condition, **When** they continue, **Then**
   they are not blocked here — this screen advises and never gates.

---

### Edge Cases

- The passenger arrives here after a failed liveness attempt. Resolved: this screen is shown once
  per enrollment on the forward path (Assumptions); it is not reused for retry. Targeted guidance
  after a failed attempt belongs to the retry path (009), which is out of scope here.
- The device has no front camera. Happy-path mode: device capability gating is deferred (Delivery
  Mode) — this screen assumes a supported device. The earliest-point catch this edge case calls
  for is deferred to whichever screen owns device-capability gating, not invented here.
- The passenger is in a dark jetbridge or facing a window. The lighting condition is the most
  common cause of failure and is stated first for that reason.
- A screen reader user encounters the screen. The three conditions are the content; the
  illustration carries none of it and is not announced as meaningful.
- The passenger backgrounds the app here. Nothing is in flight; the session resumes at this step.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The screen MUST state why a facial capture is required, in terms of confirming the
  passenger is the holder of the document just confirmed.
- **FR-002**: The screen MUST state the conditions for a successful capture as positive, actionable
  instructions.
- **FR-003**: The conditions MUST describe what the capture requires — a clear, unobstructed view
  of the face, adequate front lighting, eyes toward the camera — rather than enumerating garments
  to remove. Religious head coverings that leave the face unobstructed MUST NOT be included in any
  removal instruction (CONFLICT-001, resolved above).
- **FR-004**: The screen MUST NOT activate a camera, request a capture, or transmit anything.
- **FR-005**: The screen MUST advise only. It MUST NOT gate progress on the passenger asserting
  compliance.
- **FR-006**: The illustration MUST preview the framing used in the capture step, and MUST carry no
  information that is not also stated in text.
- **FR-007**: A help route MUST be reachable from this screen and MUST return the passenger with
  the enrollment session intact.
- **FR-008**: Backward navigation MUST return to data confirmation with the confirmed identity
  record intact.
- **FR-009**: The step indicator MUST show the document step complete and the selfie step active.
- **FR-010**: The screen MUST emit funnel events for entry, advance, help, and abandonment, keyed
  to an anonymous session identifier and carrying no personal data. Happy-path mode: event
  completeness beyond these four is deferred (Delivery Mode), but every event emitted MUST already
  carry no personal data — this half of the requirement is not relaxable.
- **FR-011**: All content MUST be reachable by assistive technology and MUST remain legible and
  unclipped at the platform's maximum text size, since the three conditions are the screen's entire
  purpose.

### Key Entities

- **Capture condition**: one stated requirement for a successful facial capture, expressed as an
  action the passenger takes. Derived from what the verification processor actually needs.
- **Enrollment session**: carried through from earlier steps; this screen advances its position and
  changes nothing else.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: ≥95% of passengers who reach this screen advance to the capture rather than
  abandoning.
- **SC-002**: The median passenger spends ≤12 seconds here; the screen consumes no more than 10% of
  the ≤3-minute enrollment budget.
- **SC-003**: First-attempt liveness success is at least 15 percentage points higher for passengers
  who saw this screen than for those routed past it, measured once both paths exist. If the screen
  does not move that number, it is costing enrollment time for nothing and should be reconsidered.
- **SC-004**: Zero camera activations occur while this screen is displayed, verified by audit.
- **SC-005**: Zero passengers in usability testing report being asked to remove a religious head
  covering.
- **SC-006**: In accessibility audit, 100% of the stated conditions are announced correctly at
  maximum text size.

## Assumptions

- The camera permission was granted at the document capture step, so this screen introduces no new
  permission request. If the front camera requires a separate grant on any supported platform, that
  request belongs to the capture step, not here.
- The conditions stated are the ones the verification processor actually requires. They are not
  invented for the screen, and they change if the processor changes.
- The screen is shown once per enrollment on the forward path.
- Liveness capture is automatic once framed, per the design of the following screen; this screen's
  job is preparation, not instruction on how to operate a shutter.
- **This feature's own happy-path deferrals** (Delivery Mode), tracked for the exit review ahead of
  the airport pilot integration:
  - Device-has-no-front-camera gating is not implemented here; assumed supported.
  - The help route may be a stub destination rather than a staffed agent path.
  - Analytics events are limited to entry/advance/help/abandonment (FR-010) rather than a fuller
    funnel, though every emitted event is already free of personal data.
  - No offline handling is implemented; the screen has no network dependency of its own to begin
    with, so this deferral is presently a no-op, not a gap.

## Dependencies

- The confirmed identity record from screen 004.
- The verification processor's documented capture requirements, which determine FR-003's wording.
- The liveness capture step (006) as the destination.
- The help and agent routes as the destination for passengers who cannot comply.

## Out of Scope

- The capture itself, its framing feedback, and its liveness prompts.
- Retry guidance after a failed attempt, which belongs to the rejection path.
- Any assessment of whether the passenger has actually met the stated conditions.
