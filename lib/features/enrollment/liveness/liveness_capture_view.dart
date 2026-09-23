import 'package:camera/camera.dart' show CameraPreview;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/design/step_indicator.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'liveness_capture_view_state.dart';
import 'liveness_capture_viewmodel.dart';
import 'widgets/liveness_failure_message.dart';
import 'widgets/liveness_instruction_banner.dart';
import 'widgets/liveness_oval_overlay.dart';
import 'widgets/phase_indicator.dart';

/// Composition only (Constitution Principle VIII): no business logic, no
/// repository/service call directly — everything here reads
/// `LivenessCaptureViewModel.state` and invokes its `Command`s.
/// `LivenessCaptureViewModel` is passed in (constructor injection at the
/// route boundary, per Principle IX), not looked up from a service
/// locator.
///
/// A full-screen dark front-camera preview with an oval framing guide, a
/// dynamic instruction, a phase indicator, and a progress badge — no
/// shutter control anywhere (FR-003), and every touch on the capture
/// surface is absorbed rather than acted on (FR-018).
class LivenessCaptureView extends StatefulWidget {
  const LivenessCaptureView({required this.viewModel, super.key});

  final LivenessCaptureViewModel viewModel;

  @override
  State<LivenessCaptureView> createState() => _LivenessCaptureViewState();
}

class _LivenessCaptureViewState extends State<LivenessCaptureView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // research.md §9: stop-and-discard on background/lock/interruption,
    // mirroring 003's CaptureView exactly.
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        widget.viewModel.onAppBackgrounded();
      case AppLifecycleState.resumed:
        widget.viewModel.onAppResumed();
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _onViewModelChanged() {
    final target = widget.viewModel.pendingNavigation;
    if (target == null) return;
    widget.viewModel.consumeNavigation();
    switch (target) {
      case LivenessNavigationTarget.documentCapture:
        context.go(AppRoutes.documentCapture);
      case LivenessNavigationTarget.verificationProgress:
        context.push(AppRoutes.verificationProgress);
      case LivenessNavigationTarget.retryGuidance:
        context.push(AppRoutes.retryGuidance);
    }
  }

  void _onBack() {
    // FR-015: `onBackNavigation` is emitted exactly once, from
    // `PopScope.onPopInvokedWithResult` below — mirrors 003/004/005's
    // identical pattern.
    context.pop();
  }

  void _onHelp() {
    context.push(AppRoutes.help);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) widget.viewModel.onBackNavigation();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            return SafeArea(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _CameraLayer(viewModel: widget.viewModel),
                  ),
                  Column(
                    children: [
                      _TopBar(onBack: _onBack, onHelp: _onHelp),
                      const SizedBox(height: 8),
                      const StepIndicator(
                        currentStep: EnrollmentProgressStep.selfie,
                      ),
                      Expanded(
                        child: _CaptureBody(viewModel: widget.viewModel),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CameraLayer extends StatelessWidget {
  const _CameraLayer({required this.viewModel});

  final LivenessCaptureViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final controller = viewModel.cameraController;
    if (controller == null || !controller.value.isInitialized) {
      // Also covers every test/fake environment — real camera preview
      // rendering needs a physical device/emulator (mirrors 003's
      // CaptureView precedent).
      return const ColoredBox(color: Colors.black);
    }
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.previewSize?.height ?? 1,
        height: controller.value.previewSize?.width ?? 1,
        child: CameraPreview(controller),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack, required this.onHelp});

  final VoidCallback onBack;
  final VoidCallback onHelp;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            label: Text(
              l10n.captureTopBarBackLabel,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: onHelp,
            child: Text(
              l10n.captureTopBarHelpLabel,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// Touch input anywhere on this body has no effect (FR-018) — there is
/// simply no `GestureDetector`/`InkWell` wired to any capture action
/// anywhere in this subtree; the footer states this explicitly for the
/// passenger.
class _CaptureBody extends StatelessWidget {
  const _CaptureBody({required this.viewModel});

  final LivenessCaptureViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final state = viewModel.state;
    return switch (state) {
      LivenessCaptureViewLoading() => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
      LivenessCaptureViewRunning(:final phase, :final progress) => _RunningBody(
        phase: phase,
        progress: progress,
      ),
      LivenessCaptureViewOutcome(:final outcome, :final limitReached) =>
        _OutcomeBody(
          viewModel: viewModel,
          outcome: outcome,
          limitReached: limitReached,
        ),
      LivenessCaptureViewStalled() => _StalledBody(viewModel: viewModel),
    };
  }
}

class _RunningBody extends StatelessWidget {
  const _RunningBody({required this.phase, required this.progress});

  final LivenessPhase phase;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Semantics(
              label: l10n.livenessProgressBadge((progress * 100).round()),
              child: ExcludeSemantics(
                child: Text(
                  l10n.livenessProgressBadge((progress * 100).round()),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        LivenessInstructionBanner(instruction: phase.instruction),
        const SizedBox(height: 16),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: LivenessOvalOverlay(progress: progress),
            ),
          ),
        ),
        const SizedBox(height: 16),
        PhaseIndicator(
          currentIndex: phase.index,
          totalPhases: phase.totalPhases,
        ),
        const SizedBox(height: 16),
        Text(
          l10n.livenessFooter,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _OutcomeBody extends StatelessWidget {
  const _OutcomeBody({
    required this.viewModel,
    required this.outcome,
    required this.limitReached,
  });

  final LivenessCaptureViewModel viewModel;
  final LivenessOutcome outcome;
  final bool limitReached;

  @override
  Widget build(BuildContext context) {
    // A success outcome always sets `pendingNavigation` in the same
    // ViewModel update that produces this state, so the view never
    // actually renders this branch for `.success()` — `_onViewModelChanged`
    // navigates away first. Defensive: never leaves the passenger on a
    // frozen surface (US2 Acceptance Scenario 5) even if that ordering
    // were ever violated.
    if (outcome is LivenessOutcomeSuccess) {
      return const SizedBox.shrink();
    }
    // A limit-reached failure also always sets `pendingNavigation`
    // (to retry guidance); the retry affordance below is only ever shown
    // below the limit.
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LivenessFailureMessage(outcome: outcome),
            if (!limitReached) ...[
              const SizedBox(height: 16),
              ListenableBuilder(
                listenable: viewModel.retry,
                builder: (context, _) => FilledButton(
                  onPressed: viewModel.retry.running
                      ? null
                      : () => viewModel.retry.run(),
                  child: Text(
                    AppLocalizations.of(context).livenessFailureRetryLabel,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StalledBody extends StatelessWidget {
  const _StalledBody({required this.viewModel});

  final LivenessCaptureViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.livenessStalledHeadline,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.livenessStalledBody,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ListenableBuilder(
              listenable: viewModel.retry,
              builder: (context, _) => FilledButton(
                onPressed: viewModel.retry.running
                    ? null
                    : () => viewModel.retry.run(),
                child: Text(l10n.livenessStalledRetryLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
