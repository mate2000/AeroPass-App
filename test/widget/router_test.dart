// T038: verifies FR-007/FR-018's invariant directly at the router level —
// the document-capture route (003-escanear-documento's real `CaptureView`
// since T026) is unreachable without a prior `Ok` from
// `ConsentRepository.recordConsent()` (i.e. a currently-active, current
// local `ConsentRecord`). Uses the app's REAL `buildAppRouter()`, unlike
// `consent_view_test.dart`'s isolated router, since the invariant lives in
// `router.dart`'s own `_redirect` function.
import 'package:aeropass_app/app/enrollment_session_controller.dart';
import 'package:aeropass_app/app/router.dart';
import 'package:aeropass_app/core/clock.dart';
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/data/services/capture_attempt_counter_repository_impl.dart';
import 'package:aeropass_app/data/services/capture_attempt_counter_service.dart';
import 'package:aeropass_app/data/services/heuristic_quality_assessor.dart';
import 'package:aeropass_app/domain/entities/consent_record.dart';
import 'package:aeropass_app/domain/entities/consent_text_version.dart';
import 'package:aeropass_app/domain/entities/enrollment_attempt_id.dart';
import 'package:aeropass_app/domain/entities/processing_scope.dart';
import 'package:aeropass_app/domain/repositories/analytics_emitter.dart';
import 'package:aeropass_app/domain/repositories/capture_attempt_counter_repository.dart';
import 'package:aeropass_app/domain/repositories/consent_repository.dart';
import 'package:aeropass_app/domain/repositories/credential_repository.dart';
import 'package:aeropass_app/domain/repositories/device_capability_checker.dart';
import 'package:aeropass_app/domain/repositories/document_quality_assessor.dart';
import 'package:aeropass_app/domain/repositories/document_verification_repository.dart';
import 'package:aeropass_app/data/services/camera_capture_service.dart';
import 'package:aeropass_app/data/services/system_settings_launcher.dart';
import 'package:aeropass_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../fakes/fake_analytics_emitter.dart';
import '../fakes/fake_camera_capture_service.dart';
import '../fakes/fake_consent_repository.dart';
import '../fakes/fake_credential_repository.dart';
import '../fakes/fake_device_capability_checker.dart';
import '../fakes/fake_document_verification_repository.dart';
import '../fakes/fake_secure_storage_platform.dart';
import '../fakes/fake_system_settings_launcher.dart';

class _FixedClock implements Clock {
  const _FixedClock();
  @override
  DateTime now() => DateTime.utc(2026, 1, 1);
}

ConsentTextVersion _sampleText() => ConsentTextVersion(
  id: 'v1',
  points: const [
    ConsentPoint(
      icon: ConsentPointIcon.camera,
      heading: '[PLACEHOLDER] Qué se captura',
      body: '[PLACEHOLDER LEGAL TEXT]',
    ),
  ],
  rightsStatement: '[PLACEHOLDER] Tus derechos',
  optionalityStatement: '[PLACEHOLDER] Es opcional',
  processorDisclosure: '[PLACEHOLDER] Procesador externo',
  privacyPolicyUrl: 'https://example.test/privacy',
  termsUrl: 'https://example.test/terms',
  publishedAt: DateTime.utc(2026, 1, 1),
);

Future<void> _pumpApp(
  WidgetTester tester, {
  required String initialLocation,
  required FakeConsentRepository consentRepository,
}) async {
  final credentialRepository = FakeCredentialRepository();
  final deviceCapabilityChecker = FakeDeviceCapabilityChecker();
  final analyticsEmitter = FakeAnalyticsEmitter();
  final sessionController = EnrollmentSessionController(
    clock: const _FixedClock(),
  );

  // 003-escanear-documento: CaptureView's route now builds a real
  // CaptureViewModel, which needs these additional dependencies —
  // fakes/no-hardware doubles throughout, same pattern as the app's other
  // widget tests.
  FlutterSecureStoragePlatform.instance = FakeSecureStoragePlatform();
  final cameraCaptureService = FakeCameraCaptureService();
  const qualityAssessor = HeuristicQualityAssessor();
  final verificationRepository = FakeDocumentVerificationRepository();
  final attemptCounterRepository = CaptureAttemptCounterRepositoryImpl(
    CaptureAttemptCounterService(secureStorage: const FlutterSecureStorage()),
    clock: const _FixedClock(),
  );
  final systemSettingsLauncher = FakeSystemSettingsLauncher();

  final router = buildAppRouter(initialLocation: initialLocation);
  addTearDown(router.dispose);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<CredentialRepository>.value(value: credentialRepository),
        Provider<ConsentRepository>.value(value: consentRepository),
        Provider<AnalyticsEmitter>.value(value: analyticsEmitter),
        Provider<DeviceCapabilityChecker>.value(value: deviceCapabilityChecker),
        Provider<CameraCaptureService>.value(value: cameraCaptureService),
        Provider<DocumentQualityAssessor>.value(value: qualityAssessor),
        Provider<DocumentVerificationRepository>.value(
          value: verificationRepository,
        ),
        Provider<CaptureAttemptCounterRepository>.value(
          value: attemptCounterRepository,
        ),
        Provider<SystemSettingsLauncher>.value(value: systemSettingsLauncher),
        ChangeNotifierProvider<EnrollmentSessionController>.value(
          value: sessionController,
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('T038: FR-007/FR-018 invariant', () {
    testWidgets(
      'navigating straight to the document-capture route with no local '
      'consent record redirects back to the consent gate',
      (tester) async {
        final consentRepository = FakeConsentRepository();
        consentRepository.seedLocalRecord(null);
        consentRepository.scriptCurrentText(Result.ok(_sampleText()));

        await _pumpApp(
          tester,
          initialLocation: AppRoutes.documentCapture,
          consentRepository: consentRepository,
        );

        expect(
          find.text('Ubica tu cédula o pasaporte dentro del marco'),
          findsNothing,
        );
        expect(find.text('Cómo tratamos tus datos'), findsWidgets);
      },
    );

    testWidgets(
      'navigating to the document-capture route with a current, active '
      'local consent record is allowed through to the real CaptureView',
      (tester) async {
        final consentRepository = FakeConsentRepository();
        consentRepository.seedLocalRecord(
          ConsentRecord(
            textVersionId: 'v1',
            enrollmentAttemptId: EnrollmentAttemptId.generate(),
            scope: ProcessingScope.identityVerification,
            confirmedAt: DateTime.utc(2026, 1, 1),
            status: ConsentRecordStatus.active,
          ),
        );
        consentRepository.scriptCurrentText(Result.ok(_sampleText()));

        await _pumpApp(
          tester,
          initialLocation: AppRoutes.documentCapture,
          consentRepository: consentRepository,
        );

        // Not redirected back to the consent gate...
        expect(find.text('Cómo tratamos tus datos'), findsNothing);
        // ...and the real CaptureView (003-escanear-documento) rendered.
        expect(
          find.text('Ubica tu cédula o pasaporte dentro del marco'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'a local consent record referring to a superseded text version does '
      'NOT count as current — redirected back to the consent gate '
      '(FR-001)',
      (tester) async {
        final consentRepository = FakeConsentRepository();
        consentRepository.seedLocalRecord(
          ConsentRecord(
            textVersionId: 'v0-superseded',
            enrollmentAttemptId: EnrollmentAttemptId.generate(),
            scope: ProcessingScope.identityVerification,
            confirmedAt: DateTime.utc(2026, 1, 1),
            status: ConsentRecordStatus.active,
          ),
        );
        consentRepository.scriptCurrentText(Result.ok(_sampleText()));

        await _pumpApp(
          tester,
          initialLocation: AppRoutes.documentCapture,
          consentRepository: consentRepository,
        );

        expect(
          find.text('Ubica tu cédula o pasaporte dentro del marco'),
          findsNothing,
        );
        expect(find.text('Cómo tratamos tus datos'), findsWidgets);
      },
    );

    testWidgets(
      'a withdrawn local consent record does not count as active — '
      'redirected back to the consent gate',
      (tester) async {
        final consentRepository = FakeConsentRepository();
        consentRepository.seedLocalRecord(
          ConsentRecord(
            textVersionId: 'v1',
            enrollmentAttemptId: EnrollmentAttemptId.generate(),
            scope: ProcessingScope.identityVerification,
            confirmedAt: DateTime.utc(2026, 1, 1),
            status: ConsentRecordStatus.withdrawn,
            withdrawalRequestedAt: DateTime.utc(2026, 1, 2),
          ),
        );
        consentRepository.scriptCurrentText(Result.ok(_sampleText()));

        await _pumpApp(
          tester,
          initialLocation: AppRoutes.documentCapture,
          consentRepository: consentRepository,
        );

        expect(
          find.text('Ubica tu cédula o pasaporte dentro del marco'),
          findsNothing,
        );
        expect(find.text('Cómo tratamos tus datos'), findsWidgets);
      },
    );
  });
}
