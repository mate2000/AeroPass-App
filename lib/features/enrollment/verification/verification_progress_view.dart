import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/design/step_indicator.dart';
import '../../../domain/entities/verification_stage.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'verification_progress_viewmodel.dart';
import 'widgets/slow_notice.dart';
import 'widgets/verification_checklist.dart';
import 'widgets/verification_illustration.dart';

/// Screen 07, "Validando" (007-validando). Composition only (Constitution
/// Principle VIII): everything here reads [VerificationProgressViewModel]
/// and invokes it.
///
/// No back or help control during a normal wait, as in the reference; the
/// back gesture does nothing (FR-017). Help appears only with the 10-second
/// notice (FR-018). Every stage change, the notice and the outcome are
/// announced, since this screen's content is entirely state (FR-014).
class VerificationProgressView extends StatefulWidget {
  const VerificationProgressView({required this.viewModel, super.key});

  final VerificationProgressViewModel viewModel;

  @override
  State<VerificationProgressView> createState() =>
      _VerificationProgressViewState();
}

class _VerificationProgressViewState extends State<VerificationProgressView>
    with WidgetsBindingObserver {
  late Map<VerificationStage, StageStatus> _announcedStages;
  bool _announcedNotice = false;
  bool _announcedFailure = false;

  VerificationProgressViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _announcedStages = Map.of(_stagesOf(_viewModel.state));
    WidgetsBinding.instance.addObserver(this);
    _viewModel.addListener(_onViewModelChanged);
    // The outcome may already be known before the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => _onViewModelChanged());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Research.md §5: backgrounding never cancels the job; on return the
    // view model re-checks elapsed time and polls at once.
    if (state == AppLifecycleState.resumed) {
      unawaited(_viewModel.onAppResumed());
    }
  }

  static Map<VerificationStage, StageStatus> _stagesOf(
    VerificationProgressViewState state,
  ) => switch (state) {
    VerificationWaiting(:final stages) => stages,
    VerificationFailed(:final stages) => stages,
  };

  void _onViewModelChanged() {
    if (!mounted) return;
    _announceChanges();
    _followNavigation();
  }

  void _announceChanges() {
    final l10n = AppLocalizations.of(context);
    final state = _viewModel.state;
    final stages = _stagesOf(state);
    for (final stage in VerificationStage.values) {
      final status = stages[stage]!;
      if (status == _announcedStages[stage]) continue;
      _announcedStages[stage] = status;
      if (status == StageStatus.running || status == StageStatus.passed) {
        _announce(stageLabel(l10n, stage, status));
      }
    }
    switch (state) {
      case VerificationWaiting(:final slowNoticeVisible):
        if (slowNoticeVisible && !_announcedNotice) {
          _announcedNotice = true;
          _announce(l10n.verificationSlowNotice);
        }
      case VerificationFailed():
        // FR-012/FR-013: one generic line, whatever the failure class.
        if (!_announcedFailure) {
          _announcedFailure = true;
          _announce(l10n.verificationFailureLine);
        }
    }
  }

  void _announce(String message) {
    SemanticsService.sendAnnouncement(
      View.of(context),
      message,
      TextDirection.ltr,
    );
  }

  /// Research.md §6: act on the one-shot target only while this route is the
  /// current one, so an outcome that arrives while help is open waits until
  /// help closes.
  void _followNavigation() {
    final target = _viewModel.pendingNavigation;
    if (target == null) return;
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;
    _viewModel.consumeNavigation();
    context.go(switch (target) {
      VerificationNavigationTarget.credentialActivated =>
        AppRoutes.credentialActivated,
      VerificationNavigationTarget.credentialNotActive =>
        AppRoutes.credentialNotActive,
      VerificationNavigationTarget.documentCapture => AppRoutes.documentCapture,
      VerificationNavigationTarget.retryGuidance => AppRoutes.retryGuidance,
      VerificationNavigationTarget.technicalError => AppRoutes.technicalError,
    });
  }

  Future<void> _openHelp() async {
    _viewModel.onHelpOpened();
    await context.push(AppRoutes.help);
    if (mounted) _followNavigation();
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
              final state = _viewModel.state;
              final stages = _stagesOf(state);
              final passed = stages.values
                  .where((s) => s == StageStatus.passed)
                  .length;
              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: AppColors.surface,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Column(
                      children: [
                        Semantics(
                          header: true,
                          child: Text(
                            l10n.verificationHeader,
                            style: textTheme.titleMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const StepIndicator(
                          currentStep: EnrollmentProgressStep.done,
                          currentStepReached: false,
                          onLightSurface: true,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                      child: Column(
                        children: [
                          VerificationIllustration(passedStages: passed),
                          const SizedBox(height: 32),
                          Text(
                            l10n.verificationTitle,
                            textAlign: TextAlign.center,
                            style: textTheme.headlineSmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.verificationSubtitle,
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),
                          VerificationChecklist(stages: stages),
                          if (state is VerificationFailed) ...[
                            const SizedBox(height: 16),
                            Text(
                              l10n.verificationFailureLine,
                              textAlign: TextAlign.center,
                              style: textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  // Pinned below the scroll area so its actions are always
                  // visible without scrolling (FR-018).
                  if (state case VerificationWaiting(slowNoticeVisible: true))
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: SlowNotice(
                        onKeepWaiting: _viewModel.dismissSlowNotice,
                        onHelp: _openHelp,
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
