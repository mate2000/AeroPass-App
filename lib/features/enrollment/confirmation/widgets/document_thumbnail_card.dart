import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/design/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// FR-001: the document image shown back to the passenger as evidence of
/// what was read. Navy card, a thumbnail of the retained bytes, a
/// "✓ Capturado" badge, and a country marker (spec.md UI Reference) — the
/// country marker is fixed ("COL") because 003-escanear-documento only
/// accepts Colombian-issued documents (cédula de ciudadanía, Colombian
/// passport); it is not derived per-document.
class DocumentThumbnailCard extends StatelessWidget {
  const DocumentThumbnailCard({required this.documentImageBytes, super.key});

  final Uint8List documentImageBytes;

  static const _countryMarker = 'COL';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.memory(
              documentImageBytes,
              width: 72,
              height: 48,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              // A decode failure (corrupt bytes, or an unsupported fixture
              // format in a test) must not take down the review screen —
              // Constitution Principle III applies to this thumbnail too.
              errorBuilder: (context, error, stackTrace) => Container(
                width: 72,
                height: 48,
                color: Colors.white24,
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.white54,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  label: l10n.confirmationCapturedBadgeLabel,
                  child: ExcludeSemantics(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.teal,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.confirmationCapturedBadgeLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  _countryMarker,
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
