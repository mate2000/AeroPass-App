import 'package:flutter/material.dart';

import '../../../../core/design/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// The 10-second notice (007-validando, FR-009, FR-018): says the wait is
/// running longer than usual and offers "Seguir esperando" and "Ayuda".
/// Neither cancels the verification or leaves the screen on its own; help is
/// pushed on top and the wait continues underneath.
class SlowNotice extends StatelessWidget {
  const SlowNotice({
    required this.onKeepWaiting,
    required this.onHelp,
    super.key,
  });

  final VoidCallback onKeepWaiting;
  final VoidCallback onHelp;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3E7EC)),
      ),
      child: Column(
        children: [
          Text(
            l10n.verificationSlowNotice,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.navy,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: onKeepWaiting,
              child: Text(l10n.verificationKeepWaiting),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                minimumSize: const Size.fromHeight(44),
              ),
              onPressed: onHelp,
              child: Text(l10n.verificationHelp),
            ),
          ),
        ],
      ),
    );
  }
}
