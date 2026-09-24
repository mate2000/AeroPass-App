import 'dart:typed_data';

import 'package:camera/camera.dart';

import '../services/liveness_camera_service.dart';

/// The `LivenessCameraService` used only when the app is launched with
/// `--dart-define=USE_FAKE_VERIFICATION_BACKEND=true` (research.md §10),
/// mirroring `DevDocumentQualityAssessor`'s precedent — never a fallback
/// path reachable from production wiring.
///
/// It drives the real front camera so the passenger sees the live preview
/// and can frame their face, exactly as in production. Only when the real
/// camera can't start (no camera, e.g. an emulator without one, or
/// permission denied) does it fall back to scripted, non-null bytes, so
/// `LivenessCaptureViewModel`'s sample loop still has something to submit.
/// Frame content is never inspected by `DevLivenessVerificationRepository`.
class DevLivenessCameraService implements LivenessCameraService {
  DevLivenessCameraService({LivenessCameraService? realCamera})
    : _realCamera = realCamera ?? FrontCameraLivenessService();

  final LivenessCameraService _realCamera;
  bool _started = false;
  bool _usingRealCamera = false;

  @override
  CameraController? get controller =>
      _usingRealCamera ? _realCamera.controller : null;

  @override
  Future<void> start() async {
    try {
      await _realCamera.start();
      _usingRealCamera = true;
    } catch (_) {
      _usingRealCamera = false;
    }
    _started = true;
  }

  @override
  Future<void> stop() async {
    _started = false;
    if (_usingRealCamera) {
      _usingRealCamera = false;
      await _realCamera.stop();
    }
  }

  @override
  Uint8List? sampleFrame() {
    if (!_started) return null;
    if (_usingRealCamera) return _realCamera.sampleFrame();
    return Uint8List(1);
  }

  /// The offline demo never submits a selfie, so its fake verification has
  /// nothing to read.
  @override
  Future<Uint8List?> captureStill() async => null;
}
