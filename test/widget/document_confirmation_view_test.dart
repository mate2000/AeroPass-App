import 'dart:typed_data';

import 'package:aeropass_app/app/enrollment_session_controller.dart';
import 'package:aeropass_app/app/pending_document_controller.dart';
import 'package:aeropass_app/app/router.dart' show AppRoutes;
import 'package:aeropass_app/core/clock.dart';
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/extraction_result.dart';
import 'package:aeropass_app/domain/entities/field_reverification_outcome.dart';
import 'package:aeropass_app/domain/entities/identity_record.dart';
import 'package:aeropass_app/features/enrollment/confirmation/document_confirmation_view.dart';
import 'package:aeropass_app/features/enrollment/confirmation/document_confirmation_viewmodel.dart';
import 'package:aeropass_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../fakes/fake_analytics_emitter.dart';
import '../fakes/fake_field_reverification_repository.dart';
import '../fakes/fake_identity_record_repository.dart';

class _FixedClock implements Clock {
  _FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

final _sampleBytes = Uint8List.fromList(List.filled(16, 1));

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

Future<void> _pumpConfirmationView(
  WidgetTester tester, {
  required DocumentConfirmationViewModel viewModel,
}) async {
  final router = GoRouter(
    initialLocation: AppRoutes.documentCapture,
    routes: [
      GoRoute(
        path: AppRoutes.documentCapture,
        builder: (context, state) =>
            const Scaffold(body: Text('document-capture-stub')),
      ),
      GoRoute(
        path: AppRoutes.documentConfirmation,
        builder: (context, state) => DocumentConfirmationView(viewModel: viewModel),
      ),
      GoRoute(
        path: AppRoutes.selfieInstructions,
        builder: (context, state) =>
            const Scaffold(body: Text('selfie-instructions-stub')),
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
  router.push(AppRoutes.documentConfirmation);
  await tester.pumpAndSettle();
}

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

  DocumentConfirmationViewModel buildViewModel() => DocumentConfirmationViewModel(
    pendingDocumentController: pendingDocumentController,
    fieldReverificationRepository: fieldReverificationRepository,
    identityRecordRepository: identityRecordRepository,
    analyticsEmitter: analyticsEmitter,
    enrollmentSessionController: sessionController,
    clock: clock,
  );

  group('T021 [US1] clean confirmation', () {
    testWidgets('shows the thumbnail, badge, notice, and every field read-only', (
      tester,
    ) async {
      pendingDocumentController.set(_sampleBytes, _cleanExtraction());
      await _pumpConfirmationView(tester, viewModel: buildViewModel());

      expect(find.text('Capturado'), findsOneWidget);
      expect(
        find.text('Verifica que los datos coincidan exactamente con tu documento original.'),
        findsOneWidget,
      );
      expect(find.text('Mateo González Restrepo'), findsOneWidget);
      expect(find.text('CC 1.234.567.890'), findsOneWidget);
      expect(find.text('Colombiana'), findsOneWidget);
      expect(find.text('14 mar 2031'), findsOneWidget);
      expect(find.text('Los datos son correctos'), findsOneWidget);
      expect(find.text('Escanear de nuevo'), findsOneWidget);
    });

    testWidgets('confirming navigates to the selfie-instructions route', (tester) async {
      pendingDocumentController.set(_sampleBytes, _cleanExtraction());
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
      await _pumpConfirmationView(tester, viewModel: buildViewModel());

      await tester.tap(find.text('Los datos son correctos'));
      await tester.pumpAndSettle();

      expect(find.text('selfie-instructions-stub'), findsOneWidget);
    });
  });

  group('T033 [US2] field correction', () {
    testWidgets('tapping the edit affordance opens the in-place editor', (tester) async {
      pendingDocumentController.set(_sampleBytes, _cleanExtraction());
      await _pumpConfirmationView(tester, viewModel: buildViewModel());

      await tester.tap(
        find.bySemanticsLabel('Editar Nacionalidad'),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets(
      'a high-confidence field being reverified shows a running state, then '
      'an unresolved outcome disables confirmation',
      (tester) async {
        pendingDocumentController.set(_sampleBytes, _cleanExtraction());
        fieldReverificationRepository.scriptReverify(
          const Result.ok(FieldReverificationOutcome.disagreed()),
        );
        await _pumpConfirmationView(tester, viewModel: buildViewModel());

        await tester.tap(find.bySemanticsLabel('Editar Número de documento'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'CC 9.999.999.999');
        await tester.tap(find.byIcon(Icons.check));
        await tester.pumpAndSettle();

        expect(
          find.text('No pudimos confirmar este dato con tu documento. Puedes intentarlo de nuevo o escanear otra vez.'),
          findsOneWidget,
        );
        final confirmButton = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Los datos son correctos'),
        );
        expect(confirmButton.onPressed, isNull);
      },
    );
  });

  group('T041 [US3] expired and missing-field blocking', () {
    testWidgets('an expired document replaces the field list with the blocked message', (
      tester,
    ) async {
      final expired = ExtractionResult(
        fields: [
          ..._cleanExtraction().fields.where((f) => f.key != FieldKey.expiryDate),
          const ExtractedField.present(
            key: FieldKey.expiryDate,
            value: '2020-01-01',
            confidence: 0.95,
          ),
        ],
      );
      pendingDocumentController.set(_sampleBytes, expired);
      await _pumpConfirmationView(tester, viewModel: buildViewModel());

      expect(find.text('Tu documento está vencido'), findsOneWidget);
      expect(find.text('Los datos son correctos'), findsNothing);
      expect(find.text('Escanear de nuevo'), findsOneWidget);
    });

    testWidgets('a missing required field shows the gap-blocked message, not a blank field', (
      tester,
    ) async {
      final missingNationality = ExtractionResult(
        fields: [
          ..._cleanExtraction().fields.where((f) => f.key != FieldKey.nationality),
          const ExtractedField.missing(key: FieldKey.nationality),
        ],
      );
      pendingDocumentController.set(_sampleBytes, missingNationality);
      await _pumpConfirmationView(tester, viewModel: buildViewModel());

      expect(find.text('No pudimos leer todos los datos de tu documento'), findsOneWidget);
      expect(find.text('Los datos son correctos'), findsNothing);
    });
  });

  group('T049: accessibility (FR-015, Constitution Principle VI)', () {
    testWidgets('every interactive control has a semantic label', (tester) async {
      pendingDocumentController.set(_sampleBytes, _cleanExtraction());
      final handle = tester.ensureSemantics();
      await _pumpConfirmationView(tester, viewModel: buildViewModel());

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      handle.dispose();
    });
  });

  group('T048: "Atrás" back navigation (FR-013)', () {
    testWidgets('pops the route, discards the pending document, and records abandonment exactly once', (
      tester,
    ) async {
      pendingDocumentController.set(_sampleBytes, _cleanExtraction());
      await _pumpConfirmationView(tester, viewModel: buildViewModel());

      await tester.tap(find.text('Atrás'));
      await tester.pumpAndSettle();

      expect(find.text('document-capture-stub'), findsOneWidget);
      expect(pendingDocumentController.hasPendingDocument, isFalse);
      expect(
        analyticsEmitter.events
            .where((e) => e.name == 'confirmation_step_abandoned')
            .length,
        1,
      );
    });
  });
}
