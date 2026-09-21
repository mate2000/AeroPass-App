import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../core/analytics_session.dart';
import '../core/clock.dart';
import '../data/dev/dev_consent_repository.dart';
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
import '../data/services/heuristic_quality_assessor.dart';
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
import 'enrollment_session_controller.dart';

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

  // Dev-only escape hatch: with no backend deployed yet, the consent
  // gate's text fetch always fails and blocks (by design — research.md
  // §5's "never fall back on a failed fetch" rule). This flag swaps in
  // `DevConsentRepository` so the gate can be reviewed against the UI
  // reference locally. Never set true in the prod launch config
  // (.vscode/launch.json); production behavior is unaffected either way,
  // since `ConsentRepositoryImpl` itself has no fallback path.
  static const _useFakeConsentBackend = bool.fromEnvironment(
    'USE_FAKE_CONSENT_BACKEND',
  );

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
    final documentVerificationService = DocumentVerificationService(dio: dio);
    final DocumentVerificationRepository documentVerificationRepository =
        DocumentVerificationRepositoryImpl(documentVerificationService);
    const DocumentQualityAssessor documentQualityAssessor =
        HeuristicQualityAssessor();
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
        ChangeNotifierProvider<EnrollmentSessionController>.value(
          value: enrollmentSessionController,
        ),
      ],
      child: child,
    );
  }
}
