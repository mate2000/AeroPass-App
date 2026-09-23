import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

/// Navigation target only (008-identidad-activa, research.md §11): the
/// "Ver mi identidad" destination, and where a link or restored navigation
/// into screen 08 lands once that screen has been shown (FR-009). The
/// persistent credential surface itself — including refreshing state and
/// the "unrefreshed" marking — is specified separately.
class CredentialDetailPlaceholderView extends StatelessWidget {
  const CredentialDetailPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            AppLocalizations.of(context).credentialDetailPlaceholderMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
