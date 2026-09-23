# Quickstart: Credential Activated (08 Identidad activa)

Validation guide once implemented. Every routing and trust rule is exercisable headlessly with
fakes. Only the Android screenshot block needs a device.

## Automated validation (run first)

```bash
flutter analyze
flutter test test/contract/credential_issuance_repository_contract_test.dart   # fake AND real
flutter test test/unit/verification_progress_viewmodel_test.dart
flutter test test/unit/credential_activated_viewmodel_test.dart
flutter test test/widget/credential_activated_view_test.dart                     # includes goldens
flutter test test/widget/router_test.dart                                         # guard of research.md §5
```

Confirm no regression from the cross-feature changes (research.md §6, §11):

```bash
flutter test test/contract/consent_repository_contract_test.dart   # withdrawal clears the credential
flutter test test/unit/withdrawal_viewmodel_test.dart
flutter test test/unit/welcome_viewmodel_test.dart
flutter test                                                        # full suite
```

## Manual validation scenarios

Run the offline demo, which uses the dev fakes for consent, verification and issuance:

```bash
flutter run --dart-define-from-file=env/dev-offline.env
```

| # | Steps | Expected |
|---|---|---|
| 1 | Walk welcome → consent → document → confirmation → selfie → liveness | The verification placeholder appears briefly, then screen 08 opens with "Tu identidad digital está activa" |
| 2 | Read the card | "Mateo González Restrepo" on at most two lines, "•••• 7890 · COL", "Creada el" today's date, "Válida hasta" a date five years out, and the "ACTIVA" badge. No stat tiles. No portrait, a generic icon instead |
| 3 | With TalkBack or VoiceOver on, focus the document line and the name | "Documento terminado en 7890, Colombia", and the full name |
| 4 | On Android, try a screenshot on screen 08 | The system blocks it, or the capture is black |
| 5 | Use the system back gesture | Trips, showing the "aún no tienes viajes" explanation. Back again does not return into capture |
| 6 | Relaunch the app | Trips, per 001. Screen 08 does not reappear |
| 7 | From a fresh run, tap "Ver mi identidad" on screen 08 | The credential detail placeholder |
| 8 | Withdraw consent from the account surface, then relaunch | Welcome, not trips (research.md §6) |

## Trust-boundary checks (review, not runtime)

- `grep` the feature for any code that constructs `ActivatedCredential` outside the issuance
  repository and its fake. There must be none (FR-001, SC-001).
- Confirm no event payload contains a name, digits, country, date or token (FR-015).
- Confirm `HappyPathFlags.assertReleaseSafe` still fails a release build with
  `USE_FAKE_VERIFICATION_BACKEND=true`, which now also selects the issuance fake.
