# Contract: the retry-guidance screen

Per research.md §1, §4–§7. What the screen shows and where it leads, in each state. The widget
tests enumerate this table.

| | `selfieRetry` | `selfieLimit` | `documentLimit` |
|---|---|---|---|
| Top bar | "Ayuda" | "Ayuda" | "Ayuda" |
| Icon | Amber warning on amber tile | Same | Same |
| Title | "No pudimos confirmar que eres tú" | "Alcanzaste el número máximo de intentos" | "Alcanzaste el número máximo de intentos con tu documento" |
| Body | Generic selfie line (research.md §5) | Selfie limit line, with agent and checkpoint | Document limit line, with agent and checkpoint |
| Advice card | Three selfie tips | — | — |
| Attempt count | Never | Never | Never |
| Primary action | "Intentar de nuevo" → `go(livenessCapture)` | "Hablar con un agente" → `push(agentEscalation)` | "Hablar con un agente" → `push(agentEscalation)` |
| Secondary action | "Hablar con un agente" → `push(agentEscalation)` | — | — |
| Back gesture | Does nothing | Does nothing | Does nothing |
| Announced on entry | Title and body | Title and body | Title and body |

## Invariants

- No text in any state contains "coincide", "suficiente", a number of attempts, or any reference to
  detection (FR-003, FR-008, SC-003).
- No state has zero routes to a person (FR-009, SC-006).
- No red and no error styling in any state (FR-002).
- No advice about the document appears in `selfieRetry` (FR-004).
