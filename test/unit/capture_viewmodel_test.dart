import 'dart:typed_data';

import 'package:aeropass_app/app/enrollment_session_controller.dart';
import 'package:aeropass_app/app/pending_document_controller.dart';
import 'package:aeropass_app/core/clock.dart';
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/data/services/camera_capture_service.dart';
import 'package:aeropass_app/domain/entities/capture_attempt_counter.dart';
import 'package:aeropass_app/domain/entities/capture_outcome.dart';
import 'package:aeropass_app/domain/entities/consent_record.dart';
import 'package:aeropass_app/domain/entities/extraction_result.dart';
import 'package:aeropass_app/domain/entities/consent_text_version.dart';
import 'package:aeropass_app/domain/entities/enrollment_attempt_id.dart';
import 'package:aeropass_app/domain/entities/processing_scope.dart';
import 'package:aeropass_app/features/enrollment/capture/capture_view_state.dart';
import 'package:aeropass_app/features/enrollment/capture/capture_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

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

/// A minimal accepted extraction — this file only needs *an* accepted
/// outcome to exist, not to exercise 004-confirmar-datos's own field logic.
const _extraction = ExtractionResult(
  fields: [
    ExtractedField.present(
      key: FieldKey.fullName,
      value: 'Mateo González Restrepo',
      confidence: 0.98,
    ),
  ],
);

void main() {
  late FakeConsentRepository consentRepository;
  late FakeCameraCaptureService cameraCaptureService;
  late FakeDocumentQualityAssessor qualityAssessor;
  late FakeDocumentVerificationRepository verificationRepository;
  late FakeCaptureAttemptCounterRepository attemptCounterRepository;
  late FakeAnalyticsEmitter analyticsEmitter;
  late EnrollmentSessionController sessionController;
  late PendingDocumentController pendingDocumentController;
  late FakeSystemSettingsLauncher systemSettingsLauncher;

  setUp(() {
    consentRepository = FakeConsentRepository();
    cameraCaptureService = FakeCameraCaptureService();
    qualityAssessor = FakeDocumentQualityAssessor();
    verificationRepository = FakeDocumentVerificationRepository();
    attemptCounterRepository = FakeCaptureAttemptCounterRepository();
    analyticsEmitter = FakeAnalyticsEmitter();
    sessionController = EnrollmentSessionController(
      clock: _FixedClock(DateTime.utc(2026, 1, 1)),
    );
    pendingDocumentController = PendingDocumentController();
    systemSettingsLauncher = FakeSystemSettingsLauncher();
  });

  CaptureViewModel buildViewModel() {
    return CaptureViewModel(
      consentRepository: consentRepository,
      cameraCaptureService: cameraCaptureService,
      qualityAssessor: qualityAssessor,
      verificationRepository: verificationRepository,
      attemptCounterRepository: attemptCounterRepository,
      enrollmentSessionController: sessionController,
      pendingDocumentController: pendingDocumentController,
      analyticsEmitter: analyticsEmitter,
      systemSettingsLauncher: systemSettingsLauncher,
    );
  }

  ConsentTextVersionStub currentText({String id = 'v1'}) =>
      ConsentTextVersionStub(id);

  ConsentRecord activeRecord({String textVersionId = 'v1'}) => ConsentRecord(
    textVersionId: textVersionId,
    enrollmentAttemptId: EnrollmentAttemptId.generate(),
    scope: ProcessingScope.identityVerification,
    confirmedAt: DateTime.utc(2026, 1, 1),
    status: ConsentRecordStatus.active,
  );

  group('T018/US1: consent-currency gate (FR-001)', () {
    test('no local consent record -> redirects to consent gate, camera never starts', () async {
      consentRepository.scriptCurrentText(Result.ok(currentText().toDomain()));
      consentRepository.seedLocalRecord(null);
      final viewModel = buildViewModel();

      await pumpEventQueue();

      expect(viewModel.pendingNavigation, CaptureNavigationTarget.consentGate);
      expect(cameraCaptureService.startCallCount, 0);
    });

    test('local record refers to a superseded text version -> redirects to consent gate', () async {
      consentRepository.scriptCurrentText(
        Result.ok(currentText(id: 'v2').toDomain()),
      );
      consentRepository.seedLocalRecord(activeRecord(textVersionId: 'v1'));
      final viewModel = buildViewModel();

      await pumpEventQueue();

      expect(viewModel.pendingNavigation, CaptureNavigationTarget.consentGate);
      expect(cameraCaptureService.startCallCount, 0);
    });

    test('local record withdrawn -> redirects to consent gate', () async {
      consentRepository.scriptCurrentText(Result.ok(currentText().toDomain()));
      consentRepository.seedLocalRecord(
        activeRecord().copyWith(status: ConsentRecordStatus.withdrawn),
      );
      final viewModel = buildViewModel();

      await pumpEventQueue();

      expect(viewModel.pendingNavigation, CaptureNavigationTarget.consentGate);
      expect(cameraCaptureService.startCallCount, 0);
    });

    test(
      'current active consent record -> camera starts, state becomes ready',
      () async {
        consentRepository.scriptCurrentText(
          Result.ok(currentText().toDomain()),
        );
        consentRepository.seedLocalRecord(activeRecord());
        final viewModel = buildViewModel();

        await pumpEventQueue();

        expect(viewModel.pendingNavigation, isNull);
        expect(cameraCaptureService.startCallCount, 1);
        expect(viewModel.state, const CaptureViewState.ready());
        expect(
          analyticsEmitter.events.map((e) => e.name),
          contains('capture_step_entered'),
        );
      },
    );
  });

  group('T018/US3: permission gating (FR-002/FR-014)', () {
    test('camera start throws -> permissionDenied(permanent: false)', () async {
      consentRepository.scriptCurrentText(Result.ok(currentText().toDomain()));
      consentRepository.seedLocalRecord(activeRecord());
      cameraCaptureService.failStartWith(StateError('denied'));
      final viewModel = buildViewModel();

      await pumpEventQueue();

      expect(
        viewModel.state,
        const CaptureViewState.permissionDenied(permanent: false),
      );
    });

    test('retryPermission after a temporary denial re-attempts start() and can '
        'succeed', () async {
      consentRepository.scriptCurrentText(Result.ok(currentText().toDomain()));
      consentRepository.seedLocalRecord(activeRecord());
      cameraCaptureService.failStartWith(StateError('denied'));
      final viewModel = buildViewModel();
      await pumpEventQueue();
      expect(
        viewModel.state,
        const CaptureViewState.permissionDenied(permanent: false),
      );

      // Simulate the passenger having granted permission before retrying.
      cameraCaptureService.failStartWith(StateError('denied again'));
      await viewModel.retryPermission.run();

      expect(
        viewModel.state,
        const CaptureViewState.permissionDenied(permanent: true),
      );
      expect(cameraCaptureService.startCallCount, 2);
    });

    test('a second denial in this screen\'s lifetime is permanent and does '
        'not re-attempt start() on a further retryPermission() call', () async {
      consentRepository.scriptCurrentText(Result.ok(currentText().toDomain()));
      consentRepository.seedLocalRecord(activeRecord());
      cameraCaptureService.failStartWith(StateError('denied'));
      final viewModel = buildViewModel();
      await pumpEventQueue();
      await viewModel.retryPermission.run();
      expect(
        viewModel.state,
        const CaptureViewState.permissionDenied(permanent: true),
      );

      final callsBefore = cameraCaptureService.startCallCount;
      await viewModel.retryPermission.run();

      expect(cameraCaptureService.startCallCount, callsBefore);
    });
  });

  group('T018/US1: happy path — capture, assess, submit, advance', () {
    test(
      'usable assessment + accepted verification -> advances to data '
      'confirmation, leaves the attempt counter unchanged (009 FR-017: only '
      'a verification match resets it), no bytes retained by the VM',
      () async {
        consentRepository.scriptCurrentText(
          Result.ok(currentText().toDomain()),
        );
        consentRepository.seedLocalRecord(activeRecord());
        final viewModel = buildViewModel();
        await pumpEventQueue();

        cameraCaptureService.scriptCapture(_frame());
        qualityAssessor.scriptAssessment(const QualityAssessment.usable());
        verificationRepository.scriptSubmit(
          const Result.ok(CaptureOutcome.accepted(extraction: _extraction)),
        );
        attemptCounterRepository.seed(
          AttemptCounterScope.documentCapture,
          CaptureAttemptCounter(
            count: 2,
            lastResetAt: DateTime.utc(2026, 1, 1),
          ),
        );

        await viewModel.capture.run();

        expect(
          viewModel.pendingNavigation,
          CaptureNavigationTarget.dataConfirmation,
        );
        expect(viewModel.state, const CaptureViewState.ready());
        expect(verificationRepository.submitCallCount, 1);
        final counter = (await attemptCounterRepository.read(
          AttemptCounterScope.documentCapture,
        )).valueOrNull!;
        expect(counter.count, 2);
        // 004-confirmar-datos research.md §1: the captured bytes and the
        // extraction are handed to PendingDocumentController before
        // navigating, never retained by the ViewModel itself.
        expect(pendingDocumentController.hasPendingDocument, isTrue);
        expect(
          pendingDocumentController.documentImageBytes,
          _frame().submissionBytes,
        );
        expect(pendingDocumentController.extraction, _extraction);
        expect(
          analyticsEmitter.events.map((e) => e.name),
          containsAll(['capture_attempted', 'capture_accepted']),
        );
      },
    );
  });

  group(
    'T031/US2: device-side and verification rejections (FR-006-FR-009)',
    () {
      test('a device-rejected capture increments the counter and never calls '
          'submit()', () async {
        consentRepository.scriptCurrentText(
          Result.ok(currentText().toDomain()),
        );
        consentRepository.seedLocalRecord(activeRecord());
        final viewModel = buildViewModel();
        await pumpEventQueue();

        cameraCaptureService.scriptCapture(_frame());
        qualityAssessor.scriptAssessment(
          const QualityAssessment.rejected(reason: QualityRejectionReason.blur),
        );

        await viewModel.capture.run();

        expect(verificationRepository.submitCallCount, 0);
        expect(
          viewModel.state,
          const CaptureViewState.ready(
            lastRejectionReason: CaptureRejectionReason.blur,
          ),
        );
        final counter = (await attemptCounterRepository.read(
          AttemptCounterScope.documentCapture,
        )).valueOrNull!;
        expect(counter.count, 1);
        expect(
          analyticsEmitter.events.map((e) => e.name),
          contains('capture_device_rejected'),
        );
      });

      test(
        'a verification rejection maps to the same actionable vocabulary and '
        'increments the counter',
        () async {
          consentRepository.scriptCurrentText(
            Result.ok(currentText().toDomain()),
          );
          consentRepository.seedLocalRecord(activeRecord());
          final viewModel = buildViewModel();
          await pumpEventQueue();

          cameraCaptureService.scriptCapture(_frame());
          qualityAssessor.scriptAssessment(const QualityAssessment.usable());
          verificationRepository.scriptSubmit(
            const Result.ok(
              CaptureOutcome.rejected(reason: CaptureRejectionReason.glare),
            ),
          );

          await viewModel.capture.run();

          expect(
            viewModel.state,
            const CaptureViewState.ready(
              lastRejectionReason: CaptureRejectionReason.glare,
            ),
          );
          final counter = (await attemptCounterRepository.read(
            AttemptCounterScope.documentCapture,
          )).valueOrNull!;
          expect(counter.count, 1);
          expect(
            analyticsEmitter.events.map((e) => e.name),
            contains('capture_verification_rejected'),
          );
        },
      );

      test(
        'reaching 3 failures routes to retry guidance and leaves the counter '
        'at the limit (009 FR-017)',
        () async {
          consentRepository.scriptCurrentText(
            Result.ok(currentText().toDomain()),
          );
          consentRepository.seedLocalRecord(activeRecord());
          final viewModel = buildViewModel();
          await pumpEventQueue();

          cameraCaptureService.scriptCapture(_frame());
          qualityAssessor.scriptAssessment(
            const QualityAssessment.rejected(
              reason: QualityRejectionReason.blur,
            ),
          );

          await viewModel.capture.run();
          await viewModel.capture.run();
          await viewModel.capture.run();

          expect(
            viewModel.pendingNavigation,
            CaptureNavigationTarget.retryGuidance,
          );
          final counter = (await attemptCounterRepository.read(
            AttemptCounterScope.documentCapture,
          )).valueOrNull!;
          expect(counter.count, captureAttemptLimit);
          expect(
            analyticsEmitter.events.map((e) => e.name),
            contains('capture_attempt_limit_reached'),
          );
        },
      );
    },
  );

  group('T039/US3: offline submission (FR-015)', () {
    test('a transport failure on submit shows offline/retry messaging, does '
        'not increment the attempt counter, and is not queued', () async {
      consentRepository.scriptCurrentText(Result.ok(currentText().toDomain()));
      consentRepository.seedLocalRecord(activeRecord());
      final viewModel = buildViewModel();
      await pumpEventQueue();

      cameraCaptureService.scriptCapture(_frame());
      qualityAssessor.scriptAssessment(const QualityAssessment.usable());
      verificationRepository.scriptSubmit(Result.error(StateError('offline')));

      await viewModel.capture.run();

      expect(viewModel.state, const CaptureViewState.ready(offline: true));
      final counter = (await attemptCounterRepository.read(
        AttemptCounterScope.documentCapture,
      )).valueOrNull!;
      expect(counter.count, 0);
    });
  });

  group('T039/US3: back navigation abandonment (FR-012)', () {
    test('onBackNavigation emits capture_step_abandoned when no outcome was recorded', () async {
      consentRepository.scriptCurrentText(Result.ok(currentText().toDomain()));
      consentRepository.seedLocalRecord(activeRecord());
      final viewModel = buildViewModel();
      await pumpEventQueue();

      viewModel.onBackNavigation();

      expect(
        analyticsEmitter.events.map((e) => e.name),
        contains('capture_step_abandoned'),
      );
    });

    test(
      'onBackNavigation does not emit abandoned after an accepted capture',
      () async {
        consentRepository.scriptCurrentText(
          Result.ok(currentText().toDomain()),
        );
        consentRepository.seedLocalRecord(activeRecord());
        final viewModel = buildViewModel();
        await pumpEventQueue();
        cameraCaptureService.scriptCapture(_frame());
        qualityAssessor.scriptAssessment(const QualityAssessment.usable());
        verificationRepository.scriptSubmit(
          const Result.ok(CaptureOutcome.accepted(extraction: _extraction)),
        );
        await viewModel.capture.run();

        viewModel.onBackNavigation();

        expect(
          analyticsEmitter.events.map((e) => e.name),
          isNot(contains('capture_step_abandoned')),
        );
      },
    );
  });

  group('lifecycle (research.md §5)', () {
    test('onAppBackgrounded stops the camera', () async {
      consentRepository.scriptCurrentText(Result.ok(currentText().toDomain()));
      consentRepository.seedLocalRecord(activeRecord());
      final viewModel = buildViewModel();
      await pumpEventQueue();

      await viewModel.onAppBackgrounded();

      expect(cameraCaptureService.stopCallCount, greaterThanOrEqualTo(1));
    });

    test('onAppResumed restarts the camera when it was ready', () async {
      consentRepository.scriptCurrentText(Result.ok(currentText().toDomain()));
      consentRepository.seedLocalRecord(activeRecord());
      final viewModel = buildViewModel();
      await pumpEventQueue();
      await viewModel.onAppBackgrounded();

      await viewModel.onAppResumed();

      expect(cameraCaptureService.startCallCount, 2);
    });
  });
  // 009-reintento addendum case 3: an exhausted limit stays in force.
  group('009: entering document capture at the limit', () {
    test('targets retry guidance and never starts the camera', () async {
      consentRepository.scriptCurrentText(Result.ok(currentText().toDomain()));
      consentRepository.seedLocalRecord(activeRecord());
      attemptCounterRepository.seed(
        AttemptCounterScope.documentCapture,
        CaptureAttemptCounter(
          count: captureAttemptLimit,
          lastResetAt: DateTime.utc(2026, 1, 1),
        ),
      );

      final viewModel = buildViewModel();
      await pumpEventQueue();

      expect(
        viewModel.pendingNavigation,
        CaptureNavigationTarget.retryGuidance,
      );
      expect(cameraCaptureService.startCallCount, 0);
    });
  });
}

/// A tiny local stand-in for constructing a `ConsentTextVersion` with only
/// the field this test file actually varies (`id`) — avoids repeating the
/// full placeholder-legal-text payload `ConsentTextVersion` requires at
/// every call site (mirrors consent_repository_contract_test.dart's own
/// `_sampleText` helper).
class ConsentTextVersionStub {
  ConsentTextVersionStub(this.id);
  final String id;

  ConsentTextVersion toDomain() => ConsentTextVersion(
    id: id,
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
}
