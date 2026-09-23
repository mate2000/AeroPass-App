import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/design/app_colors.dart';
import '../../../domain/entities/escalation.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'escalation_viewmodel.dart';
import 'widgets/channel_card.dart';
import 'widgets/module_location_sheet.dart';

/// Screen 10, "Escalar agente" (010-escalar-agente). Composition only
/// (Principle VIII). Amber, never red (FR-002). The checkpoint alternative is
/// stated in every state (FR-008). The back gesture returns to 009, which
/// pushed this screen.
class EscalationView extends StatefulWidget {
  const EscalationView({required this.viewModel, super.key});

  final EscalationViewModel viewModel;

  @override
  State<EscalationView> createState() => _EscalationViewState();
}

class _EscalationViewState extends State<EscalationView> {
  bool _announced = false;

  EscalationViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onChanged());
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    _announceOnce();
    final target = _viewModel.pendingNavigation;
    if (target == null) return;
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;
    _viewModel.consumeNavigation();
    context.go(switch (target) {
      EscalationNavigationTarget.credentialActivated =>
        AppRoutes.credentialActivated,
      EscalationNavigationTarget.documentCapture => AppRoutes.documentCapture,
      EscalationNavigationTarget.livenessCapture => AppRoutes.livenessCapture,
    });
  }

  void _announceOnce() {
    if (_announced || _viewModel.state is! EscalationViewOpen) return;
    _announced = true;
    final l10n = AppLocalizations.of(context);
    SemanticsService.sendAnnouncement(
      View.of(context),
      '${l10n.escalationTitle}. ${_body(l10n)}',
      TextDirection.ltr,
    );
  }

  String _body(AppLocalizations l10n) => switch (_viewModel.arrival) {
    EscalationArrival.byChoice => l10n.escalationBodyByChoice,
    EscalationArrival.afterLimit => l10n.escalationBodyAfterLimit,
  };

  Future<void> _primaryAction(List<AgentChannel> channels) async {
    final channel = _viewModel.onPrimaryAction();
    switch (channel) {
      case AgentChannelKind.module:
        final module = channels.firstWhere(
          (c) => c.kind == AgentChannelKind.module,
        );
        await ModuleLocationSheet.show(context, module);
      case AgentChannelKind.chat:
        await context.push(AppRoutes.agentChat);
      case null:
        return;
    }
    if (mounted) _onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            final state = _viewModel.state;
            return Column(
              children: [
                Container(
                  color: AppColors.surface,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.navy,
                    ),
                    onPressed: () => context.push(AppRoutes.help),
                    child: Text(l10n.escalationHelp),
                  ),
                ),
                Expanded(
                  child: switch (state) {
                    EscalationViewLoading() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    EscalationViewOpen(:final channels) => _OpenBody(
                      title: l10n.escalationTitle,
                      body: _body(l10n),
                      channels: channels,
                      selected: _viewModel.selectedChannel,
                      onSelect: _viewModel.select,
                    ),
                    EscalationViewDeclined() => _MessageBody(
                      title: l10n.escalationDeclinedTitle,
                      body: l10n.escalationDeclinedBody,
                    ),
                    EscalationViewExpired() => _MessageBody(
                      title: l10n.escalationExpiredTitle,
                      body: l10n.escalationExpiredBody,
                    ),
                    EscalationViewUnavailable() => _MessageBody(
                      title: l10n.escalationUnavailableTitle,
                      body: l10n.escalationUnavailableBody,
                    ),
                  },
                ),
                if (state is! EscalationViewLoading)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    child: Column(
                      children: [
                        ..._primaryButtons(l10n, state),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              minimumSize: const Size.fromHeight(48),
                            ),
                            onPressed: () => context.go(AppRoutes.welcome),
                            child: Text(l10n.escalationHomeAction),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _primaryButtons(
    AppLocalizations l10n,
    EscalationViewState state,
  ) {
    Widget primary(String label, VoidCallback onPressed) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.navy,
            minimumSize: const Size.fromHeight(56),
          ),
          onPressed: onPressed,
          child: Text(label),
        ),
      ),
    );

    return switch (state) {
      EscalationViewOpen(:final channels) =>
        switch (_viewModel.selectedChannel) {
          AgentChannelKind.module => [
            primary(
              l10n.escalationDirectionsAction,
              () => _primaryAction(channels),
            ),
          ],
          AgentChannelKind.chat => [
            primary(
              l10n.escalationStartChatAction,
              () => _primaryAction(channels),
            ),
          ],
          null => const [],
        },
      EscalationViewExpired() => [
        primary(l10n.escalationReopenAction, _viewModel.reopen),
      ],
      EscalationViewUnavailable() => [
        primary(l10n.escalationRetryAction, _viewModel.reopen),
      ],
      _ => const [],
    };
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        ExcludeSemantics(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.amberTile,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.amber,
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          body,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _CheckpointLine extends StatelessWidget {
  const _CheckpointLine();

  @override
  Widget build(BuildContext context) {
    return Text(
      AppLocalizations.of(context).escalationCheckpointLine,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall
          ?.copyWith(color: AppColors.textSecondary),
    );
  }
}

class _OpenBody extends StatelessWidget {
  const _OpenBody({
    required this.title,
    required this.body,
    required this.channels,
    required this.selected,
    required this.onSelect,
  });

  final String title;
  final String body;
  final List<AgentChannel> channels;
  final AgentChannelKind? selected;
  final void Function(AgentChannelKind) onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ordered = [
      ...channels.where((c) => c.kind == AgentChannelKind.module),
      ...channels.where((c) => c.kind == AgentChannelKind.chat),
    ];
    final anyOpen = channels.any((c) => c.available);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        children: [
          _Header(title: title, body: body),
          const SizedBox(height: 24),
          for (final channel in ordered) ...[
            ChannelCard(
              channel: channel,
              selected: selected == channel.kind,
              onSelect: () => onSelect(channel.kind),
            ),
            const SizedBox(height: 12),
          ],
          if (!anyOpen) ...[
            Text(
              l10n.escalationNoChannelOpen,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
          ],
          const _CheckpointLine(),
        ],
      ),
    );
  }
}

class _MessageBody extends StatelessWidget {
  const _MessageBody({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        children: [
          _Header(title: title, body: body),
          const SizedBox(height: 16),
          const _CheckpointLine(),
        ],
      ),
    );
  }
}
