# Research: Escalation to a Human Agent (10 Escalar agente)

No `NEEDS CLARIFICATION` markers remain (spec.md, Clarifications). What follows are the technical
decisions needed to build the screen, its chat, and its outcomes. Cross-feature changes are called
out individually.

## §1 — One escalation port, keyed by the enrollment attempt, with outcomes that carry no credential

**Decision**: a domain port `EscalationRepository` with two methods:

- `openOrResume({required EscalationArrival arrival})` → `Result<EscalationCase>`: opens an
  escalation for the current enrollment, or returns the one already open.
- `getStatus()` → `Result<EscalationStatus>`: `open(case, channels)`, `resolved(outcome)`, or
  `expired()`.

Channel availability is part of the `open` status rather than a separate call, so it always
arrives with the case state it belongs to.

The case is identified on the backend by the `EnrollmentAttemptId` already in the consent record,
as 007's verification job is. The 24-hour window (FR-022) is the backend's: `getStatus()` reports
`expired` once it passes. Nothing is persisted on the device.

`EscalationOutcome` is sealed: `credentialIssued()`, `declined()`, `attemptsReset(scope)`.
**`credentialIssued` carries no credential.** On it, the app calls 008's existing
`CredentialIssuanceRepository.requestIssuance()`, which returns the manual-review credential the
backend issued for this enrollment, writes it to storage, and hands it to 008 like any other
activated credential.

**Rationale**:
- FR-011, the spec's most important rule, becomes structural. The only object that can open 008 is
  an `IssuanceActivated`, and it can only come from the issuance port, which only returns one when
  the backend has issued a credential. A fake escalation that says `credentialIssued` without a
  backend credential behind it leads nowhere: issuance returns `notActive` or `incomplete`, and 008
  never opens.
- No new persisted state, for the same reason as 007's research §1; relaunch recovery (FR-024)
  needs only the attempt id the device already holds.
- 008 needs no second path, as the spec's assumptions require.

**Alternatives considered**:
- *An outcome carrying the credential*: rejected. It would create a second route to an
  `ActivatedCredential`, outside the issuance port and its storage-before-success rule.
- *A local "escalation opened at" timestamp for the 24 hours*: rejected. It is not on the
  persisted-state allowlist, and the backend must enforce the window anyway for the module lookup.

## §2 — Arrival, derived from the counters

**Decision**: the view model derives `EscalationArrival` from the two attempt counters, as 009 does:
any counter at the limit means `afterLimit`, otherwise `byChoice`. The body copy follows it
(FR-001, CONFLICT-005), and it is sent to `openOrResume` for the case's context and to analytics.

**Rationale**: no route parameter to forge or lose on relaunch, and the same source 009 uses.

## §3 — Channels: availability is data, not copy

**Decision**: `AgentChannel` (data-model.md) carries `kind` (`module`, `chat`), `available`,
`nextOpensAt`, an optional `estimatedWait` range, `hours` text, and for the module `locationName`
and `locationDetail` — all from the backend (or the dev fake). The screen composes its copy from
these fields and never states a wait the channel does not supply (FR-004–FR-007).

Selection: the module is preselected when available (FR-003); otherwise the chat if available;
otherwise nothing. A channel that becomes unavailable while selected is deselected and the
selection falls back by the same rule (US2 scenario 5).

## §4 — Checking for the outcome

**Decision**: while the screen is open, the view model calls `getStatus()` every 5 seconds (named
constant `escalationPollInterval`), and once on creation. At launch, the router's splash redirect
asks the same port when there is an active consent record and no credential; an open escalation
routes to this screen, and a resolved one to its outcome (FR-024). A failed read is not an outcome;
the next tick tries again.

**Rationale**: the pattern 007 already uses. The backend status is the only source of an outcome.

**Cross-feature change (001)**: the splash redirect gains one branch before its "no credential →
welcome" rule. If the escalation check fails or finds nothing open, behaviour is unchanged.

## §5 — Routing each outcome

| Outcome | App action | Destination |
|---|---|---|
| `credentialIssued` | `requestIssuance()`; on `Ok(activated)` set 008's hand-off and clear the session | `credentialActivated` |
| `credentialIssued`, issuance not activated | Treated as not yet issued; keep checking | stays on this screen |
| `declined` | Show the decline state (FR-013) | this screen, decline state |
| `attemptsReset(documentCapture)` | Reset the local document counter (stand-in for the backend's) | `documentCapture` |
| `attemptsReset(selfieLiveness)` | Reset the local selfie counter | `livenessCapture` |
| `expired` | Show the expired state with "Abrir nueva solicitud" | this screen, expired state |

The local counter reset mirrors the backend decision until FR-006's backend counter replaces the
local one; it is the only reset outside 007's `matched` branch, and it happens only on a
backend-reported agent reset (009 FR-017).

## §6 — The chat: informational, echo in happy-path mode, no attachments

**Decision**: a port `AgentChatRepository.send(String message)` → `Result<String>` (the reply). The
dev fake echoes. The chat screen (`AgentChatView`) keeps messages in memory only, has a text field
and a send button, and **no attachment control at all**; a fixed notice at the top says the chat
answers questions, cannot complete verification, and never accepts documents (FR-014, FR-021). Its
back navigation returns to this screen.

**Rationale**: with no attachment control, FR-014 holds by construction rather than by filtering.
The chat produces no outcome of any kind; outcomes only come from `getStatus()` (SC-011).

## §7 — "Cómo llegar al módulo" stays in the app

**Decision**: the module's primary action opens a bottom sheet with the airport name, where the
module is inside it, and its hours, from the channel data. No map app is opened and no new package
is added.

**Rationale**: FR-007 needs the location named, not navigation. Opening a maps application would
need a new dependency, which Principle X requires justifying, and would reveal the passenger's
destination to that application.

## §8 — Visual language and accessibility

**Decision**: the same amber icon tile as 009 (FR-002). The two channel cards are a single choice
group: each card is a `Semantics` node with `inMutuallyExclusiveGroup`, `checked`, and a label
combining name, availability and wait (FR-016). On entry the title and body are announced, as on
009. The conventional checkpoint line is always visible (FR-008).

## §9 — Analytics

**Decision**: new events in contracts/analytics-events.md: `escalationShown({arrival})`,
`escalationChannelsOffered({moduleAvailable, chatAvailable})`, `escalationChannelSelected({channel})`,
`escalationHandoffStarted({channel})`, `escalationOutcome({kind, elapsedSeconds})`. No personal
data; the document-number lookup of FR-023 happens entirely in the agent tool and never passes
through the app. Abandonment is deferred.

## §10 — Deferred, restated for tasks

- Live availability and waits (FR-004, FR-006): the dev fake supplies static values through the
  real port.
- Location relevance (FR-007): deferred; the location is always named.
- A real chat transport and the agent tooling, including the document-number lookup (FR-023) and
  manual-review issuance: backend and agent-side work, out of the app.
- Abandonment event and resolution-time reporting beyond `elapsedSeconds`.
