# Constitution Amendment Proposal: 1.4.0 → 1.5.0 (QR-pass secret)

**Status**: PROPOSED. Not applied. It needs the user's ratification.
**Raised by**: 014-qr-pase, Clarification Q1 (research.md §1).
**Governance**: this follows the constitution's Amendment procedure, which requires a written
proposal stating the principle affected, the rationale, and the migration required.

## Principles affected

1. **Principle I — Consent and Data Minimization**, the persisted-state allowlist.
2. **Security & Compliance Constraints**, the QR-pass TTL clause.

## Proposed text

### Principle I — add to the allowlist

> Persisted state is limited to: the credential token issued by the backend, its validity window, a
> display-only subset of identity fields the user already saw on the confirmation screen, the user's
> consent record with timestamp and version, a per-step capture-attempt counter (…), **and a QR-pass
> secret issued by the backend for one started trip, with its server-defined validity window and the
> server time at issuance. The pass secret MUST live in platform-backed secure storage only, MUST
> never be logged, transmitted back, or included in any event or report, and MUST be deleted when its
> validity ends, on a confirmed boarding validation, on consent withdrawal, and on credential
> revocation.**

### Security & Compliance Constraints — replace the QR-pass clause

**Current**:

> A QR pass MUST carry a short server-defined TTL and MUST NOT be regenerable offline. Expiry is
> enforced by the backend; the app's countdown is a courtesy display, never the authority.

**Proposed**:

> A QR pass MUST carry a short server-defined validity. **No pass, pass secret, or extension of
> validity may be created on the device or while offline**; only the backend issues them. Within a
> backend-issued validity, the app MAY derive short-lived rotating codes offline from the
> backend-issued secret, which readers validate independently of the app. Expiry is enforced by the
> backend; the app's countdown is a courtesy display, never the authority. A code derived from a
> device clock that differs from the backend's by more than one rotation interval MUST NOT be
> presented as usable.

## Rationale

- Principle V requires the pass to "render, count down, and remain usable with no network once
  issued", and Principle IX's offline-first rule requires the pass surface to read from local state.
- A rotating pass cannot meet either while the Security clause forbids offline regeneration, and
  while nothing about the pass may be persisted. The constitution is internally inconsistent for the
  pass the product is built around.
- The amendment keeps the backend as the only issuer and bounds what is stored: one trip's secret,
  until departure and at most 24 h. It also names the clock tolerance.

## Versioning

**MINOR (1.5.0)**. Existing guidance is expanded with new obligations: storage bounds, deletion
triggers and the clock tolerance. No previously compliant code becomes non-compliant.

## Migration required of existing code

- None for 001–012: nothing stores or derives a pass today.
- 014 phase B tasks become unblocked.
- `specs/014-qr-pase/plan.md`'s Constitution Check is updated from "blocked" to "compliant".

## Sync Impact Report (to prepend on ratification)

```
- Version change: 1.4.0 → 1.5.0
- Modified: Principle I (allowlist adds the QR-pass secret, with storage and deletion rules);
  Security & Compliance Constraints (offline regeneration clause replaced by offline derivation
  within a backend-issued validity; 30-second clock tolerance named).
- Templates requiring updates: none.
- Follow-up: 014-qr-pase phase B unblocked.
```
