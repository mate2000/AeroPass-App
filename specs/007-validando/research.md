# Research: Verification In Progress (07 Validando)

No `NEEDS CLARIFICATION` markers remain. `/speckit-specify` resolved three and `/speckit-clarify`
three more (spec.md, Clarifications). What follows are the technical decisions needed to build the
screen. Several touch code shipped by 006 and 008; each is called out individually.

## §1 — The screen observes a job keyed by the enrollment attempt id, and never submits anything

**Decision**: add a domain port `VerificationJobRepository` with one method, `getStatus()`, that
reads the backend's verification job for the current enrollment. The job is identified by the
durable `EnrollmentAttemptId` already stored in the local consent record (002). The screen polls
this method; it never uploads samples or creates a job. The samples were submitted by 003 and 006,
and the backend assembles the job from them under the same attempt id.

**Rationale**:
- FR-010's "never submit the same captured samples twice" becomes structural: this screen has no
  code path that submits anything, so it cannot submit twice (SC-004).
- The spec assumed FR-010 would need a new persisted job identifier and therefore a constitution
  amendment. It does not. The attempt id is already persisted, in the allowlisted consent record,
  precisely "so later steps … can still be correlated with the same enrollment attempt across a
  resume that spans app launches" (002's `EnrollmentAttemptId` doc comment). No amendment is
  needed, now or at FR-010's exit.
- After a document rejection the passenger re-captures, and the backend starts a new job under the
  same attempt id; `getStatus()` always returns the current job, so the app needs no job id of its
  own.

**Alternatives considered**:
- *A job id returned by 006 and persisted by the app*: rejected. It needs a new persisted value and
  an amendment for no benefit over the attempt id.
- *A push channel (websocket or push notification) for stage updates*: rejected for now. Every port
  in this app is request/response (006's research.md §1), and polling composes simply with the
  timers of §5. A push channel can replace polling behind the same port later.

## §2 — Three real stages: two from the job, the third is the issuance call itself

**Decision**: the checklist's three stages come from two sources:

| Stage | Source | Complete when |
|---|---|---|
| "Documento verificado" | `VerificationJobStatus.documentCheck` | The job reports it passed |
| "Comparando rostro" | `VerificationJobStatus.faceComparison` | The job reports it passed |
| "Creando identidad digital" | 008's `CredentialIssuanceRepository.requestIssuance()` | It returns `Ok(IssuanceOutcome.activated)` |

Issuance is requested only after the job reports the match succeeded.

**Rationale**: FR-005 becomes a property of the code rather than a rule to remember: the third
stage is drawn complete from exactly one place, the `IssuanceActivated` branch, which is also the
only place that sets 008's hand-off. It also keeps 008's hand-off unchanged, as the spec requires:
the issuance port, its storage-before-success rule and its three outcomes are reused as they are.

**Alternatives considered**:
- *Have the job report issuance too, and fetch the credential separately*: rejected. It splits one
  fact (the credential exists) across two calls that could disagree.

## §3 — Polling, and what a failed poll means

**Decision**: `VerificationProgressViewModel` calls `getStatus()` every second (named constant
`verificationPollInterval`) until the job completes or the hard timeout fires. A transport failure
on a single poll is **not** an outcome: it is retried on the next tick. Only the hard timeout (§5)
turns a lack of answers into the technical-error outcome.

**Rationale**: a checkpoint with poor connectivity (spec Edge Cases) produces isolated failed polls
that say nothing about the verification itself. Treating each as a failure would send passengers
to the technical-error path on a single dropped packet. The 30-second hard timeout already bounds
the wait, so no second retry counter is needed.

## §4 — Outcome classes, destinations and attempt counting

**Decision**: the job's terminal result maps to a sealed `VerificationOutcome`, normalized at the
data boundary. Routing (FR-008) and counting are one table, implemented in one switch:

| Outcome | Destination | Attempt counted against |
|---|---|---|
| `matched`, then issuance `activated` | 008's credential-activated screen (hand-off set) | — (selfie counter reset) |
| `matched`, then issuance `notActive` or `incomplete` | 008's not-active placeholder | none |
| `documentRejected` | Document capture (003), or retry guidance if the limit is reached | `documentCapture` |
| `faceMismatch` | Retry guidance (009) | `selfieLiveness` |
| `livenessRejected` | Retry guidance (009) | `selfieLiveness` |
| `attackDetected` | Retry guidance (009), identical to `faceMismatch` for the passenger | `selfieLiveness` |
| `serviceFailure`, or any unrecognized code | Technical error (011) | none |
| Issuance `Result.error`, or the hard timeout | Technical error (011) | none |

Attempt limits reuse the existing `captureAttemptLimit` (3) and per-step `AttemptCounterScope`s,
per 006's clarification that counters are separate per step. When a counter reaches the limit, the
destination is retry guidance, mirroring 003 and 006.

**Rationale**: SC-003 and SC-006 are tested against this one table. Mapping unrecognized codes to
`serviceFailure` at the boundary means no unknown value can be mistaken for a passenger rejection.
`attackDetected` stays a distinct domain value for audit (as in 006's research.md §7) but produces
the same destination, message and counter as `faceMismatch` (FR-012, SC-007).

## §5 — Timers are bounds, never progress

**Decision**: three named, injectable durations: `slowNoticeAfter` = 10 s, `hardTimeoutAfter` =
30 s, `failureDisplayPause` = 1.5 s. The first two are measured from the screen opening using the
injected `Clock`, so a return from the background re-checks elapsed wall time instead of trusting a
paused `Timer`. On resume, the view model polls immediately and fires the timeout at once if 30
seconds have already passed.

**Rationale**: FR-004 forbids progress on elapsed time. None of these timers advances a stage: the
notice and the timeout only bound the wait, and the pause only delays a route after a result is
already known. Injecting them keeps tests fast, as 006's `stallDuration` does.

## §6 — Help, "Seguir esperando", and outcomes that arrive while help is open

**Decision**: at 10 seconds the view shows the notice with two actions: "Seguir esperando", which
hides the notice, and "Ayuda", which `push`es the existing help placeholder. Polling and timers keep
running underneath. The view acts on a pending navigation only while its route is the current one.
When help is closed, it checks again (the `push` future completes), so an outcome that arrived
meanwhile is shown then (spec Edge Cases).

**Rationale**: using `go` while help is open would pull the passenger out of help mid-sentence.
Holding the navigation as a one-shot pending target is the pattern 006 and 008 already use.

## §7 — Back gesture

**Decision**: `PopScope(canPop: false)` for the whole screen, with no redirect. The gesture does
nothing while the wait runs (FR-017). During the failure pause it also does nothing; the route
follows 1.5 seconds later anyway.

## §8 — Step indicator: "Listo" pending, on a light surface

**Decision**: extend the shared `StepIndicator` with two optional parameters, both defaulting to
today's behaviour so 003–006 are unchanged:
- `currentStepReached` (default `true`): when `false`, the current step renders as upcoming. 07
  passes `currentStep: done, currentStepReached: false`, so Documento and Selfie show complete and
  Listo pending (FR-006, CONFLICT-004).
- `onLightSurface` (default `false`): uses a dark-grey upcoming colour instead of `white54`, which
  is invisible on 07's light background.

**Rationale**: one shared widget keeps every screen's indicator consistent (Principle X). Default
values make this a non-breaking change, with a regression test for the existing rendering.

## §9 — What assistive technology hears

**Decision**: the view announces, with `SemanticsService.sendAnnouncement` (as 006's instruction
banner does), each stage that becomes running or complete, the slow notice, and the outcome. The
failure line "No pudimos completar la verificación" is the only failure announcement, whatever the
class. The illustration is excluded from semantics.

**Rationale**: FR-014 and SC-009. The screen has no controls during a normal wait, so
announcements are its only channel for a screen-reader user.

## §10 — Technical error (011): a placeholder that can check again

**Decision**: new `TechnicalErrorPlaceholderView` at `AppRoutes.technicalError =
'/enrollment/technical-error'`. It states the problem is not the passenger's, says they can use the
regular document check at the checkpoint (constitution, contingency budget), and offers "Consultar
de nuevo", which `go`es back to the verification route. Re-entering that route starts a fresh
observation of the **same** job (§1): new timers, no new submission. It has no retry limit, since a
status check costs nothing.

## §11 — Document rejection returns the passenger to document capture

**Decision**: `EnrollmentSessionController` gains `returnToDocumentCapture()`, which sets
`stepReached` back to document capture and clears `identityConfirmed`. The view model calls it,
clears `PendingDocumentController`, increments the `documentCapture` counter, then routes to
document capture. The passenger then passes through confirmation and the selfie again, since no
sample may be reused (spec Assumptions).

**Rationale**: clearing `identityConfirmed` keeps 006's reachability guard honest: a stale link to
the liveness route cannot skip the new confirmation.

## §12 — Replacing 008's placeholder without changing its hand-off

**Decision**:
- `features/enrollment/liveness/verification_progress_placeholder_view.dart` is replaced by
  `features/enrollment/verification/verification_progress_view.dart`, the real screen, and the
  view model moves to the same folder.
- `VerificationProgressViewModel` keeps its name, constructor dependencies (plus the new job port,
  the attempt counter, the pending-document controller and a clock) and its `activated` behaviour:
  set the hand-off, clear the session, target `credentialActivated`.
- 008's `verification_progress_viewmodel_test.dart` cases for `activated`, `notActive`, `incomplete`
  and issuance errors are kept, adapted to reach issuance through a matched job.
- The liveness screen still `push`es this route on success; this screen then `go`es onward, which
  clears the stack as 008 requires.

## §13 — Analytics

**Decision**: new events, specified in contracts/analytics-events.md: `verificationStepEntered`,
`verificationStageReached({stage})`, `verificationOutcome({kind, elapsedSeconds})`,
`verificationSlowNoticeShown`, `verificationTimedOut`, `verificationHelpOpened`. `elapsedSeconds`
is an integer, rounded, and carries no personal data; it satisfies FR-016 within a launch. 008's
`credentialIssuance*` events keep firing from the issuance stage. Recovery-after-relaunch events
are deferred with FR-010.

## §14 — Dev fake: a schedule that belongs to the fake

**Decision**: `DevVerificationJobRepository`, selected by `USE_FAKE_VERIFICATION_BACKEND`, reports
the document check running then passed at about 1.5 s after its first poll, the face comparison
passed at about 3 s, then `completed(matched)`. It measures time with an injected clock. The dev
issuance fake from 008 then completes the third stage.

**Rationale**: the spec's "the schedule belongs to the fake, not to the screen". The screen code is
identical in every build; only the port's answers differ.

## §15 — Deferred: recovery after relaunch (FR-010)

**Decision**: deferred, per the spec's deferral table. Because of §1, the exit work is small: at
launch, when there is an active consent record and no credential, ask the job port whether a job is
running or finished for the attempt id, and route to this screen or to the outcome. The subtitle's
"No cierres la aplicación" stays until then (CONFLICT-002) and is softened in the same change.
Backgrounding is already safe: the job runs on the backend, and polling resumes on return (§5).
