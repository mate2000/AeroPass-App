import 'package:flutter/material.dart';

import '../../../../core/command.dart';

/// The screen's single primary action (FR-002), kept reachable one-handed
/// within the bottom half of the screen with no scrolling (FR-015) by
/// `WelcomeView`'s layout. Listens to its [Command] directly so running
/// state (Principle III/IX) disables the button and shows progress
/// without any boolean flag on the ViewModel.
class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({
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
        return SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: command.running
                ? null
                : () {
                    command.run();
                  },
            child: command.running
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(label),
          ),
        );
      },
    );
  }
}
