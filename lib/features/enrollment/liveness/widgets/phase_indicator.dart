import 'package:flutter/material.dart';

import '../../../../core/design/app_colors.dart';

/// Dots below the oval (UI Reference: "Four dots below the oval, the third
/// active"), sized to [totalPhases]. Dots at or before [currentIndex]
/// render filled; later ones render as outlines — FR-007's "index only
/// ever increases" is enforced by `LivenessCaptureViewModel`, this widget
/// only renders whatever index it's given.
class PhaseIndicator extends StatelessWidget {
  const PhaseIndicator({
    required this.currentIndex,
    required this.totalPhases,
    super.key,
  });

  final int currentIndex;
  final int totalPhases;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < totalPhases; i++) ...[
            if (i != 0) const SizedBox(width: 8),
            _Dot(filled: i <= currentIndex),
          ],
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? AppColors.teal : Colors.transparent,
        border: Border.all(color: AppColors.teal, width: 1.5),
      ),
    );
  }
}
