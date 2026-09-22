import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../core/analytics_session.dart';
import '../core/clock.dart';
import '../core/happy_path_flags.dart';
import '../data/dev/dev_consent_repository.dart';
import '../data/dev/dev_document_quality_assessor.dart';
import '../data/dev/dev_document_verification_repository.dart';
import '../data/dev/dev_field_reverification_repository.dart';
import '../data/dev/dev_identity_record_repository.dart';
import '../data/dev/dev_liveness_camera_service.dart';
import '../data/dev/dev_liveness_verification_repository.dart';
import '../data/services/camera_capture_service.dart';
import '../data/services/capture_attempt_counter_repository_impl.dart';
import '../data/services/capture_attempt_counter_service.dart';
import '../data/services/consent_repository_impl.dart';
import '../data/services/consent_service.dart';
import '../data/services/credential_repository_impl.dart';
import '../data/services/credential_service.dart';
import '../data/services/device_capability_service.dart';
import '../data/services/document_verification_repository_impl.dart';
import '../data/services/document_verification_service.dart';
import '../data/services/field_reverification_repository_impl.dart';
import '../data/services/field_reverification_service.dart';
import '../data/services/heuristic_quality_assessor.dart';
import '../data/services/identity_record_repository_impl.dart';
import '../data/services/identity_record_service.dart';
import '../data/services/liveness_camera_service.dart';
import '../data/services/liveness_verification_repository_impl.dart';
import '../data/services/liveness_verification_service.dart';
import '../data/services/logging_analytics_emitter.dart';
import '../data/services/pinned_dio_factory.dart';
import '../data/services/system_settings_launcher.dart';
import '../domain/repositories/analytics_emitter.dart';
import '../domain/repositories/capture_attempt_counter_repository.dart';
import '../domain/repositories/consent_repository.dart';
import '../domain/repositories/credential_repository.dart';
import '../domain/repositories/device_capability_checker.dart';
import '../domain/repositories/document_quality_assessor.dart';
import '../domain/repositories/document_verification_repository.dart';
import '../domain/repositories/field_reverification_repository.dart';
import '../domain/repositories/identity_record_repository.dart';
import '../domain/repositories/liveness_verification_repository.dart';
import 'enrollment_session_controller.dart';
import 'pending_document_controller.dart';

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
  // --dart-define=API_BASE_URL=... (see .vscode/launch.json's Dev/Prod
  // configs); the real per-flavor (dev/staging/prod) pinned certificate
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
    final CredentialRepository credentialRepository = CredentialRepositoryImpl(
      credentialService,
    );
    final ConsentRepository consentRepository;
    if (_useFakeConsentBackend) {
      consentRepository = DevConsentRepository();
    } else {
      final consentService = ConsentService(
        dio: dio,
        secureStorage: const FlutterSecureStorage(),
      );
      consentRepository = ConsentRepositoryImpl(consentService, clock: clock);
    }
    final AnalyticsEmitter analyticsEmitter = LoggingAnalyticsEmitter(
      sessionId: sessionId,
      clock: clock,
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
      final livenessVerificationService = LivenessVerificationService(
        dio: dio,
      );
      livenessVerificationRepository = LivenessVerificationRepositoryImpl(
        livenessVerificationService,
      );
      livenessCameraService = FrontCameraLivenessService();
    }

    return MultiProvider(
      providers: [
        Provider<Clock>.value(value: clock),
        Provider<AnalyticsSessionId>.value(value: sessionId),
        Provider<CredentialRepository>.value(value: credentialRepository),
        Provider<ConsentRepository>.value(value: consentRepository),
        Provider<AnalyticsEmitter>.value(value: analyticsEmitter),
        Provider<DeviceCapabilityChecker>.value(value: deviceCapabilityChecker),
        Provider<DocumentVerificationRepository>.value(
          value: documentVerificationRepository,
        ),
        Provider<DocumentQualityAssessor>.value(
          value: documentQualityAssessor,
        ),
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
      ],
      child: child,
    );
  }
}
