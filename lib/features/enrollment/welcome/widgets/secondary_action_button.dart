import 'package:flutter/material.dart';

import '../../../../core/command.dart';

/// The screen's single secondary action (FR-002): account recovery on a
/// new device, for a passenger who already has an account (US2,
/// Acceptance Scenario 3). Styled as a text link, not a bordered button,
/// per the mockup.
class SecondaryActionButton extends StatelessWidget {
  const SecondaryActionButton({
    required this.command,
    required this.label,
    super.key,
  });

  final Command0<void> command;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: command,
      builder: (context, _) {
        return Center(
          child: TextButton(
            onPressed: command.running
                ? null
                : () {
                    command.run();
                  },
            child: Text(label),
          ),
        );
      },
    );
  }
}
