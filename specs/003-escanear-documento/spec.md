# Feature Specification: Identity Document Capture (03 Escanear documento)

**Feature Branch**: `003-escanear-documento`

**Created**: 2026-09-21

**Status**: Draft

**Input**: User description: "Screen 03 Escanear documento — the first capture step. Full-screen dark camera with a framing guide, torch control, manual capture, and an inline error variant for unusable captures."

## UI Reference

The authoritative visual reference is
[`assets/03-escanear-documento.png`](./assets/03-escanear-documento.png) — not yet copied into this
feature directory; add it from `C:\Users\Usuario\Pictures\Screenshots\Captura de pantalla 2026-09-21
155948.png` before `/speckit-plan` if pixel-level fidelity matters. It is the source of truth for
layout, content order, and copy.

| Element | Content in the reference |
|---|---|
| Top bar, left | "‹ Atrás" |
| Top bar, right | "Ayuda" |
| Step indicator | Three segments — Documento (active, turquoise), Selfie, Listo |
| Instruction | "Ubica tu cédula o pasaporte dentro del marco" |
| Viewfinder | Full-screen dark camera preview with turquoise corner brackets, a horizontal scan line, and a faint document placeholder inside the frame |
| Hint, below frame | "Evita reflejos y sombras" |
| Control, left | Torch toggle (lightning icon) |
| Control, centre | Large capture button |
| Control, right | Clock icon — omitted from this feature's scope (see Clarifications/Assumptions); not built |
| Caption | "Toca el círculo central para capturar" |

Behaviors the reference establishes: capture is manual and initiated by the passenger, the step is
presented as the first of three, and an exit to help exists at the top right without leaving the
flow dead-ended.

The design also defines an error variant of this screen — the same layout with the frame in red and
an inline error message. That variant is specified here as part of the same feature, under User
Story 2, rather than as a separate screen.

## Clarifications

### Session 2026-09-21

- Q: Given FR-020 leaves screenshots unblocked, doesn't a screenshot of the live preview put a document image "on disk," conflicting with SC-004? → A: Keep FR-020 as-is; scope SC-004's wording to explicitly exclude OS-level screenshots — the app's own storage/logs/cache remain the audited surface.
- Q: Since the 3-attempt limit is tied to the in-memory, session-scoped counter that dies on app kill, doesn't that let a passenger bypass the limit by force-killing and reopening the app? → A: Make the counter durable — it MUST survive an app kill, requiring a new persisted, device-level attempt counter (not session-scoped in-memory state). Flagged for `/speckit-plan`'s Constitution Check: this is very likely a new category of persisted state outside Principle I's current allowlist (credential token, validity window, display-only identity subset, consent record) and will need either a clean design that avoids the conflict or a constitution amendment — the same kind of tension 001-bienvenida's planning phase hit and resolved by narrowing, not something to silently work around here.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A passenger captures their document on the first attempt (Priority: P1)

A passenger who has just given consent points their phone at their cédula or passport, sees it
framed by the guide, and taps to capture. The image is good enough to read, and the flow moves on to
confirming the extracted data. From the passenger's side this should take seconds and require no
thought beyond holding the document still.

**Why this priority**: this is the first step that produces the raw material the entire product
depends on, and it is the first step that costs money — every capture sent for verification
consumes a paid validation. A capture step that works on the first attempt is simultaneously the
fastest enrollment, the cheapest one, and the one that keeps the self-service rate up.

**Independent Test**: with consent recorded, open the capture step, capture a well-lit document, and
verify that the image is accepted, that extraction proceeds, and that no copy of the image remains
on the device afterward.

**Acceptance Scenarios**:

1. **Given** a passenger with a current consent record, **When** the capture step opens, **Then**
   the camera permission is requested with an explanation of why it is needed, and the camera
   preview starts only after permission is granted.
2. **Given** the camera preview is active, **When** the passenger positions the document within the
   frame and taps capture, **Then** the image is assessed for usability on the device before
   anything is transmitted.
3. **Given** a capture that passes the on-device quality check, **When** it is submitted, **Then**
   the flow advances to data confirmation and the step indicator reflects that the document step is
   done.
4. **Given** a completed capture, **When** the flow has advanced, **Then** no document image exists
   on disk, in the media gallery, in a cache, or in any log or crash report.
5. **Given** the capture step is open, **When** the passenger has not yet captured, **Then** the
   framing guidance and the "evita reflejos y sombras" hint are visible without obscuring the frame.

---

### User Story 2 - A capture is unusable and the passenger is told exactly why (Priority: P1)

The photo comes out blurred, glared, cropped, or aimed at the wrong side of the document. The
passenger must learn this immediately, in terms they can act on — "hay reflejo sobre el documento",
not "error de validación" — and be able to retry without leaving the screen or losing their place in
enrollment.

**Why this priority**: it shares P1 with the success path because a capture step without a usable
failure path is not shippable, and because this is where the enrollment funnel actually leaks.
Document capture fails for ordinary reasons — a worn cédula, a plastic sleeve, terminal lighting —
and each unusable capture that reaches the provider costs a paid validation and returns a slower,
vaguer answer than the device could have given instantly.

**Independent Test**: capture deliberately unusable images of each kind — blurred, glared, partially
out of frame, wrong side — and verify that each produces a specific, actionable message on the same
screen, that retry is immediate, and that failures rejected on the device never reach the provider.

**Acceptance Scenarios**:

1. **Given** a capture that fails the on-device quality check, **When** the result is shown, **Then**
   the frame indicates the error state and an inline message names the specific problem and the
   corrective action, on the same screen.
2. **Given** an unusable capture rejected on the device, **When** the passenger retries, **Then** no
   verification was consumed for the rejected attempt.
3. **Given** a capture that passes the device check but is rejected by verification, **When** the
   result returns, **Then** the passenger is returned to this screen with the reason expressed in
   the same actionable vocabulary, not the processor's error text.
4. **Given** repeated failures, **When** the attempt limit is reached, **Then** the passenger is
   moved to the retry guidance path rather than being allowed to loop indefinitely. Resolved: the
   limit is 3 failed attempts within the current enrollment session (see Assumptions).
5. **Given** any error state, **When** it is displayed, **Then** the error is conveyed by text and
   iconography, never by the red frame alone.

---

### User Story 3 - A passenger who cannot complete the capture gets out cleanly (Priority: P2)

Something makes capture impossible: the camera permission was denied, the lens is broken, the
document is too damaged to read, or the passenger simply cannot hold the phone steady. They need a
way out that ends somewhere useful rather than at a camera that will never work.

**Why this priority**: it protects the promise that the app is never the reason a passenger cannot
travel, and it is the entry point to the agent path that the rejection block exists to serve. It
ranks below the two capture stories because it has no purpose until capture exists.

**Independent Test**: deny the camera permission, then attempt the step; separately, exhaust the
attempt limit; verify that each lands on a route with a concrete next step and that the conventional
airport process is stated as available.

**Acceptance Scenarios**:

1. **Given** the passenger denies the camera permission, **When** the step cannot proceed, **Then**
   the app explains what is blocked, offers the route to the system settings that would unblock it,
   and states that the conventional airport process remains available.
2. **Given** the passenger has permanently denied the permission, **When** they return to this step,
   **Then** the app does not re-prompt the system dialog in a loop; it routes to the explanation
   directly.
3. **Given** the passenger activates "Ayuda", **When** the help route opens, **Then** they can
   return to the capture step without losing their enrollment session.
4. **Given** the passenger activates "Atrás", **When** they leave the step, **Then** any captured
   image is discarded immediately and the enrollment session is preserved as incomplete rather than
   cancelled.

---

### Edge Cases

- Consent is missing, stale, or refers to a superseded version. The camera must not open at all;
  the passenger returns to the consent gate.
- The device is offline at the moment of capture. The capture is held and the passenger is told the
  verification cannot be sent yet, with a clear retry — the image is never queued to disk to survive
  the wait.
- The app is backgrounded mid-capture, or the device locks. The camera stops and any held image is
  discarded; on return the passenger starts the capture again with the session intact.
- A call or system interruption seizes the camera. The preview recovers or the step fails with a
  clear message; it never presents a frozen frame as a live preview.
- Terminal lighting is extreme — direct floodlight causing glare, or a dim jetbridge. The torch is
  reachable one-handed and the guidance names the actual problem.
- The document is in a plastic sleeve or laminated, producing reflections the passenger does not
  perceive. The quality check must catch this rather than passing it to the processor.
- The passenger presents a document type the product does not accept. Resolved: the accepted set is
  cédula de ciudadanía and Colombian passport only (see Assumptions); any other document — cédula de
  extranjería, PEP, foreign passport — is treated as a wrong-document rejection by the quality
  assessment, with messaging that says so rather than a generic capture error.
- The passenger is using a screen reader or cannot see the frame. Framing is inherently visual; the
  step must offer an alternative route to enrollment rather than an unusable screen.
- A screenshot or screen recording is attempted while a document is in frame. Resolved: screenshots
  and screen recording are NOT blocked on this screen (see Assumptions) — unlike the credential and
  QR pass screens, this is a deliberate scope decision, not an oversight.
- The passenger taps capture repeatedly or double-taps. Exactly one capture is processed.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The step MUST NOT open the camera unless a current consent record exists covering
  identity verification. Where it does not, the passenger MUST be returned to the consent gate.
- **FR-002**: The camera permission MUST be requested at this step, accompanied by an explanation of
  what it is used for, and MUST NOT be requested before consent was given.
- **FR-003**: The screen MUST present a framing guide, an instruction naming the accepted documents,
  and guidance on avoiding glare and shadow, all visible while the preview is active.
- **FR-004**: Capture MUST be initiated by the passenger through the central control. If automatic
  capture assistance exists, it MUST be additive and MUST NOT remove manual capture.
- **FR-005**: The step MUST provide a torch toggle reachable within a one-handed grip.
- **FR-006**: Every capture MUST be assessed on the device for blur, glare, framing, and resolution
  before any transmission, and a capture failing that assessment MUST NOT be sent for verification.
- **FR-007**: A failed assessment MUST be presented inline on the same screen, naming the specific
  problem and the corrective action, conveyed by text and iconography rather than color alone, with
  retry available immediately.
- **FR-008**: A rejection returned by verification MUST be translated into the same actionable
  vocabulary as device-side rejections; processor error text MUST NEVER be shown to the passenger.
- **FR-009**: The system MUST count failed attempts against a durable, device-level counter that
  survives the app process being killed — NOT a session-scoped, in-memory counter — and, on reaching
  3 failures, MUST route the passenger to the retry guidance path rather than permitting an
  indefinite loop (resolved in Clarifications: an in-memory counter would let a passenger bypass the
  limit by force-killing and reopening the app). This is not tracked per-day or per-passenger-across-
  devices at this release — see Assumptions.
- **FR-010**: The captured image MUST exist only in memory for the duration of the verification call
  and MUST be discarded on success, failure, cancellation, backgrounding, or navigation away. It
  MUST NEVER be written to disk, the media gallery, a cache, a log, or a crash report.
- **FR-011**: The step MUST display progress within enrollment — document, selfie, completion — and
  the indicator MUST reflect actual state rather than a fixed illustration.
- **FR-012**: Backward navigation MUST discard any held image and preserve the enrollment session as
  incomplete, so it can be resumed rather than restarted.
- **FR-013**: A help route MUST be available from this screen and MUST return the passenger to the
  capture step with the session intact.
- **FR-014**: When the camera permission is denied, the step MUST explain what is blocked, offer the
  route to system settings, state that the conventional airport process remains available, and MUST
  NOT re-prompt the system dialog repeatedly.
- **FR-015**: When connectivity is unavailable, the step MUST tell the passenger the verification
  cannot be sent yet and offer retry, without persisting the image to wait.
- **FR-016**: Exactly one capture MUST be processed per activation of the capture control, regardless
  of repeated or rapid taps.
- **FR-017**: The step MUST offer passengers who cannot complete a visual capture an alternative
  route into enrollment via the agent path, rather than presenting a screen they cannot use.
- **FR-018**: The step MUST emit funnel events for entry, capture attempt, device-side rejection,
  verification rejection, success, and abandonment, keyed to an anonymous session identifier and
  containing no image data and no extracted personal data.
- **FR-019**: The screen MUST accept exactly two document types — cédula de ciudadanía and Colombian
  passport — and the instruction text and the quality assessment's "wrong document" detection MUST
  both be driven by that same accepted-document set — never two different lists.
- **FR-020**: Screenshot and screen-recording capture are explicitly NOT required to be blocked on
  this screen (a deliberate scope decision — see Assumptions), unlike the constitution's existing
  requirement for the credential and QR pass screens. SC-004 is scoped accordingly (see
  Clarifications) — it audits the app's own storage, not what a passenger's own screenshot captures.
- **FR-021**: The right-hand "clock" control shown in the UI reference is OUT OF SCOPE for this
  feature. The screen ships with only the torch toggle and the capture button; no third control is
  built. Revisit in a future design pass if a self-timer, auto-capture, or capture-history
  affordance is wanted.

### Key Entities

- **Capture attempt**: one activation of the capture control, carrying its assessment outcome and,
  if submitted, the verification result. Counted against the attempt limit; holds no image once
  resolved.
- **Quality assessment**: the device-side judgement of whether an image is usable, expressed as a
  specific reason the passenger can act on rather than a score.
- **Document image**: the raw capture. In-memory only, never persisted, never logged, discarded at
  the end of the attempt.
- **Accepted document type**: the set of identity documents the product will process, which
  determines the instruction text and what the assessment treats as the wrong document.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: ≥85% of passengers produce an accepted document capture on their first attempt.
- **SC-002**: ≥95% of passengers complete this step within 45 seconds at p90, keeping it inside the
  ≤3-minute enrollment budget.
- **SC-003**: ≥90% of unusable captures are rejected on the device, before consuming a paid
  verification.
- **SC-004**: Zero document images are found in the app's own storage, caches, logs, or crash
  reports, verified by audit on a device that has completed enrollment. This is scoped to what the
  app itself writes — it does not cover a document image a passenger captured via their own OS-level
  screenshot or screen recording of the live preview, which FR-020 explicitly permits and which is
  outside the app's control surface.
- **SC-005**: Zero captures are transmitted without a current matching consent record, verified from
  the audit trail.
- **SC-006**: ≥80% of passengers who hit a capture error recover within the same session rather than
  abandoning.
- **SC-007**: No passenger reaching the attempt limit is left without a next step, verified by
  walking every terminal state in testing.
- **SC-008**: In usability testing, ≥90% of participants shown an error message can state what to
  change before their next attempt.

## Assumptions

- Consent (002-consentimiento) is a hard precondition and has already been recorded before this step
  is reachable.
- Verification — OCR and authenticity checks — is performed by the external processor; this step's
  responsibility ends at producing a usable image and translating the outcome.
- Each submitted capture consumes a paid validation, which is why the device-side quality gate exists
  and why its effectiveness is a success criterion rather than an optimization.
- Capture is manual, per the reference. Automatic assistance, if added, supplements it.
- **Front side only**: this step captures a single side of the document. Both the Colombian cédula
  de ciudadanía's biodata face and a passport's biodata page carry the OCR-relevant identity data on
  one side, and the reference depicts a single capture screen with no "flip the document" step. A
  reverse-side capture (e.g. for a future feature that needs the cédula's back) is out of scope and
  would be a separate screen, not a variant of this one, if ever needed.
- **Attempt limit**: 3 failed attempts, counted against a durable, device-level counter that survives
  an app kill (resolved in Clarifications — an in-memory, session-scoped counter would let a
  passenger trivially bypass the cap by force-killing and reopening the app, undermining FR-009's
  cost-control purpose). Not tracked per-passenger-per-day or across devices — that would require a
  backend-side rate limit this spec doesn't own. This local durable counter is very likely a new
  category of persisted state outside Constitution Principle I's current allowlist; `/speckit-plan`
  MUST resolve this explicitly in its Constitution Check (design around it, amend the constitution,
  or narrow this requirement) rather than silently persisting it.
- The passenger holds the physical document at the moment of enrollment; capture from a stored photo
  of a document is out of scope and is treated as an unusable capture.
- **Accepted document types**: cédula de ciudadanía and Colombian passport only, matching the UI
  reference's literal "cédula o pasaporte" text. Cédula de extranjería, PEP, and foreign passports
  are explicitly not accepted at this release; a passenger presenting one is rejected with
  wrong-document messaging, not silently processed. Broadening this set is a future amendment, not
  an oversight.
- **Screenshot/recording blocking**: deliberately NOT applied to this screen, unlike the credential
  and QR pass screens the constitution already covers. The live camera preview and any
  momentarily-held captured image are governed by FR-010's in-memory-only/never-persisted rule
  regardless; screenshot-blocking was considered and declined for this screen specifically.
- **The clock-icon control**: out of scope. The reference shows it but its purpose was never
  established, and building the wrong interaction (self-timer vs. auto-capture vs. history) risks
  more rework than shipping without it. The screen has two controls: torch toggle and capture
  button.

## Dependencies

- A recorded, current consent (002-consentimiento) as a precondition, and the consent gate as the
  fallback destination when it is absent.
- The verification processor contract, including the outcome taxonomy this step must translate into
  passenger-facing language.
- The data confirmation step (004) as the success destination.
- The retry guidance (009) and agent escalation (010) paths as the destinations when attempts are
  exhausted or capture is impossible.

## Out of Scope

- OCR, authenticity checking, and face matching, all of which belong to the processor.
- Reviewing or correcting the extracted data, specified with screen 04.
- The selfie and liveness steps.
- The retry and escalation screens themselves, referenced here only as destinations.
- Reverse-side document capture (see Assumptions).
