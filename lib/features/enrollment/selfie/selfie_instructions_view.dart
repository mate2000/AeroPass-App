import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/design/step_indicator.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'selfie_instructions_viewmodel.dart';
import 'widgets/capture_conditions_list.dart';
import 'widgets/selfie_frame_preview.dart';

/// Composition only (Constitution Principle VIII): no business logic, no
/// repository/service call directly — everything here reads
/// `SelfieInstructionsViewModel.advance`'s state and invokes it.
/// `SelfieInstructionsViewModel` is passed in (constructor injection at the
/// route boundary, per Principle IX), not looked up from a service locator.
class SelfieInstructionsView extends StatefulWidget {
  const SelfieInstructionsView({required this.viewModel, super.key});

  final SelfieInstructionsViewModel viewModel;

  @override
  State<SelfieInstructionsView> createState() => _SelfieInstructionsViewState();
}

class _SelfieInstructionsViewState extends State<SelfieInstructionsView> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    widget.viewModel.advance.addListener(_onAdvanceChanged);
  }

  @override
  void dispose() {
    widget.viewModel.advance.removeListener(_onAdvanceChanged);
    super.dispose();
  }

  void _onAdvanceChanged() {
    // research.md §5: this screen has exactly one destination for its one
    // action, so the Command-completion-listener pattern (mirroring
    // ConsentView._onConfirmChanged) is the right level of mechanism —
    // no pendingNavigation enum for a choice that doesn't exist.
    if (_navigated || !widget.viewModel.advance.completed) return;
    _navigated = true;
    context.push(AppRoutes.livenessCapture);
  }

  void _onHelp() {
    widget.viewModel.onHelpOpened();
    context.push(AppRoutes.help);
  }

  void _onBack() {
    // FR-008: `onBackNavigation` is emitted exactly once, from
    // `PopScope.onPopInvokedWithResult` below — mirrors
    // 003/004's `_onBack` pattern exactly.
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) widget.viewModel.onBackNavigation();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(onBack: _onBack, onHelp: _onHelp),
              const SizedBox(height: 8),
              const StepIndicator(currentStep: EnrollmentProgressStep.selfie),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      const SelfieFramePreview(),
                      const SizedBox(height: 24),
                      Text(
                        l10n.selfieInstructionsTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.selfieInstructionsSubtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: CaptureConditionsList(),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: ListenableBuilder(
                  listenable: widget.viewModel.advance,
                  builder: (context, _) {
                    final running = widget.viewModel.advance.running;
                    return SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: running
                            ? null
                            : () => widget.viewModel.advance.run(),
                        child: running
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(l10n.selfieInstructionsPrimaryActionLabel),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
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
            icon: const Icon(Icons.chevron_left),
            label: Text(l10n.captureTopBarBackLabel),
          ),
          TextButton(
            onPressed: onHelp,
            child: Text(l10n.captureTopBarHelpLabel),
          ),
        ],
      ),
    );
  }
}
