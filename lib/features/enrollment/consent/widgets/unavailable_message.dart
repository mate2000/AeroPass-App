import 'package:flutter/material.dart';

import '../../../../domain/entities/consent_unavailable_reason.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Covers both the gate's blocking "text couldn't be fetched" state and
/// the inline "consent couldn't be recorded" (offline-blocked) message
/// (FR-008, Edge Cases) — the same reason classification (offline vs. a
/// generic fetch/save error) applies to both, so one widget renders both
/// rather than duplicating the copy-selection logic.
class UnavailableMessage extends StatelessWidget {
  const UnavailableMessage({
    required this.reason,
    this.onRetry,
    this.compact = false,
    super.key,
  });

  final UnavailableReason reason;

  /// When non-null, a retry action is offered (used for the full-page
  /// text-unavailable state; the inline confirm-failure case relies on the
  /// still-enabled primary action button as its own retry instead).
  final VoidCallback? onRetry;

  /// True for the inline (confirm-failure) presentation, which uses the
  /// confirm-blocked copy instead of the gate-unavailable copy.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final headline = reason == UnavailableReason.offline
        ? l10n.consentUnavailableOfflineHeadline
        : l10n.consentUnavailableFetchErrorHeadline;
    final body = compact
        ? (reason == UnavailableReason.offline
              ? l10n.consentConfirmBlockedOfflineMessage
              : l10n.consentConfirmBlockedGenericMessage)
        : (reason == UnavailableReason.offline
              ? l10n.consentUnavailableOfflineBody
              : l10n.consentUnavailableFetchErrorBody);

    return Semantics(
      container: true,
      liveRegion: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  compact ? body : headline,
                  style: compact
                      ? Theme.of(context).textTheme.bodyMedium
                      : Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: 8),
            Text(body, style: Theme.of(context).textTheme.bodyMedium),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(l10n.consentRetryLabel),
            ),
          ],
        ],
      ),
    );
  }
}
