import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/design/app_colors.dart';
import '../../../domain/entities/retry_guidance_state.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'retry_guidance_viewmodel.dart';
import 'widgets/advice_card.dart';

/// Screen 09, "Reintento" (009-reintento). Composition only (Constitution
/// Principle VIII). Three states, all derived by [RetryGuidanceViewModel]
/// (contracts/retry-guidance-screen.md):
///
/// - `selfieRetry`: generic failure, selfie advice, "Intentar de nuevo" and
///   "Hablar con un agente".
/// - `selfieLimit` / `documentLimit`: the limit explained for that capture,
///   the checkpoint alternative, and "Hablar con un agente" only.
///
/// Amber, never red (FR-002). No attempt count anywhere (FR-008). No back
/// control, and the back gesture does nothing (FR-018).
class RetryGuidanceView extends StatefulWidget {
  const RetryGuidanceView({required this.viewModel, super.key});

  final RetryGuidanceViewModel viewModel;

  @override
  State<RetryGuidanceView> createState() => _RetryGuidanceViewState();
}

class _RetryGuidanceViewState extends State<RetryGuidanceView> {
  static const double _iconTile = 72;
  bool _announced = false;

  RetryGuidanceViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_announceOnce);
    WidgetsBinding.instance.addPostFrameCallback((_) => _announceOnce());
  }

  @override
  void dispose() {
    _viewModel.removeListener(_announceOnce);
    super.dispose();
  }

  /// SC-009: the title and body are announced without interaction.
  void _announceOnce() {
    if (!mounted || _announced) return;
    final state = _viewModel.state;
    if (state == null) return;
    _announced = true;
    final copy = _copyFor(AppLocalizations.of(context), state);
    SemanticsService.sendAnnouncement(
      View.of(context),
      '${copy.title}. ${copy.body}',
      TextDirection.ltr,
    );
  }

  void _retry() {
    _viewModel.onRetry();
    // Clarifications: straight to the selfie camera, not the instructions.
    context.go(AppRoutes.livenessCapture);
  }

  void _talkToAgent() {
    _viewModel.onAgentRoute();
    // `push` keeps this screen underneath, so the session and the retry are
    // still there if the passenger comes back (FR-011).
    context.push(AppRoutes.agentEscalation);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
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
                      child: Text(l10n.retryGuidanceHelp),
                    ),
                  ),
                  Expanded(
                    child: state == null
                        ? const Center(child: CircularProgressIndicator())
                        : _Body(state: state, iconTile: _iconTile),
                  ),
                  if (state != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                      child: Column(
                        children: [
                          if (_viewModel.canRetry) ...[
                            _PrimaryButton(
                              label: l10n.retryAction,
                              onPressed: _retry,
                            ),
                            const SizedBox(height: 12),
                            _SecondaryButton(
                              label: l10n.retryAgentAction,
                              onPressed: _talkToAgent,
                            ),
                          ] else
                            _PrimaryButton(
                              label: l10n.retryAgentAction,
                              onPressed: _talkToAgent,
                            ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  static ({String title, String body}) _copyFor(
    AppLocalizations l10n,
    RetryGuidanceState state,
  ) => switch (state) {
    RetryGuidanceState.selfieRetry => (
      title: l10n.retrySelfieTitle,
      body: l10n.retrySelfieBody,
    ),
    RetryGuidanceState.selfieLimit => (
      title: l10n.retrySelfieLimitTitle,
      body: l10n.retrySelfieLimitBody,
    ),
    RetryGuidanceState.documentLimit => (
      title: l10n.retryDocumentLimitTitle,
      body: l10n.retryDocumentLimitBody,
    ),
  };
}

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.iconTile});

  final RetryGuidanceState state;
  final double iconTile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final copy = _RetryGuidanceViewState._copyFor(l10n, state);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        children: [
          Semantics(
            label: l10n.retryGuidanceIconSemantics,
            excludeSemantics: true,
            child: Container(
              width: iconTile,
              height: iconTile,
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
              copy.title,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            copy.body,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (state == RetryGuidanceState.selfieRetry) ...[
            const SizedBox(height: 24),
            AdviceCard(
              heading: l10n.retryAdviceHeading,
              tips: [
                AdviceTip(
                  icon: Icons.lightbulb_outline,
                  text: l10n.retryTipLighting,
                ),
                AdviceTip(
                  icon: Icons.face_retouching_natural,
                  text: l10n.retryTipFaceVisible,
                ),
                AdviceTip(
                  icon: Icons.phone_iphone,
                  text: l10n.retryTipHoldStill,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.navy,
          minimumSize: const Size.fromHeight(56),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy,
          side: const BorderSide(color: AppColors.navy),
          minimumSize: const Size.fromHeight(56),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
