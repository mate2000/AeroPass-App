# Quickstart: Service Failure (11 Error técnico)

## Automated validation

```sh
flutter analyze
flutter test test/unit/technical_error_viewmodel_test.dart \
             test/unit/technical_error_controller_test.dart \
             test/unit/verification_progress_viewmodel_test.dart \
             test/contract/service_status_repository_contract_test.dart \
             test/contract/verification_job_repository_contract_test.dart \
             test/contract/credential_issuance_repository_contract_test.dart \
             test/unit/sentry_before_send_test.dart \
             test/widget/technical_error_view_test.dart \
             test/widget/router_test.dart
flutter test
```

Expected: zero analyzer issues, and every test passes. The behaviors these tests pin down are listed
in [contracts/technical-error-routing.md](./contracts/technical-error-routing.md),
[contracts/launch-routing-addendum.md](./contracts/launch-routing-addendum.md) and
[contracts/operational-alert-port.md](./contracts/operational-alert-port.md).

## Manual walk-through on an Android device

These scenarios need the fake backend and a way to force a failure. The dev job fake reads a new
`--dart-define`, `DEV_VERIFICATION_FAILURE`, with the values `service_failure` or `hang`, and matches
as today when it is unset. Add it to `env/dev.json` for the walk, then remove it.

| # | Setup | Steps | Expected |
|---|---|---|---|
| 1 | `DEV_VERIFICATION_FAILURE=service_failure` | Enroll up to the selfie; let verification run | Screen 11 shows the neutral slate tile, "Es un problema nuestro, no tuyo.", and the tile saying only a new selfie is needed. No status card appears, because the dev source has none. No "equipo notificado" sentence appears, because the alert rule is not confirmed |
| 2 | As in 1 | Tap "Reintentar" | You land on the selfie capture, not the document scan |
| 3 | As in 1, second failure | Reach screen 11 again | "Reintentar en 15 s" counts down, and TalkBack announces it as unavailable. A third arrival holds 30 s |
| 4 | `DEV_VERIFICATION_FAILURE=hang`, airplane mode on during verification | Wait 30 s | "No pudimos conectarnos", with guidance to check the connection. Nothing says the service failed |
| 5 | `hang`, connection on | Wait 30 s | "No fue por algo que hayas hecho." No cause is stated |
| 6 | Any failure | Tap "Salir" | Welcome stays on screen and does not bounce back. The 24-hour line was visible before leaving |
| 7 | 010 regression | Reach 010, then tap "Volver al inicio" | Welcome stays on screen |
| 7b | Any failure | Tap "Hablar con un agente", then go back | Screen 010 opens. Back returns to screen 11. The checkpoint line was visible |
| 8 | TalkBack on | Open screen 11 | The title and cause are announced. Every status line is read as text |

Launch resume (FR-012) needs a backend that sends `resumableUntil`, so it is covered by router tests
1–9, not by the walk-through.

## Before a release build

- Create the Sentry alert rule on `failure_class:service`, then set `SENTRY_ALERT_RULE_CONFIRMED=true`
  in the production env file.
- Resolve the personal-data gate in contracts/operational-alert-port.md. Either set `sendDefaultPii`
  to false, or turn on the Sentry project's IP-address scrubbing, and record which.
- Remove `DEV_VERIFICATION_FAILURE` from every env file. It has no effect unless the fake backend is
  active.
