import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import 'app_colors.dart';

/// The enrollment step this screen represents, for `StepIndicator`
/// (005-instrucciones-selfie, research.md §2/data-model.md). Ordinal —
/// segments before [StepIndicator.currentStep] render complete, the
/// matching segment renders active, later segments render upcoming.
enum EnrollmentProgressStep { document, selfie, done }

/// Progress within enrollment — Documento / Selfie / Listo. Shared by
/// every enrollment screen (003-escanear-documento's capture screen and
/// 004-confirmar-datos's confirmation screen both pass `.document`;
/// 005-instrucciones-selfie passes `.selfie`) — each screen states which
/// step it represents explicitly via [currentStep] rather than the widget
/// guessing or defaulting.
class StepIndicator extends StatelessWidget {
  const StepIndicator({required this.currentStep, super.key});

  final EnrollmentProgressStep currentStep;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = <EnrollmentProgressStep, String>{
      EnrollmentProgressStep.document: l10n.captureStepDocumentLabel,
      EnrollmentProgressStep.selfie: l10n.captureStepSelfieLabel,
      EnrollmentProgressStep.done: l10n.captureStepDoneLabel,
    };
    return Semantics(
      container: true,
      label:
          '${labels[currentStep]} ${currentStep.index + 1}/'
          '${EnrollmentProgressStep.values.length}',
      child: ExcludeSemantics(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final step in EnrollmentProgressStep.values) ...[
              if (step != EnrollmentProgressStep.values.first)
                const SizedBox(width: 8),
              _Segment(label: labels[step]!, state: _stateFor(step)),
            ],
          ],
        ),
      ),
    );
  }

  _SegmentState _stateFor(EnrollmentProgressStep step) {
    if (step == currentStep) return _SegmentState.active;
    if (step.index < currentStep.index) return _SegmentState.complete;
    return _SegmentState.upcoming;
  }
}

enum _SegmentState { complete, active, upcoming }

class _Segment extends StatelessWidget {
  const _Segment({required this.label, required this.state});

  final String label;
  final _SegmentState state;

  @override
  Widget build(BuildContext context) {
    final color = state == _SegmentState.upcoming
        ? Colors.white54
        : AppColors.teal;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 32, height: 3, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: state == _SegmentState.active
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
