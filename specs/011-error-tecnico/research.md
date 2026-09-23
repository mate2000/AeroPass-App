# Research: Service Failure (11 Error técnico)

Phase 0 of the plan. The spec and its six clarifications leave no open product question; what follows
are the technical decisions needed to build it, each checked against the code as it stands after
007–010.

## §1 — What brings a passenger here, and what the app knows about it

Today 007 routes to `AppRoutes.technicalError` from three places in
`VerificationProgressViewModel`:

| 007 event | What the app actually knows | Failure class (this feature) | Job still usable? |
|---|---|---|---|
| Job completed with `serviceFailure` (includes any unrecognized provider code, mapped at the boundary) | The backend answered and said the service failed | **service** | No — the job is terminal |
| Issuance `Result.error` after a match | Depends on the error: see §2 | **service** or **connectivity** or **undetermined** | Yes — verification passed |
| The 30-second hard timeout | Whatever the polls saw during the wait: see §2 | **connectivity** or **undetermined** | Yes — the job may still finish |

**Decision**: a sealed `ServiceFailureClass` with three values — `service`, `connectivity`,
`undetermined` — plus the `VerificationStage` it happened on and a `jobTerminal` flag. It is decided
in 007, where the evidence is, and handed to screen 11 (§3).

**Rationale**: FR-009 and FR-010 require the wording to follow the evidence. Only the first row is a
*known* service failure. A timeout during which the service kept answering "in progress" is slow
service, but the spec is explicit (FR-010, "including 007's hard timeout") that a timeout does not
assert a cause, so it is `undetermined` unless the evidence says connectivity.

**Alternatives considered**: classifying on screen 11 by probing the network on entry — rejected,
because the network at the moment of display says nothing reliable about the network at the moment
of failure, and it adds a request while the service is struggling.

## §2 — Telling the device's connection from the service without a new package

**Decision**: no `connectivity_plus`. The two repositories 007 reads — verification job and
credential issuance — wrap transport errors in a domain type before returning them:

```text
TransportFailure.connectivity(cause)   // no connection reached the server
TransportFailure.service(cause)        // the server was reached and failed or answered badly
```

The mapping lives in the data layer, next to the pinned `dio` client:

| `DioExceptionType` | Wrapped as |
|---|---|
| `connectionError`, `connectionTimeout`, `sendTimeout` | `connectivity` |
| `badResponse` (any non-2xx), `receiveTimeout`, `badCertificate` | `service` |
| anything else, and non-`dio` errors | left unwrapped → the caller treats it as undetermined |

007 then decides:

- **Issuance error**: `connectivity` → connectivity; `service` → service; otherwise undetermined.
- **Hard timeout**: every poll since the screen opened returned `TransportFailure.connectivity` →
  connectivity; anything else → undetermined.

**Rationale**: the error that actually happened is better evidence than an OS reachability flag,
which reports "wifi connected" on a captive portal. It keeps `dio` out of the ViewModel (Principle
VIII) and adds no dependency (Principle X). `badCertificate` is a pinning failure; it is reported as
the service's problem because the passenger cannot fix it by reconnecting, and it must never be
worded as "check your wifi".

**Alternatives considered**: `connectivity_plus` — adds a plugin and still cannot see captive
portals; checking `error is SocketException` in the ViewModel — leaks the transport into the
presentation layer.

## §3 — Handing the failure to screen 11

**Decision**: a new app-layer, in-memory `TechnicalErrorController` (a `ChangeNotifier` like 008's
`ActivatedCredentialHandoff`), provided from the composition root. 007 calls
`record(ServiceFailure)` immediately before navigating to screen 11. Screen 11 reads `current`. It
also owns the retry pacing (§5) and the resolution timing for FR-015.

If screen 11 opens with nothing recorded (a stale back-stack entry, a deep link), it shows the
undetermined wording, sends no alert, and retries into 007 — which re-reads the real job.

**Rationale**: `go_router`'s `extra` does not survive restored navigation, and nothing here may be
persisted (Principle I). The controller dies with the process, which is exactly the lifetime the
pacing needs (Clarifications: "resets when the app is relaunched").

## §4 — Where "Reintentar" goes

**Decision** (FR-004, FR-011, CONFLICT-001):

| Recorded failure | Retry destination | Why it is not a duplicate |
|---|---|---|
| `jobTerminal` (job ended in `serviceFailure`) | **Selfie capture (006)** | The failed job cannot finish; 006 submits one new sample, creating the attempt's next job |
| Issuance failed | **Verification (007)** | 007 re-reads the same job, sees `matched`, and asks for issuance again (§12) |
| Timeout | **Verification (007)** | 007 re-reads the same job; nothing is submitted |
| Nothing recorded | **Verification (007)** | 007 re-reads whatever the backend has |

The preservation tile states the difference *before* the tap: a new selfie in the first row, "sin
repetir fotos" in the others (FR-004, SC-010). No retry lands on document capture: the confirmed
identity record lives on the backend (004), and a new selfie is compared against it.

**No attempt is consumed** (FR-002): screen 11 never touches `CaptureAttemptCounterRepository`, and
006 increments its counter only on its own capture failures, as today.

## §5 — Retry pacing

**Decision** (FR-008, Clarifications): `TechnicalErrorController` counts arrivals on screen 11 in
this process. The hold on "Reintentar", measured from the arrival:

| Arrival | Hold |
|---|---|
| 1st | none |
| 2nd | 15 s |
| 3rd | 30 s |
| 4th and later | 60 s |

A `retryAfter` from the status source (§6) that is later than the scheduled end replaces it. While
held, the button is disabled, shows "Reintentar en 12 s", and its semantics label says it is
unavailable and for how long. The count resets when 007 activates a credential (`resolve()`), and by
construction on relaunch. `Clock` is injected, so tests drive time without waiting.

**Rationale**: the pacing belongs to the session, not to the screen instance — each retry creates a
new screen 11, so a per-screen timer would restart at zero every time and pace nothing.

## §6 — The status source

**Decision**: a new read-only port, `ServiceStatusRepository.getStatus()` →
`Result<ServiceStatus>`, polled every **15 s** while screen 11 is open. The backend scopes it by the
enrollment attempt, so a regional or airport-specific outage is reported only to passengers it
affects. The response names the three journey steps — `documentScan`, `selfie`, `issuance` — each
`operational`, `degraded` or `unavailable`, with an optional `retryAfter`.

The mapping is strict: an unknown step health, a missing step, or a duplicate step makes the whole
read a `Result.error`, and the card is omitted. A card with one guessed line is a card that is not
true (FR-007). When all three are `operational`, the full card still shows (Clarifications).

The dev fake returns `Result.error` ("no status source in development"), so in happy-path mode the
card is never rendered (deferral table). The contract suite still runs the real implementation
against the fake HTTP adapter.

**Rationale**: journey vocabulary answers CONFLICT-004 — the passenger learns which part of *their*
enrollment is affected, and nothing names an internal component.

## §7 — The operational alert, and personal data in Sentry

**Decision**: a new port, `OperationalAlertReporter`, with one method,
`reportServiceFailure({stage})`, called by screen 11's ViewModel **once per recorded failure, only
for the `service` class**. The Sentry implementation sends one `captureMessage` at error level with:

- tags `failure_class=service` and `failure_stage=<stage>`, and a fingerprint of
  `['verification-service-failure', stage]`, so the alert rule groups by step;
- **no user, no request, no breadcrumbs, no extras** — the event is built in an isolated scope, and a
  `beforeSend` hook in `SentryConfig` strips `user` and `request` from any event carrying the
  `failure_class` tag.

The sentence "Nuestro equipo ya fue notificado." is shown only when all three hold:

1. the class is `service`;
2. Sentry is enabled (a DSN is defined);
3. `SentryConfig.alertRuleConfirmed` is true — a new `--dart-define` `SENTRY_ALERT_RULE_CONFIRMED`,
   off by default, set to true in an env file only after someone has created the alert rule.

**Rationale**: this is the user's chosen answer (Clarifications, option C), made falsifiable. The
third condition is what stops the sentence shipping before the rule exists (FR-006, SC-003).

**Finding — must be raised with the user, not silently changed**: `SentryConfig.configure` sets
`sendDefaultPii = true`, which lets Sentry attach the device IP address and user data to every event,
including crash reports. Principle VII forbids personal data in crash reports, and FR-018 forbids it
in this report. This feature strips it from its own event, but the global setting still applies to
crashes elsewhere. The plan records it as a release gate: either `sendDefaultPii` becomes `false`,
or the Sentry project's "Prevent storing of IP addresses" setting is enabled and recorded. The user
asked for `sendDefaultPii: true` earlier, so this is their decision to revisit.

## §8 — Launch resume, and a defect in 010's redirect

**Decision** (FR-012, Clarifications): at launch, after the credential check and 010's escalation
check, a **resumable verification** sends the passenger to 007. Resumable means all of:

- credential status is `NoCredential`, and the consent record is active;
- the job read succeeds, and the job carries a `resumableUntil` later than now;
- the job is `inProgress`, or `completed` with `serviceFailure`, or `completed` with `matched`
  (issuance still pending — the credential check already said there is none).

The backend sets `resumableUntil` to 24 hours after the failure. A job without it — the dev fake,
older backends, rejections — is not resumable, and launch behaves as before.

**Defect found in 010**: `_redirect` applies the escalation resume to both `splash` and `welcome`.
Every `context.go(AppRoutes.welcome)` — 010's "Volver al inicio", and this screen's "Salir" — would
bounce straight back to the screen the passenger just left. **Decision**: both resume checks apply
only when the matched location is `splash`, i.e. cold launch. Going to welcome shows welcome. A
regression test covers 010's button.

## §9 — Restoring the session on a resumed launch

**Decision**: when the launch redirect resumes a verification, it first calls a new
`EnrollmentSessionController.resumeAfterVerification()`, which creates a session at
`selfieCapture` with `identityConfirmed: true`.

**Rationale**: a verification job exists only after 006 submitted a sample, and 006 is reachable
only with a confirmed identity record (006's router guard). So the backend holding a job for this
attempt is proof the record was confirmed. Without this, a relaunched passenger whose retry needs a
new selfie would hit 006's guard and be sent to document capture, which breaks FR-004. Nothing new is
persisted: the proof is re-read from the backend on each launch.

## §10 — Copy by failure class

| Class | Title | Subtitle | Guidance |
|---|---|---|---|
| service | "No pudimos completar la validación" | "Es un problema nuestro, no tuyo." | "Nuestro equipo ya fue notificado." only under §7's conditions |
| connectivity | "No pudimos conectarnos" | "Parece que se perdió la conexión a internet." | "Revisa tu conexión y vuelve a intentarlo." |
| undetermined | "No pudimos completar la validación" | "No fue por algo que hayas hecho." | none |

With a `retryAfter`, the guidance adds "Puedes reintentar a las {hora}." No class says "Inténtalo en
unos minutos" (CONFLICT-002). The preservation tile appears only when the session has
`identityConfirmed`:

- a new selfie is needed: "Tus datos del documento quedaron guardados. Al reintentar, solo tendrás
  que tomarte una nueva selfie."
- otherwise: "Tus datos del documento quedaron guardados. Al reintentar, revisaremos tu validación
  sin repetir fotos."

It always ends with "Puedes retomar tu registro durante las próximas 24 horas." (FR-012).

## §11 — Visual treatment

**Decision**: a slate tile (new `AppColors.slate` and `AppColors.slateTile`) with
`Icons.home_repair_service_outlined`; no amber and no red anywhere (FR-001). Status health uses text
labels — "Operativo", "Con fallas", "No disponible" — with a dot as decoration only (FR-014). The
card header dot takes the worst health's color. The card is a live region, so a change while the
screen is open is announced. No back control. `PopScope(canPop: false)` stops the back gesture from
returning to the spinner.

## §12 — Issuance asked twice for the same attempt

**Decision**: add a clause to 008's issuance contract. A second `POST /v1/credential/issuance` for
the same enrollment attempt, after a first that failed in transit, MUST return the credential already
issued, if one was, rather than issue a second. The contract suite gains a test in which the fake
HTTP adapter answers the second request with the same token.

**Rationale**: a request that failed in transit may have succeeded on the server. Retrying through
007 re-requests issuance, so the backend must be idempotent per attempt, or SC-007's
no-duplicate-verification target becomes a no-duplicate-credential defect.

## §13 — Two constitution requirements the reference omits (found during implementation)

**Decision**: screen 11 adds a "Hablar con un agente" action, pushed on top so that back returns
here, and the checkpoint line 010 already uses (spec FR-019, FR-020).

**Rationale**: the constitution's product budgets require that "from any failure state, the agent
path MUST be one tap away", and that when the backend or network is unavailable, the app tells the
passenger "exactly what to do at the checkpoint instead". The reference screen has only
"Reintentar" and "Salir". The old placeholder carried the checkpoint line, so dropping it would
have been a regression.

**Implementation notes**: `registerArrival()` takes no time argument. The hold is measured from
the injected `Clock` when the ViewModel is built. `technicalErrorShown.stage` is null when nothing
was recorded, rather than a guessed stage. `DioExceptionType.transformTimeout` maps to the service,
because the server did answer.

