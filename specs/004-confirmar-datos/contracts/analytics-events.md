# Contract: Data confirmation funnel events (FR-016)

Keyed to the same ephemeral, per-launch `AnalyticsSessionId` every prior feature already uses. Never
the durable identity-record data, never a field's value — only which field, when a field is involved.

## Events

| Event name | When emitted | Payload (beyond session id + timestamp) |
|---|---|---|
| `confirmation_step_entered` | The screen opens with a non-empty `PendingDocumentController` | — |
| `confirmation_field_edited` | The passenger edits a field | `field`: `FieldKey` (never the value) |
| `confirmation_field_reverified` | A field's automated re-check (FR-005) completes | `field`: `FieldKey`, `confirmed`: bool |
| `confirmation_correction_attempt_limit_reached` | The 3rd unresolved correction attempt routes to re-scan (FR-019) | — |
| `confirmation_rescanned` | The passenger chooses "Escanear de nuevo" | — |
| `confirmation_blocked_unusable_document` | The screen opens to an expired document or a missing required field (FR-008/FR-009) | `reason`: `expired` \| `missingRequiredField` |
| `confirmation_confirmed` | `IdentityRecordRepository.confirm()` returns `Ok` | — |
| `confirmation_confirm_failed` | `IdentityRecordRepository.confirm()` returns `Error` (FR-017) | — |
| `confirmation_step_abandoned` | The screen is left (back navigation) with no outcome recorded | — |

## Derivable metrics

- **SC-001** (≥90% confirm without editing any field): `confirmation_confirmed` with zero preceding
  `confirmation_field_edited` in the same session, ÷ `confirmation_step_entered`.
- **SC-005** (≥95% complete within 30s at p90): time between `confirmation_step_entered` and
  `confirmation_confirmed` in the same session.
- **SC-007** proxy (usability signal derivable from funnel data alone): rate of
  `confirmation_field_edited` per `confirmation_step_entered` — a non-zero edit rate is the passive
  signal that passengers do notice incorrect fields; the ≥90% figure itself is measured in usability
  testing (spec.md), not from these events.
