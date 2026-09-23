import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/design/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';

/// Perfil is a separate surface, not yet specified (012-mis-viajes, Out of
/// Scope). Its one entry is consent withdrawal, which the constitution
/// requires within two taps of the account surface (FR-019): the Perfil tab,
/// then this row.
class ProfilePlaceholderView extends StatelessWidget {
  const ProfilePlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Semantics(
            header: true,
            child: Text(
              l10n.profileTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            child: ListTile(
              leading: const Icon(Icons.shield_outlined, color: AppColors.navy),
              title: Text(l10n.profileWithdrawConsent),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.withdrawal),
            ),
          ),
        ],
      ),
    );
  }
}
