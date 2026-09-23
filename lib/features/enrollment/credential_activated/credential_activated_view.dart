import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/design/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'credential_activated_viewmodel.dart';
import 'widgets/credential_card.dart';
import 'widgets/success_marker.dart';

/// Screen 08, "Identidad activa" (008-identidad-activa). Composition only
/// (Constitution Principle VIII): everything here reads
/// [CredentialActivatedViewModel] and invokes it.
///
/// One rendered state — the settled one. No stat tiles (FR-005), no
/// portrait (FR-018), no back button (FR-017): the system back gesture is
/// redirected forward to trips, since enrollment is complete and nothing
/// sits behind this screen on the stack.
class CredentialActivatedView extends StatefulWidget {
  const CredentialActivatedView({required this.viewModel, super.key});

  final CredentialActivatedViewModel viewModel;

  @override
  State<CredentialActivatedView> createState() =>
      _CredentialActivatedViewState();
}

class _CredentialActivatedViewState extends State<CredentialActivatedView> {
  static const double _sheetRadius = 28;
  static const double _horizontalPadding = 24;

  @override
  void initState() {
    super.initState();
    unawaited(widget.viewModel.onShown());
  }

  @override
  void dispose() {
    unawaited(widget.viewModel.onHidden());
    super.dispose();
  }

  void _goToTrips() {
    widget.viewModel.goToTrips();
    context.go(AppRoutes.trips);
  }

  void _openCredentialDetail() {
    widget.viewModel.openCredentialDetail();
    context.go(AppRoutes.credentialDetail);
  }

  void _onBackGesture() {
    widget.viewModel.onBackGesture();
    context.go(AppRoutes.trips);
  }

  @override
  Widget build(BuildContext context) {
    final credential = widget.viewModel.credential;
    if (credential == null) {
      // Only reachable if the router guard were bypassed. Never invent a
      // credential to fill the screen (FR-001).
      return const Scaffold(body: SizedBox.shrink());
    }
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _onBackGesture();
      },
      child: Scaffold(
        backgroundColor: AppColors.navy,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 32),
              const SuccessMarker(),
              const SizedBox(height: 32),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(_sheetRadius),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(
                              _horizontalPadding,
                              32,
                              _horizontalPadding,
                              16,
                            ),
                            child: Column(
                              children: [
                                Semantics(
                                  header: true,
                                  child: Text(
                                    l10n.credentialActivatedTitle,
                                    textAlign: TextAlign.center,
                                    style: textTheme.headlineSmall?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.credentialActivatedSubtitle,
                                  textAlign: TextAlign.center,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                CredentialCard(credential: credential),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            _horizontalPadding,
                            8,
                            _horizontalPadding,
                            16,
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.navy,
                                    minimumSize: const Size.fromHeight(56),
                                  ),
                                  onPressed: _goToTrips,
                                  child: Text(
                                    l10n.credentialActivatedPrimaryAction,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.textPrimary,
                                    minimumSize: const Size.fromHeight(48),
                                  ),
                                  onPressed: _openCredentialDetail,
                                  child: Text(
                                    l10n.credentialActivatedSecondaryAction,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
