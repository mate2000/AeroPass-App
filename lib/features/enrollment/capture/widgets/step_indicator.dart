import 'package:flutter/material.dart';

import '../../../../core/design/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// FR-011: progress within enrollment — Documento / Selfie / Listo — for
/// this screen, "Documento" is always the active segment (the actual state
/// this step represents; selfie/listo become dynamic once those steps
/// exist, per the constitution's KISS guidance against building ahead of
/// a second real call site).
class StepIndicator extends StatelessWidget {
  const StepIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      container: true,
      label: '${l10n.captureStepDocumentLabel} 1/3',
      child: ExcludeSemantics(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Segment(label: l10n.captureStepDocumentLabel, active: true),
            const SizedBox(width: 8),
            _Segment(label: l10n.captureStepSelfieLabel, active: false),
            const SizedBox(width: 8),
            _Segment(label: l10n.captureStepDoneLabel, active: false),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.teal : Colors.white54;
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
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
