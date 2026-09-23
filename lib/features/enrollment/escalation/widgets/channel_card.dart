import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/design/app_colors.dart';
import '../../../../domain/entities/escalation.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// One channel option (010-escalar-agente). Part of a single choice group for
/// assistive technology: its label joins the name, availability and wait,
/// and it reports whether it is selected (FR-016). An unavailable channel
/// says when it opens and cannot be selected (FR-005). Every availability
/// and wait shown comes from [channel], never from copy (FR-004, FR-006).
class ChannelCard extends StatelessWidget {
  const ChannelCard({
    required this.channel,
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final AgentChannel channel;
  final bool selected;
  final VoidCallback onSelect;

  static const _opensAtPattern = 'd MMM, H:mm';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final isModule = channel.kind == AgentChannelKind.module;
    final title = isModule
        ? l10n.escalationModuleTitle
        : l10n.escalationChatTitle;

    final details = <String>[
      if (isModule)
        [
          channel.locationName,
          channel.locationDetail,
        ].whereType<String>().join(' · ')
      else
        l10n.escalationChatPurpose,
      if (channel.available && channel.estimatedWait != null)
        l10n.escalationEstimatedWait(
          channel.estimatedWait!.minMinutes,
          channel.estimatedWait!.maxMinutes,
        ),
      if (!channel.available && channel.nextOpensAt != null)
        l10n.escalationOpensAt(
          DateFormat(
            _opensAtPattern,
            'es',
          ).format(channel.nextOpensAt!.toLocal()),
        ),
      channel.hours,
    ].where((line) => line.isNotEmpty).toList();

    final availability = channel.available
        ? l10n.escalationAvailableNow
        : l10n.escalationUnavailable;
    final dimmed = !channel.available;

    return Semantics(
      container: true,
      inMutuallyExclusiveGroup: true,
      checked: selected,
      enabled: channel.available,
      button: true,
      label: [title, availability, ...details].join('. '),
      excludeSemantics: true,
      child: Opacity(
        opacity: dimmed ? 0.55 : 1,
        child: Material(
          color: selected ? const Color(0xFFEFF3F9) : AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: selected ? AppColors.navy : const Color(0xFFE3E7EC),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: channel.available ? onSelect : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F4F7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isModule
                          ? Icons.place_outlined
                          : Icons.chat_bubble_outline,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              title,
                              style: textTheme.titleSmall?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            _AvailabilityBadge(
                              label: availability,
                              available: channel.available,
                            ),
                          ],
                        ),
                        for (final line in details) ...[
                          const SizedBox(height: 4),
                          Text(
                            line,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: selected ? AppColors.navy : AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Availability is conveyed by text, never colour alone (Principle VI).
class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({required this.label, required this.available});

  final String label;
  final bool available;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: available ? AppColors.turquoise : const Color(0xFFE3E7EC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: available ? Colors.white : AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
