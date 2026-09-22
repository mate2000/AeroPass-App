import 'dart:typed_data';

import 'package:aeropass_app/app/enrollment_session_controller.dart';
import 'package:aeropass_app/app/pending_document_controller.dart';
import 'package:aeropass_app/core/clock.dart';
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/extraction_result.dart';
import 'package:aeropass_app/domain/entities/field_reverification_outcome.dart';
import 'package:aeropass_app/domain/entities/identity_record.dart';
import 'package:aeropass_app/features/enrollment/confirmation/document_confirmation_view_state.dart';
import 'package:aeropass_app/features/enrollment/confirmation/document_confirmation_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_analytics_emitter.dart';
import '../fakes/fake_field_reverification_repository.dart';
import '../fakes/fake_identity_record_repository.dart';

class _FixedClock implements Clock {
  _FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

final _sampleBytes = Uint8List.fromList([1, 2, 3]);

ExtractionResult _cleanExtraction() => const ExtractionResult(
  fields: [
    ExtractedField.present(
      key: FieldKey.fullName,
      value: 'Mateo González Restrepo',
      confidence: 0.98,
    ),
    ExtractedField.present(
      key: FieldKey.documentNumber,
      value: 'CC 1.234.567.890',
      confidence: 0.97,
    ),
    ExtractedField.present(
      key: FieldKey.nationality,
      value: 'Colombiana',
      confidence: 0.4,
    ),
    ExtractedField.present(
      key: FieldKey.expiryDate,
      value: '2031-03-14',
      confidence: 0.95,
    ),
  ],
);

void main() {
  late PendingDocumentController pendingDocumentController;
  late FakeFieldReverificationRepository fieldReverificationRepository;
  late FakeIdentityRecordRepository identityRecordRepository;
  late FakeAnalyticsEmitter analyticsEmitter;
  late EnrollmentSessionController sessionController;
  late _FixedClock clock;

  setUp(() {
    pendingDocumentController = PendingDocumentController();
    fieldReverificationRepository = FakeFieldReverificationRepository();
    identityRecordRepository = FakeIdentityRecordRepository();
    analyticsEmitter = FakeAnalyticsEmitter();
    clock = _FixedClock(DateTime.utc(2026, 9, 21));
    sessionController = EnrollmentSessionController(clock: clock);
    sessionController.startOrResume();
  });

  DocumentConfirmationViewModel buildViewModel() {
    return DocumentConfirmationViewModel(
      pendingDocumentController: pendingDocumentController,
      fieldReverificationRepository: fieldReverificationRepository,
      identityRecordRepository: identityRecordRepository,
      analyticsEmitter: analyticsEmitter,
      enrollmentSessionController: sessionController,
      clock: clock,
    );
  }

  group('T020 [US1]: loading and the clean-confirmation happy path', () {
    test('an empty PendingDocumentController redirects to document capture', () {
      final viewModel = buildViewModel();

      expect(
        viewModel.pendingNavigation,
        DocumentConfirmationNavigationTarget.documentCapture,
      );
      expect(viewModel.state, isA<DocumentConfirmationViewLoading>());
    });

    test('a clean extraction renders every field read-only and unedited', () {
      pendingDocumentController.set(_sampleBytes, _cleanExtraction());
      final viewModel = buildViewModel();

      final state = viewModel.state;
      expect(state, isA<DocumentConfirmationViewReady>());
      final ready = state as DocumentConfirmationViewReady;
      expect(ready.fields, hasLength(4));
      expect(
        ready.fields.every((f) => f.status is FieldCorrectionUnedited),
        isTrue,
      );
      expect(
        analyticsEmitter.events.map((e) => e.name),
        contains('confirmation_step_entered'),
      );
    });

    test(
      'confirm succeeds -> submits an all-machine-read record, clears the '
      'controller, advances to the selfie step',
      () async {
        pendingDocumentController.set(_sampleBytes, _cleanExtraction());
        final viewModel = buildViewModel();
        identityRecordRepository.scriptConfirm(
          Result.ok(
            const IdentityRecord(
              fields: [
                ConfirmedField(
                  key: FieldKey.fullName,
                  value: 'Mateo González Restrepo',
                  source: FieldSource.machineRead,
                ),
              ],
            ),
          ),
        );

        await viewModel.confirm.run();

        expect(identityRecordRepository.confirmCallCount, 1);
        final submitted = identityRecordRepository.lastSubmittedRecord!;
        expect(
          submitted.fields.every((f) => f.source == FieldSource.machineRead),
          isTrue,
        );
        expect(pendingDocumentController.hasPendingDocument, isFalse);
        expect(
          viewModel.pendingNavigation,
          DocumentConfirmationNavigationTarget.selfieInstructions,
        );
        expect(
          analyticsEmitter.events.map((e) => e.name),
          contains('confirmation_confirmed'),
        );
        expect(sessionController.current?.identityConfirmed, isTrue);
      },
    );

    test(
      'confirm fails -> confirmation is not recorded, the flow does not '
      'advance, the passenger is told',
      () async {
        pendingDocumentController.set(_sampleBytes, _cleanExtraction());
        final viewModel = buildViewModel();
        identityRecordRepository.scriptConfirm(
          Result.error(StateError('offline')),
        );

        await viewModel.confirm.run();

        expect(viewModel.pendingNavigation, isNull);
        expect(pendingDocumentController.hasPendingDocument, isTrue);
        final ready = viewModel.state as DocumentConfirmationViewReady;
        expect(ready.confirmFailed, isTrue);
        expect(
          analyticsEmitter.events.map((e) => e.name),
          contains('confirmation_confirm_failed'),
        );
        expect(sessionController.current?.identityConfirmed, isFalse);
      },
    );
  });

  group('T032 [US2]: field correction and re-verification', () {
    test(
      'editing a low-confidence field is accepted immediately, no reverify call',
      () async {
        pendingDocumentController.set(_sampleBytes, _cleanExtraction());
        final viewModel = buildViewModel();

        await viewModel.editField.run((
          key: FieldKey.nationality,
          value: 'Venezolana',
        ));

        expect(fieldReverificationRepository.reverifyCallCount, 0);
        final ready = viewModel.state as DocumentConfirmationViewReady;
        final row = ready.fields.firstWhere((f) => f.key == FieldKey.nationality);
        expect(row.status, isA<FieldCorrectionAcceptedLowConfidence>());
        expect(row.currentValue, 'Venezolana');
        expect(
          analyticsEmitter.events.map((e) => e.name),
          contains('confirmation_field_edited'),
        );
      },
    );

    test(
      'editing a high-confidence field triggers reverify(); a confirmed '
      'outcome accepts it as re-verified',
      () async {
        pendingDocumentController.set(_sampleBytes, _cleanExtraction());
        final viewModel = buildViewModel();
        fieldReverificationRepository.scriptReverify(
          const Result.ok(FieldReverificationOutcome.confirmed()),
        );

        await viewModel.editField.run((
          key: FieldKey.documentNumber,
          value: 'CC 1.234.567.891',
        ));

        expect(fieldReverificationRepository.reverifyCallCount, 1);
        expect(fieldReverificationRepository.lastField, FieldKey.documentNumber);
        final ready = viewModel.state as DocumentConfirmationViewReady;
        final row = ready.fields.firstWhere(
          (f) => f.key == FieldKey.documentNumber,
        );
        expect(row.status, isA<FieldCorrectionAcceptedReverified>());
        expect(
          analyticsEmitter.events.map((e) => e.name),
          contains('confirmation_field_reverified'),
        );
      },
    );

    test(
      'a disagreed reverify outcome blocks confirmation for that field '
      '(unresolved) without forcing re-scan on the first miss',
      () async {
        pendingDocumentController.set(_sampleBytes, _cleanExtraction());
        final viewModel = buildViewModel();
        fieldReverificationRepository.scriptReverify(
          const Result.ok(FieldReverificationOutcome.disagreed()),
        );

        await viewModel.editField.run((
          key: FieldKey.documentNumber,
          value: 'CC 9.999.999.999',
        ));

        final ready = viewModel.state as DocumentConfirmationViewReady;
        final row = ready.fields.firstWhere(
          (f) => f.key == FieldKey.documentNumber,
        );
        expect(row.status, isA<FieldCorrectionUnresolved>());
        expect(row.blocksConfirmation, isTrue);
        // Not yet forced to re-scan — the cap is 3.
        expect(viewModel.pendingNavigation, isNull);
        expect(pendingDocumentController.hasPendingDocument, isTrue);
      },
    );

    test(
      'a transport-error reverify outcome is treated identically to disagreed',
      () async {
        pendingDocumentController.set(_sampleBytes, _cleanExtraction());
        final viewModel = buildViewModel();
        fieldReverificationRepository.scriptReverify(
          Result.error(StateError('offline')),
        );

        await viewModel.editField.run((
          key: FieldKey.expiryDate,
          value: '2032-01-01',
        ));

        final ready = viewModel.state as DocumentConfirmationViewReady;
        final row = ready.fields.firstWhere((f) => f.key == FieldKey.expiryDate);
        expect(row.status, isA<FieldCorrectionUnresolved>());
      },
    );

    test('an invalid-format edit is caught inline before confirmation', () async {
      pendingDocumentController.set(_sampleBytes, _cleanExtraction());
      final viewModel = buildViewModel();

      await viewModel.editField.run((key: FieldKey.documentNumber, value: 'abc'));

      final ready = viewModel.state as DocumentConfirmationViewReady;
      final row = ready.fields.firstWhere(
        (f) => f.key == FieldKey.documentNumber,
      );
      expect(row.status, isA<FieldCorrectionInvalidFormat>());
      expect(row.blocksConfirmation, isTrue);
      expect(fieldReverificationRepository.reverifyCallCount, 0);
    });

    test(
      'the 3rd unresolved correction attempt in the session discards the '
      'extraction and routes to re-scan',
      () async {
        pendingDocumentController.set(_sampleBytes, _cleanExtraction());
        final viewModel = buildViewModel();
        fieldReverificationRepository.scriptReverify(
          const Result.ok(FieldReverificationOutcome.disagreed()),
        );

        await viewModel.editField.run((
          key: FieldKey.documentNumber,
          value: 'CC 1',
        ));
        await viewModel.editField.run((
          key: FieldKey.documentNumber,
          value: 'CC 2',
        ));
        await viewModel.editField.run((
          key: FieldKey.documentNumber,
          value: 'CC 3',
        ));

        expect(
          viewModel.pendingNavigation,
          DocumentConfirmationNavigationTarget.documentCapture,
        );
        expect(pendingDocumentController.hasPendingDocument, isFalse);
        expect(
          analyticsEmitter.events.map((e) => e.name),
          contains('confirmation_correction_attempt_limit_reached'),
        );
      },
    );

    test('reverting a field back to its original value clears its status', () async {
      pendingDocumentController.set(_sampleBytes, _cleanExtraction());
      final viewModel = buildViewModel();

      await viewModel.editField.run((key: FieldKey.nationality, value: 'Peruana'));
      await viewModel.editField.run((
        key: FieldKey.nationality,
        value: 'Colombiana',
      ));

      final ready = viewModel.state as DocumentConfirmationViewReady;
      final row = ready.fields.firstWhere((f) => f.key == FieldKey.nationality);
      expect(row.status, isA<FieldCorrectionUnedited>());
      expect(row.currentValue, 'Colombiana');
    });

    test('re-scan discards the extraction and any edits, routing to capture', () async {
      pendingDocumentController.set(_sampleBytes, _cleanExtraction());
      final viewModel = buildViewModel();
      await viewModel.editField.run((key: FieldKey.nationality, value: 'Peruana'));

      await viewModel.rescan.run();

      expect(pendingDocumentController.hasPendingDocument, isFalse);
      expect(
        viewModel.pendingNavigation,
        DocumentConfirmationNavigationTarget.documentCapture,
      );
      expect(
        analyticsEmitter.events.map((e) => e.name),
        contains('confirmation_rescanned'),
      );
    });
  });

  group('T040 [US3]: expired document and missing-field blocking', () {
    test('an expired document blocks confirmation and states the reason', () {
      final expired = ExtractionResult(
        fields: [
          ..._cleanExtraction().fields.where(
            (f) => f.key != FieldKey.expiryDate,
          ),
          const ExtractedField.present(
            key: FieldKey.expiryDate,
            value: '2020-01-01',
            confidence: 0.95,
          ),
        ],
      );
      pendingDocumentController.set(_sampleBytes, expired);

      final viewModel = buildViewModel();

      expect(viewModel.state, isA<DocumentConfirmationViewBlocked>());
      final blocked = viewModel.state as DocumentConfirmationViewBlocked;
      expect(blocked.reason, DocumentBlockReason.expired);
      expect(
        analyticsEmitter.events.map((e) => e.name),
        contains('confirmation_blocked_unusable_document'),
      );
    });

    test('a missing required field is shown as an explicit gap, not confirmable', () {
      final missingNationality = ExtractionResult(
        fields: [
          ..._cleanExtraction().fields.where((f) => f.key != FieldKey.nationality),
          const ExtractedField.missing(key: FieldKey.nationality),
        ],
      );
      pendingDocumentController.set(_sampleBytes, missingNationality);

      final viewModel = buildViewModel();

      expect(viewModel.state, isA<DocumentConfirmationViewBlocked>());
      final blocked = viewModel.state as DocumentConfirmationViewBlocked;
      expect(blocked.reason, DocumentBlockReason.missingRequiredField);
    });
  });
}
