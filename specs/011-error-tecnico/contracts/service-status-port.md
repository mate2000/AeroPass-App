# Contract: Service status port

`ServiceStatusRepository` in `lib/domain/repositories/service_status_repository.dart` (FR-007,
FR-008, FR-014; research.md §6).

```text
abstract class ServiceStatusRepository {
  Future<Result<ServiceStatus>> getStatus();
}
```

## Wire format

`GET /v1/service-status?enrollmentAttemptId=<id>` over the pinned `dio` client. The id is the
`EnrollmentAttemptId` from the local consent record, so the backend can scope the status to the
passenger's airport. It carries no personal data.

```json
{
  "steps": [
    { "step": "document_scan", "health": "operational" },
    { "step": "selfie",        "health": "degraded" },
    { "step": "issuance",      "health": "operational" }
  ],
  "retryAfter": "2026-09-23T18:42:00Z"
}
```

`retryAfter` is optional.

## Mapping rules

| Input | Result |
|---|---|
| Exactly the three steps, each with a known health | `Result.ok(ServiceStatus)` |
| A missing step, a duplicate step, or an unknown step name | `Result.error(FormatException)` |
| An unknown `health` value | `Result.error(FormatException)`. A guessed state is never shown |
| `retryAfter` absent or unparsable | `retryAfter: null`; the rest still maps |
| No local consent record | `Result.error`, and no request is sent |
| Transport failure | `Result.error(TransportFailure…)` (transport-failure-addendum.md) |

## Implementations

| Implementation | Behavior |
|---|---|
| `ServiceStatusRepositoryImpl` | The mapping above |
| `DevServiceStatusRepository` | Always `Result.error(StateError('no status source in development'))`. The card is never rendered in happy-path mode |
| `FakeServiceStatusRepository` (tests) | Scripted results; errors when nothing is scripted |

## Contract test suite (real implementation against `FakeHttpClientAdapter`)

1. A valid body maps all three steps and `retryAfter`.
2. A body with all three `operational` maps. The card still shows (Clarifications).
3. A missing step, a duplicate step, an unknown step, and an unknown health each give `Result.error`.
4. A missing `retryAfter` gives null and still succeeds.
5. No consent record gives `Result.error`, with `requestCount == 0`.
6. The request carries the attempt id as a query parameter and has no body.
