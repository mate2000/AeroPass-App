# Feature Specification: Liveness Capture (06 Selfie · liveness)

**Feature Branch**: `006-selfie-liveness`

**Created**: 2026-09-22

**Status**: Draft

**Input**: User description: "Screen 06 Selfie (liveness) — automatic facial capture with a framing
oval, an animated progress ring, dynamic instruction phases, and no shutter control."

## Delivery Mode: Happy Path First

Same section as specification 005; it governs build order for this specification too (and is
already reflected in the constitution's Principle III "Happy-Path Development Mode" carve-out,
v1.4.0).

The current priority is a working end-to-end flow. Development runs in happy-path mode: the flow
must be walkable from welcome to pass without the edge-case handling, gating, and hardening
described below. Nothing here removes a requirement — each relaxation defers one, by identifier.

**Relaxable during happy-path mode**, each recorded as a deferred requirement:

- Attempt limits, retry routing, and escalation destinations.
- The full failure taxonomy; a single generic failure state may stand in.
- Offline and connectivity handling.
- Device capability gating and permission-denied paths.
- Timing and performance budgets.
- Analytics completeness — events that do exist must already carry no personal data.
- Backend and processor integrations, served by fakes implementing the real contract.

**Specific to this screen**: the liveness decision may be served by a fake processor that always
passes, so the flow is walkable without a real verification account. The instruction phases, the
progress ring, and the attack-detection feedback rules may be stubbed. **What may not be stubbed is
where the decision is made — see FR-002.** A development build that decides liveness on the device
teaches the codebase the wrong shape, and that shape is the vulnerability.

**Not relaxable, in any mode**:

- No real personal data. Synthetic documents and test faces only; a real passenger's face never
  enters a development environment.
- No persistence of images, frames, or biometric samples. In-memory only, in every mode.
- No personal data in logs, events, or crash reports.
- Consent still gates capture, even when backed by a fake recorder.
- **The device never decides liveness. A stub may answer; the app may never conclude.**
- No path that presents a valid credential or pass without backend affirmation.

Every relaxation lives behind a build flag that cannot be enabled in a release build, and the
release pipeline fails if one is (constitution v1.4.0's `HappyPathFlags.assertReleaseSafe`
mechanism, extended by this feature — research.md will confirm the exact wiring).

**Exit from happy-path mode**: every deferred requirement is implemented or explicitly accepted as
out of scope, in writing, before any build reaches a real passenger — the airport pilot integration
(constitution v1.4.0).

## UI Reference

The authoritative visual reference is
[`assets/06-selfie-liveness.png`](./assets/06-selfie-liveness.png) — not yet copied into this
feature directory; add it from `C:\Users\Usuario\Pictures\Screenshots\Captura de pantalla
2026-09-22 001911.png` before `/speckit-plan` if pixel-level fidelity matters. It is the source of
truth for layout, content order, and copy.

| Element | Content in the reference |
|---|---|
| Top bar | "‹ Atrás" (left), "Ayuda" (right) |
| Step indicator | Documento (complete), Selfie (active), Listo |
| Dynamic instruction | "Acércate un poco" — changes as the capture proceeds |
| Progress badge | "64%", top right |
| Capture surface | Dark full-screen front camera, face centred in an oval with a turquoise progress arc drawn around it |
| Phase indicator | Four dots below the oval, the third active |
| Footer | "La captura es automática — no toques la pantalla" |

Behaviors the reference establishes: capture is automatic with no shutter, progress is expressed
both as an arc and a percentage, the passenger is guided by an instruction that changes during the
capture, and the process moves through four discrete phases.

## Clarifications

### Session 2026-09-22

- Q: Should this screen block screenshots/screen-recording, given the credential/QR-pass screens
  already do and the edge case asks to "confirm and apply consistently across 003, 004, and 006"?
  → A (resolved from existing precedent, no new decision needed): **not blocked**, matching
  003-escanear-documento's and 004-confirmar-datos's own deliberate, identical decisions. The
  constitution's Security & Compliance Constraints scope screenshot-blocking specifically to "the
  credential and QR pass screens" — a persistent, reusable pass surface, not a transient capture
  surface. This screen's live preview and any momentarily-held frames are in-memory-only and
  discarded regardless of what a screenshot captures (FR-008), exactly the reasoning 003/004
  already applied. Consistency across 003/004/006 is achieved by *not* introducing a new,
  screen-specific exception — not by extending the credential-screen rule to a different category
  of screen it was never written to cover.
- Q: Is the failed-attempt limit (FR-012) shared with document capture's limit, or separate, and
  what is it? → A: **Separate**, limit of **3**, mirroring 003-escanear-documento's own limit and
  its constitutional basis. Constitution Principle I's persisted-state allowlist already reads
  generically — "a per-step capture-attempt counter ... scoped to the specific step it protects" —
  not naming 003 specifically, so this screen's own counter (count + last-reset timestamp, scoped
  to this step) is already within the existing allowlist; no further constitution amendment is
  anticipated, subject to `/speckit-plan` confirming the exact shape matches.
- Q: Should the generic message shown for a detected presentation attack be visually identical to
  at least one other, genuinely mundane failure message, so that seeing a generic message doesn't
  by itself reveal that an attack was detected? → A: Yes — the generic message is shared verbatim
  (text and styling) with a real, legitimate "unclassified quality failure" outcome (the processor
  couldn't identify a specific, actionable reason). A passenger seeing the generic message cannot
  tell "the processor couldn't classify what was wrong" from "an attack was detected" — both render
  identically. Without this, a generic message would be produced *only* by attack detection, and
  genericness itself would become the tell FR-010 exists to prevent.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A passenger completes the liveness capture hands-free (Priority: P1)

The passenger holds up their phone, sees their face inside the oval, and follows short
instructions — come closer, hold still — while a ring fills around them. They touch nothing. After
a few seconds the capture completes on its own and the flow moves to verification. The passenger
never wonders whether it worked, because the progress was visible the whole time.

**Why this priority**: this is the step that binds a living person to the document confirmed a
moment ago. Without it there is no identity product, only a photo of a card. It is also the step
most likely to fail for ordinary passengers, which makes its first-attempt success rate the
dominant term in enrollment completion.

**Independent Test**: from the instructions screen, complete a capture in good light and verify
that the capture proceeds without any touch, that progress is displayed continuously, that the
flow advances to verification, and that no frame survives on the device afterward.

**Acceptance Scenarios**:

1. **Given** a passenger arriving from the instructions screen, **When** the capture surface opens,
   **Then** the front camera preview begins framed by the oval and no shutter control is present.
2. **Given** the capture is running, **When** the passenger's position needs adjusting, **Then**
   the instruction changes to name the adjustment in two or three words, and the phase indicator
   reflects which stage the capture is in.
3. **Given** the capture is running, **When** progress is displayed, **Then** it reflects the
   actual state of the capture and never advances on a timer alone.
4. **Given** the capture completes, **When** the flow advances, **Then** the samples are submitted
   for verification and no frame, image, or derived biometric template remains on the device.
5. **Given** the capture surface is open, **When** the passenger touches the screen, **Then**
   nothing is captured or cancelled by that touch, as the footer states.

---

### User Story 2 - A capture that cannot be completed ends cleanly, without coaching an attacker (Priority: P1)

The capture does not succeed. Either the conditions were poor — too dark, face out of frame,
movement — or what was presented to the camera was not a live person. These two outcomes must be
handled differently: the first deserves specific, useful guidance; the second must never be told
what gave it away.

**Why this priority**: it shares P1 with the success path because the zero-false-accept objective
is enforced here and nowhere else in the app, and because a liveness screen that explains exactly
why a spoof failed is a tool for defeating it. Conversely, treating an ordinary poor-light failure
as a security event drives legitimate passengers to an agent and burns the self-service rate.

**Independent Test**: produce quality failures (dark room, face out of frame, movement) and verify
each returns specific guidance; then produce presentation attacks (a photo of a face, a screen
replay) and verify the passenger-facing outcome is generic, the attempt is counted, and the
specific reason appears only in the audit trail.

**Acceptance Scenarios**:

1. **Given** a capture that fails on quality, **When** the result is shown, **Then** the passenger
   is told what to change, in the same vocabulary as the instructions screen.
2. **Given** a capture that fails attack detection, **When** the result is shown, **Then** the
   message is identical — text and styling — to the one shown for an unclassified quality failure,
   names no detection signal, and is not distinguishable from that legitimate outcome.
3. **Given** any failed capture, **When** the outcome is recorded, **Then** the specific
   classification is written to the audit trail even though it was not shown to the passenger.
4. **Given** repeated failures, **When** the attempt limit is reached, **Then** the passenger is
   routed to the retry guidance path and, beyond it, to a human agent.
5. **Given** any failure, **When** it is presented, **Then** the passenger is never left on a
   frozen capture surface with no forward action.

---

### User Story 3 - A passenger stops, is interrupted, or cannot be captured at all (Priority: P2)

A call arrives mid-capture. The passenger lowers the phone. Someone cannot complete a facial
capture at all — a tremor, a visual impairment, an assistive setup that does not work with a
hands-free camera flow. The capture must abandon cleanly, discard everything it held, and offer a
route that ends with a person.

**Why this priority**: it protects the promise that the app is never the reason a passenger cannot
travel, and it prevents held biometric frames from outliving the moment they were taken. It ranks
below the two capture stories because it depends on them existing.

**Independent Test**: interrupt a capture by backgrounding the app, by an incoming call, and by
navigating back; verify in each case that held frames are discarded, the session survives as
incomplete, and a route to help remains available.

**Acceptance Scenarios**:

1. **Given** a capture in progress, **When** the app is backgrounded, the device locks, or the
   camera is seized by the system, **Then** the capture aborts, every held frame is discarded, and
   the passenger returns to a state they can restart from.
2. **Given** a capture in progress, **When** the passenger navigates back, **Then** the capture
   aborts, frames are discarded, and the enrollment session is preserved as incomplete rather than
   cancelled.
3. **Given** a passenger who cannot complete a hands-free facial capture, **When** they seek help,
   **Then** the agent route is reachable from this screen and leads to a person, not a retry loop.
4. **Given** a capture that stalls without progressing, **When** the time limit elapses, **Then**
   the capture ends with an explanation rather than continuing indefinitely.

---

### Edge Cases

- The passenger holds the phone at an angle, or in landscape. The capture either accommodates it
  or says so; it does not silently fail to make progress.
- The instruction changes faster than a passenger can read it. Each instruction must persist long
  enough to be acted on, and the phase indicator must not advance and retreat.
- The passenger cannot see the instructions while looking at the camera. This is the ordinary case,
  not an accessibility edge — a passenger following "mira directamente a la cámara" is by
  definition not reading the screen.
- Extreme lighting — direct terminal floodlight behind the passenger, or a dim jetbridge.
- A face is partially obstructed by a mask, a head covering, or hair. Whether this fails is the
  processor's rule, and it must match what the instructions screen (005) stated.
- Two faces in frame — a passenger helping a relative, or a crowded queue behind them.
- Connectivity is lost mid-capture. Held frames are discarded rather than queued to disk while
  waiting, and the passenger is told the verification could not be sent.
- A screenshot or screen recording is attempted during capture. Resolved in Clarifications: not
  blocked, consistent with 003/004's precedent — the constitution's screenshot-blocking rule is
  scoped to the credential/QR-pass screens specifically, and this screen's held data is
  memory-only regardless.
- The passenger reaches this screen without a confirmed identity record, by deep link or restored
  state. The capture must not open (FR-001).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The capture MUST NOT open without a current consent record and a confirmed identity
  record from screen 004.
- **FR-002**: The liveness and attack-detection decision MUST be made by the verification
  processor. The app MUST NOT conclude that a capture is live, genuine, or matching, in any build
  or mode — including happy-path builds, where a stub may answer but the app still only relays
  that answer, never derives one itself.
- **FR-003**: Capture MUST proceed automatically once framing is achieved, with no shutter
  control, and the surface MUST state that it is automatic.
- **FR-004**: The screen MUST display a dynamic instruction naming the single adjustment the
  passenger should make, and each instruction MUST remain visible long enough to be acted on.
- **FR-005**: Instructions MUST be conveyed through at least one non-visual channel — audio,
  haptic, or both — because a passenger looking into the camera is not reading the screen.
- **FR-006**: The screen MUST display progress that reflects the actual state of the capture.
  Progress MUST NOT advance on elapsed time alone, and MUST NOT display completion that has not
  occurred.
- **FR-007**: The phase indicator MUST reflect the capture's real stage and MUST NOT move
  backwards once a stage is complete.
- **FR-008**: Frames and derived biometric data MUST exist in memory only, for the duration of the
  capture and its verification call, and MUST be discarded on completion, failure, cancellation,
  interruption, or navigation away. They MUST NEVER be written to disk, a cache, a log, an
  analytics payload, or a crash report.
- **FR-009**: A failure caused by capture conditions the processor classifies with a specific,
  known reason MUST be presented with specific, actionable guidance in the vocabulary of the
  instructions screen.
- **FR-010**: A failure caused by attack detection MUST be presented using the exact same message
  and styling as the "unclassified quality failure" outcome (a legitimate, non-attack outcome the
  processor may also return when it cannot identify a specific reason) — never a message unique to
  attack detection. This MUST NOT name the signal or technique detected, and the two cases MUST be
  provably indistinguishable to the passenger (resolved in Clarifications): without a genuine,
  non-attack source for the same generic message, genericness itself would tell an attacker their
  attempt was flagged.
- **FR-011**: Every capture outcome MUST be recorded in the audit trail with its specific
  classification, including those presented generically to the passenger.
- **FR-012**: The system MUST count failed attempts within the enrollment session, separately from
  the document-capture attempt counter, and route to retry guidance, then to the agent path, on
  reaching a limit of 3 (resolved in Clarifications, mirroring 003-escanear-documento's own limit
  and constitutional basis).
- **FR-013**: The capture MUST end with an explanation if it does not progress within a defined
  time limit, rather than continuing indefinitely.
- **FR-014**: Interruption by backgrounding, device lock, incoming call, or system camera seizure
  MUST abort the capture and discard all held data.
- **FR-015**: Backward navigation MUST abort the capture, discard held data, and preserve the
  enrollment session as incomplete.
- **FR-016**: A help route MUST be reachable from this screen and MUST lead to the agent path for
  passengers who cannot complete a hands-free facial capture.
- **FR-017**: The screen MUST emit funnel events for entry, each phase reached, outcome by
  category, attempt count, and abandonment — carrying no frames, no biometric data, and no
  personal data.
- **FR-018**: Touch input on the capture surface MUST NOT capture, cancel, or alter the capture, as
  the footer states; only the explicit navigation and help controls respond.
- **FR-019**: The step indicator MUST show the document step complete and the selfie step active,
  consistently with screens 004 and 005.

### Key Entities

- **Capture session**: one hands-free liveness attempt, carrying its phase, its progress, and its
  outcome. Holds frames only while running.
- **Liveness outcome**: the processor's decision, classified at minimum as success, quality failure
  with a specific known reason, quality failure with no specific reason identified
  ("unclassified"), or attack detection. The classification shown to the passenger is deliberately
  coarser than the one recorded: unclassified-quality and attack-detection outcomes render with the
  identical generic message and styling (resolved in Clarifications), so the passenger-visible
  taxonomy has one fewer distinction than the audited one.
- **Instruction phase**: one stage of the capture with its own guidance. Ordered, and never
  revisited backwards within an attempt.
- **Attempt counter**: failures within the enrollment session, governing when the passenger is
  routed out of the loop. Separate from document capture's counter (resolved in Clarifications).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: ≥85% of passengers complete liveness on their first attempt.
- **SC-002**: The false rejection rate — legitimate passengers rejected — is ≤1% of captures,
  matching the product's reliability commitment.
- **SC-003**: Confirmed false accepts are zero. This is absolute; a single occurrence is a critical
  finding.
- **SC-004**: ≥95% of passengers complete this step within 30 seconds at p90, keeping enrollment
  inside the ≤3-minute budget.
- **SC-005**: Zero frames, images, or biometric templates are found on disk, in caches, in logs, or
  in crash reports after enrollment, verified by audit.
- **SC-006**: Zero passenger-facing messages disclose an attack-detection signal, verified by
  review of the complete message set.
- **SC-007**: 100% of capture outcomes are recorded with their specific classification in the audit
  trail.
- **SC-008**: ≥80% of passengers who fail a first attempt succeed on a subsequent one within the
  same session.
- **SC-009**: In testing with assistive technology, a passenger relying on non-visual channels can
  complete a capture unaided, or reaches the agent route without a dead end.

## Assumptions

- Liveness and attack detection are performed by the external processor, which returns a
  classification the app translates rather than interprets.
- The four phases in the reference correspond to real stages of the processor's capture, not to a
  decorative animation. If the processor exposes a different number of stages, the indicator
  follows the processor.
- The camera permission was granted at the document capture step; this screen introduces no new
  permission request.
- The conditions stated on the instructions screen (005) are the conditions this capture actually
  enforces. A divergence between the two is a defect in one of them.
- Only one capture runs at a time, and a new attempt begins from the first phase rather than
  resuming a partial one.
- **Screenshot/recording blocking** (resolved in Clarifications): deliberately NOT applied to this
  screen, consistent with 003/004's precedent — the constitution's rule is scoped to the
  credential/QR-pass screens, not capture screens in general.
- **Failed-attempt limit** (resolved in Clarifications): 3, separate from document capture's
  counter, persisted the same way (count + last-reset timestamp, scoped to this step) under
  Constitution Principle I's existing, generically-worded allowlist entry.
- **Stall time limit** (FR-013): no specific duration was given in the input; a reasonable default
  of 45 seconds is assumed — comfortably above SC-004's 30-second p90 target so legitimate slow
  attempts aren't cut off, while still bounding the worst case. `/speckit-plan` may adjust this
  against the processor's actual contract once known.
- This feature's happy-path deferrals (Delivery Mode), tracked for the pre-pilot exit review:
  - The fake liveness processor always passes, so quality-failure and attack-detection feedback
    paths (FR-009/FR-010) may be stubbed or unreachable in a happy-path build.
  - The instruction-phase and progress-ring animation may be simplified/stubbed.
  - Device capability gating (no front camera, permission denied) is not implemented here; assumed
    supported and granted, per 003's precedent.
  - Analytics are limited to the events FR-017 names; every emitted event still carries no personal
    data (not relaxable).

## Dependencies

- A current consent record (002) and a confirmed identity record (004).
- The verification processor's liveness contract: phases, progress signals, and an outcome
  taxonomy that separates quality failures from attack detection — FR-009 and FR-010 depend on that
  separation existing.
- The verification progress screen (007) as the success destination.
- Retry guidance (009) and agent escalation (010) as the destinations when attempts are exhausted
  or capture is impossible.

## Out of Scope

- The liveness algorithm, the matching algorithm, and their thresholds.
- The verification progress display and the credential issuance that follow.
- The retry and escalation screens themselves, referenced here only as destinations.
- Re-verification of an already-enrolled passenger on a later trip.
- Screenshot/screen-recording blocking (resolved in Clarifications — not applied, consistent with
  003/004).
