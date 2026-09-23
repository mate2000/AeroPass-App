import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/command.dart';
import '../../../core/design/step_indicator.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'document_confirmation_view_state.dart';
import 'document_confirmation_viewmodel.dart';
import 'widgets/document_thumbnail_card.dart';
import 'widgets/expired_document_message.dart';
import 'widgets/field_row.dart';
import 'widgets/missing_field_notice.dart';

/// Composition only (Constitution Principle VIII): no business logic, no
/// repository/service call directly — everything here reads
/// `DocumentConfirmationViewModel.state` and invokes its `Command`s.
/// `DocumentConfirmationViewModel` is passed in (constructor injection at
/// the route boundary, per Principle IX), not looked up from a service
/// locator.
class DocumentConfirmationView extends StatefulWidget {
  const DocumentConfirmationView({required this.viewModel, super.key});

  final DocumentConfirmationViewModel viewModel;

  @override
  State<DocumentConfirmationView> createState() =>
      _DocumentConfirmationViewState();
}

class _DocumentConfirmationViewState extends State<DocumentConfirmationView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    final target = widget.viewModel.pendingNavigation;
    if (target == null) return;
    widget.viewModel.consumeNavigation();
    switch (target) {
      case DocumentConfirmationNavigationTarget.documentCapture:
        context.go(AppRoutes.documentCapture);
      case DocumentConfirmationNavigationTarget.selfieInstructions:
        context.push(AppRoutes.selfieInstructions);
    }
  }

  void _onBack() {
    // FR-013: `onBackNavigation` is emitted exactly once, from
    // `PopScope.onPopInvokedWithResult` below — the single path both the
    // "Atrás" button (via this `context.pop()`) and the system back
    // gesture funnel through, so it's never double-counted (mirrors
    // 003-escanear-documento's `CaptureView._onBack`).
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
        body: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            return SafeArea(
              child: Column(
                children: [
                  _TopBar(onBack: _onBack),
                  const SizedBox(height: 8),
                  const StepIndicator(
                    currentStep: EnrollmentProgressStep.document,
                  ),
                  Expanded(child: _Body(viewModel: widget.viewModel)),
                ],
              ),
            );
          },
        ),
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
            icon: const Icon(Icons.chevron_left),
            label: Text(l10n.captureTopBarBackLabel),
          ),
          TextButton(
            onPressed: () => context.push(AppRoutes.help),
            child: Text(l10n.captureTopBarHelpLabel),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.viewModel});

  final DocumentConfirmationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final state = viewModel.state;
    return switch (state) {
      DocumentConfirmationViewLoading() => const Center(
        child: CircularProgressIndicator(),
      ),
      DocumentConfirmationViewBlocked(:final reason) => _BlockedBody(
        reason: reason,
        rescanCommand: viewModel.rescan,
      ),
      DocumentConfirmationViewReady ready => _ReadyBody(
        state: ready,
        viewModel: viewModel,
      ),
    };
  }
}

class _BlockedBody extends StatelessWidget {
  const _BlockedBody({required this.reason, required this.rescanCommand});

  final DocumentBlockReason reason;
  final Command0<void> rescanCommand;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            switch (reason) {
              DocumentBlockReason.expired => const ExpiredDocumentMessage(),
              DocumentBlockReason.missingRequiredField =>
                const MissingFieldNotice(),
            },
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => rescanCommand.run(),
                child: Text(l10n.confirmationSecondaryActionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadyBody extends StatelessWidget {
  const _ReadyBody({required this.state, required this.viewModel});

  final DocumentConfirmationViewReady state;
  final DocumentConfirmationViewModel viewModel;

  bool get _canConfirm =>
      !state.confirming && state.fields.every((f) => !f.blocksConfirmation);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final documentImageBytes = viewModel.documentImageBytes;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (documentImageBytes != null)
                    DocumentThumbnailCard(
                      documentImageBytes: documentImageBytes,
                    ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.confirmationNoticeText,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  for (final field in state.fields)
                    FieldRow(
                      state: field,
                      label: _labelFor(field.key, l10n),
                      onEdit: (key, value) =>
                          viewModel.editField.run((key: key, value: value)),
                    ),
                ],
              ),
            ),
          ),
          if (state.confirmFailed)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l10n.confirmationConfirmFailedMessage,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _canConfirm ? () => viewModel.confirm.run() : null,
              child: state.confirming
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.confirmationPrimaryActionLabel),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => viewModel.rescan.run(),
              child: Text(l10n.confirmationSecondaryActionLabel),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  String _labelFor(FieldKey key, AppLocalizations l10n) => switch (key) {
    FieldKey.fullName => l10n.confirmationFieldFullNameLabel,
    FieldKey.documentNumber => l10n.confirmationFieldDocumentNumberLabel,
    FieldKey.nationality => l10n.confirmationFieldNationalityLabel,
    FieldKey.expiryDate => l10n.confirmationFieldExpiryDateLabel,
  };
}
