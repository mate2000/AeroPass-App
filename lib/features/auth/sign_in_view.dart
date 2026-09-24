import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

/// Sign-in (015, the backend's authentication document): Clerk's embedded
/// `ClerkAuthentication`. It asks for whatever the Clerk instance requires,
/// such as a code, a password or the terms, so the app never handles a
/// password and never builds a token.
///
/// Composition only. The router leaves this screen by itself once the
/// session gate opens, so this view navigates nowhere. With no Clerk above
/// it ([clerkAvailable] false, as in widget tests) it shows a notice
/// instead.
class SignInView extends StatelessWidget {
  const SignInView({
    required this.clerkAvailable,
    this.completing = false,
    super.key,
  });

  final bool clerkAvailable;

  /// Signed in, while the router checks the account with the backend (a
  /// cold backend can take several seconds). The form is replaced by a
  /// progress indicator, so it cannot be submitted a second time.
  final bool completing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.signInTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (completing)
              Semantics(
                liveRegion: true,
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(l10n.signInCompleting, style: textTheme.bodyLarge),
                  ],
                ),
              )
            else if (clerkAvailable)
              const ClerkAuthentication()
            else
              Text(l10n.signInErrorNotAvailable, style: textTheme.bodyLarge),
            const SizedBox(height: 16),
            Text(l10n.signInPrivacy, style: textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
