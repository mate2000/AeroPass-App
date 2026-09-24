import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/design/app_colors.dart';
import '../../../../domain/entities/activated_credential.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/happy_path_flags.dart';

/// The credential card (008-identidad-activa, UI reference): label, holder
/// name, masked document, issue date, validity and status, with a generic
/// icon where the reference shows a portrait placeholder.
///
/// Built from [ActivatedCredential] only, which never carries the full
/// document number (FR-003, SC-005) or a face image (FR-018). Dates come
/// straight from the backend and are only formatted here (FR-004).
class CredentialCard extends StatelessWidget {
  const CredentialCard({required this.credential, super.key});

  final ActivatedCredential credential;

  /// Research.md §9: one format for both dates.
  static const _datePattern = 'd MMM y';
  static const _dateLocale = 'es';

  /// Clarifications: long names wrap to at most two lines, then ellipsis.
  static const _nameMaxLines = 2;

  static const double _radius = 20;
  static const double _padding = 20;
  static const double _portraitSize = 56;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context).textTheme;
    final dateFormat = DateFormat(_datePattern, _dateLocale);
    final issuedOn = dateFormat.format(credential.issuedAt.toLocal());
    final validUntil = dateFormat.format(credential.validUntil.toLocal());
    const onCard = Colors.white;
    final onCardMuted = Colors.white.withValues(alpha: 0.75);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(_padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_radius),
        gradient: const LinearGradient(
          colors: [AppColors.navy, AppColors.credentialCardGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.credentialCardLabel,
                      style: theme.labelSmall?.copyWith(
                        color: onCardMuted,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // FR-014: the visible name may be truncated, but the
                    // announced name is always the full value.
                    Semantics(
                      label: credential.holderName,
                      excludeSemantics: true,
                      child: Text(
                        credential.holderName,
                        maxLines: _nameMaxLines,
                        overflow: TextOverflow.ellipsis,
                        style: theme.titleLarge?.copyWith(
                          color: onCard,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // FR-014: announced as words, never as bullet glyphs.
                    Semantics(
                      label: l10n.credentialCardMaskedDocumentSemantics(
                        credential.documentLast4,
                        spokenCountryName(l10n, credential.issuingCountry),
                      ),
                      excludeSemantics: true,
                      child: Text(
                        l10n.credentialCardMaskedDocument(
                          credential.documentLast4,
                          credential.issuingCountry,
                        ),
                        style: theme.bodySmall?.copyWith(color: onCardMuted),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _GenericPortrait(label: l10n.credentialCardPortraitSemantics),
            ],
          ),
          const SizedBox(height: 20),
          // 015: the badge wraps below the dates when the row is too tight
          // (200% text, or the longer "REGISTRADO"), rather than overflowing.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 12,
            runSpacing: 8,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.credentialCardIssuedOn(issuedOn),
                    style: theme.bodySmall?.copyWith(color: onCard),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.credentialCardValidUntil(validUntil),
                    style: theme.bodySmall?.copyWith(
                      color: onCard,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              _ActiveBadge(
                label: HappyPathFlags.biometricProviderMock
                    ? l10n.credentialCardBadgeMock
                    : l10n.credentialCardActiveBadge,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Research.md §8: country names for the codes this product supports,
/// falling back to spelling the code out letter by letter, so assistive
/// technology never reads an unknown code as a word.
String spokenCountryName(AppLocalizations l10n, String countryCode) =>
    switch (countryCode) {
      'COL' => l10n.countryNameCol,
      _ => countryCode.split('').join(' '),
    };

/// FR-018: never a face image — a generic silhouette in the portrait spot.
class _GenericPortrait extends StatelessWidget {
  const _GenericPortrait({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Container(
        width: CredentialCard._portraitSize,
        height: CredentialCard._portraitSize,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.person, color: Colors.white, size: 36),
      ),
    );
  }
}

/// The "• ACTIVA" status pill. Status is conveyed by text, never by color
/// alone (Principle VI).
class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.turquoise,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ExcludeSemantics(
            child: Icon(Icons.circle, color: Colors.white, size: 8),
          ),
          const SizedBox(width: 6),
          // Flexible, so a long label at 200% text wraps inside the badge
          // instead of overflowing the card.
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
