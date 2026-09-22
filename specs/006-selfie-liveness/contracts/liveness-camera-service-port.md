# Contract: `LivenessCameraService`

Per research.md §2. Hardware-lifecycle infrastructure, not a domain-owning repository — same
category as 003's `CameraCaptureService` (front lens, continuous sampling, no shutter — the
inverse shape of 003's rear-lens, single-manual-capture service).

## Interface

```text
abstract class LivenessCameraService {
  Future<void> start();   // initializes the front-lens controller, starts the live preview
  Future<void> stop();    // stops the preview, releases the camera

  CameraController? get controller;  // for CameraPreview(controller); null before start()/after stop()

  /// The current preview frame's bytes, for one sample — never retained by
  /// this service after the call returns (FR-008). `null` if the preview
  /// isn't ready yet (e.g. immediately after `start()`).
  Uint8List? sampleFrame();
}
```

- Front lens specifically (`CameraLensDirection.front`) — no torch control (there is no meaningful
  "torch" concept for a front-facing selfie capture; the reference has none).
- `sampleFrame()` is synchronous and cheap (reads the already-decoded latest preview frame, the same
  technique 003's real implementation already uses to source `analysisBytes` for its on-device
  quality check) — this screen calls it on a fixed interval (research.md's polling loop), not on
  every raw camera callback, to bound how often `submitSample()` is called.
- No file, no gallery, no temp path — this service never touches disk, mirroring 003's real
  implementation's explicit temp-file deletion discipline (there is no still-photo `takePicture()`
  call here to produce a temp file from in the first place; every sample comes from the live preview
  stream).

## Contract test suite

1. `start()` succeeds → `controller` becomes non-null and initialized.
2. `start()` fails (no front camera, permission denied) → throws; `LivenessCaptureViewModel` maps
   this to the same permission-gating treatment 003's `CaptureViewModel` already applies (deferred
   under happy-path mode per spec.md's Assumptions — "assumed supported and granted").
3. `sampleFrame()` before `start()` completes → `null`, never throws.
4. `sampleFrame()` after `start()` → non-null bytes.
5. `stop()` releases the controller; a subsequent `sampleFrame()` → `null`.
6. `stop()` is safe to call when never started, and safe to call twice in a row (idempotent-ish, per
   003's own `CameraCaptureService.stop()` precedent).

## Fake implementation

`FakeLivenessCameraService`: no real camera, scriptable `start()` failure, `sampleFrame()` returns a
scripted byte buffer (or `null`) per call — same pattern as `FakeCameraCaptureService`.

## Real implementation

`FrontCameraLivenessService`, wrapping the `camera` plugin's `CameraController` with
`CameraLensDirection.front` and `startImageStream`, converting the latest frame to bytes on
`sampleFrame()` — no new dependency (the `camera` package is already used by 003 for exactly this
underlying capability, just the rear lens).
