# Addendum: transport failures from the job and issuance ports

Changes to 007's `VerificationJobRepository` and 008's `CredentialIssuanceRepository`
implementations, and to 008's issuance contract (research.md §2, §12). The port signatures do not
change.

## Error wrapping (data layer only)

A new `mapTransportError(Object error)` in `lib/data/services/transport_error_mapper.dart` is
applied in each `catch` of `VerificationJobRepositoryImpl` and `CredentialIssuanceRepositoryImpl`,
and in the new `ServiceStatusRepositoryImpl`:

| `DioException.type` | Returned error |
|---|---|
| `connectionError`, `connectionTimeout`, `sendTimeout` | `TransportFailure.connectivity(e)` |
| `badResponse`, `receiveTimeout`, `badCertificate` | `TransportFailure.service(e)` |
| any other type, or a non-`DioException` | `e`, unchanged |

Nothing else about either port changes. A "no consent record" error stays a plain `StateError`.

## Job status: `resumableUntil`

The job status response gains an optional `resumableUntil` (ISO 8601). It maps to
`VerificationJobStatus.resumableUntil`. When it is absent or unparsable, the value is null, and a
null never fails the read.

## Issuance idempotency (clause added to 008's contract)

A second `POST /v1/credential/issuance` for the same enrollment attempt, sent after a first request
that failed in transit, MUST return the credential already issued, if there is one, and MUST NOT
issue a second. The app relies on this when a retry from screen 11 goes through 007 again.

## Contract tests added

1. Job port: a `connectionError` gives `TransportFailure.connectivity`, a 503 gives
   `TransportFailure.service`, and a `badCertificate` gives `TransportFailure.service`.
2. Issuance port: the same three cases.
3. Issuance port: two requests, the first failing with `connectionError` and the second answering
   `activated` with token T, give `IssuanceActivated` with T, and `requestCount == 2`.
4. Job port: `resumableUntil` maps when present and is null when absent. Existing job-port contract
   tests still pass unchanged.
