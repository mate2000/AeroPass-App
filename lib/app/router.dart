import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../app/enrollment_session_controller.dart';
import '../app/pending_document_controller.dart';
import 'activated_credential_handoff.dart';
import 'technical_error_controller.dart';
import '../core/clock.dart';
import '../data/services/camera_capture_service.dart';
import '../data/services/liveness_camera_service.dart';
import '../data/services/system_settings_launcher.dart';
import '../domain/entities/consent_record.dart';
import '../domain/entities/credential_status.dart';
import '../domain/repositories/analytics_emitter.dart';
import '../domain/repositories/capture_attempt_counter_repository.dart';
import '../domain/repositories/consent_repository.dart';
import '../domain/repositories/credential_issuance_repository.dart';
import '../domain/repositories/credential_repository.dart';
import '../domain/repositories/device_capability_checker.dart';
import '../domain/repositories/document_quality_assessor.dart';
import '../domain/repositories/document_verification_repository.dart';
import '../domain/repositories/field_reverification_repository.dart';
import '../domain/repositories/identity_record_repository.dart';
import '../domain/repositories/liveness_verification_repository.dart';
import '../domain/repositories/verification_job_repository.dart';
import '../data/services/screen_capture_guard.dart';
import '../features/account/withdrawal_placeholder_view.dart';
import '../features/account/withdrawal_viewmodel.dart';
import '../domain/entities/escalation.dart';
import '../domain/repositories/agent_chat_repository.dart';
import '../domain/repositories/escalation_repository.dart';
import '../features/enrollment/escalation/agent_chat_view.dart';
import '../features/enrollment/escalation/agent_chat_viewmodel.dart';
import '../features/enrollment/escalation/escalation_view.dart';
import '../features/enrollment/escalation/escalation_viewmodel.dart';
import '../features/credential/credential_detail_placeholder_view.dart';
import '../features/enrollment/capture/capture_view.dart';
import '../features/enrollment/capture/capture_viewmodel.dart';
import '../features/enrollment/confirmation/document_confirmation_view.dart';
import '../features/enrollment/credential_activated/credential_activated_view.dart';
import '../features/enrollment/credential_activated/credential_activated_viewmodel.dart';
import '../features/enrollment/credential_activated/credential_not_active_placeholder_view.dart';
import '../features/enrollment/confirmation/document_confirmation_viewmodel.dart';
import '../features/enrollment/consent/consent_view.dart';
import '../features/enrollment/consent/consent_viewmodel.dart';
import '../features/enrollment/liveness/liveness_capture_view.dart';
import '../features/enrollment/liveness/liveness_capture_viewmodel.dart';
import '../features/enrollment/verification/verification_progress_view.dart';
import '../features/enrollment/verification/verification_progress_viewmodel.dart';
import '../features/enrollment/retry/retry_guidance_view.dart';
import '../features/enrollment/retry/retry_guidance_viewmodel.dart';
import '../features/enrollment/selfie/selfie_instructions_view.dart';
import '../features/enrollment/selfie/selfie_instructions_viewmodel.dart';
import '../features/enrollment/welcome/recovery_placeholder_view.dart';
import '../features/enrollment/welcome/terms_placeholder_view.dart';
import '../features/enrollment/welcome/welcome_view.dart';
import '../features/enrollment/welcome/welcome_viewmodel.dart';
import '../features/help_placeholder_view.dart';
import '../features/enrollment/technical_error/technical_error_view.dart';
import '../features/enrollment/technical_error/technical_error_viewmodel.dart';
import '../domain/repositories/operational_alert_reporter.dart';
import '../domain/repositories/service_status_repository.dart';
import '../domain/entities/verification_job_status.dart';
import '../domain/entities/verification_outcome.dart';
import '../domain/repositories/credential_summary_repository.dart';
import '../domain/repositories/trip_repository.dart';
import '../features/profile/profile_placeholder_view.dart';
import '../features/trip_verification_placeholder_view.dart';
import '../features/trips/trips_home_view.dart';
import '../features/trips/trips_home_viewmodel.dart';
import 'home_shell.dart';
import 'clock_trust_monitor.dart';
import '../core/happy_path_flags.dart';
import '../data/dev/dev_pass_repository.dart';
import '../domain/repositories/device_posture_checker.dart';
import '../domain/repositories/pass_code_source.dart';
import '../domain/repositories/pass_display_guard.dart';
import '../domain/repositories/pass_repository.dart';
import '../features/pass/pass_view.dart';
import '../features/pass/pass_viewmodel.dart';
import 'splash_view.dart';

/// Route paths, named once here rather than scattered as string literals
/// across the app (Constitution Principle X: "no magic values").
abstract final class AppRoutes {
  static const splash = '/splash';
  static const welcome = '/welcome';
  static const consent = '/enrollment/consent';
  static const documentCapture = '/enrollment/document-capture';
  static const documentConfirmation = '/enrollment/document-confirmation';
  static const selfieInstructions = '/enrollment/selfie-instructions';
  static const livenessCapture = '/enrollment/liveness-capture';
  static const verificationProgress = '/enrollment/verification-progress';
  static const credentialActivated = '/enrollment/credential-activated';
  static const credentialNotActive = '/enrollment/credential-not-active';
  static const credentialDetail = '/credential';
  static const technicalError = '/enrollment/technical-error';
  static const retryGuidance = '/enrollment/retry-guidance';
  static const agentEscalation = '/enrollment/agent-escalation';
  static const agentChat = '/enrollment/agent-chat';
  static const help = '/enrollment/help';
  static const trips = '/trips';
  static const recovery = '/account/recovery';
  static const terms = '/legal/terms';
  static const withdrawal = '/account/withdrawal';
  static const profile = '/profile';
  static const tripVerification = '/trip/verification';
  static const pass = '/trip/pass';
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
    observers: [SentryNavigatorObserver()],
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
            final offsetAnimation =
                Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                );
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
            verificationRepository: context
                .read<DocumentVerificationRepository>(),
            attemptCounterRepository: context
                .read<CaptureAttemptCounterRepository>(),
            enrollmentSessionController: context
                .read<EnrollmentSessionController>(),
            pendingDocumentController: context
                .read<PendingDocumentController>(),
            analyticsEmitter: context.read<AnalyticsEmitter>(),
            systemSettingsLauncher: context.read<SystemSettingsLauncher>(),
          ),
          child: Consumer<CaptureViewModel>(
            builder: (context, viewModel, _) =>
                CaptureView(viewModel: viewModel),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.documentConfirmation,
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) => DocumentConfirmationViewModel(
            pendingDocumentController: context
                .read<PendingDocumentController>(),
            fieldReverificationRepository: context
                .read<FieldReverificationRepository>(),
            identityRecordRepository: context.read<IdentityRecordRepository>(),
            analyticsEmitter: context.read<AnalyticsEmitter>(),
            enrollmentSessionController: context
                .read<EnrollmentSessionController>(),
            clock: context.read<Clock>(),
          ),
          child: Consumer<DocumentConfirmationViewModel>(
            builder: (context, viewModel, _) =>
                DocumentConfirmationView(viewModel: viewModel),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.selfieInstructions,
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) => SelfieInstructionsViewModel(
            enrollmentSessionController: context
                .read<EnrollmentSessionController>(),
            analyticsEmitter: context.read<AnalyticsEmitter>(),
          ),
          child: Consumer<SelfieInstructionsViewModel>(
            builder: (context, viewModel, _) =>
                SelfieInstructionsView(viewModel: viewModel),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.livenessCapture,
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) => LivenessCaptureViewModel(
            livenessVerificationRepository: context
                .read<LivenessVerificationRepository>(),
            livenessCameraService: context.read<LivenessCameraService>(),
            attemptCounterRepository: context
                .read<CaptureAttemptCounterRepository>(),
            enrollmentSessionController: context
                .read<EnrollmentSessionController>(),
            analyticsEmitter: context.read<AnalyticsEmitter>(),
          ),
          child: Consumer<LivenessCaptureViewModel>(
            builder: (context, viewModel, _) =>
                LivenessCaptureView(viewModel: viewModel),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.verificationProgress,
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) => VerificationProgressViewModel(
            jobRepository: context.read<VerificationJobRepository>(),
            issuanceRepository: context.read<CredentialIssuanceRepository>(),
            handoff: context.read<ActivatedCredentialHandoff>(),
            enrollmentSessionController: context
                .read<EnrollmentSessionController>(),
            pendingDocumentController: context
                .read<PendingDocumentController>(),
            attemptCounterRepository: context
                .read<CaptureAttemptCounterRepository>(),
            analyticsEmitter: context.read<AnalyticsEmitter>(),
            technicalErrorController: context.read<TechnicalErrorController>(),
            clock: context.read<Clock>(),
          ),
          child: Consumer<VerificationProgressViewModel>(
            builder: (context, viewModel, _) =>
                VerificationProgressView(viewModel: viewModel),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.credentialActivated,
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) => CredentialActivatedViewModel(
            handoff: context.read<ActivatedCredentialHandoff>(),
            analyticsEmitter: context.read<AnalyticsEmitter>(),
            screenCaptureGuard: context.read<ScreenCaptureGuard>(),
          ),
          child: Consumer<CredentialActivatedViewModel>(
            builder: (context, viewModel, _) =>
                CredentialActivatedView(viewModel: viewModel),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.credentialNotActive,
        builder: (context, state) => const CredentialNotActivePlaceholderView(),
      ),
      GoRoute(
        path: AppRoutes.technicalError,
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) => TechnicalErrorViewModel(
            technicalErrorController: context.read<TechnicalErrorController>(),
            enrollmentSessionController: context
                .read<EnrollmentSessionController>(),
            statusRepository: context.read<ServiceStatusRepository>(),
            alertReporter: context.read<OperationalAlertReporter>(),
            analyticsEmitter: context.read<AnalyticsEmitter>(),
            clock: context.read<Clock>(),
          ),
          child: Consumer<TechnicalErrorViewModel>(
            builder: (context, viewModel, _) =>
                TechnicalErrorView(viewModel: viewModel),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.retryGuidance,
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) => RetryGuidanceViewModel(
            attemptCounterRepository: context
                .read<CaptureAttemptCounterRepository>(),
            analyticsEmitter: context.read<AnalyticsEmitter>(),
          ),
          child: Consumer<RetryGuidanceViewModel>(
            builder: (context, viewModel, _) =>
                RetryGuidanceView(viewModel: viewModel),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.agentEscalation,
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) => EscalationViewModel(
            escalationRepository: context.read<EscalationRepository>(),
            issuanceRepository: context.read<CredentialIssuanceRepository>(),
            handoff: context.read<ActivatedCredentialHandoff>(),
            enrollmentSessionController: context
                .read<EnrollmentSessionController>(),
            attemptCounterRepository: context
                .read<CaptureAttemptCounterRepository>(),
            analyticsEmitter: context.read<AnalyticsEmitter>(),
            clock: context.read<Clock>(),
          ),
          child: Consumer<EscalationViewModel>(
            builder: (context, viewModel, _) =>
                EscalationView(viewModel: viewModel),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.agentChat,
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) => AgentChatViewModel(
            chatRepository: context.read<AgentChatRepository>(),
          ),
          child: Consumer<AgentChatViewModel>(
            builder: (context, viewModel, _) =>
                AgentChatView(viewModel: viewModel),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.help,
        builder: (context, state) => const HelpPlaceholderView(),
      ),
      // 012-mis-viajes research.md §8: the enrolled passenger's three tabs.
      ShellRoute(
        builder: (context, state, child) =>
            HomeShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.trips,
            builder: (context, state) => ChangeNotifierProvider(
              create: (context) => TripsHomeViewModel(
                summaryRepository: context.read<CredentialSummaryRepository>(),
                tripRepository: context.read<TripRepository>(),
                analyticsEmitter: context.read<AnalyticsEmitter>(),
                clock: context.read<Clock>(),
                passRepository: context.read<PassRepository>(),
              ),
              child: Consumer<TripsHomeViewModel>(
                builder: (context, viewModel, _) =>
                    TripsHomeView(viewModel: viewModel),
              ),
            ),
          ),
          GoRoute(
            path: AppRoutes.credentialDetail,
            builder: (context, state) =>
                const CredentialDetailPlaceholderView(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfilePlaceholderView(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.tripVerification,
        builder: (context, state) => const TripVerificationPlaceholderView(),
      ),
      // 014-qr-pase: the pass is always for the trip Mis viajes promotes as
      // next, read from the in-session snapshot. No trip id travels in the
      // route, so none reaches navigation breadcrumbs.
      GoRoute(
        path: AppRoutes.pass,
        builder: (context, state) {
          final trip = context.read<TripRepository>().lastKnown?.next;
          final passRepository = context.read<PassRepository>();
          final summaryRepository = context.read<CredentialSummaryRepository>();
          return ChangeNotifierProvider(
            create: (context) => PassViewModel(
              tripId: trip?.id,
              trip: trip,
              passRepository: passRepository,
              codeSource: context.read<PassCodeSource>(),
              displayGuard: context.read<PassDisplayGuard>(),
              postureChecker: context.read<DevicePostureChecker>(),
              clockTrust: context.read<ClockTrustMonitor>(),
              analyticsEmitter: context.read<AnalyticsEmitter>(),
              clock: context.read<Clock>(),
              loadHolderName: () async => (await summaryRepository.getSummary())
                  .valueOrNull
                  ?.holderName,
              // FR-019: the dev control acts through the fake backend only,
              // and only in a build with the release-refused flag.
              onDevExpire:
                  HappyPathFlags.devPassControls &&
                      passRepository is DevPassRepository &&
                      trip != null
                  ? () {
                      final active = passRepository.activePassFor(trip.id);
                      if (active != null) {
                        passRepository.expireNow(active.passId);
                      }
                    }
                  : null,
            ),
            child: Consumer<PassViewModel>(
              builder: (context, viewModel, _) =>
                  PassView(viewModel: viewModel),
            ),
          );
        },
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
            activatedCredentialHandoff: context
                .read<ActivatedCredentialHandoff>(),
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

  if (state.matchedLocation == AppRoutes.documentConfirmation) {
    // 004-confirmar-datos research.md §1: a deep link or a stale back-stack
    // entry straight into this route, with nothing handed off by capture,
    // is redirected back to document capture rather than trusted.
    // `DocumentConfirmationViewModel` performs the identical check again on
    // load (defense in depth) — this router-level guard exists so the
    // route never even builds the ViewModel in the stale case.
    final pendingDocumentController = context.read<PendingDocumentController>();
    return pendingDocumentController.hasPendingDocument
        ? null
        : AppRoutes.documentCapture;
  }

  if (state.matchedLocation == AppRoutes.livenessCapture) {
    // 006-selfie-liveness research.md §4: a deep link or a stale back-stack
    // entry straight into this route, without ever having confirmed
    // extracted data (004), is redirected back to document capture rather
    // than trusted. `stepReached == selfieCapture` alone is trivially
    // satisfiable by bouncing through 005 (which sets it unconditionally,
    // by design), so `identityConfirmed` is the narrower, load-bearing
    // check.
    final enrollmentSessionController = context
        .read<EnrollmentSessionController>();
    final identityConfirmed =
        enrollmentSessionController.current?.identityConfirmed ?? false;
    return identityConfirmed ? null : AppRoutes.documentCapture;
  }

  if (state.matchedLocation == AppRoutes.credentialActivated) {
    return _credentialActivatedRedirect(context);
  }

  if (!onSplashOrWelcome) {
    // A deep link straight into a stub route (consent/trips/recovery/
    // terms/withdrawal) is let through unguarded — none of those need a
    // fresh credential-status opinion to render.
    return null;
  }

  final repository = context.read<CredentialRepository>();
  final consentRepository = context.read<ConsentRepository>();
  final escalationRepository = context.read<EscalationRepository>();
  final jobRepository = context.read<VerificationJobRepository>();
  final enrollmentSessionController = context
      .read<EnrollmentSessionController>();
  final clock = context.read<Clock>();
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

  // 011 contracts/launch-routing-addendum.md: resuming an escalation or a
  // verification happens on cold launch only. Going to welcome shows welcome;
  // before this, 010's "Volver al inicio" bounced straight back.
  final coldLaunch = state.matchedLocation == AppRoutes.splash;
  if (coldLaunch && status is NoCredential) {
    if (await _hasOpenEscalation(consentRepository, escalationRepository)) {
      return AppRoutes.agentEscalation;
    }
    if (await _hasResumableVerification(
      consentRepository,
      jobRepository,
      clock,
    )) {
      enrollmentSessionController.resumeAfterVerification();
      return AppRoutes.verificationProgress;
    }
  }

  return state.matchedLocation == AppRoutes.welcome ? null : AppRoutes.welcome;
}

/// 010-escalar-agente FR-010: a passenger who left screen 10 with an
/// escalation still open (or resolved while away) resumes there on launch.
/// Keyed by the consent record's enrollment attempt, so only an active
/// consent can have one; any failed read falls through to welcome.
Future<bool> _hasOpenEscalation(
  ConsentRepository consentRepository,
  EscalationRepository escalationRepository,
) async {
  final consent = (await consentRepository.getLocalRecord()).valueOrNull;
  if (consent?.status != ConsentRecordStatus.active) return false;
  final status = (await escalationRepository.getStatus()).valueOrNull;
  return status is EscalationOpen || status is EscalationResolved;
}

/// 011-error-tecnico FR-012: a verification that failed within the backend's
/// 24-hour window resumes into 007, which re-reads the same job. A rejection
/// is not resumable here (009 owns it), and any failed read falls through to
/// welcome.
Future<bool> _hasResumableVerification(
  ConsentRepository consentRepository,
  VerificationJobRepository jobRepository,
  Clock clock,
) async {
  final consent = (await consentRepository.getLocalRecord()).valueOrNull;
  if (consent?.status != ConsentRecordStatus.active) return false;
  final job = (await jobRepository.getStatus()).valueOrNull;
  final until = switch (job) {
    VerificationJobInProgress(:final resumableUntil) => resumableUntil,
    VerificationJobCompleted(
      :final resumableUntil,
      outcome: VerificationServiceFailure() || VerificationMatched(),
    ) =>
      resumableUntil,
    _ => null,
  };
  return until != null && until.isAfter(clock.now());
}

/// 008-identidad-activa research.md §5: screen 08 builds only while the
/// in-memory hand-off holds a backend-confirmed credential AND consent is
/// still active (FR-001, FR-009, FR-011). Every other entry — a link,
/// restored navigation, a stale back-stack entry — is redirected: to the
/// credential surface if a valid credential exists, otherwise back to
/// splash, which applies spec 001's launch rule.
Future<String?> _credentialActivatedRedirect(BuildContext context) async {
  final handoff = context.read<ActivatedCredentialHandoff>();
  final consentRepository = context.read<ConsentRepository>();
  final credentialRepository = context.read<CredentialRepository>();

  if (handoff.hasCredential) {
    final consent = (await consentRepository.getLocalRecord()).valueOrNull;
    if (consent?.status == ConsentRecordStatus.active) return null;
    handoff.clear();
    return AppRoutes.splash;
  }

  final status = (await credentialRepository.getStatus()).when(
    ok: (value) => value,
    error: (_, _) => const CredentialStatus.unreachable(lastKnownStatus: null),
  );
  final hasValidCredential = switch (status) {
    Valid() => true,
    Unreachable(lastKnownStatus: final last) => last is Valid,
    NoCredential() || ExpiredOrRevoked() => false,
  };
  return hasValidCredential ? AppRoutes.credentialDetail : AppRoutes.splash;
}
