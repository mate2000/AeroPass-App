# Data Model: Service Failure (11 Error técnico)

Nothing here is persisted. Every type lives in memory, or is read from the backend on demand
(constitution Principle I).

## Domain

### `TransportFailure` (new, `lib/domain/entities/transport_failure.dart`)

The error object inside `Result.error` when a request failed in transit. Sealed:

| Variant | Meaning |
|---|---|
| `connectivity(cause)` | No connection reached the server |
| `service(cause)` | The server was reached and failed, answered badly, or failed pinning |

`cause` is the original error, kept for logging. It never reaches an event or a report. Errors that
fit neither variant stay unwrapped.

### `ServiceFailureClass` (new enum, `lib/domain/entities/service_failure.dart`)

`service`, `connectivity`, `undetermined`. It decides the wording, never blame (research.md §1).

### `ServiceFailure` (new, freezed, same file)

| Field | Type | Rule |
|---|---|---|
| `failureClass` | `ServiceFailureClass` | Decided in 007 from evidence (research.md §2) |
| `stage` | `VerificationStage` | The stage 007 was on |
| `jobTerminal` | `bool` | True only when the job completed with `serviceFailure`; true means the retry needs a new selfie |
| `occurredAt` | `DateTime` | From the injected `Clock`; used for the resolution timing |

### `JourneyStep` (new enum, `lib/domain/entities/service_status.dart`)

`documentScan`, `selfie`, `issuance`, in display order.

### `StepHealth` (new enum, same file)

`operational`, `degraded`, `unavailable`.

### `ServiceStatus` (new, freezed, same file)

| Field | Type | Rule |
|---|---|---|
| `steps` | `Map<JourneyStep, StepHealth>` | Exactly the three steps; the mapping fails otherwise |
| `retryAfter` | `DateTime?` | Optional; ignored if not in the future |

`worst` is a derived getter: `unavailable` beats `degraded`, which beats `operational`.

### `VerificationJobStatus` (change)

Both variants gain an optional `DateTime? resumableUntil`, defaulting to null. Existing constructors
compile unchanged. Null means the job is not resumable at launch (research.md §8).

## Ports (new)

| Port | Method | Returns |
|---|---|---|
| `ServiceStatusRepository` | `getStatus()` | `Result<ServiceStatus>` |
| `OperationalAlertReporter` | `reportServiceFailure({required VerificationStage stage})` | `void`, fire and forget |
| | `bool get canClaimNotification` | True only under research.md §7's three conditions |

## App layer

### `TechnicalErrorController` (new, `lib/app/technical_error_controller.dart`)

In memory, provided once from the composition root.

| Member | Behavior |
|---|---|
| `record(ServiceFailure)` | Called by 007 before navigating to screen 11. Replaces any previous record and marks it unreported |
| `ServiceFailure? current` | Read by screen 11 |
| `bool takeReportable()` | True exactly once per recorded `service` failure, then false |
| `Duration registerArrival()` | Counts one arrival and returns its hold: 0, 15, 30, 60, 60 … seconds |
| `Duration? resolve(DateTime now)` | Called by 007 on activation. Returns the time since the first failure of this run, or null if there was none. Clears the record and resets the count |

### `EnrollmentSessionController` (change)

New `resumeAfterVerification()`: when no session exists, creates one at `selfieCapture` with
`identityConfirmed: true` (research.md §9). It does nothing if a session exists.

## Screen 11 ViewModel state (`TechnicalErrorViewModel`)

| Field | Type | Source |
|---|---|---|
| `failureClass` | `ServiceFailureClass` | `current?.failureClass ?? undetermined` |
| `needsNewSelfie` | `bool` | `current?.jobTerminal ?? false` |
| `showPreservation` | `bool` | The session's `identityConfirmed` |
| `showNotificationClaim` | `bool` | `failureClass == service && reporter.canClaimNotification` |
| `status` | `ServiceStatus?` | The latest successful read; null means omit the card. A later failed read clears it |
| `retryAvailableAt` | `DateTime` | The arrival time plus the hold, or `status.retryAfter` if that is later |
| `retryRemaining` | `Duration` | Recomputed every second while positive |
| `pendingNavigation` | `TechnicalErrorTarget?` | `verification`, `selfie` or `welcome`; one shot |

### Transitions

- **Open**: register the arrival. Report the alert if `takeReportable()` is true. Emit the entry
  event. Start the status poll, and the countdown ticker while held.
- **Status read**: success sets `status` and emits the status event on the first success. Failure
  clears `status`.
- **Reintentar**: ignored while held. Otherwise emits the retry event and navigates to `selfie` if
  `needsNewSelfie`, else to `verification`.
- **Salir**: emits the exit event and navigates to `welcome`. The session and the record stay intact.
- **Dispose**: cancels both timers.
