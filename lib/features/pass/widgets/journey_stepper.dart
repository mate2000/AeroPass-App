import 'package:flutter/material.dart';

import '../../../core/design/app_colors.dart';
import '../../../domain/entities/pass.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Seguridad → Embarque (014-qr-pase FR-009, Clarifications). A step is
/// checked only because the backend reported it validated; the current
/// step is the one the code is for. Each step is read as text.
class JourneyStepper extends StatelessWidget {
  const JourneyStepper({
    required this.validated,
    this.steps = const {Checkpoint.security, Checkpoint.boarding},
    required this.current,
    super.key,
  });

  final Set<Checkpoint> validated;

  /// The checkpoints shown, in journey order (015 FR-024).
  final Set<Checkpoint> steps;

  /// Null once boarding is confirmed.
  final Checkpoint? current;

  static String labelOf(AppLocalizations l10n, Checkpoint checkpoint) =>
      switch (checkpoint) {
        Checkpoint.security => l10n.passCheckpointSecurity,
        Checkpoint.boarding => l10n.passCheckpointBoarding,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final steps = [
      for (final checkpoint in Checkpoint.values)
        if (this.steps.contains(checkpoint)) checkpoint,
    ];
    return Row(
      children: [
        for (final (index, step) in steps.indexed) ...[
          if (index > 0)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: 18),
                color: validated.contains(steps[index - 1])
                    ? AppColors.navy
                    : const Color(0xFFE3E7EC),
              ),
            ),
          _Step(
            number: index + 1,
            label: labelOf(l10n, step),
            done: validated.contains(step),
            current: current == step,
            semantics: validated.contains(step)
                ? l10n.passStepDone(labelOf(l10n, step))
                : current == step
                ? l10n.passStepCurrent(labelOf(l10n, step))
                : l10n.passStepPending(labelOf(l10n, step)),
          ),
        ],
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.number,
    required this.label,
    required this.done,
    required this.current,
    required this.semantics,
  });

  final int number;
  final String label;
  final bool done;
  final bool current;
  final String semantics;

  @override
  Widget build(BuildContext context) {
    final active = done || current;
    return Semantics(
      label: semantics,
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? AppColors.navy : const Color(0xFFF1F4F7),
            ),
            child: done
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    '$number',
                    style: TextStyle(
                      color: active ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: active ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
