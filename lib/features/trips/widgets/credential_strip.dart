import 'package:flutter/material.dart';

import '../../../core/design/app_colors.dart';
import '../../../domain/entities/credential_summary.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../core/happy_path_flags.dart';

/// The compact credential on Mis viajes (012-mis-viajes FR-002, FR-003,
/// FR-018): initials instead of any face, the holder's name, the masked
/// number, and a badge. The badge reads "ACTIVA" only when the backend
/// affirmed the credential on this read ([CredentialSummary.showsActive]).
class CredentialStrip extends StatelessWidget {
  const CredentialStrip({required this.summary, super.key});

  /// Null while nothing is known; the strip then shows no name or badge.
  final CredentialSummary? summary;

  static String initialsOf(String? name) {
    final words = (name ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '';
    final first = words.first[0];
    final second = words.length > 1 ? words[1][0] : '';
    return (first + second).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final summary = this.summary;
    final name = summary?.holderName;
    final last4 = summary?.documentLast4;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [AppColors.navy, AppColors.credentialCardGradientEnd],
        ),
      ),
      child: Row(
        children: [
          ExcludeSemantics(child: InitialsAvatar(initials: initialsOf(name))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (name != null)
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                if (last4 != null)
                  Text(
                    l10n.tripsMaskedDocument(last4),
                    style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
              ],
            ),
          ),
          if (summary != null) ...[
            const SizedBox(width: 8),
            _Badge(summary: summary),
          ],
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.summary});

  final CredentialSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final active = summary.showsActive;
    final state = switch (summary.state) {
      // 015 FR-020: never "ACTIVA" while the biometrics are simulated.
      CredentialDisplayState.active =>
        HappyPathFlags.biometricProviderMock
            ? l10n.tripsBadgeMock
            : l10n.tripsBadgeActive,
      CredentialDisplayState.expired => l10n.tripsBadgeExpired,
      CredentialDisplayState.revoked => l10n.tripsBadgeRevoked,
      CredentialDisplayState.suspended => l10n.tripsBadgeSuspended,
    };
    // The word "ACTIVA" is reserved for an affirmed credential (FR-003): an
    // unconfirmed active credential says only that it is unconfirmed.
    final label = active
        ? (HappyPathFlags.biometricProviderMock
              ? l10n.tripsBadgeMock
              : l10n.tripsBadgeActive)
        : summary.confirmed
        ? state
        : summary.state == CredentialDisplayState.active
        ? l10n.tripsBadgeUnconfirmed.toUpperCase()
        : '$state · ${l10n.tripsBadgeUnconfirmed}';
    return Container(
      constraints: const BoxConstraints(maxWidth: 180),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? AppColors.turquoise : Colors.white24,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// A neutral circle with initials. Never a facial image (FR-018).
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({required this.initials, this.size = 40, super.key});

  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFD7E3F1),
        shape: BoxShape.circle,
      ),
      child: initials.isEmpty
          ? Icon(Icons.person, color: AppColors.navy, size: size * 0.6)
          : Text(
              initials,
              // Decorative and excluded from semantics; it must fit its
              // fixed circle at any text size.
              textScaler: TextScaler.noScaling,
              style: TextStyle(
                color: AppColors.navy,
                fontWeight: FontWeight.w700,
                fontSize: size * 0.38,
              ),
            ),
    );
  }
}
