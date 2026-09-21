import 'package:flutter/material.dart';

import '../../../../domain/entities/welcome_content_variant.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// FR-012: shown instead of the normal welcome content when the device
/// can't complete enrollment, directing the passenger to the conventional
/// airport process rather than offering an action that would fail — no
/// primary/secondary action is rendered alongside this.
class DeviceUnsupportedMessage extends StatelessWidget {
  const DeviceUnsupportedMessage({required this.reason, super.key});

  final DeviceUnsupportedReason reason;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final description = reason == DeviceUnsupportedReason.noCamera
        ? l10n.welcomeDeviceUnsupportedNoCameraDescription
        : l10n.welcomeDeviceUnsupportedOsDescription;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.phonelink_erase_outlined),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.welcomeDeviceUnsupportedHeadline,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
