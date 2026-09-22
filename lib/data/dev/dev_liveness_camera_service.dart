import 'dart:typed_data';

import 'package:camera/camera.dart';

import '../services/liveness_camera_service.dart';

/// A local, no-real-camera `LivenessCameraService` used only when the app is
/// launched with `--dart-define=USE_FAKE_VERIFICATION_BACKEND=true`
/// (research.md §10), mirroring `DevDocumentQualityAssessor`'s precedent —
/// never a fallback path reachable from production wiring. `sampleFrame()`
/// returns scripted, non-null bytes once started so
/// `LivenessCaptureViewModel`'s sample loop has something to submit; the
/// content is never inspected by `DevLivenessVerificationRepository`.
class DevLivenessCameraService implements LivenessCameraService {
  bool _started = false;

  @override
  CameraController? get controller => null;

  @override
  Future<void> start() async {
    _started = true;
  }

  @override
  Future<void> stop() async {
    _started = false;
  }

  @override
  Uint8List? sampleFrame() {
    if (!_started) return null;
    return Uint8List(1);
  }
}
