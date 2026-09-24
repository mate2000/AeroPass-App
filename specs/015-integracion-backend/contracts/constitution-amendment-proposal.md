# Constitution Amendment Proposal: 1.4.0 → 1.5.0

**Status**: proposed, awaiting ratification.

**Supersedes**: `specs/014-qr-pase/contracts/constitution-amendment-proposal.md`, which is
withdrawn. It allowed offline code derivation, and DEC-01 abandons that.

**Why MINOR**: the proposal expands permitted behavior (the online-only pass, the stored auth
session) and narrows nothing that compliant code relies on.

## A1 — Principle V, the pass is online-only (DEC-01)

**Replace**:

> The QR pass MUST render, count down, and remain usable with no network once issued. Loss of
> connectivity after issuance MUST NOT invalidate the displayed pass or block its expiry countdown.

**With**:

> The QR pass is valid only within its server-defined lifetime and is renewed online. When renewal
> fails, the displayed code MUST remain until its server-defined expiry and MUST then be replaced by
> a statement that the conventional lane is available. The app MUST NEVER display a code past its
> expiry. Loss of connectivity MUST NOT leave the passenger without an instruction.

**And replace** the cold-start budget:

> Cold start to a usable QR pass for an already-enrolled user MUST stay under three seconds

**With**:

> From the passenger's request for a pass to a displayed code MUST stay under two seconds at p90 on
> a 4G connection on the minimum-spec device

## A2 — Principle IX, local state is not the pass's source of truth (DEC-01)

**Replace** "Offline-first for the issued pass…" **with**:

> **Server-first for the issued pass.** The pass surface displays only what the most recent backend
> response affirmed, held in memory. The credential surface MAY display the persisted display
> subset, marked unconfirmed until the backend affirms it.

## A3 — Principle I, the persisted-state allowlist (FR-001a)

**Add** to the list:

> the authentication session issued by the identity provider — held in platform-backed secure
> storage only, never a password or other reusable secret, and deleted on consent withdrawal

## A4 — Development Workflow, flavors

**Add**:

> The staging flavor MAY target the production service only with synthetic, marker-bearing capture
> input, and MUST NOT send camera frames.

## Not proposed

These are recorded as open, not amended:

- **Principle I, withdrawal reaches the server**: no backend endpoint exists (research.md §14). The
  requirement stands and is unmet, so it is a release blocker.
- **Principle I, the 30-day retention**: the figure stands. F-03 is the backend owner's problem.
- **Security, certificate pinning**: the requirement stands. Root-anchor pinning satisfies it as
  written (research.md §4).
