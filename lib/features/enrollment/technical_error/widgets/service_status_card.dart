import 'package:flutter/material.dart';

import '../../../../core/design/app_colors.dart';
import '../../../../domain/entities/service_status.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// "Estado del servicio" (011-error-tecnico, FR-007, FR-014).
///
/// It is built only from a live status read, and names the passenger's
/// journey steps, never internal components. Health is always written as
/// text; the dots are decoration. The card is a live region, so a change
/// while the screen is open is announced.
class ServiceStatusCard extends StatelessWidget {
  const ServiceStatusCard({required this.status, super.key});

  final ServiceStatus status;

  static Color _dotColor(StepHealth health) => switch (health) {
    StepHealth.operational => AppColors.turquoise,
    StepHealth.degraded => AppColors.slate,
    StepHealth.unavailable => AppColors.textPrimary,
  };

  static String _stepLabel(AppLocalizations l10n, JourneyStep step) =>
      switch (step) {
        JourneyStep.documentScan => l10n.technicalErrorStepDocumentScan,
        JourneyStep.selfie => l10n.technicalErrorStepSelfie,
        JourneyStep.issuance => l10n.technicalErrorStepIssuance,
      };

  static String _healthLabel(AppLocalizations l10n, StepHealth health) =>
      switch (health) {
        StepHealth.operational => l10n.technicalErrorHealthOperational,
        StepHealth.degraded => l10n.technicalErrorHealthDegraded,
        StepHealth.unavailable => l10n.technicalErrorHealthUnavailable,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE3E7EC)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Dot(color: _dotColor(status.worst)),
                const SizedBox(width: 8),
                Semantics(
                  header: true,
                  child: Text(
                    l10n.technicalErrorStatusTitle,
                    style: textTheme.titleSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final step in JourneyStep.values)
              if (status.steps[step] case final health?)
                MergeSemantics(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _stepLabel(l10n, step),
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _Dot(color: _dotColor(health)),
                        const SizedBox(width: 6),
                        Text(
                          _healthLabel(l10n, health),
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    ),
  );
}
