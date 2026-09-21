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
    final viewModel = WithdrawalViewModel(consentRepository: consentRepository);

    await pumpEventQueue();

    expect(viewModel.loading, isFalse);
    expect(viewModel.hasRecord, isTrue);
    viewModel.dispose();
  });

  test('a successful withdraw clears hasRecord (SC-005)', () async {
    final consentRepository = FakeConsentRepository();
    consentRepository.seedLocalRecord(_activeRecord());
    final viewModel = WithdrawalViewModel(consentRepository: consentRepository);
    await pumpEventQueue();

    await viewModel.withdraw.run();

    expect(viewModel.withdraw.completed, isTrue);
    expect(viewModel.hasRecord, isFalse);
    viewModel.dispose();
  });

  test('withdrawing with no local record surfaces the command error', () async {
    final consentRepository = FakeConsentRepository();
    consentRepository.seedLocalRecord(null);
    final viewModel = WithdrawalViewModel(consentRepository: consentRepository);
    await pumpEventQueue();

    await viewModel.withdraw.run();

    expect(viewModel.withdraw.error, isTrue);
    viewModel.dispose();
  });
}
