// T038: verifies FR-007/FR-018's invariant directly at the router level —
// the document-capture route (003-escanear-documento's real `CaptureView`
// since T026) is unreachable without a prior `Ok` from
// `ConsentRepository.recordConsent()` (i.e. a currently-active, current
// local `ConsentRecord`). Uses the app's REAL `buildAppRouter()`, unlike
// `consent_view_test.dart`'s isolated router, since the invariant lives in
// `router.dart`'s own `_redirect` function.
import 'package:aeropass_app/app/activated_credential_handoff.dart';
import 'package:aeropass_app/app/enrollment_session_controller.dart';
import 'package:aeropass_app/app/pending_document_controller.dart';
import 'package:aeropass_app/app/router.dart';
import 'package:aeropass_app/app/technical_error_controller.dart';
import 'package:aeropass_app/domain/entities/trip.dart';
import 'package:aeropass_app/domain/entities/pass.dart';
import 'package:aeropass_app/app/clock_trust_monitor.dart';
import 'package:aeropass_app/domain/repositories/device_posture_checker.dart';
import 'package:aeropass_app/domain/repositories/pass_code_source.dart';
import 'package:aeropass_app/domain/repositories/pass_display_guard.dart';
import 'package:aeropass_app/domain/repositories/pass_repository.dart';
import 'package:aeropass_app/features/pass/widgets/qr_code_painter.dart';
import 'package:aeropass_app/domain/repositories/credential_summary_repository.dart';
import 'package:aeropass_app/domain/repositories/trip_repository.dart';
import 'package:aeropass_app/features/account/withdrawal_placeholder_view.dart';
import 'package:aeropass_app/features/credential/credential_detail_placeholder_view.dart';
import 'package:aeropass_app/domain/entities/verification_outcome.dart';
import 'package:aeropass_app/domain/repositories/operational_alert_reporter.dart';
import 'package:aeropass_app/domain/repositories/service_status_repository.dart';
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
import 'package:aeropass_app/domain/repositories/credential_issuance_repository.dart';
import 'package:aeropass_app/domain/repositories/credential_repository.dart';
import 'package:aeropass_app/domain/repositories/verification_job_repository.dart';
import 'package:aeropass_app/domain/repositories/escalation_repository.dart';
import 'package:aeropass_app/domain/entities/escalation.dart';
import 'package:aeropass_app/domain/entities/verification_job_status.dart';
import 'package:aeropass_app/domain/repositories/device_capability_checker.dart';
import 'package:aeropass_app/domain/repositories/document_quality_assessor.dart';
import 'package:aeropass_app/domain/repositories/document_verification_repository.dart';
import 'package:aeropass_app/domain/repositories/field_reverification_repository.dart';
import 'package:aeropass_app/domain/repositories/identity_record_repository.dart';
import 'package:aeropass_app/data/services/camera_capture_service.dart';
import 'package:aeropass_app/data/services/screen_capture_guard.dart';
import 'package:aeropass_app/data/services/system_settings_launcher.dart';
import 'package:aeropass_app/domain/entities/activated_credential.dart';
import 'package:aeropass_app/domain/entities/credential_status.dart';
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
import '../fakes/fake_field_reverification_repository.dart';
import '../fakes/fake_identity_record_repository.dart';
import '../fakes/fake_screen_capture_guard.dart';
import '../fakes/fake_credential_issuance_repository.dart';
import '../fakes/fake_verification_job_repository.dart';
import '../fakes/fake_escalation_repository.dart';
import '../fakes/fake_secure_storage_platform.dart';
import '../fakes/fake_operational_alert_reporter.dart';
import '../fakes/fake_service_status_repository.dart';
import '../fakes/fake_credential_summary_repository.dart';
import '../fakes/fake_trip_repository.dart';
import '../fakes/fake_pass_display.dart';
import '../fakes/fake_pass_repository.dart';
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
  FakeCredentialRepository? credentialRepository,
  ActivatedCredentialHandoff? activatedCredentialHandoff,
  FakeEscalationRepository? escalationRepository,
  FakeVerificationJobRepository? jobRepository,
  EnrollmentSessionController? enrollmentSessionController,
  bool settle = true,
  FakeCredentialSummaryRepository? summaryRepository,
  FakeTripRepository? tripRepository,
  FakePassRepository? passRepository,
}) async {
  // 010: with nothing scripted every escalation read fails, so harnesses that
  // do not care about escalations keep 001's launch behaviour unchanged.
  final escalations = escalationRepository ?? FakeEscalationRepository();
  final credentials = credentialRepository ?? FakeCredentialRepository();
  final handoff = activatedCredentialHandoff ?? ActivatedCredentialHandoff();
  final deviceCapabilityChecker = FakeDeviceCapabilityChecker();
  final analyticsEmitter = FakeAnalyticsEmitter();
  final sessionController =
      enrollmentSessionController ??
      EnrollmentSessionController(clock: const _FixedClock());

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

  // 004-confirmar-datos: reachable from the document-capture route's own
  // accepted path, so its dependencies must be providable even when this
  // test's `initialLocation` is `documentCapture` itself.
  final fieldReverificationRepository = FakeFieldReverificationRepository();
  final identityRecordRepository = FakeIdentityRecordRepository();
  final pendingDocumentController = PendingDocumentController();

  final router = buildAppRouter(initialLocation: initialLocation);
  addTearDown(router.dispose);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<CredentialRepository>.value(value: credentials),
        Provider<ScreenCaptureGuard>.value(value: FakeScreenCaptureGuard()),
        // 007: reachable from screen 11's "Reintentar"; the job stays in
        // progress, with no resume window, so nothing navigates on its own
        // and launch behaves as before (011).
        Provider<VerificationJobRepository>.value(
          value:
              jobRepository ??
              (FakeVerificationJobRepository()..scriptResults([
                const Result.ok(
                  VerificationJobStatus.inProgress(
                    documentCheck: StageStatus.running,
                    faceComparison: StageStatus.pending,
                  ),
                ),
              ])),
        ),
        // 011: screen 11's dependencies. No status source and no alert.
        ChangeNotifierProvider<TechnicalErrorController>(
          create: (_) => TechnicalErrorController(),
        ),
        Provider<ServiceStatusRepository>.value(
          value: FakeServiceStatusRepository(),
        ),
        Provider<OperationalAlertReporter>.value(
          value: FakeOperationalAlertReporter(),
        ),
        // 012: Mis viajes. By default the summary cannot be read and there
        // are no trips, so the home shows its empty state.
        Provider<CredentialSummaryRepository>.value(
          value: summaryRepository ?? FakeCredentialSummaryRepository(),
        ),
        Provider<TripRepository>.value(
          value:
              tripRepository ??
              (FakeTripRepository()..scriptResults([
                Result.ok(
                  TripsSnapshot(
                    history: const [],
                    fetchedAt: DateTime.utc(2026, 1, 1),
                  ),
                ),
              ])),
        ),
        // 014: the pass. Trusted clock, trusted device, and a fake issuer.
        Provider<ClockTrustMonitor>.value(
          value: ClockTrustMonitor(clock: const _FixedClock())
            ..observeServerTime(DateTime.utc(2026, 1, 1)),
        ),
        Provider<PassRepository>.value(
          value: passRepository ?? FakePassRepository(),
        ),
        Provider<PassCodeSource>.value(value: FakePassCodeSource()),
        Provider<PassDisplayGuard>.value(value: FakePassDisplayGuard()),
        Provider<DevicePostureChecker>.value(value: FakeDevicePostureChecker()),
        Provider<CredentialIssuanceRepository>.value(
          value: FakeCredentialIssuanceRepository(),
        ),
        Provider<EscalationRepository>.value(value: escalations),
        ChangeNotifierProvider<ActivatedCredentialHandoff>.value(
          value: handoff,
        ),
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
        Provider<FieldReverificationRepository>.value(
          value: fieldReverificationRepository,
        ),
        Provider<IdentityRecordRepository>.value(
          value: identityRecordRepository,
        ),
        Provider<Clock>.value(value: const _FixedClock()),
        ChangeNotifierProvider<EnrollmentSessionController>.value(
          value: sessionController,
        ),
        ChangeNotifierProvider<PendingDocumentController>.value(
          value: pendingDocumentController,
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    // 007's screen animates forever, so settling would never finish.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }
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

    testWidgets('a withdrawn local consent record does not count as active — '
        'redirected back to the consent gate', (tester) async {
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
    });
  });

  // 008-identidad-activa T027: screen 08's guard, research.md §5's table.
  group('008: credential-activated guard', () {
    ConsentRecord consentWith(ConsentRecordStatus status) => ConsentRecord(
      textVersionId: 'v1',
      enrollmentAttemptId: EnrollmentAttemptId.generate(),
      scope: ProcessingScope.identityVerification,
      confirmedAt: DateTime.utc(2026, 1, 1),
      status: status,
    );

    final credential = ActivatedCredential(
      holderName: 'Mateo González Restrepo',
      documentLast4: '7890',
      issuingCountry: 'COL',
      issuedAt: DateTime.utc(2026, 9, 16, 12),
      validUntil: DateTime.utc(2031, 9, 16, 12),
    );
    const screen08Title = 'Tu identidad digital está activa';
    const detailText =
        'Tu identidad digital (pantalla pendiente de su propia especificación).';

    FakeConsentRepository consent(ConsentRecordStatus? status) {
      final repository = FakeConsentRepository();
      repository.seedLocalRecord(status == null ? null : consentWith(status));
      repository.scriptCurrentText(Result.ok(_sampleText()));
      return repository;
    }

    testWidgets('a full hand-off with active consent shows screen 08', (
      tester,
    ) async {
      final handoff = ActivatedCredentialHandoff()..set(credential);

      await _pumpApp(
        tester,
        initialLocation: AppRoutes.credentialActivated,
        consentRepository: consent(ConsentRecordStatus.active),
        activatedCredentialHandoff: handoff,
      );

      expect(find.text(screen08Title), findsOneWidget);
      expect(handoff.hasCredential, isFalse);
    });

    testWidgets('an empty hand-off with a valid credential lands on the '
        'credential detail, not screen 08', (tester) async {
      final credentials = FakeCredentialRepository()
        ..scriptResponse(
          Result.ok(CredentialStatus.valid(validUntil: DateTime.utc(2031))),
        );

      await _pumpApp(
        tester,
        initialLocation: AppRoutes.credentialActivated,
        consentRepository: consent(ConsentRecordStatus.active),
        credentialRepository: credentials,
      );

      expect(find.text(screen08Title), findsNothing);
      expect(find.text(detailText), findsOneWidget);
    });

    testWidgets('an empty hand-off, unreachable but last known valid, lands '
        'on the credential detail', (tester) async {
      final credentials = FakeCredentialRepository()
        ..scriptResponse(
          Result.ok(
            CredentialStatus.unreachable(
              lastKnownStatus: CredentialStatus.valid(
                validUntil: DateTime.utc(2031),
              ),
            ),
          ),
        );

      await _pumpApp(
        tester,
        initialLocation: AppRoutes.credentialActivated,
        consentRepository: consent(ConsentRecordStatus.active),
        credentialRepository: credentials,
      );

      expect(find.text(detailText), findsOneWidget);
    });

    testWidgets('an empty hand-off with no credential goes back into the '
        'flow, never to screen 08 or the credential detail', (tester) async {
      final credentials = FakeCredentialRepository()
        ..scriptResponse(const Result.ok(CredentialStatus.noCredential()));

      await _pumpApp(
        tester,
        initialLocation: AppRoutes.credentialActivated,
        consentRepository: consent(null),
        credentialRepository: credentials,
      );

      expect(find.text(screen08Title), findsNothing);
      expect(find.text(detailText), findsNothing);
    });

    testWidgets('a full hand-off without active consent is cleared and never '
        'shown', (tester) async {
      final handoff = ActivatedCredentialHandoff()..set(credential);
      final credentials = FakeCredentialRepository()
        ..scriptResponse(const Result.ok(CredentialStatus.noCredential()));

      await _pumpApp(
        tester,
        initialLocation: AppRoutes.credentialActivated,
        consentRepository: consent(ConsentRecordStatus.withdrawalPending),
        credentialRepository: credentials,
        activatedCredentialHandoff: handoff,
      );

      expect(find.text(screen08Title), findsNothing);
      expect(handoff.hasCredential, isFalse);
    });
  });

  // 011-error-tecnico: screen 11 replaces 007's placeholder. Opened with
  // nothing recorded, it asserts no cause, and "Reintentar" re-observes the
  // same verification.
  group('011: technical error', () {
    testWidgets('with nothing recorded it asserts no cause, and "Reintentar" '
        'returns to the verification screen', (tester) async {
      final consentRepository = FakeConsentRepository()
        ..seedLocalRecord(null)
        ..scriptCurrentText(Result.ok(_sampleText()));

      await _pumpApp(
        tester,
        initialLocation: AppRoutes.technicalError,
        consentRepository: consentRepository,
      );

      expect(find.text('No fue por algo que hayas hecho.'), findsOneWidget);
      expect(find.textContaining('problema nuestro'), findsNothing);
      expect(
        find.textContaining('control de documentos habitual'),
        findsOneWidget,
      );

      await tester.tap(find.text('Reintentar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Estamos validando tu identidad'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });
  });

  // 010-escalar-agente T028: contracts/launch-routing-addendum.md.
  group('010: launch redirect with an open escalation', () {
    ConsentRecord activeConsent() => ConsentRecord(
      textVersionId: 'v1',
      enrollmentAttemptId: EnrollmentAttemptId.generate(),
      scope: ProcessingScope.identityVerification,
      confirmedAt: DateTime.utc(2026, 1, 1),
      status: ConsentRecordStatus.active,
    );

    FakeConsentRepository consent() => FakeConsentRepository()
      ..seedLocalRecord(activeConsent())
      ..scriptCurrentText(Result.ok(_sampleText()));

    final openEscalation = Result<EscalationStatus>.ok(
      EscalationStatus.open(
        escalation: EscalationCase(
          openedAt: DateTime.utc(2026, 1, 1),
          arrival: EscalationArrival.afterLimit,
        ),
        channels: const [
          AgentChannel(
            kind: AgentChannelKind.module,
            available: true,
            hours: 'Lun–Vie',
            locationName: 'Aeropuerto de prueba',
            locationDetail: 'Segundo piso',
          ),
        ],
      ),
    );

    testWidgets(
      '1. no credential, active consent, open escalation -> the escalation screen',
      (tester) async {
        final escalations = FakeEscalationRepository()
          ..openResult = Result.ok(
            EscalationCase(
              openedAt: DateTime.utc(2026, 1, 1),
              arrival: EscalationArrival.afterLimit,
            ),
          )
          ..scriptStatuses([openEscalation]);

        await _pumpApp(
          tester,
          initialLocation: AppRoutes.splash,
          consentRepository: consent(),
          escalationRepository: escalations,
        );

        expect(find.text('Necesitamos verificarte en persona'), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 6));
      },
    );

    for (final (name, status) in [
      (
        '2. expired',
        const Result<EscalationStatus>.ok(EscalationStatus.expired()),
      ),
      (
        '3. a failed read',
        Result<EscalationStatus>.error(StateError('offline')),
      ),
    ]) {
      testWidgets('$name escalation -> welcome, unchanged', (tester) async {
        final escalations = FakeEscalationRepository()
          ..scriptStatuses([status]);

        await _pumpApp(
          tester,
          initialLocation: AppRoutes.splash,
          consentRepository: consent(),
          escalationRepository: escalations,
        );

        expect(find.text('Necesitamos verificarte en persona'), findsNothing);
        expect(find.text('Comenzar'), findsOneWidget);
      });
    }

    testWidgets(
      '4. a valid credential goes to trips without checking escalations',
      (tester) async {
        final escalations = FakeEscalationRepository()
          ..scriptStatuses([openEscalation]);
        final credentials = FakeCredentialRepository()
          ..scriptResponse(
            Result.ok(CredentialStatus.valid(validUntil: DateTime.utc(2031))),
          );

        await _pumpApp(
          tester,
          initialLocation: AppRoutes.splash,
          consentRepository: consent(),
          credentialRepository: credentials,
          escalationRepository: escalations,
        );

        expect(find.text('Aún no tienes viajes'), findsOneWidget);
        expect(escalations.statusCallCount, 0);
      },
    );
  });

  // 011-error-tecnico T013: contracts/launch-routing-addendum.md.
  group('011: launch resume of a verification', () {
    // The harness clock is 2026-01-01 00:00 UTC.
    final inAnHour = DateTime.utc(2026, 1, 1, 1);
    final anHourAgo = DateTime.utc(2025, 12, 31, 23);

    ConsentRecord activeConsent() => ConsentRecord(
      textVersionId: 'v1',
      enrollmentAttemptId: EnrollmentAttemptId.generate(),
      scope: ProcessingScope.identityVerification,
      confirmedAt: DateTime.utc(2026, 1, 1),
      status: ConsentRecordStatus.active,
    );

    FakeConsentRepository consent() => FakeConsentRepository()
      ..seedLocalRecord(activeConsent())
      ..scriptCurrentText(Result.ok(_sampleText()));

    FakeVerificationJobRepository jobOf(Result<VerificationJobStatus> status) =>
        FakeVerificationJobRepository()..scriptResults([status]);

    Result<VerificationJobStatus> inProgress(DateTime? until) => Result.ok(
      VerificationJobStatus.inProgress(
        documentCheck: StageStatus.passed,
        faceComparison: StageStatus.running,
        resumableUntil: until,
      ),
    );

    Result<VerificationJobStatus> completed(
      VerificationOutcome outcome,
      DateTime? until,
    ) => Result.ok(
      VerificationJobStatus.completed(
        outcome: outcome,
        documentCheck: StageStatus.passed,
        faceComparison: StageStatus.failed,
        resumableUntil: until,
      ),
    );

    FakeEscalationRepository openEscalation() => FakeEscalationRepository()
      ..openResult = Result.ok(
        EscalationCase(
          openedAt: DateTime.utc(2026, 1, 1),
          arrival: EscalationArrival.afterLimit,
        ),
      )
      ..scriptStatuses([
        Result.ok(
          EscalationStatus.open(
            escalation: EscalationCase(
              openedAt: DateTime.utc(2026, 1, 1),
              arrival: EscalationArrival.afterLimit,
            ),
            channels: const [
              AgentChannel(
                kind: AgentChannelKind.module,
                available: true,
                hours: 'Lun–Vie',
                locationName: 'Aeropuerto de prueba',
              ),
            ],
          ),
        ),
      ]);

    testWidgets('1. a resumable job opens verification with the identity '
        'confirmed', (tester) async {
      final session = EnrollmentSessionController(clock: const _FixedClock());
      await _pumpApp(
        tester,
        initialLocation: AppRoutes.splash,
        consentRepository: consent(),
        jobRepository: jobOf(inProgress(inAnHour)),
        enrollmentSessionController: session,
        settle: false,
      );

      expect(find.text('Estamos validando tu identidad'), findsOneWidget);
      expect(session.current?.identityConfirmed, isTrue);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 31));
    });

    testWidgets('1b. a resumed service failure reaches screen 11, which offers '
        'a new selfie', (tester) async {
      await _pumpApp(
        tester,
        initialLocation: AppRoutes.splash,
        consentRepository: consent(),
        jobRepository: jobOf(
          completed(const VerificationOutcome.serviceFailure(), inAnHour),
        ),
        settle: false,
      );
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      expect(find.text('Es un problema nuestro, no tuyo.'), findsOneWidget);
      expect(find.textContaining('nueva selfie'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 31));
    });

    for (final (name, job) in [
      ('2. an expired window', inProgress(anHourAgo)),
      ('3. no window', inProgress(null)),
      (
        '4. a rejection',
        completed(const VerificationOutcome.faceMismatch(), inAnHour),
      ),
      (
        '9. a failed read',
        Result<VerificationJobStatus>.error(StateError('offline')),
      ),
    ]) {
      testWidgets('$name goes to welcome', (tester) async {
        await _pumpApp(
          tester,
          initialLocation: AppRoutes.splash,
          consentRepository: consent(),
          jobRepository: jobOf(job),
        );

        expect(find.text('Comenzar'), findsOneWidget);
      });
    }

    testWidgets('5. an open escalation takes precedence over a resumable job', (
      tester,
    ) async {
      await _pumpApp(
        tester,
        initialLocation: AppRoutes.splash,
        consentRepository: consent(),
        escalationRepository: openEscalation(),
        jobRepository: jobOf(inProgress(inAnHour)),
      );

      expect(find.text('Necesitamos verificarte en persona'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('6. a valid credential goes to trips and never reads the job', (
      tester,
    ) async {
      final job = jobOf(inProgress(inAnHour));
      await _pumpApp(
        tester,
        initialLocation: AppRoutes.splash,
        consentRepository: consent(),
        credentialRepository: FakeCredentialRepository()
          ..scriptResponse(
            Result.ok(CredentialStatus.valid(validUntil: DateTime.utc(2031))),
          ),
        jobRepository: job,
      );

      expect(find.text('Aún no tienes viajes'), findsOneWidget);
      expect(job.callCount, 0);
    });

    testWidgets('7. regression: going to welcome with an open escalation '
        'stays on welcome (010 "Volver al inicio")', (tester) async {
      final escalations = openEscalation();
      await _pumpApp(
        tester,
        initialLocation: AppRoutes.welcome,
        consentRepository: consent(),
        escalationRepository: escalations,
      );

      expect(find.text('Comenzar'), findsOneWidget);
      expect(find.text('Necesitamos verificarte en persona'), findsNothing);
      expect(escalations.statusCallCount, 0);
    });

    testWidgets('8. regression: going to welcome with a resumable job stays '
        'on welcome (011 "Salir")', (tester) async {
      final job = jobOf(inProgress(inAnHour));
      await _pumpApp(
        tester,
        initialLocation: AppRoutes.welcome,
        consentRepository: consent(),
        jobRepository: job,
      );

      expect(find.text('Comenzar'), findsOneWidget);
      expect(job.callCount, 0);
    });
  });

  // 012-mis-viajes T012: the home shell and the two-tap withdrawal.
  group('012: Mis viajes inside the tab shell', () {
    Future<void> pumpHome(WidgetTester tester) => _pumpApp(
      tester,
      initialLocation: AppRoutes.splash,
      consentRepository: FakeConsentRepository()
        ..seedLocalRecord(null)
        ..scriptCurrentText(Result.ok(_sampleText())),
      credentialRepository: FakeCredentialRepository()
        ..scriptResponse(
          Result.ok(CredentialStatus.valid(validUntil: DateTime.utc(2031))),
        ),
      summaryRepository: FakeCredentialSummaryRepository(
        const Result.ok(FakeCredentialSummaryRepository.confirmedActive),
      ),
    );

    testWidgets('a valid credential lands on Mis viajes with three tabs', (
      tester,
    ) async {
      await pumpHome(tester);

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Viajes'), findsOneWidget);
      expect(find.text('Identidad'), findsOneWidget);
      expect(find.text('Perfil'), findsOneWidget);
      expect(find.text('ACTIVA'), findsOneWidget);
      expect(find.text('Aún no tienes viajes'), findsOneWidget);
    });

    testWidgets('Identidad opens the credential surface', (tester) async {
      await pumpHome(tester);

      await tester.tap(find.text('Identidad'));
      await tester.pumpAndSettle();

      expect(find.byType(CredentialDetailPlaceholderView), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('consent withdrawal is two taps away: Perfil, then '
        '"Retirar consentimiento"', (tester) async {
      await pumpHome(tester);

      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Retirar consentimiento'));
      await tester.pumpAndSettle();

      expect(find.byType(WithdrawalPlaceholderView), findsOneWidget);
    });
  });

  // 014-qr-pase T012: from the 013 placeholder to the pass, and back.
  group('014: the pass route', () {
    testWidgets(
      '"Continuar a tu pase" on the 013 placeholder opens the pass for '
      'the next trip',
      (tester) async {
        final trip = Trip(
          id: 'trip-1',
          origin: const Airport(code: 'BOG', city: 'Bogotá'),
          destination: const Airport(code: 'MDE', city: 'Medellín'),
          flightNumber: 'AV 9201',
          departureUtc: DateTime.utc(2026, 1, 1, 3),
          departureOffset: const Duration(hours: -5),
          status: TripStatus.onTime,
          live: true,
        );
        final passes = FakePassRepository()
          ..scriptIssues([
            Result.ok(
              Pass(
                passId: 'pass-1',
                tripId: 'trip-1',
                nextCheckpoint: Checkpoint.security,
                validUntil: DateTime.utc(2026, 1, 1, 3),
              ),
            ),
          ]);
        final trips = FakeTripRepository()
          ..lastKnown = TripsSnapshot(
            next: trip,
            history: const [],
            fetchedAt: DateTime.utc(2026, 1, 1),
          )
          ..scriptResults([
            Result.ok(
              TripsSnapshot(
                next: trip,
                history: const [],
                fetchedAt: DateTime.utc(2026, 1, 1),
              ),
            ),
          ]);

        await _pumpApp(
          tester,
          initialLocation: AppRoutes.tripVerification,
          consentRepository: FakeConsentRepository()
            ..seedLocalRecord(null)
            ..scriptCurrentText(Result.ok(_sampleText())),
          tripRepository: trips,
          passRepository: passes,
        );

        await tester.tap(find.text('Continuar a tu pase'));
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(QrCodeView), findsOneWidget);
        expect(passes.issueCount, 1);
        expect(find.text('Seguridad'), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 6));
      },
    );
  });
}
