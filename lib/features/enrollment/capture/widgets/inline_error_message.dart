import 'package:flutter/material.dart';

import '../../../../domain/entities/capture_outcome.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// FR-007/FR-008: a specific, actionable message for a rejected capture —
/// same vocabulary regardless of whether the rejection came from the
/// on-device assessor or the verification processor (FR-008), conveyed by
/// text AND an icon, never by the red viewfinder frame alone (Constitution
/// Principle VI).
class InlineErrorMessage extends StatelessWidget {
  const InlineErrorMessage({required this.reason, super.key});

  final CaptureRejectionReason reason;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (headline, body) = _copyFor(reason, l10n);
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    headline,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(body, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  (String, String) _copyFor(
    CaptureRejectionReason reason,
    AppLocalizations l10n,
  ) {
    return switch (reason) {
      CaptureRejectionReason.blur => (
        l10n.captureRejectionBlurHeadline,
        l10n.captureRejectionBlurBody,
      ),
      CaptureRejectionReason.glare => (
        l10n.captureRejectionGlareHeadline,
        l10n.captureRejectionGlareBody,
      ),
      CaptureRejectionReason.framing => (
        l10n.captureRejectionFramingHeadline,
        l10n.captureRejectionFramingBody,
      ),
      CaptureRejectionReason.wrongDocument => (
        l10n.captureRejectionWrongDocumentHeadline,
        l10n.captureRejectionWrongDocumentBody,
      ),
      CaptureRejectionReason.lowResolution => (
        l10n.captureRejectionLowResolutionHeadline,
        l10n.captureRejectionLowResolutionBody,
      ),
      CaptureRejectionReason.unreadable => (
        l10n.captureRejectionUnreadableHeadline,
        l10n.captureRejectionUnreadableBody,
      ),
    };
  }
}
