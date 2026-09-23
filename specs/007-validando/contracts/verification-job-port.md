# Contract: `VerificationJobRepository`

Per research.md §1–§4. The one port through which this screen learns how the backend verification
is going. It only reads: nothing in this port can submit samples or create a job (FR-010, SC-004).

## Interface

```text
abstract class VerificationJobRepository {
  Future<Result<VerificationJobStatus>> getStatus();
}
```

- Reads the current job for the `EnrollmentAttemptId` in the local consent record. With no local
  consent record, returns `Result.error` without a network call.
- `Result.error` means this one read failed (offline, timeout, non-2xx, pinning). It is not an
  outcome; the caller polls again (research.md §3).
- All mapping from the wire response to `VerificationJobStatus` happens inside the implementation.
  No DTO, `dio` type or backend code crosses out of `lib/data/` (Principle II).

## Wire contract (real implementation)

`GET /v1/verification/jobs/current?enrollmentAttemptId=<uuid>` over the pinned `dio` client.
Response fields as in data-model.md, `VerificationJobResponse`. The attempt id is anonymous and
carries no personal data.

## Contract test suite (run against the fake AND the real implementation)

1. In progress with document running → `Ok(inProgress(documentCheck: running, faceComparison: pending))`.
2. In progress with document passed and face running → `Ok(inProgress(passed, running))`.
3. Completed and matched → `Ok(completed(matched))` with both stages passed.
4. Completed with each rejection code → the matching `VerificationOutcome` variant, one case per code.
5. `attack_detected` → `attackDetected`, a value distinct from `faceMismatch`.
6. An unrecognized outcome code → `completed(serviceFailure)`, never an exception.
7. An unrecognized `state` → `completed(serviceFailure)`.
8. An unrecognized stage status → that stage `pending`, never `passed`.
9. Transport failure → `Result.error`.
10. No local consent record → `Result.error`, and no request is sent.

The dev fake is schedule-driven and always ends `matched` (research.md §14), so it runs cases 1–3
in time order.
