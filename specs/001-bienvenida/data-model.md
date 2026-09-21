# Data Model: Welcome & Enrollment Entry Point (01 Bienvenida)

All types below are immutable (generated `copyWith`/equality via `freezed`, per Constitution
Principle IX) and live in `domain/entities/`. None of them are written to disk by this feature; the
credential is *read* from the cache `flutter_secure_storage` holds (written elsewhere, by the
credential-issuance feature).

## CredentialStatus (sealed)

The classification `WelcomeViewModel` uses to decide what to render. Returned wrapped in
`Result<CredentialStatus>` by `CredentialRepository.getStatus()`.

| Variant | Fields | Meaning |
|---|---|---|
| `NoCredential` | — | No cached credential exists on the device. First-run or never-enrolled passenger. |
| `Valid` | `validUntil: DateTime` | A credential exists and the backend confirms it is currently valid. |
| `ExpiredOrRevoked` | `reason: ExpiryReason` (`expired` \| `revoked`) | A credential exists but the backend reports it is no longer usable. |
| `Unreachable` | `lastKnownStatus: CredentialStatus?` | The backend could not be reached to confirm status. Carries whatever status was last confirmed (nullable — never previously confirmed on this device). |

State transitions are backend-driven, not app-driven: this screen only classifies whatever the
backend/cache reports on a given check; it does not mutate credential state itself (FR-005–FR-007).

## Credential

The subset of the issued credential this screen is allowed to read (Constitution Principle I's
persisted-state allowlist).

| Field | Type | Notes |
|---|---|---|
| `token` | opaque `String` | Never logged, never included in analytics events (FR-013, Principle VII). |
| `validUntil` | `DateTime` | Drives `Valid` vs. `ExpiredOrRevoked` classification together with the backend's own status field. |

No document fields, no facial data, no name/DOB — those are out of this screen's read surface
entirely.

## EnrollmentSession (in-memory only)

Tracks progress through enrollment for the resume behavior in FR-008. **Not persisted** — held only
for the lifetime of the current app process, per the Constitution Check resolution in plan.md.

| Field | Type | Notes |
|---|---|---|
| `id` | `String` (UUID, generated at creation) | Exists only to guarantee FR-004's "exactly one session" invariant under repeated/concurrent activation of the primary action; never sent to the backend or analytics as a stable identifier. |
| `stepReached` | `EnrollmentStep` (sealed: `consent`, `documentCapture`, `selfieCapture`) | Set by later screens as the passenger progresses; this feature only reads it to decide whether to offer "resume." |
| `startedAt` | `DateTime` | In-memory only; used solely to decide UI copy ("continue where you left off"), not a resumability deadline (there is none now that state doesn't survive process termination). |

## DeviceCapability

Evaluated at launch, before offering enrollment (FR-012). Not persisted — recomputed each launch.

| Field | Type | Notes |
|---|---|---|
| `hasUsableCamera` | `bool` | |
| `osVersionSupported` | `bool` | Checked against the interim minimum-spec baseline in research.md (Android 8.0 / iOS 15.0), pending the product team's formal value. |

## AnalyticsSessionId (in-memory only)

A single `String` (UUID), generated once per app launch by the composition root and injected into
whatever emits FR-013's funnel events for this screen. Never persisted, never reused across launches
— see `contracts/analytics-events.md` for the events it keys.

## Relationships

```text
WelcomeViewModel
 ├─ reads CredentialStatus  (via CredentialRepository, backed by Credential + backend confirmation)
 ├─ reads EnrollmentSession? (in-memory, process-scoped; null if none started)
 ├─ reads DeviceCapability   (recomputed per launch)
 └─ emits funnel events keyed by AnalyticsSessionId (in-memory, process-scoped)
```

No entity here has a foreign key or persisted relationship to another — the only durable object is
`Credential`, which this feature reads but does not own or write.
