# Contract: Liveness capture funnel events (FR-017)

Keyed to the same ephemeral, per-launch `AnalyticsSessionId` every prior feature already uses. Per
research.md §8, the `outcome` event carries the *full* classification (including `attackDetected`
specifically, as an enum value) — this is a security-monitoring signal, never personal data, and
never shown to the passenger; it is the local half of SC-007's audit obligation.

## Events

| Event name | When emitted | Payload (beyond session id + timestamp) |
|---|---|---|
| `liveness_step_entered` | The screen opens and passes the reachability guard | — |
| `liveness_phase_reached` | A new phase begins (FR-007: index only ever increases) | `phaseIndex`: int, `totalPhases`: int |
| `liveness_outcome` | An attempt reaches a terminal outcome | `outcome`: `success` \| `qualityFailure` \| `unclassifiedFailure` \| `attackDetected`; `reason`: `LivenessQualityReason?` (only when `outcome == qualityFailure`) |
| `liveness_attempt_count` | Alongside each `liveness_outcome` for a non-success result | `attemptNumber`: int |
| `liveness_attempt_limit_reached` | The 3rd failed attempt routes to retry guidance | — |
| `liveness_stalled` | FR-013's time limit elapses with no terminal outcome | — |
| `liveness_step_abandoned` | The screen is left (back navigation) with no outcome recorded | — |

Per the constitution's Happy-Path Development Mode carve-out (v1.4.0): this list MAY be incomplete
relative to a fuller funnel, but every event listed above MUST already carry no personal data and
no frame/biometric content — that half is never relaxed, in any mode.

## Derivable metrics

- **SC-001** (≥85% first-attempt success): `liveness_outcome{outcome: success}` with
  `attemptNumber = 1` (or its absence, for the first attempt) ÷ `liveness_step_entered`.
- **SC-004** (≥95% complete within 30s at p90): time between `liveness_step_entered` and the
  first `liveness_outcome{outcome: success}` in the same session.
- **SC-008** (≥80% retry-success within session): a `liveness_outcome` with a non-success result
  followed by a later `liveness_outcome{outcome: success}` in the same session, ÷ total
  first-attempt failures.
- **SC-006** proxy: `liveness_outcome{outcome: attackDetected}` and
  `liveness_outcome{outcome: unclassifiedFailure}` are, by construction (research.md §7), never
  distinguishable from these events' effect on what the passenger saw — SC-006 itself is verified
  by message-set review (spec.md), not derived from analytics.
