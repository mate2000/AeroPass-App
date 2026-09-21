import 'package:flutter/material.dart';

/// Entry point only, per spec.md Out of Scope ("Account recovery on a new
/// device beyond the entry point offered here"). Reached from the welcome
/// screen's secondary action (US2, Acceptance Scenario 3).
class RecoveryPlaceholderView extends StatelessWidget {
  const RecoveryPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Credential recovery (placeholder) — implemented by the '
            'account-recovery feature.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
