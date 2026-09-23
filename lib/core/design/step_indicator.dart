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
  const StepIndicator({
    required this.currentStep,
    this.currentStepReached = true,
    this.onLightSurface = false,
    super.key,
  });

  final EnrollmentProgressStep currentStep;

  /// 007-validando (FR-006): when `false`, [currentStep] renders as upcoming
  /// rather than active — screen 07 shows Listo pending until the credential
  /// exists. Defaults to today's behaviour, so 003–006 are unchanged.
  final bool currentStepReached;

  /// 007-validando: a dark-grey upcoming colour, since `white54` disappears
  /// on a light background. Defaults to the dark-surface style.
  final bool onLightSurface;

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
          '${EnrollmentProgressStep.values.length}'
          '${currentStepReached ? '' : ', ${l10n.stepIndicatorPendingSuffix}'}',
      child: ExcludeSemantics(
        // Scales the row down only when large text makes it wider than the
        // screen (Principle VI); at normal sizes it renders unchanged.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final step in EnrollmentProgressStep.values) ...[
                if (step != EnrollmentProgressStep.values.first)
                  const SizedBox(width: 8),
                _Segment(
                  label: labels[step]!,
                  state: _stateFor(step),
                  onLightSurface: onLightSurface,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  _SegmentState _stateFor(EnrollmentProgressStep step) {
    if (step == currentStep) {
      return currentStepReached ? _SegmentState.active : _SegmentState.upcoming;
    }
    if (step.index < currentStep.index) return _SegmentState.complete;
    return _SegmentState.upcoming;
  }
}

enum _SegmentState { complete, active, upcoming }

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.state,
    required this.onLightSurface,
  });

  final String label;
  final _SegmentState state;
  final bool onLightSurface;

  static const _upcomingOnLight = Color(0xFFB8C0CC);

  @override
  Widget build(BuildContext context) {
    final color = state == _SegmentState.upcoming
        ? (onLightSurface ? _upcomingOnLight : Colors.white54)
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
