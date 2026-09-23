import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../app/router.dart';
import '../../../core/design/app_colors.dart';
import '../../../domain/entities/service_failure.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'technical_error_viewmodel.dart';
import 'widgets/service_status_card.dart';

/// Screen 11, "Error técnico" (011-error-tecnico). Composition only
/// (Principle VIII). Neutral slate, never amber or red (FR-001). There is no
/// back control, and the back gesture is blocked, so the passenger leaves by
/// "Reintentar", "Salir" or the agent path. The checkpoint alternative is
/// always stated (constitution contingency budget).
class TechnicalErrorView extends StatefulWidget {
  const TechnicalErrorView({required this.viewModel, super.key});

  final TechnicalErrorViewModel viewModel;

  @override
  State<TechnicalErrorView> createState() => _TechnicalErrorViewState();
}

class _TechnicalErrorViewState extends State<TechnicalErrorView> {
  static final _timeFormat = DateFormat('H:mm', 'es');

  TechnicalErrorViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _announce());
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    super.dispose();
  }

  void _announce() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final (title, subtitle) = _heading(l10n);
    SemanticsService.sendAnnouncement(
      View.of(context),
      '$title. $subtitle',
      TextDirection.ltr,
    );
  }

  void _onChanged() {
    if (!mounted) return;
    final target = _viewModel.pendingNavigation;
    if (target == null) return;
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;
    _viewModel.consumeNavigation();
    context.go(switch (target) {
      TechnicalErrorTarget.verification => AppRoutes.verificationProgress,
      TechnicalErrorTarget.selfie => AppRoutes.livenessCapture,
      TechnicalErrorTarget.welcome => AppRoutes.welcome,
    });
  }

  (String, String) _heading(AppLocalizations l10n) =>
      switch (_viewModel.failureClass) {
        ServiceFailureClass.service => (
          l10n.technicalErrorServiceTitle,
          l10n.technicalErrorServiceSubtitle,
        ),
        ServiceFailureClass.connectivity => (
          l10n.technicalErrorConnectivityTitle,
          l10n.technicalErrorConnectivitySubtitle,
        ),
        ServiceFailureClass.undetermined => (
          l10n.technicalErrorUndeterminedTitle,
          l10n.technicalErrorUndeterminedSubtitle,
        ),
      };

  /// FR-006, FR-008, FR-009: only statements something backs.
  List<String> _guidance(AppLocalizations l10n) {
    final retryAfter = _viewModel.retryAfter;
    return [
      if (_viewModel.failureClass == ServiceFailureClass.connectivity)
        l10n.technicalErrorConnectivityGuidance,
      if (_viewModel.showNotificationClaim) l10n.technicalErrorNotified,
      if (retryAfter != null)
        l10n.technicalErrorRetryAt(_timeFormat.format(retryAfter.toLocal())),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F5F7),
        body: SafeArea(
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              final (title, subtitle) = _heading(l10n);
              final guidance = _guidance(l10n);
              final status = _viewModel.status;
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
                      child: Text(l10n.technicalErrorHelp),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                      child: Column(
                        children: [
                          ExcludeSemantics(
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: AppColors.slateTile,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.home_repair_service_outlined,
                                color: AppColors.slate,
                                size: 34,
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
                            subtitle,
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (guidance.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              guidance.join(' '),
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                          if (status != null) ...[
                            const SizedBox(height: 24),
                            ServiceStatusCard(status: status),
                          ],
                          const SizedBox(height: 16),
                          _PreservationTile(
                            showPreservation: _viewModel.showPreservation,
                            needsNewSelfie: _viewModel.needsNewSelfie,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.technicalErrorCheckpointLine,
                            textAlign: TextAlign.center,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: _RetryButton(viewModel: _viewModel),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.textPrimary,
                                  minimumSize: const Size.fromHeight(48),
                                ),
                                onPressed: _viewModel.exit,
                                child: Text(l10n.technicalErrorExit),
                              ),
                            ),
                            Expanded(
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.navy,
                                  minimumSize: const Size.fromHeight(48),
                                ),
                                onPressed: () =>
                                    context.push(AppRoutes.agentEscalation),
                                child: Text(
                                  l10n.technicalErrorAgent,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
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
}

/// What was kept, stated exactly (FR-003, FR-004), and for how long
/// (FR-012). Without a confirmed identity record there is nothing true to
/// say was kept, so only the window is stated.
class _PreservationTile extends StatelessWidget {
  const _PreservationTile({
    required this.showPreservation,
    required this.needsNewSelfie,
  });

  final bool showPreservation;
  final bool needsNewSelfie;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lines = [
      if (showPreservation)
        needsNewSelfie
            ? l10n.technicalErrorPreservedNewSelfie
            : l10n.technicalErrorPreservedRecheck,
      l10n.technicalErrorResumeWindow,
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F7F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ExcludeSemantics(
            child: Icon(
              Icons.info_outline,
              color: AppColors.turquoise,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              lines.join(' '),
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: const Color(0xFF0E6B60)),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Reintentar", held with a visible and announced countdown (FR-008).
class _RetryButton extends StatelessWidget {
  const _RetryButton({required this.viewModel});

  final TechnicalErrorViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final held = viewModel.retryHeld;
    final seconds = viewModel.retryRemainingSeconds;
    final button = FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.navy,
        minimumSize: const Size.fromHeight(56),
      ),
      onPressed: held ? null : viewModel.retry,
      child: Text(
        held ? l10n.technicalErrorRetryIn(seconds) : l10n.technicalErrorRetry,
      ),
    );
    if (!held) return button;
    return Semantics(
      label: l10n.technicalErrorRetryHeldSemantics(seconds),
      excludeSemantics: true,
      button: true,
      enabled: false,
      child: button,
    );
  }
}
