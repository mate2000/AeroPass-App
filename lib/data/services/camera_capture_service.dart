import 'dart:async' show unawaited;
import 'dart:io' show File;
import 'dart:typed_data';

import 'package:camera/camera.dart';

import 'raw_luma_frame.dart';

/// The pair of byte buffers one manual capture produces (data-model.md:
/// `DocumentImage` is deliberately not a domain type — "`Uint8List` at the
/// boundary, by design").
///
/// - [analysisBytes]: a [RawLumaFrame]-encoded raster of the live preview
///   at the moment of capture, for `DocumentQualityAssessor.assess()`
///   (synchronous, on-device, FR-006).
/// - [submissionBytes]: the actual captured photo (JPEG), for
///   `DocumentVerificationRepository.submit()` if the assessment passes.
///
/// Neither buffer is retained by [CameraCaptureService] after [capture]
/// returns, and neither is ever written to disk by this service (FR-010) —
/// the plugin's own `takePicture()` call is pointed at a platform temp
/// path internally, but this service reads it into memory and deletes the
/// temp file immediately, never surfacing the path.
typedef CapturedDocumentFrame = ({
  Uint8List analysisBytes,
  Uint8List submissionBytes,
});

/// Wraps the `camera` plugin (research.md §1) for the document-capture
/// step's live preview, torch control, and manual still capture. An
/// abstract class (not `...Repository` — this is hardware-lifecycle
/// infrastructure, closer in spirit to `DeviceCapabilityChecker` than to a
/// domain-model-owning repository) so `CaptureViewModel` can be
/// constructor-injected with either this or a fake, per the task brief:
/// "do not let `CaptureView` construct a `CameraController` directly
/// inside itself, or you'll make the ViewModel/View untestable without a
/// real camera."
abstract class CameraCaptureService {
  /// Initializes the controller, starts the live preview, and starts
  /// receiving raw preview frames for on-tap analysis. Idempotent-ish: safe
  /// to call again after [stop] (e.g. on lifecycle resume, research.md §5).
  Future<void> start();

  /// Stops the preview/image stream and releases the camera. Called on
  /// `AppLifecycleState.paused`/`inactive` (research.md §5: "stop-and-reinit
  /// on background/lock/interruption, no 'pause and resume the same
  /// controller' approach") and on the view's own disposal.
  Future<void> stop();

  /// The live `CameraController` for `CameraPreview(controller)`, or `null`
  /// before [start] completes, after [stop], or when no real camera is
  /// available (a fake in tests never needs to provide one).
  CameraController? get controller;

  /// Whether the torch is currently on.
  bool get torchOn;

  /// Toggles the torch (FR-005). A no-op if the camera isn't started.
  Future<void> toggleTorch();

  /// Captures exactly one frame: the current live-preview frame (for
  /// on-device assessment) and a full-resolution still photo (for
  /// submission if the assessment passes). Callers MUST NOT retain either
  /// buffer beyond the current attempt (FR-010).
  Future<CapturedDocumentFrame> capture();
}

/// The real, `camera`-plugin-backed [CameraCaptureService].
class CameraPluginCaptureService implements CameraCaptureService {
  CameraPluginCaptureService({
    List<CameraDescription> Function()? availableCamerasOverride,
  }) : _availableCamerasOverride = availableCamerasOverride;

  final List<CameraDescription> Function()? _availableCamerasOverride;

  CameraController? _controller;
  CameraImage? _latestPreviewFrame;
  bool _torchOn = false;

  @override
  CameraController? get controller => _controller;

  @override
  bool get torchOn => _torchOn;

  @override
  Future<void> start() async {
    final cameras = _availableCamerasOverride != null
        ? _availableCamerasOverride()
        : await availableCameras();
    if (cameras.isEmpty) {
      throw StateError('no camera available on this device');
    }
    final rearCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    final controller = CameraController(
      rearCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    await controller.initialize();
    await controller.startImageStream((image) {
      _latestPreviewFrame = image;
    });
    _controller = controller;
    _torchOn = false;
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
  Future<void> toggleTorch() async {
    final controller = _controller;
    if (controller == null) return;
    _torchOn = !_torchOn;
    await controller.setFlashMode(_torchOn ? FlashMode.torch : FlashMode.off);
  }

  @override
  Future<CapturedDocumentFrame> capture() async {
    final controller = _controller;
    if (controller == null) {
      throw StateError('capture() called before start()');
    }
    final previewFrame = _latestPreviewFrame;
    if (previewFrame == null) {
      throw StateError('no preview frame available yet');
    }
    final analysisBytes = _toRawLumaFrame(previewFrame).encode();

    final xFile = await controller.takePicture();
    final submissionBytes = await xFile.readAsBytes();
    // FR-010: the plugin writes takePicture()'s output to a platform temp
    // path internally; delete it immediately once read into memory so no
    // copy survives on disk past this call.
    unawaited(
      File(xFile.path).delete().catchError((_) => File(xFile.path)),
    );

    return (analysisBytes: analysisBytes, submissionBytes: submissionBytes);
  }

  /// Converts a YUV420 preview frame to a [RawLumaFrame] — the Y (luma)
  /// plane in YUV420 already *is* per-pixel brightness, so this is a
  /// direct copy (with row-stride handling), not a color-space
  /// computation.
  RawLumaFrame _toRawLumaFrame(CameraImage image) {
    final yPlane = image.planes.first;
    final width = image.width;
    final height = image.height;
    final luma = Uint8List(width * height);
    final rowStride = yPlane.bytesPerRow;
    for (var y = 0; y < height; y++) {
      final rowStart = y * rowStride;
      for (var x = 0; x < width; x++) {
        luma[y * width + x] = yPlane.bytes[rowStart + x];
      }
    }
    return RawLumaFrame(width: width, height: height, luma: luma);
  }
}
