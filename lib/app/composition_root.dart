import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../core/analytics_session.dart';
import '../core/clock.dart';
import '../core/happy_path_flags.dart';
import '../core/sentry_config.dart';
import '../data/dev/dev_agent_chat_repository.dart';
import '../data/dev/dev_consent_repository.dart';
import '../data/dev/dev_credential_repository.dart';
import '../data/dev/dev_credential_summary_repository.dart';
import '../data/dev/dev_trip_repository.dart';
import '../data/dev/dev_device_posture_checker.dart';
import '../data/dev/dev_pass_repository.dart';
import '../data/services/backend_pass_code_source.dart';
import '../data/services/pass_repository_impl.dart';
import '../data/services/pass_service.dart';
import '../data/services/platform_pass_display.dart';
import '../domain/repositories/device_posture_checker.dart';
import '../domain/repositories/pass_code_source.dart';
import '../domain/repositories/pass_display_guard.dart';
import '../domain/repositories/pass_repository.dart';
import 'clock_trust_monitor.dart';
import '../data/dev/dev_escalation_repository.dart';
import '../data/dev/dev_credential_issuance_repository.dart';
import '../data/dev/dev_document_quality_assessor.dart';
import '../data/dev/dev_document_verification_repository.dart';
import '../data/dev/dev_field_reverification_repository.dart';
import '../data/dev/dev_identity_record_repository.dart';
import '../data/dev/dev_liveness_camera_service.dart';
import '../data/dev/dev_liveness_verification_repository.dart';
import '../data/dev/dev_service_status_repository.dart';
import '../data/dev/dev_verification_job_repository.dart';
import '../data/services/agent_chat_repository_impl.dart';
import '../data/services/agent_chat_service.dart';
import '../data/services/camera_capture_service.dart';
import '../data/services/capture_attempt_counter_repository_impl.dart';
import '../data/services/capture_attempt_counter_service.dart';
import '../data/services/consent_repository_impl.dart';
import '../data/services/consent_service.dart';
import '../data/services/credential_issuance_repository_impl.dart';
import '../data/services/credential_issuance_service.dart';
import '../data/services/credential_repository_impl.dart';
import '../data/services/credential_service.dart';
import '../data/services/credential_summary_repository_impl.dart';
import '../data/services/trip_repository_impl.dart';
import '../data/services/trip_service.dart';
import '../data/services/device_capability_service.dart';
import '../data/services/document_verification_repository_impl.dart';
import '../data/services/document_verification_service.dart';
import '../data/services/escalation_repository_impl.dart';
import '../data/services/escalation_service.dart';
import '../data/services/field_reverification_repository_impl.dart';
import '../data/services/field_reverification_service.dart';
import '../data/services/heuristic_quality_assessor.dart';
import '../data/services/identity_record_repository_impl.dart';
import '../data/services/identity_record_service.dart';
import '../data/services/liveness_camera_service.dart';
import '../data/services/liveness_verification_repository_impl.dart';
import '../data/services/liveness_verification_service.dart';
import '../data/services/analytics_sink.dart';
import '../data/services/attempt_tracking_consent_repository.dart';
import '../data/services/current_enrollment_attempt.dart';
import '../data/services/enrollment_duration_tracker.dart';
import '../data/services/full_display_reporter.dart';
import '../data/services/logging_analytics_emitter.dart';
import '../data/services/pinned_dio_factory.dart';
import '../data/services/screen_capture_guard.dart';
import '../data/services/sentry_log_analytics_sink.dart';
import '../data/services/sentry_operational_alert_reporter.dart';
import '../data/services/service_status_repository_impl.dart';
import '../data/services/service_status_service.dart';
import '../data/services/system_settings_launcher.dart';
import '../data/services/verification_job_repository_impl.dart';
import '../data/services/verification_job_service.dart';
import '../domain/repositories/agent_chat_repository.dart';
import '../domain/repositories/analytics_emitter.dart';
import '../domain/repositories/capture_attempt_counter_repository.dart';
import '../domain/repositories/consent_repository.dart';
import '../domain/repositories/credential_issuance_repository.dart';
import '../domain/repositories/credential_repository.dart';
import '../domain/repositories/credential_summary_repository.dart';
import '../domain/repositories/trip_repository.dart';
import '../domain/repositories/device_capability_checker.dart';
import '../domain/repositories/document_quality_assessor.dart';
import '../domain/repositories/document_verification_repository.dart';
import '../domain/repositories/escalation_repository.dart';
import '../domain/repositories/field_reverification_repository.dart';
import '../domain/repositories/identity_record_repository.dart';
import '../domain/repositories/liveness_verification_repository.dart';
import '../domain/repositories/operational_alert_reporter.dart';
import '../domain/repositories/service_status_repository.dart';
import '../domain/repositories/verification_job_repository.dart';
import 'activated_credential_handoff.dart';
import 'enrollment_session_controller.dart';
import 'pending_document_controller.dart';
import 'technical_error_controller.dart';

/// Wires every dependency the app needs, once, at the app's entry point
/// (Constitution Principle IX: "composition happens at the app's entry
/// point and at route boundaries" — never inside a widget or ViewModel via
/// a service locator or singleton lookup).
///
/// Wraps `child` (built by `app.dart`) in the `Provider`s every ViewModel
/// receives its dependencies from via constructor injection at the point
/// each ViewModel is constructed (e.g. in a route's builder), not by
/// reaching into `context` themselves.
class CompositionRoot extends StatelessWidget {
  const CompositionRoot({required this.child, super.key});

  final Widget child;

  // Interim placeholder host/pins: no backend is deployed for this feature
  // yet (spec.md Dependencies notes the credential-status check as an
  // external dependency this screen consumes). Selected per environment via
  // API_BASE_URL in the env files under env/ (passed with
  // --dart-define-from-file); the real per-flavor (dev/staging/prod) pinned certificate
  // hashes are supplied at build time once the backend exists — see the
  // Constitution's Development Workflow "Flavors" requirement.
  static const _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.dev.aeropass.example',
  );
  static const _pinnedCertificateHashes = <String>{};

  // Happy-path development-mode flags (constitution v1.4.0) — relocated to
  // `HappyPathFlags` (005-instrucciones-selfie, research.md §4) so every
  // flag has exactly one definition and one release-safety enforcement
  // point, instead of one private constant per feature.
  static const _useFakeConsentBackend = HappyPathFlags.useFakeConsentBackend;
  static const _useFakeVerificationBackend =
      HappyPathFlags.useFakeVerificationBackend;

  @override
  Widget build(BuildContext context) {
    const clock = SystemClock();
    final sessionId = AnalyticsSessionId.generate();

    final dio = buildPinnedDio(
      baseUrl: _baseUrl,
      pinnedSha256CertificateHashes: _pinnedCertificateHashes,
    );
    final credentialService = CredentialService(
      dio: dio,
      secureStorage: const FlutterSecureStorage(),
    );
    // 012-mis-viajes research.md §3: in development there is no credential
    // backend, so the dev repository plays it from the stored token.
    final CredentialRepository credentialRepository =
        _useFakeVerificationBackend
        ? DevCredentialRepository(credentialService: credentialService)
        : CredentialRepositoryImpl(credentialService);
    final CredentialSummaryRepository credentialSummaryRepository =
        _useFakeVerificationBackend
        ? DevCredentialSummaryRepository(credentialService: credentialService)
        : CredentialSummaryRepositoryImpl(credentialService, clock: clock);
    final ConsentRepository baseConsentRepository;
    if (_useFakeConsentBackend) {
      baseConsentRepository = DevConsentRepository(
        credentialService: credentialService,
      );
    } else {
      final consentService = ConsentService(
        dio: dio,
        secureStorage: const FlutterSecureStorage(),
      );
      baseConsentRepository = ConsentRepositoryImpl(
        consentService,
        clock: clock,
        credentialService: credentialService,
      );
    }
    // 015-observabilidad-sentry research §10–§11: the current enrollment
    // attempt tags funnel telemetry; the decorator keeps it in step with
    // consent, and funnel events also go to Sentry when it is configured.
    final currentEnrollmentAttempt = CurrentEnrollmentAttempt(
      consentRepository: baseConsentRepository,
    );
    unawaited(currentEnrollmentAttempt.load());
    final ConsentRepository consentRepository =
        AttemptTrackingConsentRepository(
          baseConsentRepository,
          attempt: currentEnrollmentAttempt,
        );
    final AnalyticsEmitter analyticsEmitter = LoggingAnalyticsEmitter(
      sinks: [
        DeveloperLogAnalyticsSink(sessionId: sessionId, clock: clock),
        if (SentryConfig.isEnabled)
          SentryLogAnalyticsSink(
            sessionId: sessionId,
            attempt: currentEnrollmentAttempt,
            durationTracker: EnrollmentDurationTracker(clock: clock),
          ),
      ],
    );
    final enrollmentSessionController = EnrollmentSessionController(
      clock: clock,
    );
    const DeviceCapabilityChecker deviceCapabilityChecker =
        DeviceCapabilityService();

    // 003-escanear-documento: the document-capture step's three new ports
    // (plan.md's Project Structure) — DocumentVerificationRepository,
    // DocumentQualityAssessor, and CaptureAttemptCounterRepository — plus
    // the camera-hardware boundary CaptureViewModel is constructor-injected
    // with directly (research.md §1).
    final DocumentVerificationRepository documentVerificationRepository;
    if (_useFakeVerificationBackend) {
      documentVerificationRepository = DevDocumentVerificationRepository();
    } else {
      final documentVerificationService = DocumentVerificationService(dio: dio);
      documentVerificationRepository = DocumentVerificationRepositoryImpl(
        documentVerificationService,
      );
    }
    const DocumentQualityAssessor documentQualityAssessor =
        _useFakeVerificationBackend
        ? DevDocumentQualityAssessor()
        : HeuristicQualityAssessor();
    final captureAttemptCounterService = CaptureAttemptCounterService(
      secureStorage: const FlutterSecureStorage(),
    );
    final CaptureAttemptCounterRepository captureAttemptCounterRepository =
        CaptureAttemptCounterRepositoryImpl(
          captureAttemptCounterService,
          clock: clock,
        );
    final CameraCaptureService cameraCaptureService =
        CameraPluginCaptureService();
    const SystemSettingsLauncher systemSettingsLauncher =
        PlatformSystemSettingsLauncher();

    // 004-confirmar-datos: the confirmation step's two new ports —
    // FieldReverificationRepository and IdentityRecordRepository — plus the
    // in-memory PendingDocumentController that hands a capture's bytes and
    // extraction across the navigation boundary (research.md §1, §4, §5).
    final FieldReverificationRepository fieldReverificationRepository;
    final IdentityRecordRepository identityRecordRepository;
    if (_useFakeVerificationBackend) {
      fieldReverificationRepository = DevFieldReverificationRepository();
      identityRecordRepository = DevIdentityRecordRepository();
    } else {
      final fieldReverificationService = FieldReverificationService(dio: dio);
      fieldReverificationRepository = FieldReverificationRepositoryImpl(
        fieldReverificationService,
      );
      final identityRecordService = IdentityRecordService(
        dio: dio,
        secureStorage: const FlutterSecureStorage(),
      );
      identityRecordRepository = IdentityRecordRepositoryImpl(
        identityRecordService,
      );
    }
    final pendingDocumentController = PendingDocumentController();

    // 006-selfie-liveness: the liveness-capture step's two new ports —
    // LivenessVerificationRepository and LivenessCameraService — following
    // the same dev-vs-real pattern as 003/004 (research.md §10).
    final LivenessVerificationRepository livenessVerificationRepository;
    final LivenessCameraService livenessCameraService;
    if (_useFakeVerificationBackend) {
      livenessVerificationRepository = DevLivenessVerificationRepository();
      livenessCameraService = DevLivenessCameraService();
    } else {
      final livenessVerificationService = LivenessVerificationService(dio: dio);
      livenessVerificationRepository = LivenessVerificationRepositoryImpl(
        livenessVerificationService,
      );
      livenessCameraService = FrontCameraLivenessService();
    }

    // 008-identidad-activa: the in-memory, one-time hand-off of a just-issued
    // credential (research.md §4), and screenshot blocking for credential
    // surfaces (research.md §13) — Android now, iOS deferred.
    final activatedCredentialHandoff = ActivatedCredentialHandoff();
    // The issue-only port (research.md §1), dev fake behind the same flag
    // as every other verification-backend fake (research.md §14).
    final CredentialIssuanceRepository credentialIssuanceRepository =
        _useFakeVerificationBackend
        ? DevCredentialIssuanceRepository(credentialService: credentialService)
        : CredentialIssuanceRepositoryImpl(
            CredentialIssuanceService(dio: dio),
            credentialService: credentialService,
            consentRepository: consentRepository,
          );
    final ScreenCaptureGuard screenCaptureGuard =
        defaultTargetPlatform == TargetPlatform.android
        ? const PlatformScreenCaptureGuard()
        : const NoopScreenCaptureGuard();

    // 007-validando: the read-only verification-job port (research.md §1),
    // dev fake behind the same flag as every other verification fake.
    final VerificationJobRepository verificationJobRepository =
        _useFakeVerificationBackend
        ? DevVerificationJobRepository()
        : VerificationJobRepositoryImpl(
            VerificationJobService(dio: dio),
            consentRepository: consentRepository,
          );

    // 010-escalar-agente: the escalation case and the informational chat,
    // dev fakes behind the same flag as every other verification fake.
    final EscalationRepository escalationRepository =
        _useFakeVerificationBackend
        ? DevEscalationRepository()
        : EscalationRepositoryImpl(
            EscalationService(dio: dio),
            consentRepository: consentRepository,
          );
    final AgentChatRepository agentChatRepository = _useFakeVerificationBackend
        ? DevAgentChatRepository()
        : AgentChatRepositoryImpl(AgentChatService(dio: dio));

    // 011-error-tecnico: the failure hand-off and retry pacing (in memory),
    // the live status source (a dev stand-in that never has a status), and
    // the operational alert (Sentry only when it is configured).
    final technicalErrorController = TechnicalErrorController();
    final ServiceStatusRepository serviceStatusRepository =
        _useFakeVerificationBackend
        ? const DevServiceStatusRepository()
        : ServiceStatusRepositoryImpl(
            ServiceStatusService(dio: dio),
            consentRepository: consentRepository,
          );
    final OperationalAlertReporter operationalAlertReporter =
        SentryConfig.isEnabled
        ? const SentryOperationalAlertReporter()
        : const NoopOperationalAlertReporter();

    // 012-mis-viajes: the trip source; the dev stand-in is a fixed domestic
    // itinerary. The last good snapshot lives in the instance, in memory.
    final TripRepository tripRepository = _useFakeVerificationBackend
        ? DevTripRepository(clock: clock)
        : TripRepositoryImpl(
            TripService(dio: dio),
            consentRepository: consentRepository,
            clock: clock,
          );

    // 014-qr-pase: the pass. Phase A fetches each code from the backend;
    // on-device derivation (phase B) waits on the constitution amendment.
    final clockTrustMonitor = ClockTrustMonitor(clock: clock);
    final passService = PassService(dio: dio);
    final PassRepository passRepository = _useFakeVerificationBackend
        ? DevPassRepository(clock: clock, clockTrustMonitor: clockTrustMonitor)
        : PassRepositoryImpl(
            passService,
            consentRepository: consentRepository,
            clockTrustMonitor: clockTrustMonitor,
            clock: clock,
          );
    final PassCodeSource passCodeSource = _useFakeVerificationBackend
        ? const DevPassCodeSource()
        : BackendPassCodeSource(passService, clockTrust: clockTrustMonitor);
    final DevicePostureChecker devicePostureChecker =
        _useFakeVerificationBackend
        ? const DevDevicePostureChecker()
        : const PlatformDevicePostureChecker();

    return MultiProvider(
      providers: [
        Provider<Clock>.value(value: clock),
        Provider<AnalyticsSessionId>.value(value: sessionId),
        Provider<CredentialRepository>.value(value: credentialRepository),
        Provider<ConsentRepository>.value(value: consentRepository),
        Provider<AnalyticsEmitter>.value(value: analyticsEmitter),
        Provider<FullDisplayReporter>.value(
          value: SentryConfig.isEnabled
              ? const SentryFullDisplayReporter()
              : const NoopFullDisplayReporter(),
        ),
        Provider<DeviceCapabilityChecker>.value(value: deviceCapabilityChecker),
        Provider<DocumentVerificationRepository>.value(
          value: documentVerificationRepository,
        ),
        Provider<DocumentQualityAssessor>.value(value: documentQualityAssessor),
        Provider<CaptureAttemptCounterRepository>.value(
          value: captureAttemptCounterRepository,
        ),
        Provider<CameraCaptureService>.value(value: cameraCaptureService),
        Provider<SystemSettingsLauncher>.value(value: systemSettingsLauncher),
        Provider<FieldReverificationRepository>.value(
          value: fieldReverificationRepository,
        ),
        Provider<IdentityRecordRepository>.value(
          value: identityRecordRepository,
        ),
        Provider<LivenessVerificationRepository>.value(
          value: livenessVerificationRepository,
        ),
        Provider<LivenessCameraService>.value(value: livenessCameraService),
        ChangeNotifierProvider<EnrollmentSessionController>.value(
          value: enrollmentSessionController,
        ),
        ChangeNotifierProvider<PendingDocumentController>.value(
          value: pendingDocumentController,
        ),
        Provider<ScreenCaptureGuard>.value(value: screenCaptureGuard),
        Provider<CredentialIssuanceRepository>.value(
          value: credentialIssuanceRepository,
        ),
        Provider<VerificationJobRepository>.value(
          value: verificationJobRepository,
        ),
        Provider<EscalationRepository>.value(value: escalationRepository),
        Provider<AgentChatRepository>.value(value: agentChatRepository),
        ChangeNotifierProvider<TechnicalErrorController>.value(
          value: technicalErrorController,
        ),
        Provider<ServiceStatusRepository>.value(value: serviceStatusRepository),
        Provider<CredentialSummaryRepository>.value(
          value: credentialSummaryRepository,
        ),
        Provider<TripRepository>.value(value: tripRepository),
        Provider<ClockTrustMonitor>.value(value: clockTrustMonitor),
        Provider<PassRepository>.value(value: passRepository),
        Provider<PassCodeSource>.value(value: passCodeSource),
        Provider<PassDisplayGuard>.value(
          value: const PlatformPassDisplayGuard(),
        ),
        Provider<DevicePostureChecker>.value(value: devicePostureChecker),
        Provider<OperationalAlertReporter>.value(
          value: operationalAlertReporter,
        ),
        ChangeNotifierProvider<ActivatedCredentialHandoff>.value(
          value: activatedCredentialHandoff,
        ),
      ],
      child: child,
    );
  }
}
