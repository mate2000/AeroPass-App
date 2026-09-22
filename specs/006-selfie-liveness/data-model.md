# Data Model: Liveness Capture (06 Selfie · liveness)

## AttemptCounterScope (new, shared — research.md §3)

```text
enum AttemptCounterScope { documentCapture, selfieLiveness }
```

Not a new persisted entity — a parameter distinguishing which step's `CaptureAttemptCounter`
(unchanged, 003's existing entity) a call addresses. `CaptureAttemptCounterService` maps each scope
to its own pair of secure-storage keys.

## LivenessPhase

One stage of the current attempt, as reported by the processor (spec.md Assumptions: "the four
phases... correspond to real stages of the processor's capture... If the processor exposes a
different number of stages, the indicator follows the processor").

```text
LivenessPhase
 ├─ index: int            // 0-based, ordinal within this attempt
 ├─ totalPhases: int       // as reported for this attempt — the phase indicator's dot count
 └─ instruction: LivenessInstruction
```

`LivenessInstruction` (sealed — app-owned vocabulary, never raw processor text, mirroring
`CaptureRejectionReason`'s precedent): `.moveCloser()`, `.moveBack()`, `.centerFace()`,
`.holdStill()`, `.lookAtCamera()`, `.improveLighting()`. The real adapter maps the processor's own
codes onto this fixed set (FR-004's "vocabulary of the instructions screen" — the same six or fewer
concepts 005 already established); an unrecognized code maps to `.holdStill()` as the safest
fallback (asks for nothing new, never regresses progress).

## LivenessOutcome (sealed — research.md §7)

The processor's terminal decision for one attempt.

| Variant | Fields | Passenger-facing rendering |
|---|---|---|
| `LivenessOutcome.success` | — | Advances to verification progress (007). |
| `LivenessOutcome.qualityFailure` | `reason: LivenessQualityReason` | Specific, actionable message (FR-009), in 005's vocabulary. |
| `LivenessOutcome.unclassifiedFailure` | — | The **shared generic message** (research.md §7). |
| `LivenessOutcome.attackDetected` | — | The **same shared generic message**, byte-for-byte (Clarifications) — never a distinct string, never distinct styling. |

`LivenessQualityReason` (enum): `tooDark`, `faceOutOfFrame`, `movementDetected`,
`multipleFacesDetected`, `faceObstructed`.

## LivenessSampleOutcome (sealed)

What `LivenessVerificationRepository.submitSample()` returns per call (research.md §1).

```text
LivenessSampleOutcome
 ├─ .inProgress(phase: LivenessPhase)   // capture continues; view updates phase/progress
 └─ .completed(outcome: LivenessOutcome) // terminal — the attempt is over
```

Progress (the "64%" badge, FR-006) is derived from `phase.index / phase.totalPhases` (with a
within-phase fractional component if the processor's response includes one) — never from elapsed
time, satisfying FR-006's "MUST NOT advance on elapsed time alone" by construction: there is no
timer anywhere in the progress calculation.

## LivenessAttempt (view-model-local, not persisted, not a domain entity)

One run through the loop described in research.md §1, held only for the ViewModel's lifetime.

| Field | Type | Notes |
|---|---|---|
| `sessionId` | `String?` | Set once `startSession()` succeeds; `null` before then. |
| `currentPhase` | `LivenessPhase?` | Last phase reported; `null` before the first sample. |
| `outcome` | `LivenessOutcome?` | Set only once `.completed(...)` is returned. |

## EnrollmentSession (extended — research.md §4)

```text
EnrollmentSession (existing, extended)
 ├─ id: String                          // unchanged
 ├─ stepReached: EnrollmentStep          // unchanged
 ├─ startedAt: DateTime                  // unchanged
 └─ identityConfirmed: bool (@Default(false), NEW)  // set true only by
                                          // DocumentConfirmationViewModel's
                                          // successful confirm (004, research.md §4)
```

Still never persisted — this is in-memory session-progress state, the same category `stepReached`
already is, not a new Constitution Principle I persisted-state category.

## Relationships

```text
Router guard (this feature's addition to _redirect)
 └─ AppRoutes.selfieLiveness reached
      ├─ EnrollmentSessionController.current?.identityConfirmed != true
      │    -> redirect to AppRoutes.documentCapture (research.md §4)
      └─ identityConfirmed == true -> LivenessCaptureViewModel constructed

LivenessCaptureViewModel
 ├─ owns LivenessCameraService lifecycle (start/stop, front lens, frame sampling)
 ├─ loop: LivenessVerificationRepository.startSession() -> sessionId
 │    then repeatedly: grab a sampled frame -> submitSample(sessionId, frame)
 │         ├─ .inProgress(phase) -> update LivenessAttempt.currentPhase, announce
 │         │    instruction (research.md §6), advance phase indicator (FR-007: index only
 │         │    ever increases)
 │         └─ .completed(outcome) -> stop the loop
 │              ├─ success -> AttemptCounterRepository.reset(selfieLiveness);
 │              │    advance to verification progress (007)
 │              └─ qualityFailure/unclassifiedFailure/attackDetected ->
 │                   AttemptCounterRepository.increment(selfieLiveness);
 │                   render per research.md §7's rules;
 │                   count reaching captureAttemptLimit (3) -> route to retry guidance
 ├─ Timer (45s, research.md §9): fires FR-013's stall state if no `.completed` yet
 ├─ WidgetsBindingObserver (research.md §9): backgrounding/lock/call -> stop camera,
 │    discard the in-flight frame and sessionId, no submission in flight survives
 └─ onBackNavigation(): stop camera, discard held state, preserve EnrollmentSession as
      incomplete (FR-015) — identityConfirmed is NOT cleared, so returning to this
      screen later doesn't re-trigger the guard's redirect
```

No entity here is written to disk, cached, or logged with recognizable content — frames and
`sessionId` are held only for the duration of one attempt's loop and discarded on every exit path
(FR-008), and `identityConfirmed`/`AttemptCounterScope` carry no biometric or document content at
all.
