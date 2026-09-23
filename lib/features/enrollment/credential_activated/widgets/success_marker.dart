import 'package:flutter/material.dart';

import '../../../../core/design/app_colors.dart';

/// The turquoise circle with a check that opens screen 08, per the UI
/// reference. Decorative: the title beside it carries the meaning, so it is
/// excluded from semantics rather than announced twice.
class SuccessMarker extends StatelessWidget {
  const SuccessMarker({super.key});

  static const double _diameter = 72;
  static const double _iconSize = 40;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: _diameter,
        height: _diameter,
        decoration: const BoxDecoration(
          color: AppColors.turquoise,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: _iconSize),
      ),
    );
  }
}
