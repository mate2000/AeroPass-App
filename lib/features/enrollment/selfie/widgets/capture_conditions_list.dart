import 'package:flutter/material.dart';

import '../../../../core/design/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// FR-002/FR-003: the three conditions for a successful capture, stated as
/// positive actions rather than prohibitions. Not modeled as a data list
/// (data-model.md: "Capture condition, not modeled as a type") — mirrors
/// `EnrollmentStepsList`'s precedent of hardcoded rows pulling `l10n`
/// strings, since the content has no runtime variability.
///
/// Rule 2's wording states what must be visible (an unobstructed face)
/// rather than enumerating garments to remove (CONFLICT-001, resolved in
/// spec.md) — it never asks a passenger to remove glasses or a religious
/// head covering.
class CaptureConditionsList extends StatelessWidget {
  const CaptureConditionsList({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ConditionTile(
          icon: Icons.wb_sunny_outlined,
          label: l10n.selfieInstructionsRuleLightingLabel,
        ),
        _ConditionTile(
          icon: Icons.face_outlined,
          label: l10n.selfieInstructionsRuleFaceVisibleLabel,
        ),
        _ConditionTile(
          icon: Icons.center_focus_strong_outlined,
          label: l10n.selfieInstructionsRuleEyesLabel,
        ),
      ],
    );
  }
}

class _ConditionTile extends StatelessWidget {
  const _ConditionTile({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ExcludeSemantics(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.mintChipBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.teal, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: textTheme.titleMedium)),
        ],
      ),
    );
  }
}
