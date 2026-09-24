import 'dart:typed_data';

import '../../domain/entities/capture_outcome.dart';
import '../../domain/repositories/document_quality_assessor.dart';
import 'raw_luma_frame.dart';

/// The real, heuristic (non-ML) `DocumentQualityAssessor` implementation
/// (research.md §2, contracts/quality-assessor-port.md): cheap
/// signal-processing checks over a [RawLumaFrame], with no TFLite or ML Kit
/// dependency.
///
/// **Lenient by decision (2026-09-23).** The backend reads nothing from the
/// document (015 V-07): it stores the photo as the biometric reference, and
/// the passenger types the fields. The device check therefore refuses only
/// captures that are plainly unusable:
///
/// - too small to be a photo ([minAnalysisWidth], [minAnalysisHeight]);
/// - almost all blown out by light ([glareBrightPixelRatioThreshold]);
/// - almost no detail at all, such as a covered lens or a blank frame
///   ([blurVarianceThreshold]).
///
/// The framing and document-shape checks were removed. They estimated the
/// document's outline from any pixel that stood out from the frame's
/// border, and they refused real photos as "cropped" or "not valid". The
/// `framing` and `wrongDocument` rejection reasons remain in the domain for
/// the processor-side vocabulary, but this assessor no longer produces them.
class HeuristicQualityAssessor implements DocumentQualityAssessor {
  const HeuristicQualityAssessor();

  /// Below this pixel-dimension floor, a frame is rejected outright as
  /// `lowResolution` before any other check runs.
  static const int minAnalysisWidth = 64;
  static const int minAnalysisHeight = 64;

  /// Laplacian (edge-strength) variance below this value means the frame
  /// has almost no detail, such as a covered lens or a blank frame. A
  /// merely soft photo passes.
  static const double blurVarianceThreshold = 100.0;

  /// A luma value at or above this is treated as "blown out" for the glare
  /// check.
  static const int glareLumaFloor = 245;

  /// Proportion of blown-out pixels above which the frame is rejected for
  /// glare. Only a frame that is mostly white is refused.
  static const double glareBrightPixelRatioThreshold = 0.50;

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

    return const QualityAssessment.usable();
  }

  /// Variance of the discrete Laplacian (edge-strength) over the frame's
  /// interior pixels. A low variance means few edges (research.md §2).
  double _laplacianVariance(RawLumaFrame frame) {
    var count = 0;
    var sum = 0.0;
    var sumOfSquares = 0.0;
    for (var y = 1; y < frame.height - 1; y++) {
      for (var x = 1; x < frame.width - 1; x++) {
        final laplacian =
            (frame.lumaAt(x - 1, y) +
                    frame.lumaAt(x + 1, y) +
                    frame.lumaAt(x, y - 1) +
                    frame.lumaAt(x, y + 1) -
                    4 * frame.lumaAt(x, y))
                .toDouble();
        count++;
        sum += laplacian;
        sumOfSquares += laplacian * laplacian;
      }
    }
    if (count == 0) return 0;
    final mean = sum / count;
    return sumOfSquares / count - mean * mean;
  }

  /// Proportion of pixels at or near maximum luma (blown-out highlights).
  double _brightPixelRatio(RawLumaFrame frame) {
    var brightCount = 0;
    for (final value in frame.luma) {
      if (value >= glareLumaFloor) brightCount++;
    }
    return brightCount / frame.luma.length;
  }
}
