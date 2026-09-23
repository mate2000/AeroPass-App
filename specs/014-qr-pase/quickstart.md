# Quickstart: Dynamic QR Pass (14 QR Pase)

## Automated validation

```sh
flutter analyze
dart run tool/check_release_env.dart env/prod.env
flutter test test/unit/pass_viewmodel_test.dart test/unit/clock_trust_monitor_test.dart \
             test/unit/derived_pass_code_source_test.dart test/contract/pass_repository_contract_test.dart \
             test/unit/release_env_check_test.dart test/widget/pass_view_test.dart test/widget/router_test.dart
flutter test
```

Expected: zero analyzer issues, the env check passes on `env/prod.env`, and every test passes. The
behavior these tests pin down is listed in the contracts in [contracts/](./contracts/).

## Manual walk-through on an Android device (`env/dev-offline.env` plus `DEV_PASS_CONTROLS=true`)

| # | Steps | Expected |
|---|---|---|
| 1 | Mis viajes, "Iniciar viaje", then "Continuar a tu pase" | The pass shows the name, "AV 9201 · BOG → MDE · Hoy …", "Asiento 22A", the Seguridad and Embarque stepper, and the QR. Brightness goes to maximum |
| 2 | Wait 30 s | The QR changes and the countdown restarts. TalkBack says "Código actualizado" |
| 3 | Take a screenshot | Android blocks it |
| 4 | Tap "Atrás" | Brightness returns to normal. The Mis viajes card now shows "Ver pase" |
| 5 | Tap "Ver pase" | The current code is shown, not the old one |
| 6 | Tap "Simular expirado" | "Este código expiró", with no QR and "Solicitar nuevo código" |
| 7 | Change the phone's time by 2 minutes | "La hora de tu teléfono no coincide", with no QR |
| 8 | Airplane mode (phase A) | "Necesitas conexión para obtener tu código", with the checkpoint line |
| 9 | Build with `env/prod.env` plus `DEV_PASS_CONTROLS=true` | The app refuses to start, and CI's env check fails |

Offline rotation (US2) is walked only after phase B, once the constitution amendment is ratified.

## Before a release build

- **Ratify or reject** contracts/constitution-amendment-proposal.md. Without it, the pass does not
  work offline (US2).
- The backend must issue passes, serve status with `serverTime`, and move boarded trips to history.
- Consider backend attestation (Play Integrity or App Attest), because the posture check is
  heuristic (research.md §8).
