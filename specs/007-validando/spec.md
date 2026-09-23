# Feature Specification: Verification In Progress (07 Validando)

**Feature Branch**: `007-validando`

**Created**: 2026-09-23

**Status**: Draft

**Input**: User description: "Screen 07 Validando — the wait between the liveness capture and the
activated credential. Shows a three-step checklist that completes progressively while the
verification runs."

**Note on sequence**: this specification fills the gap between 006 (liveness capture) and 008
(credential activated). It owns the waiting state and the routing of every verification outcome;
008 owns only the settled success. Specification 008 is already implemented against a placeholder
for this screen, which requests credential issuance and hands the confirmed credential to 008 in
memory. This screen replaces that placeholder and **must keep that hand-off unchanged** (see
Dependencies).

## Delivery Mode: Happy Path First

Same section as specifications 005, 006 and 008; it governs build order here too (constitution
Principle III, "Happy-Path Development Mode").

The current priority is a working end-to-end flow. Development runs in happy-path mode: the flow
must be walkable from welcome to pass without the edge-case handling, gating, and hardening
described below. Nothing here removes a requirement — each relaxation defers one, by identifier.

**Relaxable during happy-path mode**, each recorded as a deferred requirement:

- Outcome routing. A failure may return to the previous screen instead of fanning out to the
  correct destination.
- The timeout, the stall handling, and the recovery-after-relaunch behavior of FR-009 and FR-010.
- Offline and connectivity handling.
- Timing budgets.
- Analytics completeness — events that exist must already carry no personal data.
- Backend and processor integrations, served by fakes implementing the real contract. A fake that
  completes in a fixed time is acceptable here.

**Deferred requirements, by identifier** (the constitution requires this list; a deferral not
written here is not a deferral):

| Requirement | What is deferred | What still holds in happy-path mode |
|---|---|---|
| FR-010 | Surviving app closure and reconciling after relaunch. Needs no constitution amendment: the job is keyed by the enrollment attempt id already in the consent record (plan research.md §1, §15) | This screen never submits anything, so it cannot resubmit; backgrounding does not cancel the job, and polling resumes on return |
| FR-015, FR-016 | Recovery-after-relaunch events, and duration across app launches | Every other event of FR-015 ships, with in-launch duration (FR-016); none carries personal data |
| SC-001, SC-008 | Measuring against the expected duration and abandonment targets | — |
| Backend integration | Served by a fake implementing the real contract, which may complete on a fixed schedule | The fake, not the screen, reports each stage and the issuance |

**Specific to this screen**: the three checklist steps may animate on a fixed schedule against a
fake processor, because a fake has no real stages to report. The schedule belongs to the fake, not
to the screen: the screen still only shows what the fake reports. **What may not happen, in any
build, is the final step reporting completion before the backend has confirmed issuance** — see
FR-005. The distinction is not cosmetic: a screen that declares an identity created on a timer is
the same defect as a credential displayed without backend affirmation, one screen earlier.

**Not relaxable, in any mode**:

- No real personal data; synthetic identities only.
- No persistence of images or biometric samples — by this screen they have already been discarded
  and nothing here reintroduces them.
- No personal data in logs, events, or crash reports.
- **No path that declares an identity created without backend affirmation** (FR-005).
- Attack-detection outcomes stay generic to the passenger (FR-012).
- Every relaxation lives behind a build flag that cannot be enabled in a release build.

**Exit from happy-path mode**: every deferred requirement is implemented or explicitly accepted as
out of scope, in writing, before any build reaches a real passenger — the airport pilot
integration (constitution Principle III).

## UI Reference

The authoritative visual reference is [`assets/07-validando.png`](./assets/07-validando.png),
copied from `C:\Users\Usuario\Pictures\Screenshots\Captura de pantalla 2026-09-23 095453.png`. It is
the source of truth for layout, content order, and copy, except where the conflicts below override
it.

| Element | Content in the reference |
|---|---|
| Header | "Verificando" |
| Step indicator | Documento, Selfie, Listo |
| Illustration | Document card with an arrow to a face, inside a circle carrying a partial progress ring |
| Title | "Estamos validando tu identidad" |
| Subtitle | "Esto toma unos segundos. No cierres la aplicación." |
| Checklist item 1 | "Documento verificado" — complete, filled check |
| Checklist item 2 | "Comparando rostro" — in progress, spinner |
| Checklist item 3 | "Creando identidad digital" — pending, dimmed |
| Navigation | None. No back control and no help control appear on this screen. |

Behaviors the reference establishes: the wait is narrated rather than hidden, progress is expressed
as three discrete stages that complete in order, the passenger is told roughly how long to expect
and asked not to leave, and the screen offers no way out.

### Conflicts raised by the reference

- **CONFLICT-001 — a screen with no exit and no stated limit.** This is the only screen in the flow
  with neither back nor help. That is defensible while a verification is genuinely in flight, but
  as drawn there is nothing that ends the wait if the processor stalls. A passenger in a security
  queue cannot be held on a spinner indefinitely. The requirements below add a timeout and a route
  out (FR-009). **Resolved** (Clarifications): help appears together with the "taking longer than
  usual" notice and the way out, not during a normal wait (FR-018).
- **CONFLICT-002 — "No cierres la aplicación" implies the work is local.** Verification runs on the
  backend; closing the app should not destroy it, and each verification consumes a paid
  validation, so losing one and re-running it costs twice. Resolved as a sequencing rule: the
  instruction stays while FR-010 is deferred, because until recovery exists it is accurate advice,
  and it is softened (for example to "Puedes salir; te avisaremos el resultado al volver") in the
  same change that ships FR-010.
- **CONFLICT-003 — the three steps may not correspond to anything.** If the processor does not
  report per-stage progress, this checklist is a timed animation wearing the costume of real
  status. **Resolved** (Clarifications): the verification contract exposes document check, face
  comparison, and issuance as three separately observable stages, so the checklist reflects real
  status. The contract must report each one; the offline-demo fake reports them on a schedule.
- **CONFLICT-004 — the step indicator shows "Listo" as reached.** Resolved: Listo shows as pending
  until the credential exists (FR-006). Documento and Selfie show as complete.

## Clarifications

### Session 2026-09-23

- Q: Does the verification contract expose document check, face comparison, and issuance as
  separately observable stages? → A: **Yes, all three.** The checklist shows real per-stage status
  (CONFLICT-003). The contract must report each stage; the offline-demo fake reports them on a
  fixed schedule, and the screen renders only what is reported (FR-003, FR-004).
- Q: What are the expected duration and the hard timeout? → A: **The "taking longer than usual"
  notice appears at 10 seconds; the wait ends at 30 seconds** with a stated outcome and a route
  onward (FR-009). Both are measured from the screen opening and sit well inside the
  constitution's 60-second contingency budget.
- Q: Should help be reachable during the wait? → A: **Only once the "taking longer than usual"
  notice appears**, alongside the way out (CONFLICT-001, FR-018). A normal wait shows no controls,
  as in the reference.
- Q: What does the way out offered at 10 seconds actually do? → A: **"Seguir esperando" plus the
  help control.** "Seguir esperando" dismisses the notice and the passenger stays on this screen;
  nothing navigates away and the verification keeps running, with the 30-second limit unchanged.
  Leaving the app early is not offered until FR-010's recovery exists.
- Q: When the 30-second limit is reached with no result, what does the passenger see and where
  does it lead? → A: **The technical-error path, with no attempt counted.** It offers "Consultar
  de nuevo", which checks the same verification again without resubmitting it, and states that the
  passenger can use the regular document check at the checkpoint.
- Q: When a stage fails, does this screen show the failure before routing? → A: **Yes, briefly.**
  The failed stage shows a failure icon and one generic line, "No pudimos completar la
  verificación", which is announced to assistive technology; after a fixed pause of about 1.5
  seconds the flow routes to the destination for that failure class.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A passenger waits through a successful verification (Priority: P1)

The selfie is done. The passenger holds the phone for a few seconds while the app tells them what
is happening: the document checked out, the face is being compared, the identity is being created.
Each line settles in turn and the flow moves on to the activated credential. The passenger never
wonders whether the app has frozen.

**Why this priority**: this is the only point in enrollment where the passenger can do nothing but
wait, and an unexplained wait is where people close the app — abandoning an enrollment that had
already consumed a paid validation. Narrating the wait is the entire purpose of the screen.

**Independent Test**: complete a liveness capture against a successful verification and confirm the
checklist advances in order, that no step shows complete before its result is known, and that the
flow advances to the credential screen once issuance is confirmed.

**Acceptance Scenarios**:

1. **Given** a submitted verification, **When** this screen opens, **Then** it states that
   validation is in progress and gives the passenger an expectation of duration.
2. **Given** the verification is running, **When** a stage completes, **Then** the corresponding
   checklist item shows complete and the next shows in progress.
3. **Given** the verification is running, **When** progress is displayed, **Then** no item shows
   complete before its underlying result is known.
4. **Given** the backend confirms credential issuance, **When** the final item completes, **Then**
   the flow advances to the activated credential screen.
5. **Given** the screen is displayed, **When** the passenger looks at it, **Then** no personal data,
   document number, or facial image appears.
6. **Given** the screen is displayed, **When** the passenger reads the step indicator, **Then**
   Documento and Selfie show complete and Listo shows pending.

---

### User Story 2 - A verification that fails is routed to the right place (Priority: P1)

The verification does not succeed. The document was rejected, the face did not match, the
credential could not be issued, or the service itself failed. Each of these means something
different for the passenger and leads somewhere different — re-scan, retry the selfie, talk to an
agent, or a technical error that is not the passenger's fault at all.

**Why this priority**: this screen is where every outcome of enrollment fans out. It shares P1
because a wait screen that can only succeed is a wait screen that hangs on failure, and because
sending a passenger to the wrong recovery — asking them to retake a selfie when the real problem
is that the service is down — wastes their time and an attempt they did not need to spend.

**Independent Test**: force each failure class in turn and verify the passenger lands on the
destination that matches it, with an attempt counted only where an attempt was actually consumed.

**Acceptance Scenarios**:

1. **Given** a verification rejected on the document, **When** the outcome returns, **Then** the
   passenger is routed to re-capture the document, not to retry the selfie, and the attempt counts
   against the document-capture limit.
2. **Given** a verification rejected on face comparison, **When** the outcome returns, **Then** the
   passenger is routed to the retry guidance path with the attempt counted against the selfie
   limit.
3. **Given** a failure caused by the service rather than the passenger, **When** the outcome
   returns, **Then** the passenger is routed to the technical-error path, no attempt is counted
   against them, and the message does not imply they did something wrong.
4. **Given** a rejection attributable to attack detection, **When** it is presented, **Then** the
   passenger-facing outcome remains generic and names no detection signal, consistent with
   specification 006.
5. **Given** the match succeeded but the credential was issued in a non-active state or with
   incomplete data, **When** the outcome returns, **Then** the passenger is routed to the outcome
   screen defined by specification 008 for that case, not asked to re-capture anything.
6. **Given** any failure, **When** it is presented, **Then** the checklist does not remain frozen
   mid-step as the passenger's last impression.

---

### User Story 3 - The wait is interrupted, stalls, or outlives the screen (Priority: P2)

The passenger backgrounds the app, takes a call, loses signal, or the processor simply takes far
longer than expected. The verification is running on the backend and has already been paid for;
none of these should destroy it or leave the passenger stranded.

**Why this priority**: it protects both the passenger's time and a validation that has already been
purchased. It ranks below the two above because it applies to a minority of enrollments, but it is
the difference between a recoverable hiccup and a lost enrollment.

**Independent Test**: background the app mid-verification and relaunch; separately, hold the
response past the timeout; verify the enrollment resumes or ends with a stated outcome in both
cases, and that no second verification is submitted for the same capture.

**Acceptance Scenarios**:

1. **Given** a verification in flight, **When** the app is backgrounded or the device locks,
   **Then** the verification is not cancelled and the passenger returns to this screen or its
   outcome.
2. **Given** a verification in flight, **When** the app is closed and relaunched, **Then** the app
   resumes the pending verification rather than discarding the enrollment, and does not submit the
   captured samples a second time.
3. **Given** a verification that exceeds the expected duration, **When** the threshold passes,
   **Then** the passenger is told it is taking longer than usual and is offered "Seguir esperando"
   and help, neither of which cancels the verification or leaves this screen.
4. **Given** a verification that exceeds the hard timeout, **When** the limit is reached, **Then**
   the wait ends on the technical-error path with no attempt counted, offering "Consultar de nuevo"
   and the regular checkpoint process — never an indefinite spinner.
5. **Given** the passenger chose "Consultar de nuevo" after a timeout, **When** the check runs,
   **Then** the same verification is queried again and no new verification is submitted.
6. **Given** connectivity is lost while waiting, **When** it returns, **Then** the app reconciles
   the verification's outcome rather than starting over.

---

### Edge Cases

- The verification completes while the app is backgrounded. On return the passenger sees the
  outcome, not a replay of the wait.
- The processor returns an outcome the app does not recognize. It is treated as a technical error,
  not as a rejection of the passenger, and counts no attempt.
- The backend confirms the match but issuance fails. These are different stages with different
  recoveries; a match that succeeded does not force a passenger to re-capture anything (US2
  scenario 5).
- The passenger force-quits during the wait, having been told not to. Recovery must exist anyway —
  the instruction is not a control (FR-010).
- The wait resolves in well under a second, with a fast processor or a cached result. The screen
  does not linger on an artificial minimum duration: each reported stage renders as it arrives,
  and the flow advances as soon as the outcome is known (see Assumptions).
- A screen reader user waits. Progress changes and the final outcome are announced, since there are
  no controls to navigate and the only content is the changing state (FR-014).
- The passenger is at a checkpoint with poor connectivity, and the wait is long for reasons outside
  the app. The "longer than usual" notice and the hard timeout still apply (FR-009).
- The outcome arrives while the passenger has help open (FR-018). The verification is not lost:
  closing help shows the outcome, or routes to its destination, instead of resuming the wait.
- The passenger presses the system back gesture during the wait. It does not cancel the
  verification or return into the capture steps; it is ignored while a stage is running (FR-017).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The screen MUST state that verification is in progress and give the passenger an
  expectation of how long it should take.
- **FR-002**: The screen MUST narrate progress as discrete stages, each showing pending, in
  progress, or complete.
- **FR-003**: A stage MUST NOT display as complete before the verification contract reports its
  result. The contract reports document check, face comparison, and issuance separately
  (Clarifications); the screen shows exactly those three stages, in that order.
- **FR-004**: Progress MUST NOT advance on elapsed time alone, consistent with the rule applied to
  the liveness capture. In happy-path mode a fake may report stages on a fixed schedule; the screen
  still only renders what is reported.
- **FR-005**: The final stage MUST NOT report the identity as created until the backend has
  confirmed credential issuance, in any build or mode.
- **FR-006**: The step indicator MUST show the completion step (Listo) as pending until the
  credential exists.
- **FR-007**: On success, the flow MUST advance to the activated credential screen, using the
  hand-off specification 008 defines.
- **FR-008**: On failure, the system MUST route by failure class: document rejection to document
  re-capture; face comparison rejection to the retry guidance path; attack detection to the same
  destination and message as a generic selfie failure; a non-active or incomplete issuance to 008's
  outcome screen for that case; service or technical failure, and any unrecognized outcome, to the
  technical-error path. An attempt MUST be counted only where a passenger-attributable attempt was
  consumed, against the counter of the step that attempt belongs to.
- **FR-009**: At 10 seconds after the screen opens, the system MUST tell the passenger the wait is
  running longer than usual and offer "Seguir esperando", which dismisses the notice without
  navigating away or cancelling anything, together with help (FR-018). At 30
  seconds, the wait MUST end on the technical-error path with no attempt counted. That outcome
  MUST offer "Consultar de nuevo", which queries the same verification again and MUST NOT submit a
  new one, and MUST state that the passenger can use the regular document check at the
  checkpoint. Both values are named,
  configurable constants and MUST stay within the constitution's 60-second contingency budget.
- **FR-010**: A verification in flight MUST survive backgrounding, device lock, app closure, and
  loss of connectivity. On return the app MUST reconcile its outcome and MUST NOT submit the same
  captured samples for verification twice.
- **FR-011**: The screen MUST NOT display personal data, document numbers, or facial images.
- **FR-012**: Failures attributable to attack detection MUST be presented generically here as well,
  naming no detection signal, consistent with specification 006.
- **FR-013**: On a failure, the stage that failed MUST show a failure state with one generic line,
  "No pudimos completar la verificación", announced to assistive technology (FR-014). After a fixed
  pause of about 1.5 seconds, a named constant, the flow MUST route to the destination for that
  failure class (FR-008). The line MUST be identical for every failure class, so it never reveals
  which class occurred (FR-012). The checklist never stays frozen mid-stage.
- **FR-014**: Progress changes and the final outcome MUST be announced to assistive technology,
  since this screen has no controls and its content is entirely state.
- **FR-015**: The screen MUST emit events for entry, each stage reached, outcome by class, duration,
  timeout, and recovery after interruption — carrying no personal data.
- **FR-016**: Verification duration MUST be recorded such that its distribution can be measured
  against the enrollment time budget.
- **FR-017**: While a verification is running, the system back gesture MUST NOT cancel it or return
  the passenger into the capture steps.
- **FR-018**: No help or exit control MUST appear during a normal wait. When the "taking longer than
  usual" notice appears (FR-009), a help control MUST appear with it, alongside "Seguir esperando".
  Opening help MUST NOT cancel or invalidate the verification.

### Key Entities

- **Verification job**: one submitted verification, identified so it can be reconciled after an
  interruption rather than resubmitted. Owned by the backend; the app observes it.
- **Verification stage**: an observable step of that job — document check, face comparison,
  issuance — each with a pending, running, or settled state, as reported by the contract
  (Clarifications).
- **Outcome class**: what the result means for routing — success, document rejection, face-match
  rejection, attack detection, non-active or incomplete issuance, service failure. The class drives
  the destination; the passenger-facing message is deliberately coarser for the security-relevant
  classes.
- **Attempt**: a passenger-attributable failure that counts against the retry limit of the step it
  belongs to. Service failures are not attempts.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: ≥95% of verifications resolve within 10 seconds, the point where the "taking longer
  than usual" notice appears, measured from the screen opening to the outcome.
- **SC-002**: Zero verifications leave the passenger on this screen past the hard timeout without
  an outcome and a route onward.
- **SC-003**: 100% of failures are routed to the destination matching their outcome class, verified
  by exercising every class.
- **SC-004**: Zero duplicate verifications are submitted for the same capture after an
  interruption, verified from the backend's job records — each duplicate is a paid validation spent
  twice.
- **SC-005**: ≥95% of enrollments interrupted during the wait resume successfully rather than
  restarting.
- **SC-006**: Zero service failures are counted as passenger attempts.
- **SC-007**: Zero passenger-facing messages on this screen disclose an attack-detection signal.
- **SC-008**: Abandonment during the wait is below 3% of enrollments that reach this screen.
- **SC-009**: With assistive technology, the outcome of the wait is announced without the user
  needing to interact.
- **SC-010**: Zero screens show "Creando identidad digital" as complete without a backend-confirmed
  issuance, verified by test in every build flavor.

## Assumptions

- Verification runs on the backend and continues independently of the app's lifecycle. The screen
  observes a job; it does not perform the work.
- Each verification consumes a paid validation, which is why duplicate submission is a success
  criterion rather than a robustness detail.
- The captured samples have already left the device by the time this screen appears, and nothing
  here holds or re-reads them.
- The three stages in the reference are real backend stages, reported separately by the
  verification contract (Clarifications).
- **Attempt counters are per step, not shared.** Specification 006 already resolved this: document
  capture and selfie each keep their own counter with a limit of three. A document rejection here
  counts against the document counter; a face-match rejection against the selfie counter.
- **A document rejection means redoing the selfie too.** The captured samples were discarded
  after 006 and may not be kept for reuse (constitution Principle I), so re-capturing the document
  leads through confirmation and the selfie again before a new verification is submitted.
- **Liveness rejections surface at 006, not here.** The liveness capture already reports its own
  outcome, and only a passed liveness check reaches this screen. The "liveness rejected" class
  therefore applies here only if the backend re-evaluates liveness after capture; if it does, it
  routes like a face-match rejection.
- **No artificial minimum display time on success.** Each stage renders when reported and a
  success advances as soon as issuance is confirmed, favouring the ≤3-minute enrollment budget.
  The only fixed pause on this screen is the brief failure display of FR-013, which exists so the
  failure is seen and announced before the screen changes.
- Recovery after relaunch (FR-010) needs a verification-job identifier that survives the app
  closing. That identifier is not on the constitution's persisted-state allowlist, so shipping
  FR-010 requires an amendment, confirmed during planning.
- Copy is in Spanish (Colombia), matching the reference and specifications 001–008.

## Dependencies

- The verification contract, reporting the three stages separately and returning the outcome
  classes of FR-008 — FR-003 and FR-008 both depend on this.
- A verification job identifier that survives app restarts, for FR-010, and the constitution
  amendment to persist it.
- The liveness capture (006) as the origin and the submitter of the job.
- Specification 008's hand-off: this screen replaces the placeholder that currently requests
  issuance, and must keep its behavior — open the activated credential screen only on a confirmed
  active credential, hand it over in memory, and send non-active or incomplete issuance to 008's
  outcome screen.
- The activated credential screen (008) as the success destination; document re-capture (003),
  retry guidance (009), and technical error (011) as the failure destinations.

## Out of Scope

- The verification algorithms and their thresholds.
- Credential issuance itself, and the activated credential surface.
- The retry, escalation, and technical-error screens, referenced here only as destinations.
- Re-verification of an already-enrolled passenger on a later trip.
