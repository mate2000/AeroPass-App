# Quickstart: Liveness Capture (06 Selfie · liveness)

Validation guide once implemented. Like 003, this feature has a hardware dependency (the front
camera) for full manual validation, but every classification/routing rule is exercisable headlessly
via fakes.

## Automated validation (run first)

```bash
fvm flutter analyze
fvm flutter test test/unit/liveness_capture_viewmodel_test.dart
fvm flutter test test/widget/liveness_capture_view_test.dart
fvm flutter test test/contract            # LivenessVerificationRepository, LivenessCameraService,
                                           # CaptureAttemptCounterRepository (updated) — fake AND real
```

Confirm no regression in 003's and 004's suites after this feature's cross-cutting touches
(research.md §3, §4):

```bash
fvm flutter test test/unit/capture_viewmodel_test.dart
fvm flutter test test/unit/document_confirmation_viewmodel_test.dart
fvm flutter test test/contract/capture_attempt_counter_repository_contract_test.dart
fvm flutter test test/widget/router_test.dart
```

## Manual validation scenarios

Requires a prior confirmed identity record (004) and passage through the selfie instructions screen
(005) — reachable via the `USE_FAKE_CONSENT_BACKEND`/`USE_FAKE_VERIFICATION_BACKEND` dev flags with
no real backend, per 002/004's precedent. With those flags set, this screen's own liveness decision
is served by the always-succeeding dev fake (research.md §10) — a real device is still needed to
exercise the actual front-camera preview.

1. **Hands-free success (User Story 1)**
   - From the selfie instructions screen, tap "Tomar selfie" → confirm the front camera opens with
     no shutter control anywhere on screen, framed by the oval.
   - Confirm the instruction text changes at least once during the attempt, the phase dots advance
     (never retreat), and the percentage badge moves in step with the phase indicator, not on a
     visible timer.
   - Touch the capture surface repeatedly during the attempt → confirm nothing is captured,
     cancelled, or altered by the touch.
   - Let the attempt complete → confirm the flow advances to the verification-progress stub, and
     (via a device file-system check, as in 003) no frame or derived biometric data exists anywhere
     on the device afterward.

2. **Failure taxonomy (User Story 2)** — requires scripting the fake repository to specific outcomes
   rather than the always-succeeding dev fake; exercised primarily via the automated contract/unit
   suites listed above.
   - Script a quality-failure outcome → confirm a specific, actionable message renders, in 005's
     vocabulary.
   - Script an unclassified-failure outcome, then separately an attack-detected outcome → confirm
     both render the exact same message and styling — diff the rendered widget tree or screenshot
     to confirm byte-identical output.
   - Script 3 consecutive failures → confirm routing to the retry-guidance stub, and confirm the
     document-capture attempt counter (a separate counter, research.md §3) is untouched.

3. **Interruption and exit paths (User Story 3)**
   - Mid-attempt, background the app (or simulate `AppLifecycleState.paused`) → confirm the camera
     stops and no frame/session survives; returning to the app restarts the attempt cleanly.
   - Mid-attempt, tap "Atrás" → confirm the capture aborts, held data is discarded, and the
     enrollment session is preserved as incomplete (not cancelled).
   - Tap "Ayuda" → confirm the agent-escalation route is reachable (not merely a retry loop).
   - Let an attempt sit idle (no progress) past the stall timeout → confirm it ends with an
     explanation rather than continuing indefinitely.

## Reachability guard check

- Deep-link (or otherwise navigate) straight to this screen's route without having confirmed an
  identity record in the current session → confirm redirect to document capture (003), not to the
  selfie instructions screen (research.md §4 explains why redirecting there wouldn't actually guard
  anything).

## Accessibility checks

- With a screen reader active and the device screen covered (simulating "not looking at the
  screen"), confirm each instruction change is announced audibly and confirm a haptic pulse
  accompanies it.
- Confirm the generic failure state and the specific quality-failure state are each conveyed by text
  (not color alone), consistent with every prior screen in this app.
