import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/design/app_colors.dart';

/// The document-to-face illustration inside a ring (007-validando, UI
/// reference). The ring's filled fraction is [passedStages] ÷ 3 — a count of
/// backend-reported stages, never elapsed time (FR-004). Decorative, so it
/// is excluded from semantics.
class VerificationIllustration extends StatelessWidget {
  const VerificationIllustration({required this.passedStages, super.key});

  /// How many of the three stages the backend has reported passed.
  final int passedStages;

  static const double _size = 140;
  static const int _stageCount = 3;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: _size,
        child: CustomPaint(
          painter: _RingPainter(
            fraction: (passedStages / _stageCount).clamp(0, 1).toDouble(),
          ),
          child: Center(
            child: Container(
              width: _size - 28,
              height: _size - 28,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Tile(color: AppColors.navy, icon: Icons.person),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: AppColors.turquoise,
                    ),
                  ),
                  _Tile(
                    color: Color(0xFFFFD9C2),
                    icon: Icons.face_rounded,
                    iconColor: Color(0xFFE8A07C),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.color,
    required this.icon,
    this.iconColor = Colors.white,
  });

  final Color color;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 44,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: iconColor, size: 24),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.fraction});

  final double fraction;

  static const double _stroke = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final track = Paint()
      ..color = const Color(0xFFE3E7EC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke;
    canvas.drawArc(rect.deflate(_stroke / 2), 0, 2 * math.pi, false, track);
    if (fraction <= 0) return;
    final progress = Paint()
      ..color = AppColors.turquoise
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = _stroke;
    canvas.drawArc(
      rect.deflate(_stroke / 2),
      math.pi / 2,
      2 * math.pi * fraction,
      false,
      progress,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.fraction != fraction;
}
