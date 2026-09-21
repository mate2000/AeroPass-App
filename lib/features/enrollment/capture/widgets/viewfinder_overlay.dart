import 'package:flutter/material.dart';

import '../../../../core/design/app_colors.dart';

/// The full-screen dark camera preview's framing guide: turquoise corner
/// brackets and a horizontal scan line (UI Reference), turning red when
/// [hasError] is true (US2: "the same layout with the frame in red"). The
/// red frame is never the ONLY signal of an error state (FR-007/
/// Constitution Principle VI) — `InlineErrorMessage` always accompanies it
/// with text and an icon.
class ViewfinderOverlay extends StatelessWidget {
  const ViewfinderOverlay({required this.hasError, super.key});

  final bool hasError;

  static const double _cornerLength = 28;
  static const double _borderWidth = 3;

  @override
  Widget build(BuildContext context) {
    final color = hasError ? Colors.redAccent : AppColors.teal;
    return ExcludeSemantics(
      child: AspectRatio(
        aspectRatio: 0.63,
        child: Stack(
          children: [
            _Corner(alignment: Alignment.topLeft, color: color),
            _Corner(alignment: Alignment.topRight, color: color),
            _Corner(alignment: Alignment.bottomLeft, color: color),
            _Corner(alignment: Alignment.bottomRight, color: color),
            Align(
              child: Container(height: 2, color: color.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  const _Corner({required this.alignment, required this.color});

  final Alignment alignment;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isTop = alignment.y < 0;
    final isLeft = alignment.x < 0;
    return Align(
      alignment: alignment,
      child: Container(
        width: ViewfinderOverlay._cornerLength,
        height: ViewfinderOverlay._cornerLength,
        decoration: BoxDecoration(
          border: Border(
            top: isTop
                ? BorderSide(color: color, width: ViewfinderOverlay._borderWidth)
                : BorderSide.none,
            bottom: !isTop
                ? BorderSide(color: color, width: ViewfinderOverlay._borderWidth)
                : BorderSide.none,
            left: isLeft
                ? BorderSide(color: color, width: ViewfinderOverlay._borderWidth)
                : BorderSide.none,
            right: !isLeft
                ? BorderSide(color: color, width: ViewfinderOverlay._borderWidth)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
