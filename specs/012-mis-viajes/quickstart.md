# Quickstart: Trips Home (12 Mis viajes)

## Automated validation

```sh
flutter analyze
flutter test test/contract/trip_repository_contract_test.dart \
             test/contract/credential_summary_repository_contract_test.dart \
             test/unit/trips_home_viewmodel_test.dart \
             test/widget/trips_home_view_test.dart \
             test/widget/router_test.dart
flutter test
```

Expected: zero analyzer issues, and every test passes. The behavior these tests pin down is listed in
[contracts/trips-home-ui.md](./contracts/trips-home-ui.md), [contracts/trip-port.md](./contracts/trip-port.md)
and [contracts/credential-summary-port.md](./contracts/credential-summary-port.md).

## Manual walk-through on an Android device (fake backend, `env/dev-offline.env`)

| # | Steps | Expected |
|---|---|---|
| 1 | Complete enrollment through 008, then tap "Ver mis viajes" | The strip shows initials, the name, "•••• 1234" and "ACTIVA". The next trip is BOG → MDE, today, gate D12, seat 22A. "Iniciar viaje" is enabled |
| 2 | Tap "Iniciar viaje" | The 013 placeholder opens. No pass is shown |
| 3 | Kill and relaunch the app | Launch lands on Mis viajes, with the strip filled from storage and confirmed by the fake backend |
| 4 | Scroll to "Viajes recientes" | Three domestic rows, plain text with no arrows, and the 90-day line |
| 5 | Tap Perfil, then "Retirar consentimiento" | The withdrawal screen opens in two taps |
| 6 | Turn on TalkBack and focus the trip card | It reads "De Bogotá a Medellín, vuelo AV 9201…", not letters |
| 7 | Put the phone in airplane mode and wait 60 s on the screen | The trip stays, marked "Actualizado hace 1 min". The strip shows "SIN CONFIRMAR" instead of "ACTIVA". "Iniciar viaje" is replaced by the connection reason |

## Before a release build

- The backend must send `holderName`, `documentLast4` and `suspended` on the status endpoint, and
  `GET /v1/trips` must filter domestic segments and the 90-day history.
- Decide whether repeat use needs a true cohort (research.md §9). If it does, that needs a
  constitution amendment for a stable anonymous identifier.
