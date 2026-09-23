# Quickstart: Escalation to a Human Agent (10 Escalar agente)

Validation guide once implemented. Every channel, outcome and launch rule runs headlessly with
fakes. The offline demo's fakes always succeed, so the screen is reached on a device through 009's
"Hablar con un agente".

## Automated validation (run first)

```bash
flutter analyze
flutter test test/contract/escalation_repository_contract_test.dart   # fake AND real
flutter test test/unit/escalation_viewmodel_test.dart
flutter test test/widget/escalation_view_test.dart                    # incl. goldens
flutter test test/widget/agent_chat_view_test.dart
flutter test test/widget/router_test.dart                             # launch-routing addendum
flutter test                                                          # full suite
```

## Manual validation scenarios

```bash
flutter run --dart-define-from-file=env/dev-offline.env
```

| # | Steps | Expected |
|---|---|---|
| 1 | Force one face mismatch (as in 009's quickstart), then "Hablar con un agente" | "Necesitamos verificarte en persona", the by-choice body (no "agotaste"), amber icon, the module preselected with its airport, location and hours, the chat below, the checkpoint line |
| 2 | Tap "Cómo llegar al módulo" | A sheet with the airport, where the module is, and its hours |
| 3 | Select the chat, tap "Iniciar chat", send a message | The echo reply; a notice that the chat cannot verify; no attachment control |
| 4 | Back from the chat, then back again | This screen, then 009 |
| 5 | "Volver al inicio", then open the escalation route again from 009 | The same open escalation, not a new one. (A full relaunch lands on welcome in the offline demo, because its consent fake is in memory; relaunch recovery is covered by the router tests and needs the real backend.) |
| 6 | TalkBack on, move through the channel cards | Each is announced as an option in a group, with its availability and whether it is selected |

## Review checks

- Search the feature: no code constructs an `ActivatedCredential` or sets 008's hand-off except
  through `CredentialIssuanceRepository` (FR-011, SC-002).
- The chat has no attachment control and no path to an outcome (FR-014, SC-011).
