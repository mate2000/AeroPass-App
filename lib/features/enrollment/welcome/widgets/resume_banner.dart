import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';

/// FR-008: offers to resume an in-progress (process-alive-only)
/// enrollment session rather than silently restarting or presenting the
/// first-run framing again.
class ResumeBanner extends StatelessWidget {
  const ResumeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.play_circle_outline),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.welcomeResumeHeadline,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.welcomeResumeDescription,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
