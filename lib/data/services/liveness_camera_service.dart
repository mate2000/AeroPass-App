import 'dart:typed_data';

import 'package:camera/camera.dart';

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
    _controller = controller;
  }

  @override
  Future<void> stop() async {
    final controller = _controller;
    _controller = null;
    _latestPreviewFrame = null;
    if (controller == null) return;
    if (controller.value.isStreamingImages) {
      await controller.stopImageStream();
    }
    await controller.dispose();
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
