import 'package:aeropass_app/app/enrollment_session_controller.dart';
import 'package:aeropass_app/app/router.dart' show AppRoutes;
import 'package:aeropass_app/core/clock.dart';
import 'package:aeropass_app/features/enrollment/selfie/selfie_instructions_view.dart';
import 'package:aeropass_app/features/enrollment/selfie/selfie_instructions_viewmodel.dart';
import 'package:aeropass_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../fakes/fake_analytics_emitter.dart';

class _FixedClock implements Clock {
  _FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

Future<void> _pumpSelfieInstructionsView(
  WidgetTester tester, {
  required SelfieInstructionsViewModel viewModel,
  TextScaler? textScaler,
}) async {
  final router = GoRouter(
    initialLocation: AppRoutes.documentConfirmation,
    routes: [
      GoRoute(
        path: AppRoutes.documentConfirmation,
        builder: (context, state) =>
            const Scaffold(body: Text('document-confirmation-stub')),
      ),
      GoRoute(
        path: AppRoutes.selfieInstructions,
        builder: (context, state) => SelfieInstructionsView(viewModel: viewModel),
      ),
      GoRoute(
        path: AppRoutes.livenessCapture,
        builder: (context, state) =>
            const Scaffold(body: Text('liveness-capture-stub')),
      ),
      GoRoute(
        path: AppRoutes.help,
        builder: (context, state) => const Scaffold(body: Text('help-stub')),
      ),
    ],
  );

  final app = MaterialApp.router(
    routerConfig: router,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
  await tester.pumpWidget(
    textScaler == null
        ? app
        : MediaQuery(
            data: MediaQueryData(textScaler: textScaler),
            child: app,
          ),
  );
  router.push(AppRoutes.selfieInstructions);
  await tester.pumpAndSettle();
}

void main() {
  late EnrollmentSessionController sessionController;
  late FakeAnalyticsEmitter analyticsEmitter;

  setUp(() {
    sessionController = EnrollmentSessionController(
      clock: _FixedClock(DateTime.utc(2026, 1, 1)),
    );
    sessionController.startOrResume();
    analyticsEmitter = FakeAnalyticsEmitter();
  });

  SelfieInstructionsViewModel buildViewModel() => SelfieInstructionsViewModel(
    enrollmentSessionController: sessionController,
    analyticsEmitter: analyticsEmitter,
  );

  group('T013 [US1] instructional content', () {
    testWidgets('shows the title, subtitle, and all three conditions', (
      tester,
    ) async {
      await _pumpSelfieInstructionsView(tester, viewModel: buildViewModel());

      expect(find.text('Ahora una selfie'), findsOneWidget);
      expect(
        find.text('Necesitamos confirmar que eres el titular del documento.'),
        findsOneWidget,
      );
      expect(find.text('Buena iluminación, de frente a la luz'), findsOneWidget);
      expect(
        find.text('Rostro descubierto y visible por completo'),
        findsOneWidget,
      );
      expect(find.text('Mira directamente a la cámara'), findsOneWidget);
      expect(find.text('Tomar selfie'), findsOneWidget);
    });

    testWidgets(
      'the step indicator shows this step as Selfie (2/3), not Documento',
      (tester) async {
        await _pumpSelfieInstructionsView(tester, viewModel: buildViewModel());

        expect(find.bySemanticsLabel('Selfie 2/3'), findsOneWidget);
      },
    );

    testWidgets('tapping "Tomar selfie" navigates to liveness capture', (
      tester,
    ) async {
      await _pumpSelfieInstructionsView(tester, viewModel: buildViewModel());

      await tester.tap(find.text('Tomar selfie'));
      await tester.pumpAndSettle();

      expect(find.text('liveness-capture-stub'), findsOneWidget);
    });
  });

  group('T022 [US2] help route, back navigation, and CONFLICT-001 wording', () {
    testWidgets('"Ayuda" opens help and returns with the session intact', (
      tester,
    ) async {
      await _pumpSelfieInstructionsView(tester, viewModel: buildViewModel());

      await tester.tap(find.text('Ayuda'));
      await tester.pumpAndSettle();
      expect(find.text('help-stub'), findsOneWidget);

      final navigator = tester.state<NavigatorState>(
        find.byType(Navigator).first,
      );
      navigator.pop();
      await tester.pumpAndSettle();

      expect(find.text('Ahora una selfie'), findsOneWidget);
      expect(
        analyticsEmitter.events.map((e) => e.name),
        contains('selfie_instructions_help_opened'),
      );
    });

    testWidgets('"Atrás" pops to data confirmation', (tester) async {
      await _pumpSelfieInstructionsView(tester, viewModel: buildViewModel());

      await tester.tap(find.text('Atrás'));
      await tester.pumpAndSettle();

      expect(find.text('document-confirmation-stub'), findsOneWidget);
      expect(
        analyticsEmitter.events.map((e) => e.name),
        contains('selfie_instructions_step_abandoned'),
      );
    });

    testWidgets(
      'the face-visibility condition never mentions removing glasses, caps, or a mask',
      (tester) async {
        await _pumpSelfieInstructionsView(tester, viewModel: buildViewModel());

        expect(find.textContaining('gafas'), findsNothing);
        expect(find.textContaining('gorra'), findsNothing);
        expect(find.textContaining('mascarilla'), findsNothing);
      },
    );
  });

  group('T025: accessibility (FR-011/SC-006, Constitution Principle VI)', () {
    testWidgets('every interactive control has a semantic label', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpSelfieInstructionsView(tester, viewModel: buildViewModel());

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      handle.dispose();
    });

    testWidgets(
      'the title, subtitle, and all three conditions remain legible and '
      'unclipped at the platform maximum text size',
      (tester) async {
        await _pumpSelfieInstructionsView(
          tester,
          viewModel: buildViewModel(),
          textScaler: const TextScaler.linear(3.0),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('Ahora una selfie'), findsOneWidget);
        expect(
          find.text('Necesitamos confirmar que eres el titular del documento.'),
          findsOneWidget,
        );
        expect(find.text('Buena iluminación, de frente a la luz'), findsOneWidget);
        expect(
          find.text('Rostro descubierto y visible por completo'),
          findsOneWidget,
        );
        expect(find.text('Mira directamente a la cámara'), findsOneWidget);
      },
    );
  });
}
