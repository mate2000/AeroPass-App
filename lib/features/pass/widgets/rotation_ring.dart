import 'package:flutter/material.dart';

import '../../../core/design/app_colors.dart';

/// The progress arc around the code: how much of the current rotation window
/// is left. Decoration only; the countdown text carries the meaning.
class RotationRing extends StatelessWidget {
  const RotationRing({
    required this.fractionLeft,
    required this.child,
    super.key,
  });

  final double fractionLeft;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _RingPainter(fractionLeft),
      child: Padding(padding: const EdgeInsets.all(14), child: child),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.fraction);

  final double fraction;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 4.0;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(24));
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xFFE3E7EC)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    final path = Path()..addRRect(rrect);
    final metric = path.computeMetrics().first;
    final length = metric.length * fraction.clamp(0.0, 1.0);
    canvas.drawPath(
      metric.extractPath(0, length),
      Paint()
        ..color = AppColors.turquoise
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.fraction != fraction;
}
