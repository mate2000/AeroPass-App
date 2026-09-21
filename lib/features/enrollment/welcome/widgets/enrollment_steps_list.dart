import 'package:flutter/material.dart';

import '../../../../core/design/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// FR-001: the three enrollment steps (identity document, selfie,
/// travel), stated on this screen rather than deferred to a later one
/// (FR-004's edge case). Each row shows a single-line label; the icon is
/// decorative only — every fact it suggests is also stated in the visible
/// (and therefore screen-reader-reachable) title text (FR-014).
class EnrollmentStepsList extends StatelessWidget {
  const EnrollmentStepsList({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _EnrollmentStepTile(
          icon: Icons.badge_outlined,
          title: l10n.welcomeStepDocumentTitle,
        ),
        _EnrollmentStepTile(
          icon: Icons.face_retouching_natural_outlined,
          title: l10n.welcomeStepSelfieTitle,
        ),
        _EnrollmentStepTile(
          icon: Icons.flight_takeoff_outlined,
          title: l10n.welcomeStepTravelTitle,
        ),
      ],
    );
  }
}

class _EnrollmentStepTile extends StatelessWidget {
  const _EnrollmentStepTile({required this.icon, required this.title});

  final IconData icon;
  final String title;

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
          Expanded(child: Text(title, style: textTheme.titleMedium)),
        ],
      ),
    );
  }
}
