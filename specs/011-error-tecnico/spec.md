# Feature Specification: Service Failure (11 Error técnico)

**Feature Branch**: `011-error-tecnico`

**Created**: 2026-09-23

**Status**: Draft

> **Superseded in part by 015** (`specs/015-integracion-backend`): the backend has no service-status endpoint. Release omits the card, and `NO_CONCLUYENTE`'s `reintentar_en_segundos` paces the retry.

**Input**: User description: "Screen 11 Error técnico — shown when verification fails for reasons
attributable to the service rather than the passenger. States that it is not the passenger's fault,
shows component status, confirms their progress is preserved, and offers a retry."

**Note on sequence**: this screen replaces the technical-error placeholder that 007 already routes
to. Today three outcomes of 007 arrive there: the verification job reports a service failure (or a
code the app does not recognize), the credential issuance request fails, and the 30-second hard
timeout expires. The first two are known service failures. **The timeout is not** — the app waited
and received nothing, which may be the service or may be the passenger's connection. That
distinction drives FR-009 and FR-010.

## Delivery Mode: Happy Path First

Same section as specifications 005 through 010; it governs build order here too (constitution
Principle III, "Happy-Path Development Mode").

The current priority is a working end-to-end flow. Development runs in happy-path mode: the flow
must be walkable from welcome to pass without the edge-case handling, gating, and hardening
described below. Nothing here removes a requirement — each relaxation defers one, by identifier.

**Relaxable during happy-path mode**, each recorded as a deferred requirement:

- Live component status; the status card may be omitted entirely rather than faked.
- Retry backoff and the wait guidance of FR-008.
- Offline-versus-service-failure discrimination.
- Analytics completeness — events that exist must already carry no personal data.
- Backend integrations, served by fakes implementing the real contract.

**Deferred requirements, by identifier** (the constitution requires this list; a deferral not
written here is not a deferral):

| Requirement | What is deferred | What still holds in happy-path mode |
|---|---|---|
| FR-007, SC-004 | A live status source | **The card is omitted.** It is never rendered from copy or from hard-coded values; the fake source reports "no status available" |
| FR-008 | Pacing repeated retries | The guidance never advises waiting while the button invites an immediate retry against a known-degraded part |
| FR-009, SC-005 | Telling a connectivity failure from a service failure | The screen still never asserts a cause it does not know (FR-010): a timeout reads as "we could not finish", not "our servers failed" |
| FR-006, SC-003 | The alert rule that turns the app's error report into a notification to the team | The app already sends the error report for every known service failure; **the "equipo notificado" sentence stays hidden** behind a build flag until the rule is confirmed to exist |
| FR-015, FR-016 | The complete event set and the occurrence rate | Any event that is emitted carries no personal data |
| Backend integrations | A real status source and a real verification job | Fakes implement the same contract the real services will |

**Specific to this screen**: the status card may be absent in development, but **it may not display
invented status**. A component reported "Operativo" by hard-coded text is worse than no card,
because the card's only value is that it is true. Likewise, the claim in FR-006 that the team was
notified may not ship before the alerting it refers to exists.

**Not relaxable, in any mode**:

- No real personal data; synthetic identities only.
- **No persistence of images or biometric samples — including to make a retry cheaper** (FR-005).
  See CONFLICT-001, which is the whole substance of this screen.
- No personal data in logs, events, or crash reports.
- **No service failure counted as a passenger attempt** (FR-002).
- Every relaxation lives behind a build flag that cannot be enabled in a release build.

**Exit from happy-path mode**: every deferred requirement is implemented or explicitly accepted as
out of scope, in writing, before any build reaches a real passenger.

## UI Reference

The authoritative visual reference is [`assets/11-error-tecnico.png`](./assets/11-error-tecnico.png),
copied from `C:\Users\Usuario\Pictures\Screenshots\Captura de pantalla 2026-09-23 134019.png`. It is
the source of truth for layout, content order, and styling, except where the conflicts below
override it.

| Element | Content in the reference |
|---|---|
| Top bar | "Ayuda" (right). No back control. |
| Status icon | Slate tile with a toolbox-and-exclamation glyph — deliberately neutral, neither red nor amber |
| Title | "No pudimos completar la validación" |
| Subtitle | "Es un problema nuestro, no tuyo." |
| Guidance | "Inténtalo en unos minutos. Nuestro equipo ya fue notificado." |
| Status card | "Estado del servicio" with an amber dot |
| Component 1 | "Verificación biométrica" — "Degradado" |
| Component 2 | "Escaneo de documentos" — "Operativo" |
| Component 3 | "Servidores de identidad" — "Operativo" |
| Reassurance | "Tus datos quedaron guardados. No tendrás que empezar de cero cuando reintentes." (turquoise tile) |
| Primary action | "Reintentar" |
| Secondary action | "Salir" |

Behaviors the reference establishes: the failure is attributed to the service rather than the
passenger, the state of the service is disclosed rather than hidden, progress is presented as
preserved, and both a retry and an exit are offered.

### Conflicts raised by the reference

- **CONFLICT-001 — "Tus datos quedaron guardados" promises something the architecture forbids.**
  Document images and liveness frames are discarded by design and cannot be preserved to make a
  retry cheaper. What survives is the enrollment session and the confirmed identity record, so a
  passenger whose selfie verification failed will have to retake the selfie — exactly the work they
  read this sentence as promising to avoid. **Resolved in the requirements**: no build persists a
  capture for any reason (FR-005, constitution — not a clarification, a non-negotiable). The sentence
  names what survives — the confirmed document details — and, when the retry needs a new selfie, says
  so before the passenger taps (FR-003, FR-004). The retry lands where the preserved state genuinely
  resumes: re-checking the same verification when it may still finish, the selfie when it cannot
  (FR-011).
- **CONFLICT-002 — "Inténtalo en unos minutos" sits above an immediate retry.** **Resolved in the
  requirements**: the guidance says when to try, from data, or says nothing about waiting; and a
  retry against a part the status source reports degraded is paced rather than offered as instant
  (FR-008).
- **CONFLICT-003 — "Nuestro equipo ya fue notificado" is a factual claim.** **Resolved**
  (Clarifications): the sentence is kept. It is made true by the app itself — every known service
  failure sends an error report to the project's error-reporting service, and an alert rule on that
  report notifies the team. The sentence is shown only for a known service failure, never for a
  connectivity or undetermined failure, and never in a build shipped before the alert rule exists
  (FR-006, FR-018).
- **CONFLICT-004 — the status card names internal components.** "Servidores de identidad" and
  "Verificación biométrica" describe the architecture; announcing which subsystem is degraded is
  information a passenger cannot act on but an attacker can, and it becomes a public reliability
  signal to airport clients. **Resolved** (Clarifications): the card is kept, but names the steps
  of the passenger's journey — "Escaneo de documento", "Selfie", "Emisión de tu identidad" — never
  internal components, and comes from a live source or is omitted (FR-007).
- **CONFLICT-005 — "Es un problema nuestro, no tuyo" is false after a timeout.** Found while writing
  this spec: 007's hard timeout routes here, and a timeout does not know whose fault it is. On a
  congested terminal wifi it is usually the connection. **Resolved in the requirements**: the
  subtitle attributing fault to the service appears only for a known service failure; a connectivity
  failure says so; an undetermined cause says only that the check could not be finished and that it
  was not the passenger's doing (FR-009, FR-010). "No tuyo" remains true in every case — the passenger
  was not rejected — so it is kept wherever it is accurate.

## Clarifications

### Session 2026-09-23

- Q: Is the "Nuestro equipo ya fue notificado" sentence shown, and what makes it true? → A: Keep it,
  backed by the app's own error report (the project's existing Sentry integration) plus an alert rule
  on that report that notifies the team. Shown only for a known service failure, and not before the
  rule exists.
- Q: Is the status card wanted, and does it name internal components or the passenger's journey? →
  A: Keep the card, naming the passenger's steps ("Escaneo de documento", "Selfie", "Emisión de tu
  identidad") from a live source; omitted in development and whenever no live status is available.
- Q: How long does the enrollment stay resumable after "Salir", and is the passenger notified on
  recovery? → A: 24 hours, with no recovery notification.
- Q: When a passenger who tapped "Salir" reopens the app within the 24 hours, where do they land? →
  A: Straight on the verification screen (007), which checks the same verification again and ends
  in its outcome, or back on this screen with the current status.
- Q: When the status source gives no time to try again, how long must the passenger wait between
  repeated taps on "Reintentar"? → A: The first retry is immediate, then 15 s, 30 s and 60 s, capped
  at 60 s, with the countdown shown on the button.
- Q: When the live status reports every step as working but the passenger still got a service
  failure, what does the status area show? → A: The full card, with every step marked working.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A passenger learns the failure is not theirs and keeps their progress (Priority: P1)

Verification failed, and not because of anything the passenger did. They are told so plainly, told
what still works, told exactly what of their progress is kept, and offered a retry. They do not
conclude that they were rejected, and they do not start over.

**Why this priority**: the difference between this screen and the retry screen is the difference
between a passenger who tries again and a passenger who believes the system refused them.
Attributing a service failure to the passenger is the fastest way to lose someone who would have
enrolled fine ten minutes later.

**Independent Test**: force a service-side failure and verify the screen presents it as a service
problem, states accurately what is preserved, offers a retry, and consumes no attempt.

**Acceptance Scenarios**:

1. **Given** a verification that failed for a service reason, **When** this screen opens, **Then**
   it states the failure is on the service's side, without implying the passenger did anything
   wrong.
2. **Given** this screen is shown, **When** the attempt count is evaluated, **Then** no attempt has
   been consumed and the passenger's retry budget is unchanged.
3. **Given** a verification whose job may still finish, **When** the passenger taps "Reintentar",
   **Then** the same job is checked again, nothing is resubmitted, and no capture is repeated.
4. **Given** a verification whose job ended in a service failure, **When** this screen opens,
   **Then** it says before the retry that a new selfie is needed and the document details are kept;
   **and When** the passenger retries, **Then** they land on the selfie step, not on document
   scanning or the start.
5. **Given** the passenger taps "Salir", **When** they reopen the app within 24 hours of the
   failure, **Then** they land on the verification screen, which checks the same verification again
   without resubmitting it, and the enrollment resumes rather than restarts.
6. **Given** this screen is shown, **When** it is presented, **Then** its visual treatment is
   neutral — neither the amber of the retry screen nor any red.

---

### User Story 2 - What the screen says about the service is true (Priority: P1)

The status card, the notification claim, and the preservation promise are all factual assertions
made to a passenger at the moment they are deciding whether to keep trusting the product. Each must
be derived from something real, or not be made.

**Why this priority**: it shares P1 because a reassurance screen that reassures falsely is worse
than no screen — it converts a technical failure into a credibility failure, and this product is
sold on reliability to an airport that will audit it. Three separate claims on one screen each need
a source.

**Independent Test**: verify the status card reflects a live status source and disappears without
one; verify the notification sentence appears only when an alert was raised; verify the preservation
statement matches the state that survives.

**Acceptance Scenarios**:

1. **Given** the status card is displayed, **When** the status source reports a change while the
   passenger is on the screen, **Then** the card reflects the new state.
2. **Given** no live status source is available, or its read fails, **When** this screen opens,
   **Then** the card is omitted rather than shown with invented values.
3. **Given** the live status reports every step as working, **When** this screen opens after a
   service failure, **Then** the card is still shown, with each step marked working.
4. **Given** the screen claims the team was notified, **When** the failure occurred, **Then** an
   alert was actually raised for it.
5. **Given** the screen states what is preserved, **When** the passenger retries, **Then** exactly
   that is preserved — no more and no less.

---

### User Story 3 - A connectivity problem is not blamed on the service (Priority: P2)

The passenger's own connection dropped. Telling them "es un problema nuestro" is wrong, and it sends
them to wait for a fix that will never come because nothing is broken on the service side.

**Why this priority**: it protects the credibility the rest of the screen depends on, and it is a
common case in a terminal with congested public wifi. It ranks below the two above because it is a
discrimination problem rather than a structural one.

**Independent Test**: fail the verification with the device offline and verify the passenger is told
about their connection, not about a service outage; then restore the connection and verify the retry
reconciles the same job.

**Acceptance Scenarios**:

1. **Given** the device has no connectivity, **When** verification cannot be completed, **Then** the
   passenger is told the connection is the problem and what to do, not that the service is at fault.
2. **Given** connectivity is restored, **When** the passenger retries, **Then** the enrollment
   resumes without a duplicate verification being submitted.
3. **Given** the cause cannot be determined, **When** the screen is shown, **Then** it does not
   assert a cause it does not know.

---

### Edge Cases

- **The failure happened after the verification was paid for but before its outcome reached the
  app.** Retrying reconciles the existing job rather than submitting a second one, per 007 (FR-011).
- **The credential issuance failed after a successful verification.** The verification is not lost;
  the retry asks for issuance again and needs no new capture.
- **The degraded part is the one the passenger needs**, so an immediate retry will fail again. The
  retry is paced (FR-008).
- **The outage is regional or airport-specific rather than global.** A global status would mislead a
  passenger who is unaffected or affected differently; the card shows only status scoped to the
  passenger's journey, or is omitted.
- **The passenger retries repeatedly during an outage**, adding load to a service already
  struggling. The first retry is immediate; each later one waits 15 s, 30 s, then 60 s at most
  (FR-008).
- **The outage resolves while the passenger is on the screen.** The status updates; the screen never
  claims freshness it cannot see.
- **The passenger exits and the outage persists for hours.** The enrollment stays resumable for 24
  hours from the failure (Clarifications). No notification is sent when the service recovers; the
  passenger returns on their own. After 24 hours, the enrollment starts over from the document scan,
  and the screen states the window on "Salir" (FR-012).
- **A screen reader user reads the status card.** Each part's state is announced as text, never
  conveyed by the dot colors alone (FR-014).
- **The passenger reached this screen with an identity record already confirmed** — the preserved
  state is meaningful here, and the statement says so. A failure before any record was confirmed
  preserves nothing worth claiming, and the statement is not shown.
- **"Ayuda" is opened** from this screen; returning leaves the screen as it was.
- **The back gesture** does not return to the verification spinner; the passenger leaves by
  "Reintentar" or "Salir".

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The screen MUST attribute a known service failure to the service, without implying
  passenger fault, and MUST NOT use the visual language of passenger error — no red and no amber.
- **FR-002**: A service failure, a connectivity failure, and an undetermined failure MUST NOT consume
  a verification attempt or count against the retry limit, consistent with 007 and 009.
- **FR-003**: Any statement about preserved progress MUST describe exactly what survives — the
  enrollment session and the confirmed identity record — and MUST NOT imply that captured images or
  biometric samples were retained. When no identity record was confirmed, no preservation statement
  is shown.
- **FR-004**: The retry MUST resume at the point the preserved state actually supports, and the
  screen MUST say before the retry when a capture must be repeated.
- **FR-005**: No captured image or biometric sample MAY be persisted in order to make a retry cheaper,
  in any build or mode.
- **FR-006**: The screen MUST NOT claim that the team was notified unless the failure actually raised
  an operational alert. The sentence is shown only for a known service failure, for which the app
  sends an error report that an alert rule turns into a notification to the team; it is never shown
  for a connectivity or undetermined failure. [See CONFLICT-003.]
- **FR-007**: Where service status is displayed, it MUST be derived from a live status source, scoped
  to the passenger's journey, and MUST name the passenger's steps — document scan, selfie, identity
  issuance — never internal components. Where no live source is available or its read fails, the
  status display MUST be omitted rather than populated with static or invented values. When a live
  status is available, the card MUST show every step of the journey, including when all of them are
  reported working. [See CONFLICT-004.]
- **FR-008**: The guidance MUST NOT advise waiting while offering an immediate retry against a part
  the status source reports degraded. Where the source provides a time to try again, the screen MUST
  state it and hold the retry until then; where it does not, the screen MUST NOT advise a wait, and
  repeated retries MUST be paced: the first retry is available immediately, and each later arrival
  on this screen in the same enrollment session holds "Reintentar" for 15 s, then 30 s, then 60 s,
  capped at 60 s. While held, the button shows the remaining seconds and is announced as unavailable
  with that time. The schedule is kept in memory only; it resets when a verification succeeds or the
  app is relaunched. A time from the status source overrides the schedule.
- **FR-009**: The system MUST distinguish a failure caused by the device's connectivity from one
  caused by the service, and MUST NOT attribute a connectivity problem to the service. A connectivity
  failure MUST tell the passenger to check their connection.
- **FR-010**: Where the cause cannot be determined — including 007's hard timeout — the screen MUST
  NOT assert one. It says the check could not be finished and that it was not the passenger's doing.
- **FR-011**: A retry MUST reconcile any verification already submitted rather than submitting a
  duplicate, consistent with 007: it re-checks the same job while that job may still finish, requests
  issuance again when verification succeeded but issuance failed, and returns to the selfie step only
  when the job ended in a service failure.
- **FR-012**: "Salir" MUST preserve the enrollment session so the passenger resumes rather than
  restarts, and MUST take the passenger to the start screen. The enrollment MUST stay resumable for
  24 hours from the failure; the screen MUST state that window, and no recovery notification is
  sent. Reopening the app within that window MUST land the passenger on the verification screen
  (007), which re-checks the same verification: a finished one proceeds to its outcome, and one that
  is still failing or ended in a service failure returns here with the current status, where the
  retry follows FR-011. Reopening after the window follows the normal launch.
- **FR-013**: The screen MUST NOT display personal data, document numbers, or facial images.
- **FR-014**: Status states MUST be conveyed as text and not by color alone, MUST be announced by
  assistive technology, and the screen's title and cause MUST be announced when it opens.
- **FR-015**: The screen MUST emit events for entry, failure class, status states at the time, retry
  taken, exit, and eventual resolution — carrying no personal data.
- **FR-016**: Occurrences of this screen MUST be measurable as a rate against total enrollments,
  since it is the passenger-visible face of the availability commitment.
- **FR-017**: The screen MUST keep a forward action in every state: "Reintentar" (possibly paced,
  with its time stated) and "Salir" are always present, and "Ayuda" is always reachable.
- **FR-018**: The error report sent for a known service failure MUST carry the failure class and the
  step, and no personal data, document numbers, or images; it is the source the team's alert is
  raised from.

- **FR-019** *(constitution, product budgets)*: The agent path MUST be one tap away. Screen 11
  offers "Hablar con un agente", which opens the escalation screen (010). Added during
  implementation: the reference shows no such action, but the constitution requires it from any
  failure state.
- **FR-020** *(constitution, contingency budget)*: The screen MUST state what the passenger can do
  at the checkpoint instead: "También puedes usar el control de documentos habitual en el
  aeropuerto." This is shown in every state.

### Key Entities

- **Service failure**: a verification outcome attributable to the service rather than the passenger.
  Distinct from a rejection in every respect: it consumes no attempt, routes here, and carries an
  operational alert where one exists.
- **Failure class**: which of the three causes brought the passenger here — a known service failure,
  a connectivity failure, or an undetermined one. It decides the wording; it never decides blame.
- **Service status**: the live state of the parts of the passenger's journey, if disclosed. Data,
  never copy; optionally with a time to try again.
- **Preserved state**: precisely what survives a failure — the enrollment session and the confirmed
  identity record — and explicitly not captures.
- **Verification job**: the possibly-in-flight job that a retry must reconcile rather than
  duplicate.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Zero service failures are counted as passenger attempts.
- **SC-002**: Zero images or biometric samples are persisted as a consequence of this screen's
  preservation behavior, verified by audit.
- **SC-003**: 100% of occurrences of this screen that display the notification claim correspond to an
  operational alert actually raised.
- **SC-004**: Displayed status matches the live status source in ≥99% of displays; with no source,
  0 displays show a status.
- **SC-005**: Zero connectivity failures are presented to passengers as service outages.
- **SC-006**: ≥70% of passengers who reach this screen return and complete enrollment within 24
  hours.
- **SC-007**: Zero duplicate verifications are submitted as a result of a retry from this screen.
- **SC-008**: This screen is reached in ≤0.1% of enrollments, consistent with the availability
  commitment the product makes to its airport clients — it is the passenger-visible measure of that
  number.
- **SC-009**: In usability testing, ≥90% of participants correctly state that the failure was not
  their fault and that they can try again.
- **SC-010**: In 100% of retries that require a new selfie, the screen said so before the passenger
  tapped "Reintentar".

## Assumptions

- This screen is reached from verification (007) when the outcome is a service failure, an
  unrecognized outcome code, an issuance failure, or the hard timeout — never a passenger-attributable
  rejection, which goes to 009.
- Captures have already been discarded by the time this screen appears; what is preserved is session
  and identity-record state only. The confirmed identity record lives with the backend, so a new
  selfie is compared against it without rescanning the document.
- The app can tell whether the device had connectivity when the failure happened; when it cannot,
  the failure is undetermined, not a service failure.
- The status source, if used, can express the state of the parts relevant to a passenger's journey,
  and can scope that state where an outage is not global.
- The 24-hour window matches 010's escalation window and SC-006's 24-hour return target.
- Copy is in Spanish (Colombia), matching the reference and specifications 001–010.

## Dependencies

- The verification outcome classification from 007, including the service-failure class, and 007's
  job reconciliation.
- The project's existing error-reporting service, with an alert rule on service-failure reports
  that notifies the team, for FR-006 and FR-018.
- A live service-status source, for FR-007, or the decision to omit the card.
- Connectivity detection sufficient to distinguish device from service, for FR-009.
- The selfie step (006) and verification (007) as retry destinations; credential issuance (008) for
  an issuance retry.
- A 24-hour resumable window for the enrollment after a failure, kept by the backend against the
  enrollment attempt, for FR-012.

## Out of Scope

- The operational monitoring and alerting systems themselves.
- The public status page, if one exists, and its relationship to what is shown here.
- Incident communication to airport clients.
- Passenger-attributable rejections and their retry path, specified with 009.
