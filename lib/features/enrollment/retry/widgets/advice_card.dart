import 'package:flutter/material.dart';

import '../../../../core/design/app_colors.dart';

/// One tip on the advice card: its text, and a decorative icon.
class AdviceTip {
  const AdviceTip({required this.icon, required this.text});

  final IconData icon;
  final String text;
}

/// The "Consejos para el siguiente intento" card (009-reintento, UI
/// reference). Icons are decorative and excluded from semantics; the text
/// carries the meaning (Principle VI).
class AdviceCard extends StatelessWidget {
  const AdviceCard({required this.heading, required this.tips, super.key});

  final String heading;
  final List<AdviceTip> tips;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: textTheme.titleSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          for (final tip in tips) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(
                  child: Icon(tip.icon, size: 20, color: AppColors.amber),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tip.text,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
