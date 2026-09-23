import 'package:flutter/material.dart';

import '../../../../domain/entities/liveness_outcome.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// FR-009/FR-010: one branch for `qualityFailure(reason)` (specific,
/// actionable copy per reason, in the instructions screen's vocabulary),
/// and one shared branch for `unclassifiedFailure`/`attackDetected` —
/// deliberately the SAME copy lookup (`_genericCopy`), not two
/// near-duplicate string pairs, so the two outcomes are provably
/// indistinguishable to the passenger (Clarifications, SC-006). Never call
/// this with `LivenessOutcome.success()`.
class LivenessFailureMessage extends StatelessWidget {
  const LivenessFailureMessage({required this.outcome, super.key});

  final LivenessOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (headline, body) = switch (outcome) {
      LivenessOutcomeQualityFailure(:final reason) => _reasonCopy(reason, l10n),
      LivenessOutcomeUnclassifiedFailure() ||
      LivenessOutcomeAttackDetected() => _genericCopy(l10n),
      LivenessOutcomeSuccess() => throw StateError(
        'LivenessFailureMessage must not be built for a success outcome',
      ),
    };
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

  (String, String) _reasonCopy(
    LivenessQualityReason reason,
    AppLocalizations l10n,
  ) {
    return switch (reason) {
      LivenessQualityReason.tooDark => (
        l10n.livenessFailureTooDarkHeadline,
        l10n.livenessFailureTooDarkBody,
      ),
      LivenessQualityReason.faceOutOfFrame => (
        l10n.livenessFailureFaceOutOfFrameHeadline,
        l10n.livenessFailureFaceOutOfFrameBody,
      ),
      LivenessQualityReason.movementDetected => (
        l10n.livenessFailureMovementDetectedHeadline,
        l10n.livenessFailureMovementDetectedBody,
      ),
      LivenessQualityReason.multipleFacesDetected => (
        l10n.livenessFailureMultipleFacesDetectedHeadline,
        l10n.livenessFailureMultipleFacesDetectedBody,
      ),
      LivenessQualityReason.faceObstructed => (
        l10n.livenessFailureFaceObstructedHeadline,
        l10n.livenessFailureFaceObstructedBody,
      ),
    };
  }

  (String, String) _genericCopy(AppLocalizations l10n) =>
      (l10n.livenessFailureGenericHeadline, l10n.livenessFailureGenericBody);
}
