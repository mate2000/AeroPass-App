# Contract: `FieldReverificationRepository`

Per research.md §4 and FR-005.

## Interface

```text
abstract class FieldReverificationRepository {
  Future<Result<FieldReverificationOutcome>> reverify({
    required Uint8List documentImageBytes,
    required FieldKey field,
    required String candidateValue,
  });
}
```

- Called only for an edit to a field whose original processor-reported confidence was ≥0.95
  (Clarifications) and whose edited value materially differs from the original.
- `documentImageBytes` is the same retained bytes held by `PendingDocumentController` — never a fresh
  capture, never written to disk by this call.
- `Result.error` is reserved for transport failure (offline, timeout, pinning failure), exactly as
  `DocumentVerificationRepository.submit` already reserves it. Per the Clarifications' resolution, the
  ViewModel treats an `Error` here identically to `FieldReverificationOutcome.disagreed()` — both mean
  "the re-check could not confirm the edit" — there is no agent-escalation fallback for either case
  (resolved in Clarifications: automated re-check only).

## Contract test suite

1. Candidate value matches what the retained image actually shows →
   `Ok(FieldReverificationOutcome.confirmed())`.
2. Candidate value does not match → `Ok(FieldReverificationOutcome.disagreed())`.
3. Offline / transport failure → `Error` (never a bare exception; never `Ok`).
4. Called with a `field` the processor's contract doesn't support re-reading → the real
   implementation's mapping MUST still resolve to a defined outcome (falls back to `disagreed`, not an
   unhandled exception) — mirrors 003's "unrecognized error code" guard case.

## Fake implementation

Scripted responses, no network — same pattern as `FakeDocumentVerificationRepository`.

## Real implementation

`FieldReverificationService` (certificate-pinned `dio`, reusing `buildPinnedDio`) +
`FieldReverificationRepositoryImpl`. No processor DTO, error code, or exception type crosses into
`DocumentConfirmationViewModel`.
