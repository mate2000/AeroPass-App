import 'package:flutter/material.dart';

import '../../../../domain/entities/credential_status.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// FR-006: shown instead of the first-run pitch when a credential exists
/// but is expired or revoked — a distinct explanation, not a generic
/// first-run screen. The distinction from a resumable session must not
/// rely on color alone (FR-014); an icon plus heading text carries it.
class ReenrollmentBanner extends StatelessWidget {
  const ReenrollmentBanner({this.reason, super.key});

  final ExpiryReason? reason;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final description = reason == ExpiryReason.revoked
        ? l10n.welcomeReenrollmentRequiredRevokedDescription
        : l10n.welcomeReenrollmentRequiredExpiredDescription;
    return Semantics(
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.welcomeReenrollmentRequiredHeadline,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
