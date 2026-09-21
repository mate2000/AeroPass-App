import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';

/// FR-001: states the passenger-facing benefit and, folded into the
/// description sentence, that the service is free — before any enrollment
/// action is offered. A named widget class, never a `_buildX()` method
/// (Constitution Principle X).
class BenefitSummary extends StatelessWidget {
  const BenefitSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.welcomeBenefitHeadline, style: textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(l10n.welcomeBenefitDescription, style: textTheme.bodyMedium),
      ],
    );
  }
}
