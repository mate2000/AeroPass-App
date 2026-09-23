# Addendum: launch routing (changes to 001 and 010)

This addendum changes `_redirect` in `lib/app/router.dart` (FR-012, Clarifications; research.md §8,
§9).

## Order of the decision at cold launch (`splash`)

1. A valid credential, or an unreachable status whose last known value was valid, goes to **trips**.
   This is unchanged, and no escalation or job read happens.
2. `NoCredential`, an active consent, and an open or resolved escalation go to **agent escalation**.
   This is 010's rule, unchanged.
3. `NoCredential`, an active consent, and a **resumable job** first call
   `EnrollmentSessionController.resumeAfterVerification()`, then go to **verification (007)**.
4. Everything else goes to **welcome**, as before.

A job is resumable when the read succeeds, `resumableUntil` is later than `Clock.now()`, and the job
is `inProgress`, `completed(serviceFailure)` or `completed(matched)`. Any read failure means it is
not resumable.

## Defect fix: resume only on cold launch

Steps 2 and 3 apply only when `state.matchedLocation == AppRoutes.splash`. Today step 2 also runs
for `welcome`, so any `context.go(AppRoutes.welcome)` bounces back. That includes 010's "Volver al
inicio" and this screen's "Salir". After the fix, going to welcome shows welcome. The credential
rule for `welcome` (step 1) and the fire-and-forget withdrawal retry stay as they are.

## Router tests

| # | Setup | Expected |
|---|---|---|
| 1 | splash, no credential, active consent, no escalation, job `completed(serviceFailure)` resumable until +1 h | verification screen; the session has `identityConfirmed` |
| 2 | Same as 1, but `resumableUntil` is in the past | welcome |
| 3 | Same as 1, but `resumableUntil` is absent | welcome |
| 4 | splash, job `completed(faceMismatch)` with `resumableUntil` | welcome, because a rejection is not resumable here |
| 5 | splash, an open escalation and a resumable job | agent escalation; the escalation takes precedence |
| 6 | splash, a valid credential and a resumable job | trips, and the job repository is never read |
| 7 | **Regression**: `go(welcome)` with an open escalation | welcome stays (010's "Volver al inicio") |
| 8 | **Regression**: `go(welcome)` with a resumable job | welcome stays (this screen's "Salir") |
| 9 | The job read fails | welcome |

All existing router tests must pass unchanged. The harness default for the job repository is
"nothing scripted", so its read fails and launch behaves as before.
