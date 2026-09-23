# Quickstart: Verification In Progress (07 Validando)

Validation guide once implemented. Every stage, routing and timing rule runs headlessly with fakes
and injected durations; the device walk-through covers look, announcements and backgrounding.

## Automated validation (run first)

```bash
flutter analyze
flutter test test/contract/verification_job_repository_contract_test.dart   # fake AND real
flutter test test/unit/verification_progress_viewmodel_test.dart            # rows R1–R11 of contracts/outcome-routing.md
flutter test test/widget/verification_progress_view_test.dart               # checklist, notice, help, back, goldens
flutter test test/widget/step_indicator_test.dart                           # addendum cases 1–3
```

Confirm 008's hand-off and 003–006's screens are unchanged:

```bash
flutter test test/widget/credential_activated_view_test.dart
flutter test test/widget/router_test.dart
flutter test                                                                 # full suite
```

## Manual validation scenarios

```bash
flutter run --dart-define-from-file=env/dev-offline.env
```

| # | Steps | Expected |
|---|---|---|
| 1 | Walk the flow through the selfie | "Verificando" opens with the title, "Esto toma unos segundos. No cierres la aplicación.", and three pending stages. The indicator shows Documento and Selfie complete, Listo pending |
| 2 | Watch the checklist | "Documento verificado" completes, then "Comparando rostro", then "Creando identidad digital", each only when reported, then screen 08 opens |
| 3 | With TalkBack or VoiceOver on, repeat 1–2 without touching the screen | Each stage change and the outcome are announced |
| 4 | Use the system back gesture during the wait | Nothing happens; the verification continues |
| 5 | Background the app mid-wait for a few seconds, then return | The wait resumes or the outcome shows; nothing restarts |
| 6 | Run the widget tests for the slow and timeout paths (the dev fake is fast) | Notice at 10 s with "Seguir esperando" and "Ayuda"; technical-error path at 30 s offering "Consultar de nuevo" |

## Review checks

- Search the feature for any call that submits samples or creates a job. There must be none (SC-004).
- Confirm the issuance stage is marked `passed` in exactly one place, the `IssuanceActivated`
  branch (FR-005, SC-010).
- Confirm no event payload contains personal data or isolates attack detection (FR-015, SC-007).
