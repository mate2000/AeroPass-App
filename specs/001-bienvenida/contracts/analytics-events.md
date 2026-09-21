# Contract: Welcome screen funnel events (FR-013)

Events this screen MUST emit so enrollment-start funnel metrics (SC-001, SC-002) are derivable
without later instrumentation, per Constitution Principle VII. All events are keyed by the in-memory,
per-launch `AnalyticsSessionId` (data-model.md) and carry **no personal data** — no credential token,
no document/biometric content, no name.

## Events

| Event name | When emitted | Payload (beyond session id + timestamp) |
|---|---|---|
| `welcome_screen_shown` | The welcome content actually renders (i.e. NOT when the passenger is routed straight to trips, and NOT during the launch splash) | `variant`: `first_run` \| `reenrollment_required` \| `resume_offered` |
| `welcome_primary_action_tapped` | The primary action ("begin enrollment") is activated, once per created `EnrollmentSession` (FR-004's single-session guarantee applies here too — no duplicate event for a double-tap that was already suppressed) | `variant` (same as above) |
| `welcome_secondary_action_tapped` | The secondary action (account recovery on a new device) is activated | — |
| `welcome_privacy_terms_opened` | The passenger navigates to the privacy/data-handling terms from this screen (User Story 3) | — |
| `welcome_device_unsupported_shown` | The device-capability check fails and the unsupported-device message is shown instead of the normal welcome content (FR-012) | `reason`: `no_camera` \| `unsupported_os` |

## Derivable metrics

- **SC-001** (≥70% begin enrollment in the same session): `welcome_primary_action_tapped` count ÷
  `welcome_screen_shown` count where `variant = first_run`, within the same `AnalyticsSessionId`.
- **SC-002** (median ≤15s before acting): timestamp delta between `welcome_screen_shown` and
  whichever of `welcome_primary_action_tapped` / app-backgrounded-without-action comes first.
- **SC-008** (≥60% resume rather than restart after backgrounding mid-enrollment): compared against
  `welcome_screen_shown` events with `variant = resume_offered` vs. the subsequent
  `welcome_primary_action_tapped` (resume accepted) vs. a fresh session being started instead.

## Explicitly out of scope for this contract

Cross-launch "repeat use across flights" (Principle VII) is **not** derivable from these events,
by design — the session id is per-launch and in-memory only (data-model.md, plan.md Constitution
Check). That metric is computed from backend, credential-linked events emitted by the
credential-issuance and trips-and-pass features once a passenger is enrolled.
