import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';

/// FR-009: the processor could not read a required field for this
/// document. Shown as an explicit gap that blocks the whole screen — never
/// as a blank value alongside otherwise-editable fields — with re-scan
/// offered as the only resolution (missing data isn't something a
/// passenger can freely type in, per CONFLICT-001's resolution).
class MissingFieldNotice extends StatelessWidget {
  const MissingFieldNotice({super.key});

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
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.confirmationMissingFieldHeadline,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.confirmationMissingFieldBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
