# Contract: `ConsentRepository`

The domain-owned port `ConsentViewModel` (and the withdrawal placeholder view) depend on.

## Interface

```text
abstract class ConsentRepository {
  Future<Result<ConsentTextVersion>> getCurrentText();
  Future<Result<ConsentRecord>> recordConsent({required String textVersionId});
  Future<Result<ConsentRecord?>> getLocalRecord();
  Future<Result<ConsentRecord>> withdraw();
  Future<void> retryPendingWithdrawal();
}
```

- `getCurrentText()`: always a live fetch (research.md §5). `Error` on any network/parse failure —
  the ViewModel maps this directly to the gate's blocking "unavailable" state (Edge Cases), never a
  stale fallback.
- `recordConsent()`: generates the `EnrollmentAttemptId` (research.md §3), submits to the backend,
  and — only after the backend confirms — persists the local copy and returns `Ok`. If the device is
  offline or the backend call fails, returns `Error`; the ViewModel does NOT advance past the gate
  (FR-008). This is why recording is never attempted while offline rather than queued like
  withdrawal — FR-007 requires the record to exist *before* any capture surface is reachable, so an
  unconfirmed queued record can't stand in for it.
- `getLocalRecord()`: reads the local secure-storage copy, or `Ok(null)` if none exists. Used both
  to decide whether to skip the gate (already consented to the current version) and to check
  currency (compare `.textVersionId` against a fresh `getCurrentText()` — the repository doesn't
  do this comparison itself, to keep it a single-responsibility read).
- `withdraw()`: transitions the local record to `withdrawalPending` immediately (local effect,
  SC-005 — no network dependency for this step) and attempts backend delivery inline; if that
  attempt fails, the record stays `withdrawalPending` locally and `retryPendingWithdrawal()` picks
  it up later. Returns `Error` only if there is no local record to withdraw in the first place.
- `retryPendingWithdrawal()`: no-op if there's no `withdrawalPending` record, or if a delivery
  attempt is already in flight. Never throws — failures are swallowed and simply retried on the next
  call (research.md §4's opportunistic trigger).

## Contract test suite (Principle IV, Principle X Liskov)

The same suite runs against both the fake and the real implementation.

1. `getCurrentText()` succeeds → `Ok(ConsentTextVersion)` with all fields populated.
2. `getCurrentText()` fails (network/parse) → `Error`.
3. `recordConsent()` while online, backend accepts → `Ok(ConsentRecord)` with `status = active`,
   a freshly-generated `enrollmentAttemptId`, and the local copy persisted (verified via a
   subsequent `getLocalRecord()` in the same test returning the same record).
4. `recordConsent()` while offline/backend rejects → `Error`; `getLocalRecord()` afterward still
   returns `Ok(null)` — no partial record was persisted.
5. `getLocalRecord()` with no prior consent → `Ok(null)`.
6. `withdraw()` with an active local record, backend reachable → `Ok(ConsentRecord)` with
   `status = withdrawn` (immediate success case) or `withdrawalPending` (if the fake/real backend
   simulates a slow confirmation) — both are valid outcomes of this call; the test asserts the local
   record's status is no longer `active` immediately after the call returns, regardless of which.
7. `withdraw()` with no local record → `Error`.
8. `retryPendingWithdrawal()` with a `withdrawalPending` local record and a now-reachable backend →
   the local record's status becomes `withdrawn` after the call.
9. `retryPendingWithdrawal()` with no `withdrawalPending` record → no-op, doesn't throw.

## Fake implementation (`FakeConsentRepository`)

Scripted responses, no network, no `flutter_secure_storage`, no provider SDK — per Principle II's
"full test suite against a fake with no network linked" pattern, reused here for consistency even
though this repository isn't adapter-ing the verification provider itself.

## Real implementation (`ConsentRepositoryImpl`)

Backed by `ConsentService` (`data/services/`), composing:

- A certificate-pinned `dio` client (`buildPinnedDio`, reused from 001-bienvenida) for the
  GET-current-text, POST-consent, and POST-withdrawal calls.
- `flutter_secure_storage` for the local `ConsentRecord` copy.
- Mapping of any thrown exception into `Result.error`, never a bare exception crossing into
  `ConsentViewModel` (Principle IX).

No `dio` exception type or raw JSON shape may appear outside `data/services/`.
