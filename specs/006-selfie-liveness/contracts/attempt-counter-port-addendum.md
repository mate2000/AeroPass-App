# Contract addendum: `CaptureAttemptCounterRepository` (003, extended by this feature)

This does not replace `specs/003-escanear-documento/contracts/capture-attempt-counter-port.md` — it
records the one change this feature makes to that already-shipped contract, per research.md §3.

## What changes

```text
// Before (003, as shipped):
abstract class CaptureAttemptCounterRepository {
  Future<Result<CaptureAttemptCounter>> read();
  Future<Result<CaptureAttemptCounter>> increment();
  Future<Result<CaptureAttemptCounter>> reset();
}

// After (this feature):
abstract class CaptureAttemptCounterRepository {
  Future<Result<CaptureAttemptCounter>> read(AttemptCounterScope scope);
  Future<Result<CaptureAttemptCounter>> increment(AttemptCounterScope scope);
  Future<Result<CaptureAttemptCounter>> reset(AttemptCounterScope scope);
}
```

`CaptureAttemptCounter` and `captureAttemptLimit` (still `3`) are unchanged. `AttemptCounterScope`
is a new, two-value enum (`documentCapture`, `selfieLiveness`).

## What does NOT change

- The entity shape (count + lastResetAt only).
- The limit value (3) — this feature's Clarifications confirmed it matches 003's, not a new number.
- The "never `Ok(null)`; a zeroed counter is itself meaningful" rule.

## Migration obligations this feature carries

1. `CaptureAttemptCounterService`: each secure-storage key pair becomes scope-derived (e.g.
   `aeropass.capture.document.attempt_count` / `aeropass.capture.selfie_liveness.attempt_count`) —
   the document-capture key strings are kept byte-identical to what 003 already writes, so an
   in-progress document-capture counter isn't silently reset by this change.
2. `CaptureAttemptCounterRepositoryImpl`: forwards `scope` to the service; no other logic changes.
3. `CaptureViewModel` (003): its three call sites (`read`, `increment`, `reset`) each add
   `AttemptCounterScope.documentCapture`.
4. `FakeCaptureAttemptCounterRepository` and
   `test/contract/capture_attempt_counter_repository_contract_test.dart`: updated to the new
   signature; 003's own 4 contract cases are re-run as regression coverage (both fake and real).

## Contract test additions (this feature)

1. `documentCapture` and `selfieLiveness` scopes are independent: incrementing one leaves the
   other's `read()` at its prior value.
2. `reset(selfieLiveness)` does not affect `documentCapture`'s stored counter, and vice versa.
3. 003's existing 4 cases (read-with-nothing-written, increment×3, reset, survives-a-new-instance),
   run once per scope.
