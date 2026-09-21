# Data Model: Informed Consent Gate (02 Consentimiento)

All types below are immutable (generated `copyWith`/equality via `freezed`, per Constitution
Principle IX) and live in `domain/entities/`.

## ConsentTextVersion

Fetched fresh each time the gate is presented (research.md §5) — never persisted, never cached
across a failed refetch.

| Field | Type | Notes |
|---|---|---|
| `id` | `String` | The version identifier a `ConsentRecord` references. |
| `points` | `List<ConsentPoint>` | Rendered in order; the reference shows 3, but the app doesn't hard-code that count — legal content, not app logic, decides how many. |
| `rightsStatement` | `String` | FR-002: the passenger's rights over their data. |
| `optionalityStatement` | `String` | FR-003: that providing sensitive data is optional. |
| `processorDisclosure` | `String` | FR-002: names that verification is performed by an external processor (resolves the reference's undisclosed-processor gap). |
| `privacyPolicyUrl` | `String` | FR-012. |
| `termsUrl` | `String` | FR-012. |
| `publishedAt` | `DateTime` | Displayed if useful for FR-014's "indicating what changed" framing; not otherwise used by app logic. |

### ConsentPoint

| Field | Type | Notes |
|---|---|---|
| `icon` | `ConsentPointIcon` (sealed: `camera`, `clock`, `share`) | Decorative; the heading/body text carries the actual fact (FR-014/no-color/no-icon-only-meaning, consistent with 001-bienvenida's FR-014 pattern). |
| `heading` | `String` | e.g. "Qué se captura". |
| `body` | `String` | e.g. "Imagen de tu documento...". |

## ConsentRecord (persisted — local secure-storage copy + backend system of record)

The **only** new persisted entity this feature introduces, per the Constitution Check's resolution:
withdrawal is a status transition on this record, not a second entity.

| Field | Type | Notes |
|---|---|---|
| `textVersionId` | `String` | References the `ConsentTextVersion.id` shown at confirmation time. |
| `enrollmentAttemptId` | `EnrollmentAttemptId` | Durable anonymous identifier (see below), generated at confirmation. |
| `scope` | `ProcessingScope` (sealed, currently only `.identityVerification`) | FR-005: never bundles another purpose. |
| `confirmedAt` | `DateTime` | |
| `status` | `ConsentRecordStatus` (sealed: `active`, `withdrawalPending`, `withdrawn`) | State machine below. |
| `withdrawalRequestedAt` | `DateTime?` | Set when `status` becomes `withdrawalPending`; null while `active`. |

**State transitions**: `active → withdrawalPending` (passenger withdraws, possibly offline) →
`withdrawn` (backend confirms receipt, via `retryPendingWithdrawal()` or an immediate successful
call). There is no path back to `active` — a withdrawn record's only future is a brand-new consent
flow producing a brand-new `ConsentRecord`, never a resurrected old one.

**Local effect vs. backend confirmation**: the credential/pass invalidation SC-005 requires (≤1s,
no network dependency) happens the instant `status` becomes `withdrawalPending` locally — it does
not wait for `withdrawn`. The backend transition to `withdrawn` is what satisfies SC-004's 24-hour
processing budget.

## EnrollmentAttemptId

| Field | Type | Notes |
|---|---|---|
| `value` | `String` (UUID v4, via `core/uuid.dart`) | Generated once, at consent confirmation. Persisted as part of `ConsentRecord`. Distinct from 001-bienvenida's `AnalyticsSessionId`, which stays in-memory/per-launch only — see research.md §3 and spec.md's Clarifications. |

## ProcessingScope (sealed)

| Variant | Notes |
|---|---|
| `identityVerification` | The only variant at this release (FR-005). Adding a second purpose (analytics, communications) is a spec amendment, not a new enum case slipped in here. |

## Relationships

```text
ConsentViewModel
 ├─ fetches ConsentTextVersion        (via ConsentRepository, not persisted)
 ├─ reads local ConsentRecord?        (via ConsentRepository, secure-storage-backed; null if none)
 └─ on confirm: creates ConsentRecord (generates EnrollmentAttemptId, persists locally + backend)

WithdrawalPlaceholderView
 └─ calls ConsentRepository.withdraw() on the existing local ConsentRecord (status → withdrawalPending)

go_router._redirect (existing, 001-bienvenida)
 └─ opportunistically calls ConsentRepository.retryPendingWithdrawal() (research.md §4)
```

No entity here is written to disk outside the single `ConsentRecord` — `ConsentTextVersion` is
always live-fetched, matching Principle I's minimization stance the same way 001-bienvenida's
`CredentialStatus`/`DeviceCapability` are recomputed rather than cached.
