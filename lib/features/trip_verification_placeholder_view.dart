import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../l10n/generated/app_localizations.dart';

/// Stands in for screen 13, the automatic re-verification before a pass
/// (012-mis-viajes FR-009). It produces no pass: 013 and 014 are specified
/// separately. 014-qr-pase: "Continuar a tu pase" opens the pass, which
/// asks the backend to issue it; this placeholder asserts nothing itself.
class TripVerificationPlaceholderView extends StatelessWidget {
  const TripVerificationPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const ExcludeSemantics(
                child: Icon(Icons.verified_user, size: 48),
              ),
              const SizedBox(height: 16),
              Semantics(
                header: true,
                child: Text(
                  l10n.tripVerificationTitle,
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.tripVerificationBody,
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.pushReplacement(AppRoutes.pass),
                child: Text(l10n.passContinueToPass),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.pop(),
                child: Text(l10n.tripVerificationBack),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
