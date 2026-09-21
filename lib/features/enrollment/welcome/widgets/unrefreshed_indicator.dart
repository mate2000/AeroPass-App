import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';

/// FR-007: indicates the shown status could not be freshly confirmed
/// because the backend was unreachable — never signaled by color alone
/// (FR-014), so this carries an icon and explicit text.
class UnrefreshedIndicator extends StatelessWidget {
  const UnrefreshedIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      container: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.welcomeUnrefreshedIndicator,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
