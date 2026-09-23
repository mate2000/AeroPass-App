# Contract: `CredentialIssuanceRepository`

Per research.md §1–§3. The one port through which the app learns that a credential was issued.
Every active credential this app ever displays originates here (FR-001, SC-001).

## Interface

```text
abstract class CredentialIssuanceRepository {
  Future<Result<IssuanceOutcome>> requestIssuance();
}
```

- Called by `VerificationProgressViewModel` only. No other ViewModel receives this port
  (Constitution Principle X, interface segregation).
- The request carries the durable `EnrollmentAttemptId` from the local consent record, so the
  backend can correlate issuance with the verification it already holds. It carries no personal
  data.
- On `Ok(activated(...))`, the implementation has **already** written the token and `validUntil` to
  secure storage. If that write fails, the method returns `Result.error`, never `Ok(activated)`.
- On `Ok(notActive)`, `Ok(incomplete)` or `Result.error`, nothing is written.
- Mapping from the wire response to `IssuanceOutcome` follows research.md §2, in order. No DTO,
  `dio` type or backend error code leaves `lib/data/` (Principle II).

## Wire contract (real implementation)

`POST /v1/credential/issuance` over the pinned `dio` client, body
`{ "enrollmentAttemptId": "<uuid>" }`. Response fields as in data-model.md,
`CredentialIssuanceResponse`. Until the backend exists, this is the contract the dev fake and the
real implementation's contract tests share.

## Contract test suite (run against the fake AND the real implementation)

1. Backend returns a complete active credential → `Ok(activated)` with every field mapped, and the
   token and `validUntil` present in secure storage afterwards.
2. Backend returns `status: "suspended"` with complete fields → `Ok(notActive(suspended))`, and
   nothing written.
3. Backend returns `status: "active"` with `validUntil` missing → `Ok(incomplete())`, nothing
   written.
4. Backend returns `documentLast4: "12345"` → `Ok(incomplete())`.
5. Backend returns `validUntil` earlier than `issuedAt` → `Ok(incomplete())`.
6. Backend returns an unrecognized `status` → `Ok(incomplete())`, never an unhandled exception.
7. Transport failure (offline, timeout, non-2xx, pinning) → `Result.error`, nothing written.
8. Complete active response, but the secure-storage write throws → `Result.error`, never
   `Ok(activated)`.
9. The `ActivatedCredential` returned in case 1 exposes no token and no full document number
   (asserted structurally, by the type having no such field).

## Dev fake

`DevCredentialIssuanceRepository` (research.md §14) always returns case 1's shape with synthetic
data and writes the same two keys, so a relaunch after the demo behaves like production.

## Idempotency per enrollment attempt (added by 011-error-tecnico)

A second `POST /v1/credential/issuance` for the same enrollment attempt, sent after a first request
that failed in transit, MUST return the credential already issued, if there is one, and MUST NOT
issue a second. A retry from screen 11 goes through 007 again, which asks for issuance again, so
this clause is what keeps a lost response from becoming a duplicate credential. The contract suite
covers it: a first request failing with `connectionError` and a second answering `activated` give
the same token, with two requests sent (011 contracts/transport-failure-addendum.md, case 3).
