import 'package:flutter/material.dart';

import '../../../../core/command.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// FR-014/US3: shown when the camera permission is denied — explains what
/// is blocked, offers either a retry (temporary denial) or the
/// system-settings route (permanent denial, never re-prompting the OS
/// dialog again), and always states that the conventional airport process
/// remains available.
class PermissionDeniedMessage extends StatelessWidget {
  const PermissionDeniedMessage({
    required this.permanent,
    required this.retryCommand,
    required this.openSettingsCommand,
    super.key,
  });

  final bool permanent;
  final Command0<void> retryCommand;
  final Command0<void> openSettingsCommand;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final headline = permanent
        ? l10n.capturePermissionDeniedPermanentHeadline
        : l10n.capturePermissionDeniedTemporaryHeadline;
    final body = permanent
        ? l10n.capturePermissionDeniedPermanentBody
        : l10n.capturePermissionDeniedTemporaryBody;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.no_photography_outlined, color: Colors.white70, size: 40),
            const SizedBox(height: 16),
            Text(
              headline,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            if (permanent)
              _ActionButton(
                command: openSettingsCommand,
                label: l10n.capturePermissionOpenSettingsLabel,
              )
            else
              _ActionButton(
                command: retryCommand,
                label: l10n.capturePermissionRetryLabel,
              ),
            const SizedBox(height: 16),
            Text(
              l10n.captureConventionalProcessStatement,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.command, required this.label});

  final Command0<void> command;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: command,
      builder: (context, _) {
        return FilledButton(
          onPressed: command.running ? null : () => command.run(),
          child: Text(label),
        );
      },
    );
  }
}
