# Research: Verification Retry (09 Reintento)

No `NEEDS CLARIFICATION` markers remain (spec.md, Clarifications). What follows are the technical
decisions needed to build the screen and to change the shipped retry policy of 003, 006 and 007.
Each cross-feature change is called out individually.

## §1 — The screen derives its state from the counters, not from how it was reached

**Decision**: `RetryGuidanceViewModel` reads both attempt counters on creation and decides its
state from them:

| Counters | State |
|---|---|
| `documentCapture` count ≥ limit | **Document limit**: explains the limit for the document, agent route only |
| else `selfieLiveness` count ≥ limit | **Selfie limit**: explains the limit for the selfie, agent route only |
| else | **Selfie retry**: generic failure, selfie advice, "Intentar de nuevo" and the agent route |

No route parameter or hand-off tells it which capture failed.

**Rationale**: the four entry points (spec Assumptions) produce exactly these three states, and the
counters already hold the facts that distinguish them. A route parameter such as `?limit=false`
could be forged by a deep link to offer a retry past the limit; reading the counter makes FR-010
structural. It also means a passenger who returns later, or relaunches, lands in the right state.
If a counter read fails, the screen shows the limit state for the selfie: it never offers a retry
it cannot justify, and the agent route stays available (FR-009).

**Alternatives considered**:
- *A query parameter `capture=document|selfie`*: rejected. It duplicates what the counters say and
  opens the forged-retry path above.
- *An in-memory hand-off*: rejected. It is lost on relaunch, and the counters survive it.

## §2 — The retry policy, applied to shipped code (FR-017, CONFLICT-005)

**Decision**: one policy across the three steps that touch the counters:

| Change | Where | Today | After |
|---|---|---|---|
| Reset on success of the step | 003 `CaptureViewModel._registerAccepted` | Resets `documentCapture` on every accepted photo | **Removed** |
| Reset on success of the step | 006 `LivenessCaptureViewModel`, liveness success | Resets `selfieLiveness` | **Removed** |
| Reset on reaching the limit | 003, 006, and 007 rows R6 and R7–R9 | Resets before routing to retry guidance | **Removed** |
| Reset on a verification match | 007 `VerificationProgressViewModel`, `matched` | Resets `selfieLiveness` only, and only on `activated` | Resets **both** counters as soon as the job reports `matched` |
| Limit check on entry | 003 and 006 view models | None | If the step's counter is already at the limit, route to retry guidance without opening the camera |

**Rationale**: the clarified policy is that only a verification match (or an agent) resets a
counter. The entry check is what makes an exhausted limit stay "in force" (US3 scenario 3,
SC-010): without it, a passenger could navigate back into the camera and keep capturing. Resetting
on `matched` rather than `activated` follows the clarification's wording: the passenger got
through verification, and an issuance problem after that is not their attempt.

**Consequence to note**: 003 counts device-side photo rejections and 007's verification rejections
against the same `documentCapture` counter. Since an accepted photo no longer resets it, earlier
rejected photos now add up with a later verification rejection. This follows the clarified policy
and is covered by the updated 003 tests.

**Alternatives considered**:
- *Keep 003's and 006's success resets*: rejected in Clarifications (option C there). They happen on
  every retry and would erase the count the limit depends on.

## §3 — The counter stays behind the existing port; the backend version is a swap

**Decision**: no new port. `CaptureAttemptCounterRepository` (003, generalized in 006) already
exposes `read`, `increment` and `reset` per scope. In happy-path mode its local secure-storage
implementation stands in, as the spec allows. FR-006's backend-owned counter becomes a new
implementation of the same port at the first real integration, keyed by the enrollment attempt id,
with no change to any caller.

**Rationale**: the spec's own warning is that the client must not own the count once real passengers
arrive. Keeping every caller on the port means that move rebuilds one class, not the retry policy.

## §4 — Routes out of the screen

**Decision**:
- "Intentar de nuevo" → `context.go(AppRoutes.livenessCapture)`: straight to the selfie camera,
  replacing the stack (Clarifications). 006's guard passes because `identityConfirmed` is untouched
  on this path.
- "Hablar con un agente" → `context.push(AppRoutes.agentEscalation)`: the existing placeholder for
  010. `push` keeps this screen underneath, so the session and the retry are still there if the
  passenger comes back.
- "Ayuda" (top bar) → `context.push(AppRoutes.help)`.
- `PopScope(canPop: false)`: the back gesture does nothing (FR-018).

## §5 — Copy

**Decision**: all strings in `lib/l10n/app_es.arb`.

| State | Title | Body | Advice |
|---|---|---|---|
| Selfie retry | "No pudimos confirmar que eres tú" | "No logramos verificar tu identidad con esta selfie. ¡Sin problema, inténtalo otra vez!" | "Busca un lugar con buena iluminación, de preferencia natural." / "Asegúrate de que tu rostro esté descubierto y visible por completo." / "Sostén el teléfono a la altura de tus ojos y quédate quieto." |
| Selfie limit | "Alcanzaste el número máximo de intentos" | "Por ahora no puedes volver a tomar la selfie. Habla con un agente para volver a intentarlo, o usa el control de documentos habitual en el aeropuerto." | none |
| Document limit | "Alcanzaste el número máximo de intentos con tu documento" | "Por ahora no puedes volver a escanear tu documento. Habla con un agente para volver a intentarlo, o usa el control de documentos habitual en el aeropuerto." | none |

**Rationale**: FR-003 (no comparison, no threshold), FR-005 (005's face wording), FR-008 (no count
anywhere), FR-013 (agent and checkpoint in the limit state). The retry body is identical for face
mismatch, liveness rejection and attack detection, since they share this state (spec US1 scenario
6).

## §6 — Visual language

**Decision**: an amber warning icon (`Icons.warning_amber_rounded`) on an amber tile, with two new
named colours in `AppColors` (`amber`, `amberTile`). No red, no error styling (FR-002). The state is
carried by the title text; the icon is excluded from semantics.

## §7 — What assistive technology hears

**Decision**: on entry, the view announces the title and body with
`SemanticsService.sendAnnouncement`, as screens 006 and 007 do (SC-009). The advice is ordinary
text in reading order; the title is a semantics header.

## §8 — Analytics and the audit trail

**Decision**: three new `AnalyticsEmitter` methods (contracts/analytics-events.md):
`retryGuidanceShown({state})`, `retryGuidanceRetryTaken()`, `retryGuidanceAgentRouteTaken({state})`,
where `state` is `selfieRetry`, `selfieLimit` or `documentLimit`. The abandonment event is deferred
(spec deferral table). FR-016's specific classification is already recorded where it originates:
006's own `livenessOutcome` event, and the backend's job record for 007's classifications. This
screen adds nothing that could isolate attack detection.

## §9 — Deferred and out of scope, restated for tasks

- Tailoring advice to the processor's reason (FR-004): deferred; one selfie tip set ships.
- Backend counter (FR-006): deferred to the first real integration, behind the same port (§3).
- Agent context and agent reset (FR-012, US2 scenario 5): deferred to 010. Until then an exhausted
  limit cannot be reset in the app; the dev fakes always succeed, so the offline demo never reaches
  it.
- Offline detection before a retry: deferred.
