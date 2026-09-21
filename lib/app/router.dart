import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../app/enrollment_session_controller.dart';
import '../data/services/camera_capture_service.dart';
import '../data/services/system_settings_launcher.dart';
import '../domain/entities/consent_record.dart';
import '../domain/entities/credential_status.dart';
import '../domain/repositories/analytics_emitter.dart';
import '../domain/repositories/capture_attempt_counter_repository.dart';
import '../domain/repositories/consent_repository.dart';
import '../domain/repositories/credential_repository.dart';
import '../domain/repositories/device_capability_checker.dart';
import '../domain/repositories/document_quality_assessor.dart';
import '../domain/repositories/document_verification_repository.dart';
import '../features/account/withdrawal_placeholder_view.dart';
import '../features/account/withdrawal_viewmodel.dart';
import '../features/agent_escalation_placeholder_view.dart';
import '../features/enrollment/capture/capture_view.dart';
import '../features/enrollment/capture/capture_viewmodel.dart';
import '../features/enrollment/capture/document_confirmation_placeholder_view.dart';
import '../features/enrollment/consent/consent_view.dart';
import '../features/enrollment/consent/consent_viewmodel.dart';
import '../features/enrollment/welcome/recovery_placeholder_view.dart';
import '../features/enrollment/welcome/terms_placeholder_view.dart';
import '../features/enrollment/welcome/welcome_view.dart';
import '../features/enrollment/welcome/welcome_viewmodel.dart';
import '../features/help_placeholder_view.dart';
import '../features/retry_guidance_placeholder_view.dart';
import '../features/trips/trips_placeholder_view.dart';
import 'splash_view.dart';

/// Route paths, named once here rather than scattered as string literals
/// across the app (Constitution Principle X: "no magic values").
abstract final class AppRoutes {
  static const splash = '/splash';
  static const welcome = '/welcome';
  static const consent = '/enrollment/consent';
  static const documentCapture = '/enrollment/document-capture';
  static const documentConfirmation = '/enrollment/document-confirmation';
  static const retryGuidance = '/enrollment/retry-guidance';
  static const agentEscalation = '/enrollment/agent-escalation';
  static const help = '/enrollment/help';
  static const trips = '/trips';
  static const recovery = '/account/recovery';
  static const terms = '/legal/terms';
  static const withdrawal = '/account/withdrawal';
}

/// The app's `go_router` skeleton, including the credential-status-aware
/// redirect that satisfies FR-005–FR-007/FR-017 and US2's Independent
/// Test: a valid credential is routed straight to trips without the
/// welcome route ever building; an unreachable check whose last known
/// status was valid does the same (Edge Cases: "must not be dropped into
/// first-run onboarding on the strength of a network failure").
///
/// `WelcomeView`'s `WelcomeViewModel` is composed here, at the route
/// boundary, from `Provider`-supplied dependencies (Constitution
/// Principle IX: "composition happens at the app's entry point and at
/// route boundaries") — `WelcomeView` itself never reaches into a service
/// locator.
///
/// Deep-link entry handling: `go_router`'s default route-information
/// parser resolves the platform-provided initial URI against the routes
/// below automatically (e.g. an airline-email or airport-QR deep link
/// naming `/trips` lands there directly, subject to the same redirect);
/// an unmatched path falls back to the splash route via [errorBuilder]
/// rather than crashing.
GoRouter buildAppRouter({String? initialLocation}) {
  return GoRouter(
    initialLocation: initialLocation ?? AppRoutes.splash,
    redirect: _redirect,
    errorBuilder: (context, state) => const SplashView(),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) => WelcomeViewModel(
            credentialRepository: context.read<CredentialRepository>(),
            deviceCapabilityChecker: context.read<DeviceCapabilityChecker>(),
            enrollmentSessionController: context
                .read<EnrollmentSessionController>(),
            analyticsEmitter: context.read<AnalyticsEmitter>(),
          ),
          child: Consumer<WelcomeViewModel>(
            builder: (context, viewModel, _) =>
                WelcomeView(viewModel: viewModel),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.consent,
        // research.md §1: a sheet-style pageBuilder — opaque: false keeps
        // WelcomeView mounted and visible underneath the semi-transparent
        // barrier, which is what produces the reference's "dimmed welcome
        // screen behind the sheet" effect, without showModalBottomSheet.
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          opaque: false,
          barrierDismissible: false,
          barrierColor: const Color(0x99000000),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
            return SlideTransition(position: offsetAnimation, child: child);
          },
          child: ChangeNotifierProvider(
            create: (context) => ConsentViewModel(
              consentRepository: context.read<ConsentRepository>(),
              analyticsEmitter: context.read<AnalyticsEmitter>(),
            ),
            child: Consumer<ConsentViewModel>(
              builder: (context, viewModel, _) =>
                  ConsentView(viewModel: viewModel),
            ),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.documentCapture,
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) => CaptureViewModel(
            consentRepository: context.read<ConsentRepository>(),
            cameraCaptureService: context.read<CameraCaptureService>(),
            qualityAssessor: context.read<DocumentQualityAssessor>(),
            verificationRepository: context.read<DocumentVerificationRepository>(),
            attemptCounterRepository: context.read<CaptureAttemptCounterRepository>(),
            enrollmentSessionController: context.read<EnrollmentSessionController>(),
            analyticsEmitter: context.read<AnalyticsEmitter>(),
            systemSettingsLauncher: context.read<SystemSettingsLauncher>(),
          ),
          child: Consumer<CaptureViewModel>(
            builder: (context, viewModel, _) => CaptureView(viewModel: viewModel),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.documentConfirmation,
        builder: (context, state) => const DocumentConfirmationPlaceholderView(),
      ),
      GoRoute(
        path: AppRoutes.retryGuidance,
        builder: (context, state) => const RetryGuidancePlaceholderView(),
      ),
      GoRoute(
        path: AppRoutes.agentEscalation,
        builder: (context, state) => const AgentEscalationPlaceholderView(),
      ),
      GoRoute(
        path: AppRoutes.help,
        builder: (context, state) => const HelpPlaceholderView(),
      ),
      GoRoute(
        path: AppRoutes.trips,
        builder: (context, state) => const TripsPlaceholderView(),
      ),
      GoRoute(
        path: AppRoutes.recovery,
        builder: (context, state) => const RecoveryPlaceholderView(),
      ),
      GoRoute(
        path: AppRoutes.terms,
        builder: (context, state) => const TermsPlaceholderView(),
      ),
      GoRoute(
        path: AppRoutes.withdrawal,
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) => WithdrawalViewModel(
            consentRepository: context.read<ConsentRepository>(),
          ),
          child: Consumer<WithdrawalViewModel>(
            builder: (context, viewModel, _) =>
                WithdrawalPlaceholderView(viewModel: viewModel),
          ),
        ),
      ),
    ],
  );
}

Future<String?> _redirect(BuildContext context, GoRouterState state) async {
  final onSplashOrWelcome =
      state.matchedLocation == AppRoutes.splash ||
      state.matchedLocation == AppRoutes.welcome;

  // research.md §4: opportunistic, fire-and-forget retry of any
  // `withdrawalPending` consent — piggybacked on this function because it
  // already runs a network call every time the app re-evaluates the
  // splash/welcome routes (every cold launch and every foreground return
  // that re-enters those routes). Never awaited — a slow or failing
  // attempt must not block this redirect's own navigation decision.
  if (onSplashOrWelcome) {
    unawaited(context.read<ConsentRepository>().retryPendingWithdrawal());
  }

  if (state.matchedLocation == AppRoutes.documentCapture) {
    // 003-escanear-documento FR-001: the document-capture surface MUST NOT
    // be reachable without a *current* recorded consent — active status
    // AND referring to the currently-published text version, not merely
    // "some" active record. A deep link or a stale back-stack entry
    // straight into this route is redirected back to the gate rather than
    // trusted. `CaptureViewModel` performs the identical check again on
    // load (defense in depth, and the behavior its own unit tests exercise
    // in isolation) — this router-level guard exists so the route never
    // even builds the camera-owning view in the stale case.
    final consentRepository = context.read<ConsentRepository>();
    final localResult = await consentRepository.getLocalRecord();
    final record = localResult.valueOrNull;
    final textResult = await consentRepository.getCurrentText();
    final isCurrent = textResult.when(
      ok: (text) =>
          record != null &&
          record.status == ConsentRecordStatus.active &&
          record.textVersionId == text.id,
      error: (_, _) => false,
    );
    return isCurrent ? null : AppRoutes.consent;
  }

  if (!onSplashOrWelcome) {
    // A deep link straight into a stub route (consent/trips/recovery/
    // terms/withdrawal) is let through unguarded — none of those need a
    // fresh credential-status opinion to render.
    return null;
  }

  final repository = context.read<CredentialRepository>();
  final result = await repository.getStatus();
  final status = result.when(
    ok: (value) => value,
    error: (_, _) => const CredentialStatus.unreachable(lastKnownStatus: null),
  );

  final shouldShowTrips = switch (status) {
    Valid() => true,
    Unreachable(lastKnownStatus: final last) => last is Valid,
    NoCredential() || ExpiredOrRevoked() => false,
  };

  if (shouldShowTrips) {
    return state.matchedLocation == AppRoutes.trips ? null : AppRoutes.trips;
  }

  return state.matchedLocation == AppRoutes.welcome ? null : AppRoutes.welcome;
}
