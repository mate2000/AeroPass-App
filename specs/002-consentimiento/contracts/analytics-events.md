# Contract: Consent gate funnel events (FR-017)

Events this screen MUST emit so presentation/confirmation/decline/abandonment are derivable without
later instrumentation (Constitution Principle VII). Keyed by the **same in-memory, per-launch
`AnalyticsSessionId`** 001-bienvenida's welcome screen already uses — not the durable
`EnrollmentAttemptId`, and never any consent text content (FR-017 is explicit: "no personal data and
no consent text").

## Events

| Event name | When emitted | Payload (beyond session id + timestamp) |
|---|---|---|
| `consent_gate_shown` | The gate's content renders (text successfully fetched) | `hasPriorRecord`: bool — whether a local `ConsentRecord` for a superseded version already existed (FR-014's "presented again" path) |
| `consent_gate_unavailable_shown` | The text fetch fails and the blocking unavailable state renders instead | `reason`: `offline` \| `fetch_error` |
| `consent_confirmed` | `recordConsent()` returns `Ok` | `textVersionId` (not the text itself — just which version, for SC-002's "identifies the exact text version" measurement) |
| `consent_confirm_failed` | `recordConsent()` returns `Error` (FR-008's blocked-advance path) | — |
| `consent_declined` | The passenger taps "Ahora no" | — |
| `consent_dismissed` | Back gesture / barrier tap / system navigation (FR-010) | — |
| `consent_gate_abandoned` | The gate is left (backgrounded/killed) with neither confirm nor an explicit decline recorded | — |

## Derivable metrics

- **SC-006** (≥85% confirm and proceed, decline rate tracked): `consent_confirmed` count ÷
  (`consent_confirmed` + `consent_declined` + `consent_dismissed`) count, within the same
  `AnalyticsSessionId`.
- **SC-007** (median ≤30s at the gate): timestamp delta between `consent_gate_shown` and whichever
  of `consent_confirmed` / `consent_declined` / `consent_dismissed` comes first.

## Explicitly out of scope for this contract

`consent_declined`/`consent_dismissed` do not carry a stated reason as a structured field — the
spec's SC-006 says "decline rate and its stated reasons tracked," but no UI element in the reference
collects a reason from the passenger (asking "why are you declining?" is a product decision outside
this spec's scope, not an omission in this contract).
