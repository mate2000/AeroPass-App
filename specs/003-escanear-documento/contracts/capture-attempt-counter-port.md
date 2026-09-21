# Contract: `CaptureAttemptCounterRepository`

The port backing the constitution's amended Principle I persisted state (count + last-reset
timestamp only). Referenced by `plan.md`'s Project Structure and test layout; documented here to
close that gap before task generation.

## Interface

```text
abstract class CaptureAttemptCounterRepository {
  Future<Result<CaptureAttemptCounter>> read();
  Future<Result<CaptureAttemptCounter>> increment();
  Future<Result<CaptureAttemptCounter>> reset();
}
```

- `read()`: returns the current counter, or a fresh `CaptureAttemptCounter(count: 0, lastResetAt: <now>)`
  if none has ever been written (first-ever attempt on this device) — never `Ok(null)`, since a
  zeroed counter is itself a valid, meaningful value here (unlike `ConsentRepository.getLocalRecord()`,
  where "no record" and "a record" are semantically different).
- `increment()`: persists `count + 1` with the same `lastResetAt`, and returns the updated value.
- `reset()`: persists `count: 0` with a fresh `lastResetAt`, and returns the updated value. Called on
  a successful capture (`CaptureOutcome.accepted`) or when the limit-reached routing occurs
  (research.md §3 — the limit protects one continuous run of attempts, not a lifetime ban).
- All three return `Error` only on a genuine storage failure (e.g. platform secure-storage
  exception) — never for "no data yet," which `read()` handles by returning a zeroed value.

## Contract test suite

1. `read()` with nothing ever written → `Ok(CaptureAttemptCounter(count: 0, ...))`.
2. `increment()` three times in a row → `read()` afterward reflects `count: 3` with the same
   `lastResetAt` each time (unchanged by increment).
3. `reset()` after a nonzero count → `read()` afterward reflects `count: 0` and a new `lastResetAt`
   strictly later than the previous one.
4. The counter survives being read by a **new instance** of the repository (simulating an app
   restart) — the real implementation's defining requirement, per the constitution amendment.

## Fake implementation

`FakeCaptureAttemptCounterRepository` — in-memory `CaptureAttemptCounter` field, no secure storage,
same scripted-double pattern as the app's other fakes.

## Real implementation

`CaptureAttemptCounterService` (`flutter_secure_storage`, reusing the same instance already
constructed for credential/consent) + `CaptureAttemptCounterRepositoryImpl`.
