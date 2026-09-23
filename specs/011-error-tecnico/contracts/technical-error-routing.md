# Contract: entering and leaving screen 11

Changes to 007's `VerificationProgressViewModel`, and the behavior of the new
`TechnicalErrorViewModel` (FR-002, FR-004, FR-008–FR-011; research.md §1–§5).

## Entry: what 007 records before navigating to screen 11

| 007 event | `failureClass` | `stage` | `jobTerminal` |
|---|---|---|---|
| Job `completed(serviceFailure)` | `service` | the stage that was running | **true** |
| Issuance `Result.error(TransportFailure.service)` | `service` | `issuance` | false |
| Issuance `Result.error(TransportFailure.connectivity)` | `connectivity` | `issuance` | false |
| Issuance `Result.error(other)` | `undetermined` | `issuance` | false |
| Hard timeout, every poll failed with `TransportFailure.connectivity` | `connectivity` | the running stage | false |
| Hard timeout, any other poll history | `undetermined` | the running stage | false |

Rules that do not change:

- None of these touches `CaptureAttemptCounterRepository` (FR-002).
- 007 still resets both counters only on `matched` (009 FR-017).
- On `IssuanceActivated`, 007 also calls `TechnicalErrorController.resolve(now)`. If that returns a
  duration, 007 emits `technicalErrorResolved(elapsedSeconds)`.

## Exit: where screen 11 sends the passenger

| Action | Condition | Destination |
|---|---|---|
| Reintentar | `jobTerminal` | `AppRoutes.livenessCapture` (006) |
| Reintentar | otherwise, including nothing recorded | `AppRoutes.verificationProgress` (007) |
| Reintentar | the button is held | nothing; the tap is ignored |
| Salir | always | `AppRoutes.welcome` (research.md §8's splash-only rule keeps it there) |
| Ayuda | always | push `AppRoutes.help`; returning leaves the screen unchanged |
| Back gesture | always | blocked (`PopScope(canPop: false)`) |

## Test-first cases (Principle IV)

ViewModel unit tests, using fakes and a controllable `Clock`:

1. Each of 007's six entry rows records the class, stage and `jobTerminal` shown above. These are
   007 ViewModel tests.
2. None of them increments either attempt counter.
3. Retrying a `jobTerminal` failure targets the selfie. Every other case targets verification.
4. Pacing: the first arrival is not held. The second is held 15 s, the third 30 s, the fourth and
   fifth 60 s. After `resolve()`, the next arrival is not held.
5. A `retryAfter` later than the scheduled hold replaces it. An earlier or past `retryAfter` does not.
6. A tap while held produces no navigation and no retry event.
7. With nothing recorded, the wording is `undetermined`, no alert is sent, and the retry targets
   verification.
8. Screen 11 reads no capture, and its ViewModel imports no camera or capture code. This is enforced
   by the existing import-boundary test, extended to this feature.
