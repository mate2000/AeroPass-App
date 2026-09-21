import 'package:flutter/material.dart';

import '../../../../core/command.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// FR-004/FR-016: the large central capture control. Disabled while
/// [command] is already running — combined with [Command]'s own
/// re-entrancy guard, this is the belt-and-suspenders guarantee that
/// "exactly one capture is processed" even under a rapid double-tap.
class CaptureButton extends StatelessWidget {
  const CaptureButton({required this.command, super.key});

  final Command0<void> command;

  static const double _diameter = 72;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: command,
      builder: (context, _) {
        final enabled = !command.running;
        return Semantics(
          label: l10n.captureButtonSemanticLabel,
          button: true,
          enabled: enabled,
          excludeSemantics: true,
          child: GestureDetector(
            onTap: enabled ? () => command.run() : null,
            child: Container(
              width: _diameter,
              height: _diameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.white70, width: 4),
              ),
              alignment: Alignment.center,
              child: command.running
                  ? const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }
}
