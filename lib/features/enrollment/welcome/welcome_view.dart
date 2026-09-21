import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/design/app_colors.dart';
import '../../../domain/entities/welcome_content_variant.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'welcome_view_state.dart';
import 'welcome_viewmodel.dart';
import 'widgets/benefit_summary.dart';
import 'widgets/device_unsupported_message.dart';
import 'widgets/enrollment_steps_list.dart';
import 'widgets/primary_action_button.dart';
import 'widgets/privacy_terms_link.dart';
import 'widgets/reenrollment_banner.dart';
import 'widgets/resume_banner.dart';
import 'widgets/secondary_action_button.dart';
import 'widgets/unrefreshed_indicator.dart';
import 'widgets/welcome_hero.dart';

/// Composition only (Constitution Principle VIII): no business logic, no
/// repository/service call directly — everything here reads
/// `WelcomeViewModel.state` and invokes its `Command`s. `WelcomeViewModel`
/// is passed in (constructor injection at the route boundary, per
/// Principle IX), not looked up from a service locator.
class WelcomeView extends StatefulWidget {
  const WelcomeView({required this.viewModel, super.key});

  final WelcomeViewModel viewModel;

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  bool _navigatedToConsent = false;
  bool _navigatedToRecovery = false;

  @override
  void initState() {
    super.initState();
    widget.viewModel.primaryAction.addListener(_onPrimaryActionChanged);
    widget.viewModel.secondaryAction.addListener(_onSecondaryActionChanged);
    widget.viewModel.openPrivacyTerms.addListener(_onOpenPrivacyTermsChanged);
  }

  @override
  void dispose() {
    widget.viewModel.primaryAction.removeListener(_onPrimaryActionChanged);
    widget.viewModel.secondaryAction.removeListener(_onSecondaryActionChanged);
    widget.viewModel.openPrivacyTerms.removeListener(
      _onOpenPrivacyTermsChanged,
    );
    super.dispose();
  }

  void _onPrimaryActionChanged() {
    if (_navigatedToConsent || !widget.viewModel.primaryAction.completed) {
      return;
    }
    _navigatedToConsent = true;
    context.push(AppRoutes.consent);
  }

  void _onSecondaryActionChanged() {
    if (_navigatedToRecovery || !widget.viewModel.secondaryAction.completed) {
      return;
    }
    _navigatedToRecovery = true;
    context.push(AppRoutes.recovery);
  }

  void _onOpenPrivacyTermsChanged() {
    if (!widget.viewModel.openPrivacyTerms.completed) return;
    // Reset so re-opening after returning emits/pushes again rather than
    // being treated as already-navigated (US3, Acceptance Scenario 2: the
    // passenger returns to the welcome screen with no state lost and can
    // open the terms again).
    widget.viewModel.openPrivacyTerms.clearResult();
    context.push(AppRoutes.terms);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final state = widget.viewModel.state;
        return Scaffold(
          backgroundColor: AppColors.navy,
          body: SafeArea(
            child: _WelcomeShell(
              sheet: switch (state) {
                WelcomeViewChecking() => const _CheckingSheet(),
                WelcomeViewDeviceUnsupported(:final reason) =>
                  DeviceUnsupportedMessage(reason: reason),
                WelcomeViewContent() => _WelcomeContentSheet(
                  state: state,
                  viewModel: widget.viewModel,
                ),
              },
            ),
          ),
        );
      },
    );
  }
}

/// The navy hero + rounded white sheet shell every welcome-screen state
/// renders inside, so the branding stays consistent across the
/// checking/first-run/re-enrollment/device-unsupported states (the mockup
/// only shows the first-run state, but the constitution's Principle III
/// requires every one of these to be a fully designed state, not an
/// afterthought).
class _WelcomeShell extends StatelessWidget {
  const _WelcomeShell({required this.sheet});

  final Widget sheet;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const WelcomeHero(),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 12,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: sheet,
          ),
        ),
      ],
    );
  }
}

class _CheckingSheet extends StatelessWidget {
  const _CheckingSheet();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _WelcomeContentSheet extends StatelessWidget {
  const _WelcomeContentSheet({required this.state, required this.viewModel});

  final WelcomeViewContent state;
  final WelcomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  switch (state.variant) {
                    WelcomeScreenVariant.reenrollmentRequired =>
                      ReenrollmentBanner(reason: state.expiryReason),
                    WelcomeScreenVariant.resumeOffered => const ResumeBanner(),
                    WelcomeScreenVariant.firstRun => const BenefitSummary(),
                  },
                  if (state.unrefreshed) ...[
                    const SizedBox(height: 12),
                    const UnrefreshedIndicator(),
                  ],
                  const SizedBox(height: 24),
                  const EnrollmentStepsList(),
                  const SizedBox(height: 16),
                  PrivacyTermsLink(
                    command: viewModel.openPrivacyTerms,
                    label: l10n.welcomePrivacyTermsLinkLabel,
                  ),
                ],
              ),
            ),
          ),
          // FR-015: primary action stays within the bottom half of the
          // screen and reachable without scrolling — it's pinned outside
          // the scrollable content above, not inside it.
          PrimaryActionButton(
            command: viewModel.primaryAction,
            label: l10n.welcomePrimaryActionLabel,
          ),
          const SizedBox(height: 4),
          SecondaryActionButton(
            command: viewModel.secondaryAction,
            label: l10n.welcomeSecondaryActionLabel,
          ),
        ],
      ),
    );
  }
}
