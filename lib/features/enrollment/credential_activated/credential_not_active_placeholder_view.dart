import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

/// Navigation target only (008-identidad-activa, FR-010, research.md §11):
/// where the passenger goes when the backend issues a non-active or
/// incomplete credential. Screen 08 never opens in that case. The real
/// outcome screen arrives with its own spec; until then this placeholder
/// stands in, as the spec's deferral table allows.
class CredentialNotActivePlaceholderView extends StatelessWidget {
  const CredentialNotActivePlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              AppLocalizations.of(context)
                  .credentialNotActivePlaceholderMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      ),
    );
  }
}
