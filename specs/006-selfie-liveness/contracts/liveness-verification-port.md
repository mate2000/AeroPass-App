# Contract: `LivenessVerificationRepository`

Per research.md §1. The one port through which every liveness/attack-detection classification this
app ever displays or records originates — FR-002's security boundary lives here structurally, not
by convention.

## Interface

```text
abstract class LivenessVerificationRepository {
  Future<Result<String>> startSession();  // returns a sessionId

  Future<Result<LivenessSampleOutcome>> submitSample({
    required String sessionId,
    required Uint8List frameBytes,
  });
}
```

- `startSession()` begins one attempt. `Result.error` is a transport failure (offline, timeout,
  pinning failure) — before any frame has been sent, nothing has been risked.
- `submitSample(...)` is called repeatedly by the ViewModel, once per sampled frame, until it
  returns `Ok(LivenessSampleOutcome.completed(...))`. `frameBytes` is never retained by the caller
  after this call returns (FR-008), exactly as `DocumentVerificationRepository.submit`'s convention
  already establishes.
- `Result.error` on `submitSample` is a transport failure mid-attempt — the ViewModel treats it as
  a non-terminal hiccup up to a small retry bound, and as `LivenessOutcome.unclassifiedFailure()`
  (research.md §7) if retries are exhausted — never as `LivenessOutcome.attackDetected()`, since a
  transport failure carries no security signal at all.
- The real implementation owns 100% of the mapping from whatever the processor's actual wire
  contract is (its own phase count, instruction codes, and outcome taxonomy) into
  `LivenessSampleOutcome`/`LivenessPhase`/`LivenessInstruction`/`LivenessOutcome` — no processor
  DTO, error code, or SDK type may appear outside `lib/data/` (Constitution Principle II).

## Contract test suite

1. `startSession()` succeeds → `Ok(sessionId)`, a non-empty string.
2. `startSession()` transport failure → `Error`.
3. `submitSample(...)` mid-attempt, processor reports phase 2 of 4 → `Ok(LivenessSampleOutcome.inProgress(phase: ...))` with `phase.index == 1`, `phase.totalPhases == 4`.
4. `submitSample(...)` final sample, processor reports success → `Ok(LivenessSampleOutcome.completed(outcome: LivenessOutcome.success()))`.
5. `submitSample(...)`, processor reports a known quality-failure code (e.g. "too dark") → `Ok(...completed(outcome: LivenessOutcome.qualityFailure(reason: LivenessQualityReason.tooDark)))`.
6. `submitSample(...)`, processor reports an attack-detection code → `Ok(...completed(outcome: LivenessOutcome.attackDetected()))` — the contract test asserts this is a *distinct domain value* from `unclassifiedFailure()`, even though both render identically in the UI (that collapsing happens at the view layer, per research.md §7 — the port itself MUST still report the true classification, or SC-007's audit obligation cannot be met).
7. `submitSample(...)`, processor reports a code the mapping does not recognize → the real implementation's mapping MUST still resolve to `LivenessOutcome.unclassifiedFailure()`, never an unhandled exception (mirrors 003's "unrecognized error code" guard case).
8. `submitSample(...)` transport failure → `Error` (never a bare exception; never `Ok`).

## Fake implementation

`FakeLivenessVerificationRepository`: scripted responses, no network — same pattern as
`FakeDocumentVerificationRepository`.

## Dev (happy-path) implementation

`DevLivenessVerificationRepository` (research.md §10, wired behind
`HappyPathFlags.useFakeVerificationBackend`): `startSession()` always succeeds immediately;
`submitSample()` advances through a fixed 4-phase scripted sequence (one phase per call, regardless
of `frameBytes` content — it is never inspected) and returns `.completed(LivenessOutcome.success())`
on the 4th call. Never returns a failure outcome — happy-path mode's job is to prove the flow is
walkable, not to exercise the failure taxonomy (spec.md's own Delivery Mode section: "the
attack-detection feedback rules may be stubbed").

## Real implementation

`LivenessVerificationService` (certificate-pinned `dio`, reusing `buildPinnedDio`) +
`LivenessVerificationRepositoryImpl`, which owns the processor's phase/instruction/outcome-code →
domain-vocabulary mapping. No processor DTO, error code, or exception type crosses into
`LivenessCaptureViewModel`.
