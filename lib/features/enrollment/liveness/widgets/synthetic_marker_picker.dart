import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design/app_colors.dart';
import '../../../../core/synthetic_marker.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Dev and staging only (015 research.md §6, T044). It chooses which mock
/// result the synthetic selfie asks the backend for, so 009, 010 and 011
/// can be reached against a real backend. The view builds it only under
/// `HappyPathFlags.syntheticCapture`, so a prod build does not contain it.
class SyntheticMarkerPicker extends StatelessWidget {
  const SyntheticMarkerPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selection = context.watch<SyntheticMarkerSelection>();
    String label(SyntheticSelfieMarker marker) => switch (marker) {
      SyntheticSelfieMarker.ok => l10n.devSyntheticMarkerOk,
      SyntheticSelfieMarker.spoof => l10n.devSyntheticMarkerSpoof,
      SyntheticSelfieMarker.other => l10n.devSyntheticMarkerOther,
      SyntheticSelfieMarker.timeout => l10n.devSyntheticMarkerTimeout,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.devSyntheticMarkerLabel,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              Wrap(
                spacing: 8,
                children: [
                  for (final marker in SyntheticSelfieMarker.values)
                    ChoiceChip(
                      key: Key('synthetic-marker-${marker.name}'),
                      label: Text(label(marker)),
                      selected: selection.selfie == marker,
                      onSelected: (_) => selection.selfie = marker,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
