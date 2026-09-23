import 'dart:typed_data';

import '../../domain/entities/capture_outcome.dart';
import '../../domain/repositories/document_quality_assessor.dart';
import 'raw_luma_frame.dart';

/// A rectangular region detected within a [RawLumaFrame], used by
/// [HeuristicQualityAssessor]'s framing/wrong-document checks.
class _DocumentBounds {
  const _DocumentBounds({
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
  });

  final int minX;
  final int minY;
  final int maxX;
  final int maxY;

  int get width => maxX - minX + 1;
  int get height => maxY - minY + 1;
  int get area => width * height;

  bool touchesEdge(int frameWidth, int frameHeight) =>
      minX == 0 ||
      minY == 0 ||
      maxX == frameWidth - 1 ||
      maxY == frameHeight - 1;
}

/// The real, heuristic (non-ML) `DocumentQualityAssessor` implementation
/// (research.md §2, contracts/quality-assessor-port.md): cheap,
/// well-understood signal-processing checks over a [RawLumaFrame] — no
/// TFLite/ML Kit dependency (a deliberate KISS decision, not an
/// oversight — see research.md §2's Alternatives).
///
/// **Threshold tuning note**: the numeric constants below are reasonable
/// starting points chosen for this feature's synthetic fixtures and the
/// signal-processing literature's typical ranges, not values tuned against
/// real document photographs — real-world tuning (once field data from
/// actual captures is available) is an explicit follow-up, not a defect in
/// this implementation.
class HeuristicQualityAssessor implements DocumentQualityAssessor {
  const HeuristicQualityAssessor();

  /// Below this pixel-dimension floor, a frame is rejected outright as
  /// `lowResolution` before any other check runs.
  static const int minAnalysisWidth = 64;
  static const int minAnalysisHeight = 64;

  /// Laplacian (edge-strength) variance below this value indicates too few
  /// sharp edges — i.e. blur.
  static const double blurVarianceThreshold = 5000.0;

  /// A luma value at or above this is treated as "blown out" for the glare
  /// check.
  static const int glareLumaFloor = 245;

  /// Proportion of blown-out pixels above which the frame is rejected for
  /// glare.
  static const double glareBrightPixelRatioThreshold = 0.15;

  /// A detected document region must occupy at least this proportion of
  /// the frame's area to be considered "in frame" rather than a framing
  /// rejection.
  static const double minDocumentFillRatio = 0.35;

  /// How far a detected region's luma must differ from the estimated
  /// background luma to be counted as part of the document, when scanning
  /// for its bounds.
  static const int foregroundLumaDelta = 40;

  /// ISO/IEC 7810 ID-1 card ratio (85.6mm / 54mm) — the cédula de
  /// ciudadanía's shape (FR-019).
  static const double cedulaAspectRatio = 85.6 / 54.0;

  /// Approximate Colombian passport biodata-page ratio (FR-019).
  static const double passportAspectRatio = 125.0 / 88.0;

  /// How far a detected region's aspect ratio (or its reciprocal, to
  /// tolerate portrait-vs-landscape framing) may differ from either
  /// accepted document ratio before it's classified as `wrongDocument`.
  static const double aspectRatioTolerance = 0.35;

  @override
  QualityAssessment assess(Uint8List frameBytes) {
    final RawLumaFrame frame;
    try {
      frame = RawLumaFrame.decode(frameBytes);
    } on FormatException {
      return const QualityAssessment.rejected(
        reason: QualityRejectionReason.lowResolution,
      );
    }

    if (frame.width < minAnalysisWidth || frame.height < minAnalysisHeight) {
      return const QualityAssessment.rejected(
        reason: QualityRejectionReason.lowResolution,
      );
    }

    if (_brightPixelRatio(frame) > glareBrightPixelRatioThreshold) {
      return const QualityAssessment.rejected(
        reason: QualityRejectionReason.glare,
      );
    }

    if (_laplacianVariance(frame) < blurVarianceThreshold) {
      return const QualityAssessment.rejected(
        reason: QualityRejectionReason.blur,
      );
    }

    final bounds = _detectDocumentBounds(frame);
    if (bounds == null || bounds.touchesEdge(frame.width, frame.height)) {
      return const QualityAssessment.rejected(
        reason: QualityRejectionReason.framing,
      );
    }

    final fillRatio = bounds.area / (frame.width * frame.height);
    if (fillRatio < minDocumentFillRatio) {
      return const QualityAssessment.rejected(
        reason: QualityRejectionReason.framing,
      );
    }

    if (!_matchesAcceptedDocumentRatio(bounds.width / bounds.height)) {
      return const QualityAssessment.rejected(
        reason: QualityRejectionReason.wrongDocument,
      );
    }

    return const QualityAssessment.usable();
  }

  /// Variance of the discrete Laplacian (edge-strength) over the frame's
  /// interior pixels — a low variance means few sharp edges, i.e. blur
  /// (research.md §2).
  double _laplacianVariance(RawLumaFrame frame) {
    final responses = <double>[];
    for (var y = 1; y < frame.height - 1; y++) {
      for (var x = 1; x < frame.width - 1; x++) {
        final center = frame.lumaAt(x, y);
        final laplacian =
            frame.lumaAt(x - 1, y) +
            frame.lumaAt(x + 1, y) +
            frame.lumaAt(x, y - 1) +
            frame.lumaAt(x, y + 1) -
            4 * center;
        responses.add(laplacian.toDouble());
      }
    }
    if (responses.isEmpty) return 0;
    final mean = responses.reduce((a, b) => a + b) / responses.length;
    final variance =
        responses.map((r) => (r - mean) * (r - mean)).reduce((a, b) => a + b) /
        responses.length;
    return variance;
  }

  /// Percentage of pixels at or near maximum luma (blown-out highlights) —
  /// a high percentage indicates glare/reflection (research.md §2).
  double _brightPixelRatio(RawLumaFrame frame) {
    var brightCount = 0;
    for (final value in frame.luma) {
      if (value >= glareLumaFloor) brightCount++;
    }
    return brightCount / frame.luma.length;
  }

  /// A cheap foreground/background split: estimates the background luma
  /// from the frame's border pixels, then finds the bounding box of pixels
  /// differing from it by more than [foregroundLumaDelta] — a stand-in for
  /// full contour detection (research.md §2), sufficient to catch the
  /// "obviously unusable" framing cases this device-side gate targets.
  _DocumentBounds? _detectDocumentBounds(RawLumaFrame frame) {
    final backgroundLuma = _estimateBorderLuma(frame);

    var minX = frame.width;
    var minY = frame.height;
    var maxX = -1;
    var maxY = -1;

    for (var y = 0; y < frame.height; y++) {
      for (var x = 0; x < frame.width; x++) {
        final delta = (frame.lumaAt(x, y) - backgroundLuma).abs();
        if (delta > foregroundLumaDelta) {
          if (x < minX) minX = x;
          if (y < minY) minY = y;
          if (x > maxX) maxX = x;
          if (y > maxY) maxY = y;
        }
      }
    }

    if (maxX < minX || maxY < minY) return null;
    return _DocumentBounds(minX: minX, minY: minY, maxX: maxX, maxY: maxY);
  }

  int _estimateBorderLuma(RawLumaFrame frame) {
    var sum = 0;
    var count = 0;
    for (var x = 0; x < frame.width; x++) {
      sum += frame.lumaAt(x, 0);
      sum += frame.lumaAt(x, frame.height - 1);
      count += 2;
    }
    for (var y = 0; y < frame.height; y++) {
      sum += frame.lumaAt(0, y);
      sum += frame.lumaAt(frame.width - 1, y);
      count += 2;
    }
    return count == 0 ? 0 : (sum / count).round();
  }

  /// FR-019: the instruction text and this "wrong document" detection are
  /// driven by the same accepted-document set — cédula de ciudadanía and
  /// Colombian passport — never two different lists. Checks both the
  /// detected ratio and its reciprocal, since a passenger may frame the
  /// document in either orientation.
  bool _matchesAcceptedDocumentRatio(double ratio) {
    return _withinTolerance(ratio, cedulaAspectRatio) ||
        _withinTolerance(ratio, passportAspectRatio) ||
        _withinTolerance(1 / ratio, cedulaAspectRatio) ||
        _withinTolerance(1 / ratio, passportAspectRatio);
  }

  bool _withinTolerance(double ratio, double target) =>
      (ratio - target).abs() <= aspectRatioTolerance;
}
