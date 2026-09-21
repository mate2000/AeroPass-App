import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

/// The brief branded splash/loading state shown while the launch-time
/// credential-status check runs (FR-017) — neither the welcome content
/// nor the trips surface. `router.dart`'s redirect logic navigates away
/// from this route once the check resolves.
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              l10n.splashLoadingLabel,
              semanticsLabel: l10n.splashLoadingLabel,
            ),
          ],
        ),
      ),
    );
  }
}
