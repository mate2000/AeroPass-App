import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/generated/app_localizations.dart';
import 'withdrawal_viewmodel.dart';

/// A minimal, two-action entry point for withdrawing consent (FR-015: no
/// more than two actions from the account surface — this route itself is
/// the second, reached from wherever the account surface's own entry point
/// pushes it). The polished account surface this eventually lives inside
/// is out of scope (spec.md Out of Scope).
class WithdrawalPlaceholderView extends StatelessWidget {
  const WithdrawalPlaceholderView({required this.viewModel, super.key});

  final WithdrawalViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.withdrawalTitle)),
      body: ListenableBuilder(
        listenable: Listenable.merge([viewModel, viewModel.withdraw]),
        builder: (context, _) {
          if (viewModel.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (viewModel.withdraw.completed) ...[
                  Text(
                    l10n.withdrawalSuccessMessage,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ] else if (!viewModel.hasRecord) ...[
                  Text(
                    l10n.withdrawalNoRecordMessage,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ] else ...[
                  Text(
                    l10n.withdrawalDescription,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: viewModel.withdraw.running
                          ? null
                          : () => viewModel.withdraw.run(),
                      child: viewModel.withdraw.running
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.withdrawalConfirmActionLabel),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      child: Text(l10n.withdrawalCancelActionLabel),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
