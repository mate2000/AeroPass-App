// Synthetic (programmatically generated) fixture frames for
// heuristic_quality_assessor_test.dart, per contracts/quality-assessor-port.md
// and the task brief's explicit guidance: fixtures here are synthetic, not
// real document photos. Each fixture is built directly in the
// `RawLumaFrame` raw-luma-raster format `HeuristicQualityAssessor` consumes
// (lib/data/services/raw_luma_frame.dart) — no image codec involved, so
// these are plain Dart, fully deterministic, and require no binary assets
// checked into the repository.
import 'dart:typed_data';

import 'package:aeropass_app/data/services/raw_luma_frame.dart';

class _Rect {
  const _Rect(this.left, this.top, this.width, this.height);
  final int left;
  final int top;
  final int width;
  final int height;

  bool contains(int x, int y) =>
      x >= left && x < left + width && y >= top && y < top + height;
}

const _canvasWidth = 200;
const _canvasHeight = 150;
const _backgroundLuma = 60;

// A cédula-shaped (ISO/IEC 7810 ID-1, ratio ≈1.585) rectangle, centered,
// comfortably inside the canvas (no edge touching) and covering >35% of
// the canvas area — a well-framed capture.
const _wellFramedDocument = _Rect(20, 25, 159, 100);

// Same shape, but shifted so its left edge touches the canvas boundary —
// a cropped/out-of-frame capture.
const _croppedDocument = _Rect(0, 25, 159, 100);

// A square (ratio 1.0) document region, matching neither accepted
// document ratio, well-framed otherwise.
const _wrongShapeDocument = _Rect(37, 12, 126, 126);

Uint8List _buildFrame({
  required _Rect? document,
  required bool textured,
  _Rect? glarePatch,
}) {
  final luma = Uint8List(_canvasWidth * _canvasHeight);
  for (var y = 0; y < _canvasHeight; y++) {
    for (var x = 0; x < _canvasWidth; x++) {
      int value;
      if (document != null && document.contains(x, y)) {
        if (textured) {
          // A fine checkerboard produces a very high Laplacian response —
          // a stand-in for a genuinely sharp, in-focus capture.
          value = (x + y).isEven ? 220 : 140;
        } else {
          // Flat fill — no high-frequency content, i.e. blurred.
          value = 180;
        }
      } else {
        value = _backgroundLuma;
      }
      if (glarePatch != null && glarePatch.contains(x, y)) {
        value = 255;
      }
      luma[y * _canvasWidth + x] = value;
    }
  }
  return RawLumaFrame(
    width: _canvasWidth,
    height: _canvasHeight,
    luma: luma,
  ).encode();
}

/// 1. Sharp, well-lit, correctly-framed cédula-shaped fixture -> `usable`.
Uint8List sharpWellFramedCedulaFixture() =>
    _buildFrame(document: _wellFramedDocument, textured: true);

/// 2. Heavily blurred fixture -> `rejected(blur)`.
Uint8List heavilyBlurredFixture() =>
    _buildFrame(document: _wellFramedDocument, textured: false);

/// 3. A fixture with a large blown-out highlight region -> `rejected(glare)`.
Uint8List largeGlarePatchFixture() => _buildFrame(
  document: _wellFramedDocument,
  textured: true,
  glarePatch: const _Rect(60, 50, 100, 60),
);

/// 4. A fixture cropped at the frame edge -> `rejected(framing)`.
Uint8List croppedAtEdgeFixture() =>
    _buildFrame(document: _croppedDocument, textured: true);

/// 5. A fixture with a shape matching neither accepted document ratio ->
/// `rejected(wrongDocument)`.
Uint8List wrongShapeFixture() =>
    _buildFrame(document: _wrongShapeDocument, textured: true);

/// 6. A fixture below the minimum resolution floor -> `rejected(lowResolution)`.
Uint8List belowMinimumResolutionFixture() {
  const width = 30;
  const height = 30;
  final luma = Uint8List(width * height)..fillRange(0, width * height, 128);
  return RawLumaFrame(width: width, height: height, luma: luma).encode();
}

/// 7. A frame with no detail at all (a covered lens) -> `rejected(blur)`.
Uint8List blankFrameFixture() {
  final luma = Uint8List(_canvasWidth * _canvasHeight)
    ..fillRange(0, _canvasWidth * _canvasHeight, 90);
  return RawLumaFrame(
    width: _canvasWidth,
    height: _canvasHeight,
    luma: luma,
  ).encode();
}

/// 8. A frame mostly blown out by light -> `rejected(glare)`.
Uint8List mostlyBlownOutFixture() => _buildFrame(
  document: _wellFramedDocument,
  textured: true,
  glarePatch: const _Rect(0, 0, 200, 110),
);
