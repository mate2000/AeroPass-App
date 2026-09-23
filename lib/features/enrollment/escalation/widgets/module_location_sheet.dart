import 'package:flutter/material.dart';

import '../../../../core/design/app_colors.dart';
import '../../../../domain/entities/escalation.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// "Cómo llegar al módulo" (010-escalar-agente, research.md §7): the airport,
/// where the module is inside it, and its hours, from the channel data. It
/// stays in the app — no maps application is opened.
class ModuleLocationSheet extends StatelessWidget {
  const ModuleLocationSheet({required this.module, super.key});

  final AgentChannel module;

  static Future<void> show(BuildContext context, AgentChannel module) =>
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (_) => ModuleLocationSheet(module: module),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                l10n.escalationLocationSheetTitle,
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (module.locationName != null)
              Text(
                module.locationName!,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (module.locationDetail != null) ...[
              const SizedBox(height: 4),
              Text(module.locationDetail!, style: textTheme.bodyMedium),
            ],
            const SizedBox(height: 12),
            Text(
              l10n.escalationLocationHours(module.hours),
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
