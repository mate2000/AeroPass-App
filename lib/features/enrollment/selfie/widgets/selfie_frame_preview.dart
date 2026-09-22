import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/design/app_colors.dart';

/// FR-006: previews the framing the passenger will meet on the liveness
/// capture step — a face centered in a dashed turquoise oval. Carries no
/// information not also stated in text (spec.md UI Reference), so it is
/// wrapped in `ExcludeSemantics` — never announced as meaningful (Edge
/// Cases: "the illustration carries none of it and is not announced as
/// meaningful").
class SelfieFramePreview extends StatelessWidget {
  const SelfieFramePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: 160,
        height: 200,
        child: CustomPaint(
          painter: const _DashedOvalPainter(),
          child: const Center(
            child: Icon(Icons.face, size: 72, color: AppColors.teal),
          ),
        ),
      ),
    );
  }
}

/// A dashed oval outline, drawn directly (research.md §3) rather than via a
/// dashed-border package — a single decorative shape doesn't clear
/// Constitution Principle X's "two real call sites" bar for a dependency.
class _DashedOvalPainter extends CustomPainter {
  const _DashedOvalPainter();

  static const _dashLength = 8.0;
  static const _gapLength = 6.0;
  static const _strokeWidth = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      _strokeWidth,
      _strokeWidth,
      size.width - _strokeWidth * 2,
      size.height - _strokeWidth * 2,
    );
    final path = Path()..addOval(rect);
    final paint = Paint()
      ..color = AppColors.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = math.min(distance + _dashLength, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + _gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
