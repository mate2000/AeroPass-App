import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart' show PlatformException;

import '../../core/diagnostics.dart';

/// Wraps the `camera` plugin (research.md §2) for the liveness-capture
/// step's live preview and continuous frame sampling — front lens
/// specifically (`CameraLensDirection.front`), no torch control, no
/// shutter: the inverse shape of `CameraCaptureService`'s rear-lens,
/// single-manual-capture service (contracts/liveness-camera-service-port.md).
abstract class LivenessCameraService {
  /// Initializes the front-lens controller and starts the live preview.
  Future<void> start();

  /// Stops the preview and releases the camera.
  Future<void> stop();

  /// For `CameraPreview(controller)`; `null` before [start]/after [stop].
  CameraController? get controller;

  /// The current preview frame's bytes, for one sample — never retained by
  /// this service after the call returns (FR-008). `null` if the preview
  /// isn't ready yet (e.g. immediately after [start]).
  Uint8List? sampleFrame();

  /// 015 research.md §7: one JPEG still of the passenger, taken when the
  /// liveness challenge completes. It is sent as the backend's `selfie`.
  /// `null` if no still can be taken. The caller submits it and drops it.
  Future<Uint8List?> captureStill();
}

/// The real, `camera`-plugin-backed [LivenessCameraService]. Front lens,
/// `startImageStream`-backed [sampleFrame] — no file, no gallery, no temp
/// path (every sample comes from the live preview stream, never a
/// still-photo `takePicture()` call).
class FrontCameraLivenessService implements LivenessCameraService {
  FrontCameraLivenessService({
    List<CameraDescription> Function()? availableCamerasOverride,
  }) : _availableCamerasOverride = availableCamerasOverride;

  final List<CameraDescription> Function()? _availableCamerasOverride;

  CameraController? _controller;
  CameraImage? _latestPreviewFrame;

  @override
  CameraController? get controller => _controller;

  @override
  Future<void> start() async {
    final cameras = _availableCamerasOverride != null
        ? _availableCamerasOverride()
        : await availableCameras();
    if (cameras.isEmpty) {
      throw StateError('no camera available on this device');
    }
    final frontCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    final controller = CameraController(
      frontCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    await controller.initialize();
    await controller.startImageStream((image) {
      _latestPreviewFrame = image;
    });
    // Overlapping start() calls (an attempt superseded mid-start) must not
    // leak the earlier controller and keep holding the camera.
    final previous = _controller;
    _controller = controller;
    if (previous != null) await _release(previous);
  }

  @override
  Future<void> stop() async {
    final controller = _controller;
    _controller = null;
    _latestPreviewFrame = null;
    if (controller == null) return;
    await _release(controller);
  }

  /// Stops and disposes [controller]. The Android camera plugin can throw
  /// while releasing a preview it had not finished setting up
  /// (`releaseFlutterSurfaceTexture() cannot be called if the
  /// flutterSurfaceProducer ... has not yet been initialized`, seen in
  /// production). The camera is being given up either way, so the error is
  /// logged and never fails the flow.
  Future<void> _release(CameraController controller) async {
    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
      await controller.dispose();
    } on Object catch (error) {
      const Diagnostics().warn('camera_release_failed', {
        'code': error.runtimeType,
        'detail': error is PlatformException ? error.code : null,
      });
    }
  }

  /// Stops the preview stream, which some camera implementations need before
  /// `takePicture()`. It then reads the JPEG into memory and deletes the
  /// plugin's temp file at once. That is 003's `CameraPluginCaptureService`
  /// precedent (FR-010 there), so no copy survives on disk.
  @override
  Future<Uint8List?> captureStill() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return null;
    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
      final xFile = await controller.takePicture();
      final bytes = await xFile.readAsBytes();
      unawaited(File(xFile.path).delete().catchError((_) => File(xFile.path)));
      return bytes;
    } on Object {
      return null;
    }
  }

  @override
  Uint8List? sampleFrame() {
    final frame = _latestPreviewFrame;
    if (frame == null) return null;
    return _toJpegLikeBytes(frame);
  }

  /// Converts the latest YUV420 preview frame's Y (luma) plane into a flat
  /// byte buffer — the same "raw bytes of the live preview" technique
  /// `CameraCaptureService`'s real implementation already uses, since this
  /// port's contract only requires bytes a processor can classify, not a
  /// specific encoded format.
  Uint8List _toJpegLikeBytes(CameraImage image) {
    final yPlane = image.planes.first;
    final width = image.width;
    final height = image.height;
    final bytes = Uint8List(width * height);
    final rowStride = yPlane.bytesPerRow;
    for (var y = 0; y < height; y++) {
      final rowStart = y * rowStride;
      for (var x = 0; x < width; x++) {
        bytes[y * width + x] = yPlane.bytes[rowStart + x];
      }
    }
    return bytes;
  }
}
