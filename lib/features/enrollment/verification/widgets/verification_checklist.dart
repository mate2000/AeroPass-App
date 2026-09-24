import 'package:flutter/material.dart';

import '../../../../core/design/app_colors.dart';
import '../../../../domain/entities/verification_stage.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/happy_path_flags.dart';

/// The three-stage checklist (007-validando, UI reference): pending rows are
/// dimmed, the running row shows a spinner, passed rows a filled check, and a
/// failed row a failure icon. Each row's wording follows its status, so
/// "Documento verificado" appears only once the backend reports it (FR-003).
///
/// Status is conveyed by icon and text, never colour alone (Principle VI).
/// Rows are excluded from semantics: the view announces changes instead
/// (FR-014), so a screen reader never re-reads the whole list.
class VerificationChecklist extends StatelessWidget {
  const VerificationChecklist({required this.stages, super.key});

  final Map<VerificationStage, StageStatus> stages;

  static const double _iconSize = 28;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final stage in VerificationStage.values)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _Row(
              status: stages[stage] ?? StageStatus.pending,
              label: stageLabel(
                l10n,
                stage,
                stages[stage] ?? StageStatus.pending,
              ),
            ),
          ),
      ],
    );
  }
}

/// The wording for [stage] at [status]: the completed form only once it has
/// passed.
String stageLabel(
  AppLocalizations l10n,
  VerificationStage stage,
  StageStatus status,
) {
  final passed = status == StageStatus.passed;
  return switch (stage) {
    VerificationStage.documentCheck =>
      passed
          ? (HappyPathFlags.biometricProviderMock
                ? l10n.verificationStageDocumentPassedMock
                : l10n.verificationStageDocumentPassed)
          : l10n.verificationStageDocumentRunning,
    VerificationStage.faceComparison =>
      passed
          ? (HappyPathFlags.biometricProviderMock
                ? l10n.verificationStageFacePassedMock
                : l10n.verificationStageFacePassed)
          : l10n.verificationStageFaceRunning,
    VerificationStage.issuance =>
      passed
          ? l10n.verificationStageIssuancePassed
          : l10n.verificationStageIssuanceRunning,
  };
}

class _Row extends StatelessWidget {
  const _Row({required this.status, required this.label});

  final StageStatus status;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dimmed = status == StageStatus.pending;
    return ExcludeSemantics(
      child: Row(
        children: [
          SizedBox.square(
            dimension: VerificationChecklist._iconSize,
            child: _StatusIcon(status: status),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyLarge?.copyWith(
                color: dimmed
                    ? AppColors.textSecondary.withValues(alpha: 0.5)
                    : AppColors.textPrimary,
                fontWeight: dimmed ? FontWeight.w400 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});

  final StageStatus status;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      StageStatus.pending => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE3E7EC), width: 2),
        ),
      ),
      StageStatus.running => const Padding(
        padding: EdgeInsets.all(2),
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppColors.turquoise,
        ),
      ),
      StageStatus.passed => Container(
        decoration: const BoxDecoration(
          color: AppColors.turquoise,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
      ),
      StageStatus.failed => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
      ),
    };
  }
}
