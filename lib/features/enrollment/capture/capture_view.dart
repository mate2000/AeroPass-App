import 'package:camera/camera.dart' show CameraPreview;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/design/step_indicator.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'capture_view_state.dart';
import 'capture_viewmodel.dart';
import 'widgets/capture_button.dart';
import 'widgets/inline_error_message.dart';
import 'widgets/permission_denied_message.dart';
import 'widgets/torch_toggle.dart';
import 'widgets/viewfinder_overlay.dart';

/// Composition only (Constitution Principle VIII): no business logic, no
/// repository/service call directly — everything here reads
/// `CaptureViewModel.state` and invokes its `Command`s. `CaptureViewModel`
/// is passed in (constructor injection at the route boundary, per
/// Principle IX), not looked up from a service locator.
///
/// A full-screen dark camera preview with a framing guide, torch and
/// capture controls, and an inline error variant — all one screen/state
/// machine, per spec.md's UI Reference ("That variant is specified here as
/// part of the same feature... rather than as a separate screen").
class CaptureView extends StatefulWidget {
  const CaptureView({required this.viewModel, super.key});

  final CaptureViewModel viewModel;

  @override
  State<CaptureView> createState() => _CaptureViewState();
}

class _CaptureViewState extends State<CaptureView> with WidgetsBindingObserver {
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
    // research.md §5: stop-and-reinit on background/lock/interruption —
    // never resumed with a stale/frozen frame.
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
      case CaptureNavigationTarget.consentGate:
        context.go(AppRoutes.consent);
      case CaptureNavigationTarget.dataConfirmation:
        context.push(AppRoutes.documentConfirmation);
      case CaptureNavigationTarget.retryGuidance:
        context.push(AppRoutes.retryGuidance);
    }
  }

  void _onBack() {
    // FR-012: `onBackNavigation` is emitted exactly once, from
    // `PopScope.onPopInvokedWithResult` below — the single path both the
    // "Atrás" button (via this `context.pop()`) and the system back
    // gesture funnel through, so it's never double-counted.
    context.pop();
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
                  Positioned.fill(child: _CameraLayer(viewModel: widget.viewModel)),
                  Column(
                    children: [
                      _TopBar(onBack: _onBack),
                      const SizedBox(height: 8),
                      const StepIndicator(
                        currentStep: EnrollmentProgressStep.document,
                      ),
                      Expanded(
                        child: _CaptureBody(
                          viewModel: widget.viewModel,
                        ),
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

  final CaptureViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final controller = viewModel.cameraController;
    if (controller == null || !controller.value.isInitialized) {
      // Also covers every test/fake environment (T051/T052 note: real
      // camera preview rendering needs a physical device/emulator).
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
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

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
            onPressed: () => context.push(AppRoutes.help),
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

class _CaptureBody extends StatelessWidget {
  const _CaptureBody({required this.viewModel});

  final CaptureViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final state = viewModel.state;
    return switch (state) {
      CaptureViewChecking() => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
      CaptureViewPermissionDenied(:final permanent) => PermissionDeniedMessage(
        permanent: permanent,
        retryCommand: viewModel.retryPermission,
        openSettingsCommand: viewModel.openSystemSettings,
      ),
      CaptureViewReady(
        lastRejectionReason: final rejectionReason,
        offline: final offline,
      ) =>
        _ReadyBody(
          viewModel: viewModel,
          rejectionReason: rejectionReason,
          offline: offline,
        ),
    };
  }
}

class _ReadyBody extends StatelessWidget {
  const _ReadyBody({
    required this.viewModel,
    required this.rejectionReason,
    required this.offline,
  });

  final CaptureViewModel viewModel;
  final CaptureRejectionReason? rejectionReason;
  final bool offline;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasError = rejectionReason != null;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            l10n.captureInstruction,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ViewfinderOverlay(hasError: hasError),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.captureHint,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 12),
        if (rejectionReason != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: InlineErrorMessage(reason: rejectionReason!),
          ),
        if (offline)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _OfflineBanner(viewModel: viewModel),
          ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TorchToggle(
              command: viewModel.toggleTorch,
              torchOn: viewModel.torchOn,
            ),
            CaptureButton(command: viewModel.capture),
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.captureCaption,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.viewModel});

  final CaptureViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.captureOfflineHeadline,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.captureOfflineBody,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            ListenableBuilder(
              listenable: viewModel.capture,
              builder: (context, _) => TextButton(
                onPressed: viewModel.capture.running
                    ? null
                    : () => viewModel.capture.run(),
                child: Text(l10n.captureOfflineRetryLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
