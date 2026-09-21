import 'package:flutter/material.dart';

import '../../../../core/command.dart';

/// The gate's primary action ("Acepto y continúo"). Disabled — accessibly,
/// not just by color (FR-006) — until [enabled] is true; [disabledHint] is
/// announced to assistive technology as the reason while disabled, on top
/// of the standard Material disabled-button styling (opacity/elevation,
/// not hue alone).
class GatePrimaryActionButton extends StatelessWidget {
  const GatePrimaryActionButton({
    required this.command,
    required this.enabled,
    required this.label,
    required this.disabledHint,
    super.key,
  });

  final Command0<void> command;
  final bool enabled;
  final String label;
  final String disabledHint;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: command,
      builder: (context, _) {
        final canPress = enabled && !command.running;
        return Semantics(
          enabled: canPress,
          label: label,
          hint: canPress ? null : disabledHint,
          button: true,
          excludeSemantics: true,
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: canPress ? () => command.run() : null,
              child: command.running
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(label),
            ),
          ),
        );
      },
    );
  }
}

/// The gate's decline action ("Ahora no"). Presented with comparable
/// prominence to the primary action (FR-011: full-width, same footprint)
/// rather than a small text link, since declining here is legally
/// significant and must not read as an afterthought.
class GateSecondaryActionButton extends StatelessWidget {
  const GateSecondaryActionButton({
    required this.command,
    required this.label,
    super.key,
  });

  final Command1<void, bool> command;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: command,
      builder: (context, _) {
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: command.running ? null : () => command.run(false),
            child: Text(label),
          ),
        );
      },
    );
  }
}
