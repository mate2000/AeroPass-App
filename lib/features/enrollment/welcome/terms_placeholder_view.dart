import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

/// Plain-language data-handling statement (User Story 3): what's
/// collected, who verifies it, retention period, and how to revoke. Ships
/// against a placeholder link per FR-011's documented blocking dependency
/// (final legal-reviewed privacy terms and terms-of-service URLs have not
/// been published yet — see spec.md Dependencies).
class TermsPlaceholderView extends StatelessWidget {
  const TermsPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.termsScreenTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TermsSection(
              heading: l10n.termsWhatWeCollectHeading,
              body: l10n.termsWhatWeCollectBody,
            ),
            _TermsSection(
              heading: l10n.termsWhoVerifiesHeading,
              body: l10n.termsWhoVerifiesBody,
            ),
            _TermsSection(
              heading: l10n.termsRetentionHeading,
              body: l10n.termsRetentionBody,
            ),
            _TermsSection(
              heading: l10n.termsRevocationHeading,
              body: l10n.termsRevocationBody,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.termsPlaceholderLinkNotice,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _TermsSection extends StatelessWidget {
  const _TermsSection({required this.heading, required this.body});

  final String heading;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
