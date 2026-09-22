import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/design/app_colors.dart';

/// The full-screen dark camera preview's framing guide (UI Reference): an
/// oval outline with a turquoise progress arc drawn around it, filling as
/// [progress] (0.0–1.0, FR-006) advances. Purely decorative (`ExcludeSemantics`)
/// — `LivenessInstructionBanner` and `PhaseIndicator` carry the actual
/// guidance and progress information to assistive technology.
class LivenessOvalOverlay extends StatelessWidget {
  const LivenessOvalOverlay({required this.progress, super.key});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AspectRatio(
        aspectRatio: 0.75,
        child: CustomPaint(
          painter: _OvalProgressPainter(progress: progress.clamp(0, 1)),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _OvalProgressPainter extends CustomPainter {
  _OvalProgressPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final trackPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawOval(rect.deflate(2), trackPaint);

    if (progress <= 0) return;
    final arcPaint = Paint()
      ..color = AppColors.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      rect.deflate(2),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_OvalProgressPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
