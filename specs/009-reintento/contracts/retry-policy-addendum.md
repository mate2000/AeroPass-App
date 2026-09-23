# Addendum: the retry policy across 003, 006 and 007

Per research.md §2 and spec FR-017. Changes shipped behaviour in three view models. Every change is
covered by an updated or new test in that feature's existing suite.

## Changes

### 003 — `CaptureViewModel`

1. `_registerAccepted` no longer calls `reset(documentCapture)`.
2. The limit path no longer calls `reset(documentCapture)` before routing to retry guidance.
3. On creation, if `read(documentCapture).count >= captureAttemptLimit`, the view model targets
   retry guidance and does not start the camera.

### 006 — `LivenessCaptureViewModel`

1. A liveness success no longer calls `reset(selfieLiveness)`.
2. The limit path no longer calls `reset(selfieLiveness)` before routing to retry guidance.
3. On creation, if `read(selfieLiveness).count >= captureAttemptLimit`, the view model targets
   retry guidance and does not start the camera.

### 007 — `VerificationProgressViewModel`

1. On `completed(matched)`, before requesting issuance, reset **both** `documentCapture` and
   `selfieLiveness`.
2. Row R1 no longer resets `selfieLiveness` (already done at `matched`).
3. Rows R6 and R7–R9 no longer reset a counter when it reaches the limit.

## Regression tests

1. 003: an accepted photo leaves the counter unchanged.
2. 003: reaching the limit leaves the counter at the limit.
3. 003: entering with the counter at the limit targets retry guidance; the camera is not started.
4. 006: a liveness success leaves the counter unchanged.
5. 006: reaching the limit leaves the counter at the limit.
6. 006: entering with the counter at the limit targets retry guidance; the camera is not started.
7. 007: `matched` resets both counters, even when issuance then fails.
8. 007: R6 and R7–R9 at the limit leave the counter at the limit.
9. All other existing 003, 006 and 007 tests still pass, updated only where they asserted a reset
   this addendum removes.
