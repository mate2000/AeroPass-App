import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/design/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'consent_view_state.dart';
import 'consent_viewmodel.dart';
import 'widgets/confirmation_checkbox.dart';
import 'widgets/consent_point_tile.dart';
import 'widgets/gate_actions.dart';
import 'widgets/unavailable_message.dart';

/// Composition only (Constitution Principle VIII): no business logic, no
/// repository/service call directly — everything here reads
/// `ConsentViewModel.state` and invokes its `Command`s. `ConsentViewModel`
/// is passed in (constructor injection at the route boundary, per
/// Principle IX), not looked up from a service locator.
///
/// Rendered as a dimmed-overlay sheet over the (still-visible) welcome
/// screen via the route's own `CustomTransitionPage(opaque: false)`
/// (research.md §1) — this widget itself only needs to paint the sheet and
/// the tappable barrier above it, not a full opaque background.
class ConsentView extends StatefulWidget {
  const ConsentView({required this.viewModel, super.key});

  final ConsentViewModel viewModel;

  @override
  State<ConsentView> createState() => _ConsentViewState();
}

class _ConsentViewState extends State<ConsentView> {
  bool _navigatedForward = false;
  bool _navigatedBack = false;

  @override
  void initState() {
    super.initState();
    widget.viewModel.confirm.addListener(_onConfirmChanged);
    widget.viewModel.decline.addListener(_onDeclineChanged);
  }

  @override
  void dispose() {
    widget.viewModel.confirm.removeListener(_onConfirmChanged);
    widget.viewModel.decline.removeListener(_onDeclineChanged);
    super.dispose();
  }

  void _onConfirmChanged() {
    if (_navigatedForward || !widget.viewModel.confirm.completed) return;
    _navigatedForward = true;
    context.push(AppRoutes.documentCapture);
  }

  void _onDeclineChanged() {
    if (_navigatedBack || !widget.viewModel.decline.completed) return;
    _navigatedBack = true;
    final l10n = AppLocalizations.of(context);
    // FR-009: a plain statement that the conventional airport process
    // remains available. Shown via the app-level ScaffoldMessenger
    // (MaterialApp.router provides one above the Navigator), so it
    // persists visibly across the pop back to the welcome screen.
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.consentDeclinedMessage)));
    context.pop();
  }

  void _onDismiss() {
    // research.md §2: back gesture, barrier tap, and system navigation all
    // invoke the SAME decline Command the explicit "Ahora no" button uses
    // — dismissal is never treated as acceptance (FR-010) by construction,
    // not by each call site remembering to route to the same outcome.
    widget.viewModel.decline.run(true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _onDismiss();
      },
      child: Material(
        type: MaterialType.transparency,
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            final l10n = AppLocalizations.of(context);
            return Stack(
              children: [
                Positioned.fill(
                  child: Semantics(
                    label: l10n.consentBarrierDismissLabel,
                    button: true,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _onDismiss,
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    // Absorbs taps so they never fall through to the
                    // barrier detector above.
                    onTap: () {},
                    child: _ConsentSheet(viewModel: widget.viewModel),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The sheet's visual shape (rounded top corners, drag handle, shadow),
/// reusing the same technique 001-bienvenida's `_WelcomeShell` established
/// (research.md §1).
class _ConsentSheet extends StatelessWidget {
  const _ConsentSheet({required this.viewModel});

  final ConsentViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final state = viewModel.state;
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 16,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const _DragHandle(),
              const SizedBox(height: 4),
              Expanded(
                child: switch (state) {
                  ConsentViewLoading() => const _LoadingContent(),
                  ConsentViewUnavailable(:final reason) => _UnavailableContent(
                    reason: reason,
                    onRetry: viewModel.retry,
                  ),
                  ConsentViewReady ready => _ReadyContent(
                    state: ready,
                    viewModel: viewModel,
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _LoadingContent extends StatelessWidget {
  const _LoadingContent();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _UnavailableContent extends StatelessWidget {
  const _UnavailableContent({required this.reason, required this.onRetry});

  final UnavailableReason reason;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: UnavailableMessage(reason: reason, onRetry: onRetry),
      ),
    );
  }
}

class _ReadyContent extends StatelessWidget {
  const _ReadyContent({required this.state, required this.viewModel});

  final ConsentViewReady state;
  final ConsentViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final confirmFailureReason = viewModel.confirmFailureReason;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FR-013/Edge Cases: at large dynamic-type sizes, only the
          // confirmation checkbox and the two actions stay pinned outside
          // scroll (always reachable without hunting for them); the title,
          // subtitle, and full legal content scroll together so the fixed
          // footer never grows tall enough to push the actions off-screen.
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.consentTitle, style: textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(l10n.consentSubtitle, style: textTheme.bodyMedium),
                  if (state.hasPriorRecord) ...[
                    const SizedBox(height: 12),
                    _PriorRecordBanner(message: l10n.consentPriorRecordBanner),
                  ],
                  const SizedBox(height: 8),
                  for (final point in state.text.points)
                    ConsentPointTile(point: point),
                  const SizedBox(height: 8),
                  Text(state.text.rightsStatement, style: textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Text(
                    state.text.optionalityStatement,
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.text.processorDisclosure,
                    style: textTheme.bodySmall,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => context.push(AppRoutes.terms),
                      child: Text(l10n.consentLegalLinksLabel),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),
          ConfirmationCheckbox(
            checked: state.checkboxChecked,
            onChanged: viewModel.toggleCheckbox,
            label: l10n.consentCheckboxLabel,
          ),
          if (confirmFailureReason != null) ...[
            const SizedBox(height: 8),
            UnavailableMessage(reason: confirmFailureReason, compact: true),
          ],
          const SizedBox(height: 12),
          GatePrimaryActionButton(
            command: viewModel.confirm,
            enabled: viewModel.canConfirm,
            label: l10n.consentPrimaryActionLabel,
            disabledHint: l10n.consentPrimaryActionDisabledHint,
          ),
          const SizedBox(height: 8),
          GateSecondaryActionButton(
            command: viewModel.decline,
            label: l10n.consentSecondaryActionLabel,
          ),
        ],
      ),
    );
  }
}

class _PriorRecordBanner extends StatelessWidget {
  const _PriorRecordBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.mintChipBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(message, style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }
}
