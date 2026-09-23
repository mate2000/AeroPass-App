# Addendum: the launch redirect checks for an open escalation (change to 001)

Per research.md §4 and spec FR-024.

## Change

In `router.dart`'s splash/welcome redirect, before the rule that sends "no credential" to welcome:

1. If the credential status is `NoCredential` and the local consent record is `active`, call
   `EscalationRepository.getStatus()`.
2. `open` → redirect to `AppRoutes.agentEscalation`.
3. `resolved(...)` → redirect to `AppRoutes.agentEscalation`, whose view model routes the outcome on
   its first read.
4. `expired`, `Result.error`, or no consent record → unchanged: welcome, as today.

A valid credential still goes to trips first; this check never runs when a credential exists.

## Regression tests (router_test.dart)

1. No credential, active consent, open escalation → the escalation screen.
2. No credential, active consent, expired escalation → welcome.
3. No credential, the escalation read fails → welcome.
4. Valid credential → trips, and the escalation port is not called.
5. All of 001's existing launch tests still pass.
