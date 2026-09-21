# Quickstart: Identity Document Capture (03 Escanear documento)

Validation guide once implemented. Requires a physical device or emulator with camera support —
unlike 001/002, this feature cannot be fully exercised in a pure widget-test/no-device environment
for its camera-dependent paths (the quality-assessor and repository contract tests can, and should,
still run headless).

## Automated validation (run first)

```bash
fvm flutter analyze
fvm flutter test test/unit                # CaptureViewModel + HeuristicQualityAssessor
fvm flutter test test/widget              # CaptureView states (mocked camera service)
fvm flutter test test/contract            # DocumentVerificationRepository + CaptureAttemptCounterRepository, fake AND real
```

## Manual validation scenarios

Each maps to an Acceptance Scenario in spec.md. Requires a prior confirmed consent record
(002-consentimiento) and, ideally, the `USE_FAKE_CONSENT_BACKEND` dev flag or a reachable backend for
002's flow first.

1. **First-attempt success (User Story 1)**
   - With consent recorded, open the capture step → confirm camera permission is requested with an
     explanation, and the preview starts only after granting.
   - Frame a real or fixture cédula/passport, tap capture → confirm the image is assessed on-device
     before anything is sent, a passing capture advances to the data-confirmation stub, and the step
     indicator marks "Documento" done.
   - Confirm (via a device file-system check) no document image exists anywhere after advancing.

2. **Unusable capture, actionable error (User Story 2)**
   - Deliberately capture blurred / glared / cropped / wrong-document images → confirm each produces
     a distinct, specific inline message (not a generic error) and the frame turns to the error
     state, with retry immediately available on the same screen.
   - Confirm a device-rejected capture never reaches the verification submission call (check via the
     fake `DocumentVerificationRepository`'s call count in a widget test, or network logs on a real
     backend).
   - Fail 3 times in a row → confirm routing to the retry-guidance stub, and confirm the attempt
     counter persists across an app kill (force-close mid-failures, reopen, confirm the count picked
     up where it left off — this is the whole reason for the constitution amendment).

3. **Clean exit paths (User Story 3)**
   - Deny the camera permission → confirm the explanation, the system-settings route, and the
     "conventional airport process" statement all appear; confirm no repeated system permission
     prompt on a second visit after a permanent denial.
   - Tap "Ayuda" → confirm the help placeholder opens and returning lands back on the capture step
     with the enrollment session intact.
   - Tap "Atrás" mid-capture → confirm any held image is discarded and the session is preserved as
     incomplete, not cancelled.

## Accessibility / consent-gate checks

- Confirm arriving at this route without a current consent record (or with one referring to a
  superseded version) redirects to the consent gate rather than ever opening the camera (FR-001).
- Confirm error states are distinguishable in grayscale (text/iconography, not the red frame alone).
