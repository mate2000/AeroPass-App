import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';

/// FR-008: the document is expired — confirmation is blocked outright, the
/// reason is stated plainly, and the passenger is directed to the
/// conventional airport process (reusing 003's own statement — the same
/// fact, not a re-worded duplicate).
class ExpiredDocumentMessage extends StatelessWidget {
  const ExpiredDocumentMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      container: true,
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_busy,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.confirmationExpiredHeadline,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.confirmationExpiredBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.captureConventionalProcessStatement,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
