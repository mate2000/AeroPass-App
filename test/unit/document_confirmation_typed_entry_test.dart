// 015 T040 (FR-002, FR-002a, FR-016, FR-022, contracts/outcome-mapping.md
// "Registration"): 004 with nothing read from the document. The passenger
// types every field and chooses the type, the backend's rules apply on the
// device, and each refusal has its own consequence.
import 'dart:typed_data';

import 'package:aeropass_app/app/enrollment_session_controller.dart';
import 'package:aeropass_app/app/pending_document_controller.dart';
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/identity_record.dart';
import 'package:aeropass_app/domain/entities/registration_rejection.dart';
import 'package:aeropass_app/domain/entities/session_state.dart';
import 'package:aeropass_app/domain/entities/transport_failure.dart';
import 'package:aeropass_app/data/services/local_document_capture_repository.dart';
import 'package:aeropass_app/domain/entities/capture_outcome.dart';
import 'package:aeropass_app/features/enrollment/confirmation/document_confirmation_view_state.dart';
import 'package:aeropass_app/features/enrollment/confirmation/document_confirmation_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_analytics_emitter.dart';
import '../fakes/fake_clock.dart';
import '../fakes/fake_field_reverification_repository.dart';
import '../fakes/fake_identity_record_repository.dart';

final _photo = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xD9]);

void main() {
  late PendingDocumentController pending;
  late FakeFieldReverificationRepository reverification;
  late FakeIdentityRecordRepository identity;
  late EnrollmentSessionController session;
  late FakeClock clock;

  setUp(() async {
    pending = PendingDocumentController();
    reverification = FakeFieldReverificationRepository();
    identity = FakeIdentityRecordRepository();
    clock = FakeClock(DateTime(2026, 9, 23, 10));
    session = EnrollmentSessionController(clock: clock)..startOrResume();
    final outcome =
        (await const LocalDocumentCaptureRepository().submit(_photo))
                .valueOrNull!
            as CaptureOutcomeAccepted;
    pending.set(_photo, outcome.extraction);
  });

  DocumentConfirmationViewModel build() => DocumentConfirmationViewModel(
    pendingDocumentController: pending,
    fieldReverificationRepository: reverification,
    identityRecordRepository: identity,
    analyticsEmitter: FakeAnalyticsEmitter(),
    enrollmentSessionController: session,
    clock: clock,
  );

  DocumentConfirmationViewReady ready(DocumentConfirmationViewModel vm) =>
      vm.state as DocumentConfirmationViewReady;

  Future<void> fillValid(DocumentConfirmationViewModel vm) async {
    vm.selectDocumentType(DocumentType.cc);
    await vm.editField.run((key: FieldKey.fullName, value: 'Ana Prueba'));
    await vm.editField.run((
      key: FieldKey.documentNumber,
      value: '1.020.304.050',
    ));
    await vm.editField.run((key: FieldKey.expiryDate, value: '2030-01-31'));
  }

  bool canConfirm(DocumentConfirmationViewModel vm) {
    final state = ready(vm);
    return state.fields.every((f) => !f.blocksConfirmation) &&
        state.documentType != null;
  }

  test('an all-empty capture is typed entry, with no nationality', () {
    final vm = build();
    expect(ready(vm).typedEntry, isTrue);
    expect(ready(vm).fields.map((f) => f.key), [
      FieldKey.fullName,
      FieldKey.documentNumber,
      FieldKey.expiryDate,
    ]);
  });

  test('empty fields and no type block confirmation', () async {
    final vm = build();
    expect(canConfirm(vm), isFalse);
    await vm.confirm.run();
    expect(identity.confirmCallCount, 0);
  });

  test('typed edits are accepted without re-verification', () async {
    final vm = build();
    await fillValid(vm);
    expect(canConfirm(vm), isTrue);
    expect(reverification.reverifyCallCount, 0);
  });

  test(
    "the backend's rules mark a bad field before sending (FR-022)",
    () async {
      final vm = build();
      await vm.editField.run((key: FieldKey.documentNumber, value: '12'));
      await vm.editField.run((key: FieldKey.expiryDate, value: '2026-09-22'));
      await vm.editField.run((key: FieldKey.fullName, value: 'A'));
      for (final field in ready(vm).fields) {
        expect(field.status, const FieldCorrectionStatus.invalidFormat());
      }
    },
  );

  test('confirm sends the type, the typed values and the photo', () async {
    identity.scriptConfirm(const Result.ok(IdentityRecord(fields: [])));
    final vm = build();
    await fillValid(vm);
    await vm.confirm.run();

    final record = identity.lastSubmittedRecord!;
    expect(record.documentType, DocumentType.cc);
    expect(
      {for (final f in record.fields) f.key: f.value},
      {
        FieldKey.fullName: 'Ana Prueba',
        FieldKey.documentNumber: '1.020.304.050',
        FieldKey.expiryDate: '2030-01-31',
      },
    );
    expect(identity.lastDocumentPhoto, _photo);
    expect(
      vm.pendingNavigation,
      DocumentConfirmationNavigationTarget.selfieInstructions,
    );
  });

  group('each refusal', () {
    Future<DocumentConfirmationViewModel> refusedWith(Object error) async {
      identity.scriptConfirm(Result.error(error));
      final vm = build();
      await fillValid(vm);
      await vm.confirm.run();
      return vm;
    }

    test('InvalidFields marks the named fields and the type', () async {
      final vm = await refusedWith(
        const InvalidFields(
          fields: {FieldKey.documentNumber},
          documentType: true,
        ),
      );
      final state = ready(vm);
      expect(state.documentTypeInvalid, isTrue);
      expect(
        state.fields.firstWhere((f) => f.key == FieldKey.documentNumber).status,
        const FieldCorrectionStatus.invalidFormat(),
      );
      expect(
        state.fields.firstWhere((f) => f.key == FieldKey.fullName).status,
        isNot(const FieldCorrectionStatus.invalidFormat()),
      );
    });

    test('DocumentExpired blocks the document', () async {
      final vm = await refusedWith(const DocumentExpired());
      expect(
        vm.state,
        const DocumentConfirmationViewState.blocked(
          reason: DocumentBlockReason.expired,
        ),
      );
    });

    test('DocumentOwnedElsewhere goes to the agent, not an error', () async {
      final vm = await refusedWith(const DocumentOwnedElsewhere());
      expect(
        vm.pendingNavigation,
        DocumentConfirmationNavigationTarget.agentEscalation,
      );
      expect(ready(vm).confirmFailed, isFalse);
      expect(pending.hasPendingDocument, isFalse);
    });

    test('RecaptureDocument returns to capture', () async {
      final vm = await refusedWith(const RecaptureDocument());
      expect(
        vm.pendingNavigation,
        DocumentConfirmationNavigationTarget.documentCapture,
      );
    });

    test('each service or session condition has its own message', () async {
      final cases = <Object, ConfirmFailureKind>{
        const RegistrationServiceBusy(retryAfter: Duration(seconds: 30)):
            ConfirmFailureKind.serviceBusy,
        const AccountHasOtherDocument():
            ConfirmFailureKind.accountHasOtherDocument,
        const SessionUnavailable(): ConfirmFailureKind.session,
        const TransportFailure.connectivity('offline'):
            ConfirmFailureKind.connection,
        StateError('anything else'): ConfirmFailureKind.generic,
      };
      for (final MapEntry(key: error, value: kind) in cases.entries) {
        final vm = await refusedWith(error);
        expect(ready(vm).confirmFailed, isTrue, reason: '$error');
        expect(ready(vm).failureKind, kind, reason: '$error');
      }
    });
  });
}
