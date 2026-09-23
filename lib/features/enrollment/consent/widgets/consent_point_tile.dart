import 'package:flutter/material.dart';

import '../../../../core/design/app_colors.dart';
import '../../../../domain/entities/consent_text_version.dart';

/// One privacy point (FR-002/FR-014): icon + heading + body. The icon is
/// decorative only — every fact it suggests is also stated in the visible
/// (and therefore screen-reader-reachable) heading/body text, so it's
/// excluded from the semantics tree rather than carrying meaning by itself.
class ConsentPointTile extends StatelessWidget {
  const ConsentPointTile({required this.point, super.key});

  final ConsentPoint point;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.mintChipBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _iconFor(point.icon),
                color: AppColors.teal,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(point.heading, style: textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(point.body, style: textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(ConsentPointIcon icon) => switch (icon) {
    ConsentPointIcon.camera => Icons.camera_alt_outlined,
    ConsentPointIcon.clock => Icons.schedule_outlined,
    ConsentPointIcon.share => Icons.share_outlined,
  };
}
