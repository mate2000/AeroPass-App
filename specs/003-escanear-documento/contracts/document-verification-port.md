# Contract: `DocumentVerificationRepository`

## Interface

```text
abstract class DocumentVerificationRepository {
  Future<Result<CaptureOutcome>> submit(Uint8List documentImageBytes);
}
```

- Called only after `DocumentQualityAssessor.assess()` returns `usable` (FR-006) — this port never
  sees a device-rejected capture.
- `Result.error` is reserved for transport failure (offline, timeout, pinning failure) — FR-015's
  "verification cannot be sent yet" state. A processor-side *rejection* of the document is `Ok`
  wrapping `CaptureOutcome.rejected(...)`, not an `Error` — like 001-bienvenida's `Unreachable`
  status, a rejection is an expected, classified outcome with its own defined UI state, not an
  exceptional one.
- `documentImageBytes` is never retained by the caller after this call returns (by convention — the
  service does not accept or produce a stored copy).

## Contract test suite

1. Submission accepted by the processor → `Ok(CaptureOutcome.accepted)`.
2. Submission rejected for blur → `Ok(CaptureOutcome.rejected(CaptureRejectionReason.blur))`.
3. Submission rejected for glare → `Ok(CaptureOutcome.rejected(CaptureRejectionReason.glare))`.
4. Submission rejected as wrong document → `Ok(CaptureOutcome.rejected(CaptureRejectionReason.wrongDocument))`.
5. Submission rejected for a processor-only reason with no device-side equivalent →
   `Ok(CaptureOutcome.rejected(CaptureRejectionReason.unreadable))`.
6. Offline / transport failure → `Error` (never a bare exception; never `Ok`).
7. A malformed/unrecognized processor error code → the real implementation's mapping MUST still
   resolve to a defined `CaptureRejectionReason` (falls back to `unreadable`, never an unhandled
   exception) — this case exists specifically in the fake to guard the mapping's completeness.

## Fake implementation

Scripted responses, no network — used by widget/unit tests and the contract suite, same pattern as
`FakeConsentRepository`/`FakeCredentialRepository`.

## Real implementation

`DocumentVerificationService` (certificate-pinned `dio`, reusing `buildPinnedDio`) +
`DocumentVerificationRepositoryImpl`, which owns the processor error-code → `CaptureRejectionReason`
mapping. No processor DTO, error code, or exception type crosses into `CaptureViewModel`.
