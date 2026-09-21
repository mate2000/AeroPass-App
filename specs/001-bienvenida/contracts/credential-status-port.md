# Contract: `CredentialRepository`

The domain-owned port `WelcomeViewModel` depends on to resolve launch-time credential status.
Constitution Principle IX (Result objects) and Principle II's adapter-boundary pattern both apply
here, even though this isn't the OCR/liveness/face-match provider — the same shape is used for
consistency and testability.

## Interface

```text
abstract class CredentialRepository {
  Future<Result<CredentialStatus>> getStatus();
}
```

- `Result<CredentialStatus>` is `Ok(CredentialStatus)` or `Error(CredentialError)` — see
  data-model.md for `CredentialStatus`'s variants.
- `CredentialError` is a sealed type; for this feature, the only classified error path is
  `CredentialError.unreachable`, which `WelcomeViewModel` treats identically to
  `CredentialStatus.Unreachable` (both mean "show last known state, mark unrefreshed" — FR-007).
- Must complete within the app's overall splash budget (SC-003: ≤2s p90 including this call, on the
  minimum-spec device) — a slow real implementation is a defect against that budget, not something
  this contract itself times out.

## Contract test suite (Principle IV, Principle X Liskov)

The **same** test suite runs against both implementations; neither may special-case the test runner.

1. No cached credential exists → `Ok(NoCredential)`.
2. A cached credential exists and the backend confirms it valid → `Ok(Valid(validUntil))`.
3. A cached credential exists and the backend reports it expired → `Ok(ExpiredOrRevoked(expired))`.
4. A cached credential exists and the backend reports it revoked → `Ok(ExpiredOrRevoked(revoked))`.
5. A cached credential exists, backend call fails (network/timeout/pinning failure) →
   `Ok(Unreachable(lastKnownStatus: <previously cached status, or null if none>))`. This is
   modeled as `Ok`, not `Error` — unreachability is an expected, classified outcome the UI has a
   defined state for (FR-007), not an exceptional one.
6. No cached credential exists, backend call fails → `Ok(Unreachable(lastKnownStatus: null))`.

## Fake implementation (`FakeCredentialRepository`)

Used by widget/unit tests and by contract test case 1–6 above. Constructed with a preset scripted
response (or sequence of responses) — no network, no `flutter_secure_storage`, no `dio` linked, per
Principle II's "full test suite against a fake with no network and no provider SDK linked."

## Real implementation (`CredentialRepositoryImpl`)

Backed by `CredentialService` (data/services/), which composes:

- A `flutter_secure_storage` read for the cached `Credential` (token + validUntil).
- A `dio` call (certificate-pinned, per research.md §4) to the backend's credential-status endpoint.
- Mapping of any thrown exception (timeout, pinning failure, non-2xx) into `Unreachable`, never a
  bare exception crossing into `WelcomeViewModel` (Principle IX: exceptions caught at the service
  boundary).

No provider SDK, DTO, or `dio` exception type may appear outside `data/services/` — `WelcomeViewModel`
and `WelcomeView` only ever see `CredentialStatus`/`Result`.
