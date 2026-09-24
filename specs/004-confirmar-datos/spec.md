# Feature Specification: Extracted Data Confirmation (04 Confirmar datos)

**Feature Branch**: `004-confirmar-datos`

**Created**: 2026-09-21

**Status**: Draft

> **Superseded in part by 015** (`specs/015-integracion-backend`): the passenger types the name, number and expiry and chooses CC, CE or Pasaporte (FR-002a). Field re-verification has no backend and is not wired in release.

**Input**: User description: "Screen 04 Confirmar datos — shows the captured document and the fields
extracted from it, lets the passenger verify them, and takes their confirmation before the flow moves
to the selfie."

## UI Reference

The authoritative visual reference is
[`assets/04-confirmar-datos.png`](./assets/04-confirmar-datos.png) — not yet copied into this feature
directory; add it from `C:\Users\Usuario\Pictures\Screenshots\Captura de pantalla 2026-09-21
213556.png` before `/speckit-plan` if pixel-level fidelity matters. It is the source of truth for
layout, content order, and copy.

| Element | Content in the reference |
|---|---|
| Top bar | "‹ Atrás" (left), "Ayuda" (right) |
| Step indicator | Documento (active), Selfie, Listo — still within the document step |
| Document card | Navy card with a thumbnail of the captured document, a "✓ Capturado" badge, and a country marker ("COL") |
| Notice | "Verifica que los datos coincidan exactamente con tu documento original." |
| Field 1 | Nombre completo — "Mateo González Restrepo", with an edit affordance |
| Field 2 | Número de documento — "CC 1.234.567.890", with an edit affordance |
| Field 3 | Nacionalidad — "Colombiana", with an edit affordance |
| Field 4 | Fecha de vencimiento — "14 mar 2031", with an edit affordance |
| Primary action | "Los datos son correctos" |
| Secondary action | "Escanear de nuevo" |

Behaviors the reference establishes: the document image is shown back to the passenger as evidence of
what was read, the four extracted fields are presented read-only with an explicit affordance to edit
each, confirmation is a deliberate act, and re-scanning is available without leaving the flow.

### CONFLICT-001 — free editing of extracted identity fields (resolved)

The reference gives every field an edit affordance, including name and document number. Unrestricted
retyping would break the link between the physical document and the identity record at exactly the
point the product exists to establish it: the record would then assert what the passenger typed, not
what the document says — a direct collision with the zero-false-accepts budget.

**Resolved**: editing exists to correct a poor machine reading of a field (option (a) below), not as a
general-purpose text field (b), and not removed in favor of re-scan-only (c) — a passenger stuck behind
one wrong letter has no forward path otherwise. FR-004–FR-006 implement this: an edit is always
recorded as passenger-corrected against the retained original, and a material change to a
high-confidence field is never accepted on the passenger's assertion alone. This applies uniformly to
all four displayed fields — correctability is governed by the processor's confidence and the
materiality of the change, not by which field is being edited (see FR-005).

## Clarifications

### Session 2026-09-21

- Q: Does the issued credential's validity end at the document's expiry date, and is there a minimum
  remaining validity required to enroll at all? → A: Decouple credential validity from document
  expiry for this screen. FR-008 (block on an already-expired document) stands alone; no minimum
  remaining-validity threshold is added, and no near-expiry warning ships this release. Credential
  validity policy, if it differs from document expiry, is a backend/product decision out of this
  screen's scope.
- Q: Should screenshot/screen-recording capture be blocked on this screen, given it displays the
  passenger's full name and document number — more identifying data than the capture screen (003),
  where blocking was deliberately declined? → A: Do not block it, consistent with 003-escanear-documento's
  precedent. The underlying document image remains in-memory-only and is discarded per FR-011
  regardless of what a screenshot captures.
- Q: What confidence score counts as "high confidence" for a field, so that editing it triggers
  mandatory automated re-verification (FR-005) rather than being accepted on the passenger's word
  alone? → A: ≥0.95. Fields the processor reported below 0.95 confidence are treated as low-confidence;
  their edits are accepted and marked passenger-corrected without mandatory re-verification.
- Q: When an edit to a high-confidence field must be re-verified against the captured document, is
  that an automated re-check (the processor re-reads just that field from the retained image) with
  agent review as a fallback, or automated re-check only with no agent fallback? → A: Automated
  re-check only, no agent fallback. If the re-check cannot confirm the passenger's edit, confirmation
  is blocked and the passenger is directed to re-scan; this specific case does not escalate to the
  agent path.
- Q: Should there be a cap on how many correction attempts a passenger can make on this screen before
  being routed elsewhere, given each high-confidence correction now triggers an automated re-check
  call? → A: Yes — 3 unresolved correction attempts (session-scoped, any field) routes the passenger
  to re-scan, mirroring 003-escanear-documento's capture-attempt-cap pattern.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A passenger confirms correctly extracted data (Priority: P1)

The document was read cleanly. The passenger sees their name, document number, nationality, and expiry
date next to a thumbnail of the document they just photographed, checks them against the card in their
hand, and confirms. This takes seconds and is the only moment in the flow where a human verifies that
the machine read the document correctly.

**Why this priority**: confirmation is what turns an extraction into an identity record, and it is the
last point before the biometric step at which an error is cheap to fix. Everything downstream —
matching the face to the document, binding the passenger to a flight, authorizing them at a checkpoint
— inherits whatever is confirmed here.

**Independent Test**: complete a document capture, verify the extracted fields are displayed alongside
the captured image, confirm them, and verify that the identity record carries exactly those values and
that the flow advances to the selfie step.

**Acceptance Scenarios**:

1. **Given** a successful extraction, **When** this screen opens, **Then** it shows the captured
   document image and every extracted field that will be stored, with nothing stored that is not
   shown.
2. **Given** the fields are displayed, **When** the passenger reads them, **Then** each is labelled in
   the same vocabulary as the physical document, and the notice instructs comparison against the
   original.
3. **Given** the passenger confirms, **When** the flow advances, **Then** the confirmed values are
   recorded as the identity record and the passenger moves to the selfie step.
4. **Given** the passenger confirms, **When** the record is written, **Then** it retains only the
   fields shown on this screen, and the document image is discarded.

---

### User Story 2 - A passenger corrects a field the machine read wrong (Priority: P1)

One field is wrong — an accent dropped from a surname, a digit misread, a date transposed. The
passenger corrects it. The correction must be possible, because OCR is imperfect and a passenger stuck
behind a wrong letter has no way forward; but a corrected field cannot simply be believed, because the
product's guarantee is that the record matches the document, not that it matches what the passenger
typed.

**Why this priority**: it shares P1 because without it the flow dead-ends on an ordinary OCR error, and
because getting the trust model wrong here is the single easiest way to introduce a false accept. The
correction path is where the two risks meet.

**Independent Test**: produce an extraction with a wrong field, correct it, and verify that the
correction is recorded as passenger-supplied, that it is re-checked against the captured document
rather than accepted on trust, and that a correction which cannot be substantiated does not silently
become the record.

**Acceptance Scenarios**:

1. **Given** a field the processor reported with low confidence, **When** the passenger edits it,
   **Then** the edit is accepted and marked as passenger-corrected in the audit trail, with the
   original extracted value retained alongside it.
2. **Given** a field the processor read with high confidence, **When** the passenger edits it to a
   materially different value, **Then** the system MUST NOT accept it on trust; it automatically
   re-reads the disputed field from the retained document image, and where that re-check cannot confirm
   the edit, confirmation is blocked and the passenger is directed to re-scan rather than the value
   being accepted or an agent being pulled in.
3. **Given** any edit, **When** the passenger confirms, **Then** the record shows which fields were
   machine-read and which were passenger-corrected.
4. **Given** the passenger edits a field, **When** they enter a value inconsistent with the field's
   expected form, **Then** the problem is shown inline before confirmation is possible.
5. **Given** the passenger would rather start over, **When** they choose to re-scan, **Then** the
   extraction and any edits are discarded and they return to the capture step.
6. **Given** the passenger has made 3 unresolved correction attempts in this session (edits whose
   automated re-check could not confirm them), **When** the third is reached, **Then** the passenger is
   routed to re-scan rather than permitted to keep editing.

---

### User Story 3 - A document that cannot be used is caught before the biometric step (Priority: P2)

The document is expired, or the extraction is missing a field the product requires. Better to stop here
— with the document still in hand and no biometric taken — than after a selfie, a verification charge,
and two more minutes of the passenger's time.

**Why this priority**: it prevents spending a paid verification and a passenger's patience on an
enrollment that cannot succeed, and it is the cheapest possible place to fail. It ranks below the two
confirmation stories because it only applies to a minority of enrollments.

**Independent Test**: present documents that are expired and missing a required field, and verify each
is stopped here with an explanation and a next step rather than being carried into the selfie step.

**Acceptance Scenarios**:

1. **Given** an extracted expiry date in the past, **When** this screen opens, **Then** confirmation is
   blocked, the reason is stated plainly, and the passenger is directed to the conventional airport
   process.
2. **Given** a required field that could not be extracted, **When** this screen opens, **Then** the gap
   is shown explicitly rather than as a blank, and the passenger is offered a re-scan.

---

### Edge Cases

- The passenger edits a field and then re-scans. All edits are discarded with the extraction; a
  correction never survives onto a different document.
- The extracted name exceeds what the screen can show, or contains characters the field cannot render.
  The full value must remain visible and verifiable, since the passenger is being asked to compare it
  character by character.
- The document is a type whose fields differ — a passport carries different fields from a cédula. The
  screen shows the fields that document actually has rather than a fixed four.
- The passenger backgrounds the app at this point. The extraction is held for the session but the
  document image is not written to disk; on return the passenger either confirms or re-scans.
- Connectivity is lost before confirmation. Confirmation cannot be recorded, so the flow does not
  advance and the passenger is told why.
- A screenshot is attempted while the document number and full name are on screen. Resolved: not
  blocked, per the Clarifications above — consistent with 003-escanear-documento's precedent.
- A screen reader user reviews the fields. Each value must be announced in full, including
  character-by-character reading of the document number on request, since verification is the task.
- The extraction returns a nationality the product does not serve. This is the point at which the
  accepted-document decision from screen 003 becomes visible to the passenger.
- The passenger repeatedly edits a high-confidence field and each automated re-check fails to confirm
  it. Resolved: after 3 unresolved attempts in the session, the passenger is routed to re-scan rather
  than allowed to keep retrying (FR-019).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The screen MUST display the captured document image alongside the extracted fields, so
  the passenger can see what was read and from what.
- **FR-002**: The screen MUST display every extracted field that will be retained in the identity
  record, and MUST NOT retain any field it does not display.
- **FR-003**: Fields MUST be presented read-only by default, with an explicit action required to edit
  any of them.
- **FR-004**: An edit to a field MUST be recorded as passenger-corrected, preserving the original
  machine-extracted value alongside the corrected one in the audit trail.
- **FR-005**: An edit that materially changes a field the processor read with high confidence (defined
  as processor-reported confidence ≥0.95 — see Clarifications) MUST NOT be accepted on the passenger's
  assertion alone; the system MUST automatically re-verify it by re-reading the disputed field from the
  retained document image (resolved in Clarifications: automated re-check only, with no agent fallback
  for this specific case). Where the re-check confirms the edit, it is accepted as re-verified. Where
  the re-check cannot confirm it — because it disagrees or because the re-check itself fails —
  confirmation MUST be blocked and the passenger MUST be directed to re-scan; this case MUST NOT route
  to the agent path. A field reported below 0.95 confidence is low-confidence: its edit is accepted and
  recorded as passenger-corrected without mandatory re-verification. This rule applies uniformly to all
  displayed fields (name, document number, nationality, expiry alike) — resolved in CONFLICT-001 above:
  it is the processor's confidence and the materiality of the change that gate acceptance, not which
  field is being edited.
- **FR-006**: Edited values MUST be validated against the expected form of their field before
  confirmation is permitted, with any problem shown inline.
- **FR-007**: Confirmation MUST be an explicit act, MUST NOT be implied by scrolling or by time, and
  MUST be unavailable while any field is in an invalid or unresolved state.
- **FR-008**: The system MUST block confirmation when the document is expired, stating the reason and
  directing the passenger to the conventional airport process.
- **FR-009**: The system MUST show a field that could not be extracted as an explicit gap rather than
  as an empty value, and MUST offer a re-scan.
- **FR-010**: Re-scanning MUST discard the extraction and every edit made to it, and MUST return the
  passenger to the capture step with the enrollment session intact.
- **FR-011**: The document image MUST remain in memory only and MUST be discarded once confirmation is
  recorded or the passenger leaves the step, per the same rule that governs capture.
- **FR-012**: Field labels MUST use the vocabulary of the physical document so the passenger can compare
  them directly, and the notice instructing exact comparison MUST be visible before the fields.
- **FR-013**: Backward navigation MUST preserve the enrollment session as incomplete and MUST discard
  the held image; it MUST NOT silently confirm.
- **FR-014**: The screen MUST display progress within enrollment consistently with the preceding step.
- **FR-015**: Every field value MUST be fully announceable by assistive technology, including
  character-level reading of the document number, since verification is the passenger's task here.
- **FR-016**: The screen MUST emit funnel events for entry, edit of a field, re-scan, block due to an
  unusable document, confirmation, and abandonment — recording which field was edited, never its value.
- **FR-017**: Confirmation MUST be recorded durably before the flow advances; where it cannot be
  recorded, the flow MUST NOT advance and the passenger MUST be told.
- **FR-018**: Screenshot and screen-recording capture are explicitly NOT required to be blocked on this
  screen, consistent with 003-escanear-documento's precedent (see Clarifications) — a deliberate scope
  decision, not an oversight.
- **FR-019**: The system MUST count unresolved correction attempts — edits whose automated re-check
  (FR-005) could not confirm them — against a session-scoped cap of 3, and MUST route the passenger to
  re-scan on reaching the cap rather than permitting further edits (resolved in Clarifications,
  mirroring 003-escanear-documento's capture-attempt-cap pattern). The cap resets when the passenger
  re-scans.

### Key Entities

- **Extraction result**: the set of fields the processor read from the document, each with the value,
  the field it belongs to, and the confidence the processor assigned. Held for the session only.
- **Identity record**: what confirmation produces — the values the passenger verified, each marked as
  machine-read or passenger-corrected. The authority for every downstream check.
- **Field correction**: a passenger-supplied replacement for an extracted value, carrying the original
  value, the new one, and the resolution of whether it was substantiated. Counted against the
  session-scoped correction-attempt cap (FR-019) when unresolved.
- **Document validity**: the expiry date and the derived judgement of whether the document can support
  enrollment now.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: ≥90% of passengers confirm without editing any field, which is the practical measure of
  whether capture and extraction are working.
- **SC-002**: 100% of confirmed identity records distinguish machine-read from passenger-corrected
  values, verifiable from the audit trail.
- **SC-003**: Zero identity records contain a passenger-supplied value for a high-confidence field that
  was not automatically re-verified against the retained document image.
- **SC-004**: Zero enrollments proceed past this screen on an expired document.
- **SC-005**: ≥95% of passengers complete this step within 30 seconds at p90, keeping it inside the
  ≤3-minute enrollment budget.
- **SC-006**: Zero document images are found on disk, in caches, or in logs after this step, verified
  by audit.
- **SC-007**: In usability testing, ≥90% of participants who are shown a deliberately incorrect field
  notice it before confirming — the screen's entire purpose is that they do.
- **SC-008**: No field is stored that was not displayed here, verified by comparing the record schema
  against the screen.

## Assumptions

- Extraction is performed by the external processor and arrives with per-field confidence. If the
  processor does not supply confidence, FR-005 cannot be implemented as written and the correction
  model has to be decided differently.
- The passenger still has the physical document in hand at this moment, which is what makes
  verification meaningful.
- The four fields in the reference are the minimum set. Which fields a given document type yields may
  vary, and the screen renders what that document has.
- Confirmation here establishes the identity record; the biometric step that follows binds a face to
  it. The two are separate assertions and neither substitutes for the other.
- **Credential validity vs. document expiry** (resolved in Clarifications): this screen's only validity
  gate is FR-008 (block on an already-expired document). No minimum remaining-validity threshold is
  enforced, and no near-expiry warning ships this release; whether the issued credential's own validity
  window is bounded by the document's expiry is a backend/product policy decision outside this screen's
  scope, and can be revisited as a future amendment if a near-expiry warning is wanted.
- **Editability scope** (resolved in CONFLICT-001): all four displayed fields carry an edit affordance,
  per the UI reference. What differs by field is not whether it is editable but how a material,
  high-confidence correction is handled — always automatically re-verified, never accepted on assertion
  alone (FR-005).
- **Screenshot/recording blocking** (resolved in Clarifications): deliberately NOT applied to this
  screen, consistent with 003-escanear-documento's precedent, since the underlying data is in-memory
  only and discarded per FR-011 regardless of what a screenshot captures.
- **High-confidence threshold** (resolved in Clarifications): ≥0.95 processor-reported confidence. This
  requires the processor's extraction contract to supply a per-field confidence score in that range;
  see the first Assumption above.
- **Re-verification mechanism** (resolved in Clarifications): re-verifying a disputed high-confidence
  field is an automated re-read of that field from the retained document image, not a route to the
  agent path (010). An automated re-check that cannot confirm the edit blocks confirmation and directs
  the passenger to re-scan. This requires the processor's extraction contract to support re-reading a
  single named field on demand against an already-captured image, which is a capability beyond the
  single whole-document read 003 depends on and should be confirmed as available during planning.
- **Correction-attempt cap** (resolved in Clarifications): 3 unresolved correction attempts per
  session (FR-019), mirroring 003-escanear-documento's capture-attempt-cap pattern. Unlike that cap,
  this one is session-scoped rather than a durable, device-level counter — it was not raised as a
  cost-control concern requiring survival across an app kill, only as a bound on repeated automated
  re-checks within one sitting.

## Dependencies

- The document capture step (003) as the source of the image and the origin of any re-scan.
- The processor's extraction contract, including per-field confidence and the ability to re-read a
  single disputed field against a retained image on demand, both of which FR-005 depends on.
- A durable identity record store that can represent machine-read and passenger-corrected values
  distinctly.
- The selfie instructions step (005) as the success destination for a confirmed record.
- The accepted document types and their field sets, carried over from 003.

## Out of Scope

- OCR and authenticity verification themselves.
- The biometric capture and the face-to-document match.
- Editing identity data after enrollment completes, which is a support and re-enrollment concern.
- Agent-mediated review of a correction: resolved in Clarifications — an edit to a high-confidence
  field that the automated re-check cannot confirm blocks confirmation and directs the passenger to
  re-scan; it does not escalate to the agent path.
- A near-expiry warning or a minimum remaining-validity threshold (see Clarifications) — deferred to a
  future decision, should the credential's own validity policy require it.
