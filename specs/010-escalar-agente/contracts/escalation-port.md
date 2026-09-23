# Contract: `EscalationRepository`

Per research.md §1, §3–§5. The one port through which the app opens an escalation and learns its
state and outcome. It never carries a credential: an agent's approval reaches the app only through
008's issuance port (FR-011).

## Interface

```text
abstract class EscalationRepository {
  Future<Result<EscalationCase>> openOrResume({required EscalationArrival arrival});
  Future<Result<EscalationStatus>> getStatus();
}
```

- Both read the `EnrollmentAttemptId` from the local consent record; without one, `Result.error`
  and no request is sent.
- `openOrResume` returns the open case if one exists (FR-022); it never opens a second while one is
  open.
- `getStatus` reports `expired` once the backend's 24-hour window has passed.
- All mapping happens inside the implementation (Principle II); unknown values map to their safe
  readings (data-model.md, `EscalationStatusResponse`).

## Wire contract (real implementation)

- `POST /v1/escalations` with `{ enrollmentAttemptId, arrival }`.
- `GET /v1/escalations/current?enrollmentAttemptId=<uuid>`.

## Contract test suite (run against the fake AND the real implementation)

1. `openOrResume` with no open case opens one and returns it.
2. `openOrResume` with a case already open returns that case, with its original `openedAt`.
3. `getStatus` on an open case returns `open` with both channels and their fields.
4. A channel with a wait range maps to `estimatedWait`; one without maps to `null`.
5. An unavailable channel maps `available: false` with its `nextOpensAt`.
6. A channel missing `available` maps to unavailable.
7. `resolved` with `credential_issued`, `declined`, and `attempts_reset` for each scope map to their
   variants; none carries a credential.
8. An unknown outcome, or an unknown `state`, is a failed read (`Result.error`) — never an outcome; the caller keeps checking.
9. `expired` maps to `expired`.
10. Transport failure → `Result.error`.
11. No local consent record → `Result.error`, no request sent.
