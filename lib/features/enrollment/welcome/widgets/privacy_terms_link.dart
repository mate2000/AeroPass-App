import 'package:flutter/material.dart';

import '../../../../core/command.dart';

/// US3 / FR-010: a route to the plain-language data-handling statement,
/// available before any capture begins.
class PrivacyTermsLink extends StatelessWidget {
  const PrivacyTermsLink({
    required this.command,
    required this.label,
    super.key,
  });

  final Command0<void> command;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: () {
          command.run();
        },
        child: Text(label),
      ),
    );
  }
}
