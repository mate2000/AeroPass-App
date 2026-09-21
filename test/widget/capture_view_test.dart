import 'dart:typed_data';

import 'package:aeropass_app/app/enrollment_session_controller.dart';
import 'package:aeropass_app/app/router.dart' show AppRoutes;
import 'package:aeropass_app/core/clock.dart';
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/data/services/camera_capture_service.dart';
import 'package:aeropass_app/domain/entities/capture_outcome.dart';
import 'package:aeropass_app/domain/entities/consent_record.dart';
import 'package:aeropass_app/domain/entities/consent_text_version.dart';
import 'package:aeropass_app/domain/entities/enrollment_attempt_id.dart';
import 'package:aeropass_app/domain/entities/processing_scope.dart';
import 'package:aeropass_app/features/enrollment/capture/capture_view.dart';
import 'package:aeropass_app/features/enrollment/capture/capture_viewmodel.dart';
import 'package:aeropass_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../fakes/fake_analytics_emitter.dart';
import '../fakes/fake_camera_capture_service.dart';
import '../fakes/fake_capture_attempt_counter_repository.dart';
import '../fakes/fake_consent_repository.dart';
import '../fakes/fake_document_quality_assessor.dart';
import '../fakes/fake_document_verification_repository.dart';
import '../fakes/fake_system_settings_launcher.dart';

class _FixedClock implements Clock {
  _FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

CapturedDocumentFrame _frame() => (
  analysisBytes: Uint8List.fromList([1, 2, 3]),
  submissionBytes: Uint8List.fromList([4, 5, 6]),
);

ConsentTextVersion _sampleText() => ConsentTextVersion(
  id: 'v1',
  points: const [
    ConsentPoint(
      icon: ConsentPointIcon.camera,
      heading: '[PLACEHOLDER]',
      body: '[PLACEHOLDER]',
    ),
  ],
  rightsStatement: '[PLACEHOLDER]',
  optionalityStatement: '[PLACEHOLDER]',
  processorDisclosure: '[PLACEHOLDER]',
  privacyPolicyUrl: 'https://example.test/privacy',
  termsUrl: 'https://example.test/terms',
  publishedAt: DateTime.utc(2026, 1, 1),
);

ConsentRecord _activeRecord() => ConsentRecord(
  textVersionId: 'v1',
  enrollmentAttemptId: EnrollmentAttemptId.generate(),
  scope: ProcessingScope.identityVerification,
  confirmedAt: DateTime.utc(2026, 1, 1),
  status: ConsentRecordStatus.active,
);

/// Wraps `CaptureView` in a self-contained `MaterialApp.router`, independent
/// of the app's real `router.dart` — mirroring `consent_view_test.dart`'s
/// own isolation pattern.
Future<void> _pumpCaptureView(
  WidgetTester tester, {
  required CaptureViewModel viewModel,
}) async {
  final router = GoRouter(
    initialLocation: AppRoutes.consent,
    routes: [
      GoRoute(
        path: AppRoutes.consent,
        builder: (context, state) => const Scaffold(body: Text('consent-stub')),
      ),
      GoRoute(
        path: AppRoutes.documentCapture,
        builder: (context, state) => CaptureView(viewModel: viewModel),
      ),
      GoRoute(
        path: AppRoutes.documentConfirmation,
        builder: (context, state) =>
            const Scaffold(body: Text('document-confirmation-stub')),
      ),
      GoRoute(
        path: AppRoutes.retryGuidance,
        builder: (context, state) =>
            const Scaffold(body: Text('retry-guidance-stub')),
      ),
      GoRoute(
        path: AppRoutes.help,
        builder: (context, state) => const Scaffold(body: Text('help-stub')),
      ),
    ],
  );

  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
  router.push(AppRoutes.documentCapture);
  await tester.pumpAndSettle();
}

void main() {
  late FakeConsentRepository consentRepository;
  late FakeCameraCaptureService cameraCaptureService;
  late FakeDocumentQualityAssessor qualityAssessor;
  late FakeDocumentVerificationRepository verificationRepository;
  late FakeCaptureAttemptCounterRepository attemptCounterRepository;
  late FakeAnalyticsEmitter analyticsEmitter;
  late EnrollmentSessionController sessionController;
  late FakeSystemSettingsLauncher systemSettingsLauncher;

  setUp(() {
    consentRepository = FakeConsentRepository();
    consentRepository.scriptCurrentText(Result.ok(_sampleText()));
    consentRepository.seedLocalRecord(_activeRecord());
    cameraCaptureService = FakeCameraCaptureService();
    qualityAssessor = FakeDocumentQualityAssessor();
    verificationRepository = FakeDocumentVerificationRepository();
    attemptCounterRepository = FakeCaptureAttemptCounterRepository();
    analyticsEmitter = FakeAnalyticsEmitter();
    sessionController = EnrollmentSessionController(
      clock: _FixedClock(DateTime.utc(2026, 1, 1)),
    );
    systemSettingsLauncher = FakeSystemSettingsLauncher();
  });

  CaptureViewModel buildViewModel() => CaptureViewModel(
    consentRepository: consentRepository,
    cameraCaptureService: cameraCaptureService,
    qualityAssessor: qualityAssessor,
    verificationRepository: verificationRepository,
    attemptCounterRepository: attemptCounterRepository,
    enrollmentSessionController: sessionController,
    analyticsEmitter: analyticsEmitter,
    systemSettingsLauncher: systemSettingsLauncher,
  );

  group('T019 [US1] permission states', () {
    testWidgets('a temporary permission denial shows the retry message, no capture button', (
      tester,
    ) async {
      cameraCaptureService.failStartWith(StateError('denied'));
      await _pumpCaptureView(tester, viewModel: buildViewModel());

      expect(find.text('Necesitamos acceso a tu cámara'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
      expect(find.bySemanticsLabel('Capturar documento'), findsNothing);
    });

    testWidgets('the live-preview (ready) state shows the instruction and capture control', (
      tester,
    ) async {
      await _pumpCaptureView(tester, viewModel: buildViewModel());

      expect(
        find.text('Ubica tu cédula o pasaporte dentro del marco'),
        findsOneWidget,
      );
      expect(find.text('Documento'), findsOneWidget);
      expect(find.bySemanticsLabel('Capturar documento'), findsOneWidget);
    });
  });

  group('T019 [US1] successful capture', () {
    testWidgets(
      'a successful capture navigates to the data-confirmation route',
      (tester) async {
        await _pumpCaptureView(tester, viewModel: buildViewModel());

        cameraCaptureService.scriptCapture(_frame());
        qualityAssessor.scriptAssessment(const QualityAssessment.usable());
        verificationRepository.scriptSubmit(
          const Result.ok(CaptureOutcome.accepted()),
        );

        await tester.tap(find.bySemanticsLabel('Capturar documento'));
        await tester.pumpAndSettle();

        expect(find.text('document-confirmation-stub'), findsOneWidget);
      },
    );
  });

  group('T032 [US2] device/verification rejection error states', () {
    testWidgets('a blur rejection shows the specific actionable message with retry available', (
      tester,
    ) async {
      await _pumpCaptureView(tester, viewModel: buildViewModel());
      cameraCaptureService.scriptCapture(_frame());
      qualityAssessor.scriptAssessment(
        const QualityAssessment.rejected(reason: QualityRejectionReason.blur),
      );

      await tester.tap(find.bySemanticsLabel('Capturar documento'));
      await tester.pumpAndSettle();

      expect(find.text('La imagen está borrosa'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      // Retry is immediately available on the same screen.
      expect(find.bySemanticsLabel('Capturar documento'), findsOneWidget);
    });

    testWidgets('a glare rejection shows its own distinct message', (tester) async {
      await _pumpCaptureView(tester, viewModel: buildViewModel());
      cameraCaptureService.scriptCapture(_frame());
      qualityAssessor.scriptAssessment(
        const QualityAssessment.rejected(reason: QualityRejectionReason.glare),
      );

      await tester.tap(find.bySemanticsLabel('Capturar documento'));
      await tester.pumpAndSettle();

      expect(find.text('Hay reflejo sobre el documento'), findsOneWidget);
    });

    testWidgets(
      'a verification-processor rejection uses the same actionable vocabulary',
      (tester) async {
        await _pumpCaptureView(tester, viewModel: buildViewModel());
        cameraCaptureService.scriptCapture(_frame());
        qualityAssessor.scriptAssessment(const QualityAssessment.usable());
        verificationRepository.scriptSubmit(
          const Result.ok(
            CaptureOutcome.rejected(reason: CaptureRejectionReason.wrongDocument),
          ),
        );

        await tester.tap(find.bySemanticsLabel('Capturar documento'));
        await tester.pumpAndSettle();

        expect(find.text('Este documento no es válido'), findsOneWidget);
      },
    );

    testWidgets('reaching the attempt limit navigates to the retry-guidance route', (
      tester,
    ) async {
      await _pumpCaptureView(tester, viewModel: buildViewModel());
      cameraCaptureService.scriptCapture(_frame());
      qualityAssessor.scriptAssessment(
        const QualityAssessment.rejected(reason: QualityRejectionReason.blur),
      );

      for (var i = 0; i < 3; i++) {
        await tester.tap(find.bySemanticsLabel('Capturar documento'));
        await tester.pumpAndSettle();
      }

      expect(find.text('retry-guidance-stub'), findsOneWidget);
    });
  });

  group('T040 [US3] permission-denied settings route', () {
    testWidgets(
      'a permanent denial offers "Abrir configuración" which invokes the '
      'system-settings launcher',
      (tester) async {
        cameraCaptureService.failStartWith(StateError('denied'));
        final viewModel = buildViewModel();
        await _pumpCaptureView(tester, viewModel: viewModel);
        await viewModel.retryPermission.run();
        await tester.pumpAndSettle();

        expect(find.text('El acceso a la cámara está bloqueado'), findsOneWidget);
        expect(
          find.text(
            'Mientras tanto, puedes continuar con el proceso habitual en '
            'el mostrador del aeropuerto.',
          ),
          findsOneWidget,
        );

        await tester.tap(find.text('Abrir configuración'));
        await tester.pumpAndSettle();

        expect(systemSettingsLauncher.openCallCount, 1);
      },
    );
  });

  group('T040 [US3] "Ayuda" round-trip', () {
    testWidgets('opening help and returning keeps the capture step intact', (
      tester,
    ) async {
      await _pumpCaptureView(tester, viewModel: buildViewModel());

      await tester.tap(find.text('Ayuda'));
      await tester.pumpAndSettle();
      expect(find.text('help-stub'), findsOneWidget);

      final navigator = tester.state<NavigatorState>(
        find.byType(Navigator).first,
      );
      navigator.pop();
      await tester.pumpAndSettle();

      expect(
        find.text('Ubica tu cédula o pasaporte dentro del marco'),
        findsOneWidget,
      );
    });
  });

  group('T048: accessibility (FR-007, Constitution Principle VI)', () {
    testWidgets('every interactive control has a semantic label', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpCaptureView(tester, viewModel: buildViewModel());

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      handle.dispose();
    });

    testWidgets(
      'an error state is conveyed by text and an icon, not the red frame '
      'alone — the rejection headline is present as real (screen-reader- '
      'reachable) text',
      (tester) async {
        final viewModel = buildViewModel();
        await _pumpCaptureView(tester, viewModel: viewModel);
        cameraCaptureService.scriptCapture(_frame());
        qualityAssessor.scriptAssessment(
          const QualityAssessment.rejected(
            reason: QualityRejectionReason.framing,
          ),
        );

        await tester.tap(find.bySemanticsLabel('Capturar documento'));
        await tester.pumpAndSettle();

        expect(
          find.text('El documento no está completo en el marco'),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      },
    );
  });

  group('T040 [US3] "Atrás" back navigation (FR-012)', () {
    testWidgets(
      '"Atrás" pops the route and records abandonment exactly once',
      (tester) async {
        final viewModel = buildViewModel();
        await _pumpCaptureView(tester, viewModel: viewModel);

        await tester.tap(find.text('Atrás'));
        await tester.pumpAndSettle();

        expect(find.text('consent-stub'), findsOneWidget);
        expect(
          analyticsEmitter.events
              .where((e) => e.name == 'capture_step_abandoned')
              .length,
          1,
        );
      },
    );
  });
}
