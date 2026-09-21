import 'dart:typed_data';

import 'package:aeropass_app/data/services/camera_capture_service.dart';
import 'package:camera/camera.dart';

/// A scripted, no-hardware `CameraCaptureService` double, mirroring the
/// app's other fakes (Constitution Principle II's testability requirement
/// extended to this camera-hardware boundary). Never exposes a real
/// `CameraController` — `CaptureView` renders a placeholder in tests
/// instead of `CameraPreview`, which is exactly why [controller] is
/// nullable on the port.
class FakeCameraCaptureService implements CameraCaptureService {
  bool started = false;
  int startCallCount = 0;
  int stopCallCount = 0;
  int captureCallCount = 0;
  int toggleTorchCallCount = 0;

  CapturedDocumentFrame _nextCapture = (
    analysisBytes: Uint8List(0),
    submissionBytes: Uint8List(0),
  );

  Object? _startError;
  Object? _captureError;

  void scriptCapture(CapturedDocumentFrame frame) {
    _nextCapture = frame;
  }

  /// Makes the next (and subsequent) [start] call throw, e.g. to simulate
  /// a denied camera permission (FR-014) or hardware failure.
  void failStartWith(Object error) {
    _startError = error;
  }

  void failCaptureWith(Object error) {
    _captureError = error;
  }

  @override
  CameraController? get controller => null;

  @override
  bool get torchOn => _torchOn;
  bool _torchOn = false;

  @override
  Future<void> start() async {
    startCallCount++;
    final error = _startError;
    if (error != null) {
      throw error;
    }
    started = true;
  }

  @override
  Future<void> stop() async {
    stopCallCount++;
    started = false;
  }

  @override
  Future<void> toggleTorch() async {
    toggleTorchCallCount++;
    _torchOn = !_torchOn;
  }

  @override
  Future<CapturedDocumentFrame> capture() async {
    captureCallCount++;
    final error = _captureError;
    if (error != null) {
      throw error;
    }
    return _nextCapture;
  }
}
