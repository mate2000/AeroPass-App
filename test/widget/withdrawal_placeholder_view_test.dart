import 'package:aeropass_app/domain/entities/consent_record.dart';
import 'package:aeropass_app/domain/entities/enrollment_attempt_id.dart';
import 'package:aeropass_app/domain/entities/processing_scope.dart';
import 'package:aeropass_app/features/account/withdrawal_placeholder_view.dart';
import 'package:aeropass_app/features/account/withdrawal_viewmodel.dart';
import 'package:aeropass_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_consent_repository.dart';

ConsentRecord _activeRecord() => ConsentRecord(
  textVersionId: 'v1',
  enrollmentAttemptId: EnrollmentAttemptId.generate(),
  scope: ProcessingScope.identityVerification,
  confirmedAt: DateTime.utc(2026, 1, 1),
  status: ConsentRecordStatus.active,
);

Future<void> _pumpWithdrawalView(
  WidgetTester tester, {
  required WithdrawalViewModel viewModel,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: WithdrawalPlaceholderView(viewModel: viewModel),
    ),
  );
}

void main() {
  group('T031 [US3] withdrawal placeholder', () {
    testWidgets(
      'confirming withdrawal invalidates the local record within the '
      'local-effect budget with no network dependency (SC-005)',
      (tester) async {
        // FakeConsentRepository never touches the network, mirroring
        // SC-005's "no network dependency for the local effect" — this
        // repository double has none to depend on in the first place.
        final consentRepository = FakeConsentRepository();
        consentRepository.seedLocalRecord(_activeRecord());
        final viewModel = WithdrawalViewModel(
          consentRepository: consentRepository,
        );
        await _pumpWithdrawalView(tester, viewModel: viewModel);
        await tester.pumpAndSettle();

        expect(find.text('Retirar consentimiento'), findsOneWidget);

        await tester.tap(find.text('Retirar consentimiento'));
        // A single pump (not pumpAndSettle) stands in for SC-005's ≤1s
        // budget: the local effect must already be applied almost
        // immediately, not after a network round trip.
        await tester.pump();

        final localResult = await consentRepository.getLocalRecord();
        final record = localResult.valueOrNull;
        expect(record, isNotNull);
        expect(record!.status, isNot(ConsentRecordStatus.active));

        await tester.pumpAndSettle();
        expect(
          find.text('Tu consentimiento fue retirado. Tu credencial ya no es válida.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'with no local record, shows the no-active-consent message instead '
      'of the confirm action',
      (tester) async {
        final consentRepository = FakeConsentRepository();
        consentRepository.seedLocalRecord(null);
        final viewModel = WithdrawalViewModel(
          consentRepository: consentRepository,
        );
        await _pumpWithdrawalView(tester, viewModel: viewModel);
        await tester.pumpAndSettle();

        expect(
          find.text(
            'No encontramos un consentimiento activo para retirar en este '
            'dispositivo.',
          ),
          findsOneWidget,
        );
        expect(find.text('Retirar consentimiento'), findsNothing);
      },
    );
  });
}
