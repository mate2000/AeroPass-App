import 'dart:typed_data';

import 'package:camera/camera.dart';

import '../../core/synthetic_marker.dart';
import '../services/camera_capture_service.dart';
import '../services/liveness_camera_service.dart';
import 'synthetic_image_source.dart';

/// 006's camera with a synthetic still (015 research.md §6, FR-018). The
/// preview runs, so the challenge and its guidance are exercised, but the
/// still sent to the backend is the chosen `MOCK:` marker image, never a
/// camera frame. Wired only while `SYNTHETIC_CAPTURE` is on.
class SyntheticLivenessCameraService implements LivenessCameraService {
  SyntheticLivenessCameraService(this._camera, {required this.selection});

  final LivenessCameraService _camera;
  final SyntheticMarkerSelection selection;

  @override
  CameraController? get controller => _camera.controller;

  @override
  Future<void> start() => _camera.start();

  @override
  Future<void> stop() => _camera.stop();

  /// A frame for the local challenge only. It is never uploaded.
  @override
  Uint8List? sampleFrame() => _camera.sampleFrame() ?? Uint8List(1);

  @override
  Future<Uint8List?> captureStill() async =>
      SyntheticImageSource.selfie(selection.selfie);
}

/// 003's camera with a synthetic photo. The real preview still feeds the
/// on-device quality check, but the photo registered with the backend is
/// the `MOCK:documento` image.
class SyntheticCameraCaptureService implements CameraCaptureService {
  SyntheticCameraCaptureService(this._camera);

  final CameraCaptureService _camera;

  @override
  CameraController? get controller => _camera.controller;

  @override
  Future<void> start() => _camera.start();

  @override
  Future<void> stop() => _camera.stop();

  @override
  bool get torchOn => _camera.torchOn;

  @override
  Future<void> toggleTorch() => _camera.toggleTorch();

  @override
  Future<CapturedDocumentFrame> capture() async {
    final real = await _camera.capture();
    return (
      analysisBytes: real.analysisBytes,
      submissionBytes: SyntheticImageSource.document(),
    );
  }
}
