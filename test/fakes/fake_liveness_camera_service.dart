import 'dart:async' show Completer;
import 'dart:typed_data';

import 'package:aeropass_app/data/services/liveness_camera_service.dart';
import 'package:camera/camera.dart';

/// A scripted, no-hardware `LivenessCameraService` double, mirroring
/// `FakeCameraCaptureService`'s pattern for the front-lens, continuous-
/// sampling shape (contracts/liveness-camera-service-port.md).
class FakeLivenessCameraService implements LivenessCameraService {
  bool started = false;
  int startCallCount = 0;
  int stopCallCount = 0;

  /// When set, [start] waits for this to complete, simulating a camera
  /// that's slow to open (e.g. behind the permission dialog).
  Completer<void>? startGate;

  /// Called at the beginning of every [stop], before it takes effect.
  void Function()? onStop;

  Uint8List? _nextFrame;
  Object? _startError;

  /// Sets the value the next (and subsequent, until re-scripted) call to
  /// [sampleFrame] returns while started.
  void scriptFrame(Uint8List? frame) {
    _nextFrame = frame;
  }

  /// Makes the next [start] call throw (contract case 2: no front camera,
  /// permission denied).
  void failStartWith(Object error) {
    _startError = error;
  }

  @override
  CameraController? get controller => null;

  @override
  Future<void> start() async {
    startCallCount++;
    final gate = startGate;
    if (gate != null) await gate.future;
    final error = _startError;
    if (error != null) {
      throw error;
    }
    started = true;
  }

  @override
  Future<void> stop() async {
    onStop?.call();
    stopCallCount++;
    started = false;
  }

  @override
  Uint8List? sampleFrame() {
    if (!started) return null;
    return _nextFrame;
  }
}
