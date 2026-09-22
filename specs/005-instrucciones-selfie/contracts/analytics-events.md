# Contract: Selfie instructions funnel events (FR-010)

Keyed to the same ephemeral, per-launch `AnalyticsSessionId` every prior feature already uses.
Never any personal data — this screen has none to leak in the first place, but the discipline is
stated for consistency with 001–004's contracts.

## Events

| Event name | When emitted | Payload (beyond session id + timestamp) |
|---|---|---|
| `selfie_instructions_step_entered` | The screen opens | — |
| `selfie_instructions_advanced` | The passenger activates "Tomar selfie" | — |
| `selfie_instructions_help_opened` | The passenger activates "Ayuda" | — |
| `selfie_instructions_step_abandoned` | The screen is left (back navigation) with no advance recorded | — |

Per the constitution's Happy-Path Development Mode carve-out (v1.4.0): this list MAY remain
incomplete relative to a fuller funnel (e.g., no distinct "returned from help" event), but every
event listed above MUST already carry no personal data — that half of Principle VII is never
relaxed, in any mode.

## Derivable metrics

- **SC-001** (≥95% advance rather than abandon): `selfie_instructions_advanced` ÷
  `selfie_instructions_step_entered`, within the same `AnalyticsSessionId`.
- **SC-002** (median ≤12s here): time between `selfie_instructions_step_entered` and
  `selfie_instructions_advanced` in the same session.
- **SC-003** (first-attempt liveness lift): requires correlating `selfie_instructions_step_entered`
  presence with the liveness step's own first-attempt outcome event once 006 exists — not
  measurable from this feature's events alone; noted as a future cross-feature analysis, not a gap
  in this contract.
