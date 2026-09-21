import 'package:flutter/material.dart';

import '../../../../core/command.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// FR-005: the torch toggle, reachable one-handed — positioned by
/// `CaptureView` at the left of the bottom control row, within the bottom
/// half of the screen (Constitution Principle V).
class TorchToggle extends StatelessWidget {
  const TorchToggle({required this.command, required this.torchOn, super.key});

  final Command0<void> command;
  final bool torchOn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: command,
      builder: (context, _) {
        final label = torchOn
            ? l10n.captureTorchOnSemanticLabel
            : l10n.captureTorchOffSemanticLabel;
        return Semantics(
          label: label,
          button: true,
          excludeSemantics: true,
          child: IconButton(
            onPressed: command.running ? null : () => command.run(),
            iconSize: 32,
            color: Colors.white,
            icon: Icon(torchOn ? Icons.flash_on : Icons.flash_off),
          ),
        );
      },
    );
  }
}
