import 'package:clerk_flutter/clerk_flutter.dart' show ClerkAuthState;
import 'package:dio/dio.dart' show Dio;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../core/analytics_session.dart';
import '../core/clock.dart';
import '../core/happy_path_flags.dart';
import '../core/sentry_config.dart';
import '../core/synthetic_marker.dart';
import '../data/auth/auth_interceptor.dart';
import '../data/auth/clerk_session_token_provider.dart';
import '../data/auth/test_session_token_provider.dart';
import '../data/auth/unavailable_session_token_provider.dart';
import '../data/dev/dev_agent_chat_repository.dart';
import '../data/dev/dev_consent_repository.dart';
import '../data/dev/dev_credential_issuance_repository.dart';
import '../data/dev/dev_credential_repository.dart';
import '../data/dev/dev_credential_summary_repository.dart';
import '../data/dev/dev_device_posture_checker.dart';
import '../data/dev/dev_document_quality_assessor.dart';
import '../data/dev/dev_document_verification_repository.dart';
import '../data/dev/dev_escalation_repository.dart';
import '../data/dev/dev_field_reverification_repository.dart';
import '../data/dev/dev_identity_record_repository.dart';
import '../data/dev/dev_liveness_camera_service.dart';
import '../data/dev/dev_liveness_verification_repository.dart';
import '../data/dev/dev_pass_repository.dart';
import '../data/dev/dev_service_status_repository.dart';
import '../data/dev/dev_trip_repository.dart';
import '../data/dev/dev_verification_job_repository.dart';
import '../data/dev/synthetic_capture.dart';
import '../data/services/backend_biometric_verification_repository.dart';
import '../data/services/backend_identity_record_repository.dart';
import '../data/services/backend_pass_repository.dart';
import '../data/services/biometric_service.dart';
import '../data/services/camera_capture_service.dart';
import '../data/services/capture_attempt_counter_repository_impl.dart';
import '../data/services/capture_attempt_counter_service.dart';
import '../data/services/consent_service.dart';
import '../data/services/credential_service.dart';
import '../data/services/device_capability_service.dart';
import '../data/services/heuristic_quality_assessor.dart';
import '../data/services/issued_token_pass_code_source.dart';
import '../data/services/liveness_camera_service.dart';
import '../data/services/local_consent_repository.dart';
import '../data/services/local_document_capture_repository.dart';
import '../data/services/local_liveness_repository.dart';
import '../data/services/logging_analytics_emitter.dart';
import '../data/services/pass_service.dart';
import '../data/services/passenger_backed_credential_repository.dart';
import '../data/services/passenger_issuance_repository.dart';
import '../data/services/passenger_service.dart';
import '../data/services/diagnostics_interceptor.dart';
import '../data/services/pinned_dio_factory.dart';
import '../data/services/platform_pass_display.dart';
import '../data/services/screen_capture_guard.dart';
import '../data/services/sentry_operational_alert_reporter.dart';
import '../data/services/system_settings_launcher.dart';
import '../domain/repositories/agent_chat_repository.dart';
import '../domain/repositories/analytics_emitter.dart';
import '../domain/repositories/capture_attempt_counter_repository.dart';
import '../domain/repositories/consent_repository.dart';
import '../domain/repositories/credential_issuance_repository.dart';
import '../domain/repositories/credential_repository.dart';
import '../domain/repositories/credential_summary_repository.dart';
import '../domain/repositories/device_capability_checker.dart';
import '../domain/repositories/device_posture_checker.dart';
import '../domain/repositories/document_quality_assessor.dart';
import '../domain/repositories/document_verification_repository.dart';
import '../domain/repositories/escalation_repository.dart';
import '../domain/repositories/field_reverification_repository.dart';
import '../domain/repositories/identity_record_repository.dart';
import '../domain/repositories/liveness_verification_repository.dart';
import '../domain/repositories/operational_alert_reporter.dart';
import '../domain/repositories/pass_code_source.dart';
import '../domain/repositories/pass_display_guard.dart';
import '../domain/repositories/pass_repository.dart';
import '../domain/repositories/passenger_repository.dart';
import '../domain/repositories/service_status_repository.dart';
import '../domain/repositories/session_token_provider.dart';
import '../domain/repositories/trip_repository.dart';
import '../domain/repositories/verification_job_repository.dart';
import 'activated_credential_handoff.dart';
import 'clock_trust_monitor.dart';
import 'enrollment_session_controller.dart';
import 'flight_code_handoff.dart';
import 'pending_document_controller.dart';
import 'server_backed_attempt_counter_repository.dart';
import 'session_gate.dart';
import 'submission_backed_job_repository.dart';
import 'technical_error_controller.dart';
import 'verification_submission.dart';

/// Wires every dependency the app needs, once, at the app's entry point
/// (Constitution Principle IX: "composition happens at the app's entry
/// point and at route boundaries" — never inside a widget or ViewModel via
/// a service locator or singleton lookup).
///
/// Two wirings (015 contracts/flavor-wiring.md):
///
/// - **dev-offline** (`USE_FAKE_VERIFICATION_BACKEND`): every port is a dev
///   fake, and nothing talks to a backend. It is the offline demo, and a
///   release build refuses the flag.
/// - **every other build** (dev with a local backend, staging, prod): the
///   ports the real backend serves are wired to it. The ports it does not
///   serve are local, or **not wired**. A port that is not wired is
///   provided as `null`, and its screen shows its release variant (Q3). No
///   class that calls a path the backend lacks is constructed here (FR-025).
class CompositionRoot extends StatelessWidget {
  const CompositionRoot({
    required this.child,
    required this.trustAnchors,
    this.clerkAuthState,
    super.key,
  });

  final Widget child;

  /// Clerk's embedded auth state, created in `main()` when sign-in is
  /// required (the Clerk flavors with a publishable key). Null in dev and in
  /// the offline demo.
  final ClerkAuthState? clerkAuthState;

  /// The only TLS roots every backend client trusts (015 research.md §4),
  /// loaded from `assets/tls/` in `main()` before the first frame.
  final TrustAnchors trustAnchors;

  // Selected per flavor via API_BASE_URL in env/ (passed with
  // --dart-define-from-file). The default is the deployed service, so a
  // build with no env file still talks to a real host through the pinned
  // client.
  static const _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://aeropass-lac.vercel.app',
  );

  static const _offline = HappyPathFlags.useFakeVerificationBackend;
  static const _fakeConsent = HappyPathFlags.useFakeConsentBackend;

  @override
  Widget build(BuildContext context) {
    const clock = SystemClock();
    const secureStorage = FlutterSecureStorage();
    final sessionId = AnalyticsSessionId.generate();

    final dio = buildPinnedDio(
      baseUrl: _baseUrl,
      anchors: trustAnchors,
      allowInsecureHttp: HappyPathFlags.allowInsecureLocalBackend,
    );
    // 015 FR-001, the backend's authentication document: one token per
    // `/v1/*` call. Dev answers `test:<id>` for a local fake-mode backend.
    // Staging and prod sign in by email code through Clerk. The session is
    // held in memory until amendment A3 allows storing it (T024). With no
    // publishable key, calls fail honestly with SessionUnavailable.
    final clerk = clerkAuthState;
    final SessionGate? sessionGate = clerk == null ? null : SessionGate();
    final SessionTokenProvider sessionTokenProvider =
        HappyPathFlags.authMode == AuthMode.test
        ? TestSessionTokenProvider(secureStorage: secureStorage)
        : clerk != null
        ? ClerkSessionTokenProvider(
            ClerkAuthStateSession(clerk),
            gate: sessionGate!,
          )
        : const UnavailableSessionTokenProvider();
    dio.interceptors
      ..add(AuthInterceptor(tokens: sessionTokenProvider, dio: dio))
      // After the auth interceptor, so each attempt, retry included, is
      // logged.
      ..add(DiagnosticsInterceptor());

    final credentialService = CredentialService(secureStorage: secureStorage);
    final AnalyticsEmitter analyticsEmitter = LoggingAnalyticsEmitter(
      sessionId: sessionId,
      clock: clock,
    );
    final enrollmentSessionController = EnrollmentSessionController(
      clock: clock,
    );
    final pendingDocumentController = PendingDocumentController();
    final activatedCredentialHandoff = ActivatedCredentialHandoff();
    final technicalErrorController = TechnicalErrorController();
    final clockTrustMonitor = ClockTrustMonitor(clock: clock);
    final syntheticMarkerSelection = SyntheticMarkerSelection();
    final flightCodeHandoff = FlightCodeHandoff();
    const DeviceCapabilityChecker deviceCapabilityChecker =
        DeviceCapabilityService();
    const SystemSettingsLauncher systemSettingsLauncher =
        PlatformSystemSettingsLauncher();
    final ScreenCaptureGuard screenCaptureGuard =
        defaultTargetPlatform == TargetPlatform.android
        ? const PlatformScreenCaptureGuard()
        : const NoopScreenCaptureGuard();
    final OperationalAlertReporter operationalAlertReporter =
        SentryConfig.isEnabled
        ? const SentryOperationalAlertReporter()
        : const NoopOperationalAlertReporter();
    final localAttemptCounters = CaptureAttemptCounterRepositoryImpl(
      CaptureAttemptCounterService(secureStorage: secureStorage),
      clock: clock,
    );

    final ConsentRepository consentRepository = _fakeConsent
        ? DevConsentRepository(credentialService: credentialService)
        : LocalConsentRepository(
            ConsentService(secureStorage: secureStorage),
            credentialService: credentialService,
            sessionTokenProvider: sessionTokenProvider,
            clock: clock,
          );

    final ports = _offline
        ? _Ports.devOffline(
            credentialService: credentialService,
            clock: clock,
            clockTrustMonitor: clockTrustMonitor,
            localAttemptCounters: localAttemptCounters,
          )
        : _Ports.backend(
            dio: dio,
            credentialService: credentialService,
            clock: clock,
            clockTrustMonitor: clockTrustMonitor,
            localAttemptCounters: localAttemptCounters,
            syntheticMarkerSelection: syntheticMarkerSelection,
          );

    return MultiProvider(
      providers: [
        Provider<Clock>.value(value: clock),
        Provider<AnalyticsSessionId>.value(value: sessionId),
        Provider<SessionTokenProvider>.value(value: sessionTokenProvider),
        Provider<ClerkAuthState?>.value(value: clerk),
        ChangeNotifierProvider<SessionGate?>.value(value: sessionGate),
        Provider<ConsentRepository>.value(value: consentRepository),
        Provider<AnalyticsEmitter>.value(value: analyticsEmitter),
        Provider<DeviceCapabilityChecker>.value(value: deviceCapabilityChecker),
        Provider<SystemSettingsLauncher>.value(value: systemSettingsLauncher),
        Provider<ScreenCaptureGuard>.value(value: screenCaptureGuard),
        Provider<OperationalAlertReporter>.value(
          value: operationalAlertReporter,
        ),
        Provider<ClockTrustMonitor>.value(value: clockTrustMonitor),
        Provider<PassDisplayGuard>.value(
          value: const PlatformPassDisplayGuard(),
        ),
        ChangeNotifierProvider<EnrollmentSessionController>.value(
          value: enrollmentSessionController,
        ),
        ChangeNotifierProvider<PendingDocumentController>.value(
          value: pendingDocumentController,
        ),
        ChangeNotifierProvider<ActivatedCredentialHandoff>.value(
          value: activatedCredentialHandoff,
        ),
        ChangeNotifierProvider<TechnicalErrorController>.value(
          value: technicalErrorController,
        ),
        ChangeNotifierProvider<SyntheticMarkerSelection>.value(
          value: syntheticMarkerSelection,
        ),
        ChangeNotifierProvider<FlightCodeHandoff>.value(
          value: flightCodeHandoff,
        ),
        // The ports that differ between the two wirings.
        Provider<CredentialRepository>.value(value: ports.credential),
        Provider<CredentialSummaryRepository>.value(
          value: ports.credentialSummary,
        ),
        Provider<PassengerRepository?>.value(value: ports.passenger),
        Provider<DocumentVerificationRepository>.value(
          value: ports.documentVerification,
        ),
        Provider<DocumentQualityAssessor>.value(value: ports.qualityAssessor),
        Provider<CaptureAttemptCounterRepository>.value(
          value: ports.attemptCounters,
        ),
        Provider<CameraCaptureService>.value(value: ports.documentCamera),
        Provider<FieldReverificationRepository?>.value(
          value: ports.fieldReverification,
        ),
        Provider<IdentityRecordRepository>.value(value: ports.identityRecord),
        Provider<LivenessVerificationRepository>.value(value: ports.liveness),
        Provider<LivenessCameraService>.value(value: ports.livenessCamera),
        Provider<VerificationSubmission?>.value(
          value: ports.verificationSubmission,
        ),
        Provider<CredentialIssuanceRepository>.value(value: ports.issuance),
        Provider<VerificationJobRepository>.value(value: ports.verificationJob),
        Provider<EscalationRepository?>.value(value: ports.escalation),
        Provider<AgentChatRepository?>.value(value: ports.agentChat),
        Provider<ServiceStatusRepository?>.value(value: ports.serviceStatus),
        Provider<TripRepository?>.value(value: ports.trips),
        Provider<PassRepository>.value(value: ports.pass),
        Provider<PassCodeSource>.value(value: ports.passCode),
        Provider<DevicePostureChecker>.value(value: ports.devicePosture),
      ],
      child: child,
    );
  }
}

/// The ports whose implementation depends on the wiring (015
/// contracts/flavor-wiring.md, "Port wiring"). A `null` field is a port
/// that is not wired.
class _Ports {
  _Ports._({
    required this.credential,
    required this.credentialSummary,
    required this.passenger,
    required this.documentVerification,
    required this.qualityAssessor,
    required this.attemptCounters,
    required this.documentCamera,
    required this.fieldReverification,
    required this.identityRecord,
    required this.liveness,
    required this.livenessCamera,
    required this.verificationSubmission,
    required this.issuance,
    required this.verificationJob,
    required this.escalation,
    required this.agentChat,
    required this.serviceStatus,
    required this.trips,
    required this.pass,
    required this.passCode,
    required this.devicePosture,
  });

  /// The offline demo: every port is a dev fake.
  factory _Ports.devOffline({
    required CredentialService credentialService,
    required Clock clock,
    required ClockTrustMonitor clockTrustMonitor,
    required CaptureAttemptCounterRepository localAttemptCounters,
  }) => _Ports._(
    credential: DevCredentialRepository(credentialService: credentialService),
    credentialSummary: DevCredentialSummaryRepository(
      credentialService: credentialService,
    ),
    passenger: null,
    documentVerification: DevDocumentVerificationRepository(),
    qualityAssessor: const DevDocumentQualityAssessor(),
    attemptCounters: localAttemptCounters,
    documentCamera: CameraPluginCaptureService(),
    fieldReverification: DevFieldReverificationRepository(),
    identityRecord: DevIdentityRecordRepository(),
    liveness: DevLivenessVerificationRepository(),
    livenessCamera: DevLivenessCameraService(),
    verificationSubmission: null,
    issuance: DevCredentialIssuanceRepository(
      credentialService: credentialService,
    ),
    verificationJob: DevVerificationJobRepository(),
    escalation: DevEscalationRepository(),
    agentChat: DevAgentChatRepository(),
    serviceStatus: const DevServiceStatusRepository(),
    trips: DevTripRepository(clock: clock),
    pass: DevPassRepository(clock: clock, clockTrustMonitor: clockTrustMonitor),
    passCode: const DevPassCodeSource(),
    devicePosture: const DevDevicePostureChecker(),
  );

  /// The real backend (research.md §7 to §11): registration, `/me`,
  /// verification and the pass, over the five real endpoints. Consent,
  /// document capture and the liveness challenge stay on the device.
  /// Escalation, chat, service status, trips and field re-verification are
  /// not wired.
  factory _Ports.backend({
    required Dio dio,
    required CredentialService credentialService,
    required Clock clock,
    required ClockTrustMonitor clockTrustMonitor,
    required CaptureAttemptCounterRepository localAttemptCounters,
    required SyntheticMarkerSelection syntheticMarkerSelection,
  }) {
    final passengerService = PassengerService(dio: dio);
    final passengers = PassengerBackedCredentialRepository(
      passengerService,
      credentialService: credentialService,
      clock: clock,
    );
    final verificationSubmission = VerificationSubmission(
      repository: BackendBiometricVerificationRepository(
        BiometricService(dio: dio),
      ),
    );
    final passRepository = BackendPassRepository(
      PassService(dio: dio),
      clockTrustMonitor: clockTrustMonitor,
    );
    // 015 FR-018: in dev and staging the backend receives only generated
    // marker images, never a camera frame.
    final CameraCaptureService documentCamera = HappyPathFlags.syntheticCapture
        ? SyntheticCameraCaptureService(CameraPluginCaptureService())
        : CameraPluginCaptureService();
    final LivenessCameraService livenessCamera = HappyPathFlags.syntheticCapture
        ? SyntheticLivenessCameraService(
            FrontCameraLivenessService(),
            selection: syntheticMarkerSelection,
          )
        : FrontCameraLivenessService();
    return _Ports._(
      credential: passengers,
      credentialSummary: passengers,
      passenger: passengers,
      documentVerification: const LocalDocumentCaptureRepository(),
      qualityAssessor: const HeuristicQualityAssessor(),
      attemptCounters: ServerBackedAttemptCounterRepository(
        local: localAttemptCounters,
        submission: verificationSubmission,
        clock: clock,
      ),
      documentCamera: documentCamera,
      fieldReverification: null,
      identityRecord: BackendIdentityRecordRepository(
        passengerService,
        credentialService: credentialService,
      ),
      liveness: LocalLivenessRepository(),
      livenessCamera: livenessCamera,
      verificationSubmission: verificationSubmission,
      issuance: PassengerIssuanceRepository(passengers, clock: clock),
      verificationJob: SubmissionBackedJobRepository(verificationSubmission),
      escalation: null,
      agentChat: null,
      serviceStatus: null,
      trips: null,
      pass: passRepository,
      passCode: IssuedTokenPassCodeSource(passRepository),
      devicePosture: const PlatformDevicePostureChecker(),
    );
  }

  final CredentialRepository credential;
  final CredentialSummaryRepository credentialSummary;
  final PassengerRepository? passenger;
  final DocumentVerificationRepository documentVerification;
  final DocumentQualityAssessor qualityAssessor;
  final CaptureAttemptCounterRepository attemptCounters;
  final CameraCaptureService documentCamera;
  final FieldReverificationRepository? fieldReverification;
  final IdentityRecordRepository identityRecord;
  final LivenessVerificationRepository liveness;
  final LivenessCameraService livenessCamera;
  final VerificationSubmission? verificationSubmission;
  final CredentialIssuanceRepository issuance;
  final VerificationJobRepository verificationJob;
  final EscalationRepository? escalation;
  final AgentChatRepository? agentChat;
  final ServiceStatusRepository? serviceStatus;
  final TripRepository? trips;
  final PassRepository pass;
  final PassCodeSource passCode;
  final DevicePostureChecker devicePosture;
}
