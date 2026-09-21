# Contract: Document capture funnel events (FR-018)

Keyed to the same ephemeral, per-launch `AnalyticsSessionId` 001/002 already use. Never the durable
`EnrollmentAttemptId` tied to consent, and never image bytes or extracted data.

## Events

| Event name | When emitted | Payload (beyond session id + timestamp) |
|---|---|---|
| `capture_step_entered` | The screen opens and passes the consent-currency gate | — |
| `capture_permission_denied_shown` | Camera permission denied (temporary or permanent) | `permanent`: bool |
| `capture_attempted` | The passenger activates the capture control | `attemptNumber`: int (current `CaptureAttemptCounter.count + 1`) |
| `capture_device_rejected` | On-device quality assessment fails | `reason`: `QualityRejectionReason` |
| `capture_verification_rejected` | The processor rejects a device-passed capture | `reason`: `CaptureRejectionReason` |
| `capture_accepted` | The processor accepts the capture | — |
| `capture_attempt_limit_reached` | The 3rd failure routes to retry guidance | — |
| `capture_step_abandoned` | The screen is left (back navigation) with no outcome recorded | — |

## Derivable metrics

- **SC-001** (≥85% first-attempt success): `capture_accepted` with `attemptNumber = 1` ÷
  `capture_step_entered`, within the same `AnalyticsSessionId`.
- **SC-003** (≥90% unusable captures rejected on-device): `capture_device_rejected` ÷
  (`capture_device_rejected` + `capture_verification_rejected`).
- **SC-006** (≥80% recover within session after an error): a `capture_device_rejected` or
  `capture_verification_rejected` followed by a later `capture_accepted` in the same session, ÷
  total error events.
