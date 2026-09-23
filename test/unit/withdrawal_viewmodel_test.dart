import 'package:aeropass_app/app/activated_credential_handoff.dart';
import 'package:aeropass_app/domain/entities/activated_credential.dart';
import 'package:aeropass_app/domain/entities/consent_record.dart';
import 'package:aeropass_app/domain/entities/enrollment_attempt_id.dart';
import 'package:aeropass_app/domain/entities/processing_scope.dart';
import 'package:aeropass_app/features/account/withdrawal_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_consent_repository.dart';

ConsentRecord _activeRecord() => ConsentRecord(
  textVersionId: 'v1',
  enrollmentAttemptId: EnrollmentAttemptId.generate(),
  scope: ProcessingScope.identityVerification,
  confirmedAt: DateTime.utc(2026, 1, 1),
  status: ConsentRecordStatus.active,
);

void main() {
  test('loads whether a local record exists (hasRecord)', () async {
    final consentRepository = FakeConsentRepository();
    consentRepository.seedLocalRecord(_activeRecord());
    final viewModel = WithdrawalViewModel(
      consentRepository: consentRepository,
      activatedCredentialHandoff: ActivatedCredentialHandoff(),
    );

    await pumpEventQueue();

    expect(viewModel.loading, isFalse);
    expect(viewModel.hasRecord, isTrue);
    viewModel.dispose();
  });

  test('a successful withdraw clears hasRecord (SC-005)', () async {
    final consentRepository = FakeConsentRepository();
    consentRepository.seedLocalRecord(_activeRecord());
    final viewModel = WithdrawalViewModel(
      consentRepository: consentRepository,
      activatedCredentialHandoff: ActivatedCredentialHandoff(),
    );
    await pumpEventQueue();

    await viewModel.withdraw.run();

    expect(viewModel.withdraw.completed, isTrue);
    expect(viewModel.hasRecord, isFalse);
    viewModel.dispose();
  });

  test('withdrawing with no local record surfaces the command error', () async {
    final consentRepository = FakeConsentRepository();
    consentRepository.seedLocalRecord(null);
    final viewModel = WithdrawalViewModel(
      consentRepository: consentRepository,
      activatedCredentialHandoff: ActivatedCredentialHandoff(),
    );
    await pumpEventQueue();

    await viewModel.withdraw.run();

    expect(viewModel.withdraw.error, isTrue);
    viewModel.dispose();
  });

  // 008-identidad-activa T028: withdrawal also ends any pending
  // presentation of a just-issued credential (FR-011).
  test(
    'a successful withdraw clears the activated-credential hand-off',
    () async {
      final consentRepository = FakeConsentRepository();
      consentRepository.seedLocalRecord(_activeRecord());
      final handoff = ActivatedCredentialHandoff()
        ..set(
          ActivatedCredential(
            holderName: 'Mateo González Restrepo',
            documentLast4: '7890',
            issuingCountry: 'COL',
            issuedAt: DateTime.utc(2026, 9, 16),
            validUntil: DateTime.utc(2031, 9, 16),
          ),
        );
      final viewModel = WithdrawalViewModel(
        consentRepository: consentRepository,
        activatedCredentialHandoff: handoff,
      );
      await pumpEventQueue();

      await viewModel.withdraw.run();

      expect(handoff.hasCredential, isFalse);
      viewModel.dispose();
    },
  );
}
