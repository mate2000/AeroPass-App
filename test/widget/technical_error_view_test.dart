// 011-error-tecnico T012/T026/T039: screen 11 — wording by failure class,
// the neutral treatment, what was kept, the live status card, the
// notification claim, the held retry, navigation, announcements, goldens.
import 'package:aeropass_app/app/enrollment_session_controller.dart';
import 'package:aeropass_app/app/router.dart' show AppRoutes;
import 'package:aeropass_app/app/technical_error_controller.dart';
import 'package:aeropass_app/core/design/app_colors.dart';
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/service_failure.dart';
import 'package:aeropass_app/domain/entities/service_status.dart';
import 'package:aeropass_app/domain/entities/verification_stage.dart';
import 'package:aeropass_app/features/enrollment/technical_error/technical_error_view.dart';
import 'package:aeropass_app/features/enrollment/technical_error/technical_error_viewmodel.dart';
import 'package:aeropass_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../fakes/fake_analytics_emitter.dart';
import '../fakes/fake_clock.dart';
import '../fakes/fake_operational_alert_reporter.dart';
import '../fakes/fake_service_status_repository.dart';

Result<ServiceStatus> _status({
  StepHealth selfie = StepHealth.operational,
  DateTime? retryAfter,
}) => Result.ok(
  ServiceStatus(
    steps: {
      JourneyStep.documentScan: StepHealth.operational,
      JourneyStep.selfie: selfie,
      JourneyStep.issuance: StepHealth.operational,
    },
    retryAfter: retryAfter,
  ),
);

class _Harness {
  final clock = FakeClock();
  final controller = TechnicalErrorController();
  final status = FakeServiceStatusRepository();
  final analytics = FakeAnalyticsEmitter();
  final announcements = <String>[];
  late final session = EnrollmentSessionController(clock: clock);
  late FakeOperationalAlertReporter alerts;
}

Future<_Harness> _pump(
  WidgetTester tester, {
  ServiceFailureClass? failureClass = ServiceFailureClass.service,
  bool terminal = true,
  bool identityConfirmed = true,
  bool canClaim = false,
  List<Result<ServiceStatus>> statuses = const [],
  int previousArrivals = 0,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  final h = _Harness()
    ..alerts = FakeOperationalAlertReporter(canClaimNotification: canClaim);
  if (identityConfirmed) {
    h.session
      ..startOrResume()
      ..markIdentityConfirmed();
  }
  if (failureClass != null) {
    h.controller.record(
      ServiceFailure(
        failureClass: failureClass,
        stage: VerificationStage.faceComparison,
        jobTerminal: terminal,
        occurredAt: h.clock.now(),
      ),
    );
  }
  for (var i = 0; i < previousArrivals; i++) {
    h.controller.registerArrival();
  }
  h.status.scriptResults(statuses);

  tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
    SystemChannels.accessibility,
    (message) async {
      final data = (message as Map)['data'] as Map?;
      final text = data?['message'];
      if (text is String) h.announcements.add(text);
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger
        .setMockDecodedMessageHandler<dynamic>(
          SystemChannels.accessibility,
          null,
        ),
  );

  Widget stub(String name) => Scaffold(body: Center(child: Text(name)));
  final router = GoRouter(
    initialLocation: AppRoutes.technicalError,
    routes: [
      GoRoute(
        path: AppRoutes.technicalError,
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => TechnicalErrorViewModel(
            technicalErrorController: h.controller,
            enrollmentSessionController: h.session,
            statusRepository: h.status,
            alertReporter: h.alerts,
            analyticsEmitter: h.analytics,
            clock: h.clock,
          ),
          child: Consumer<TechnicalErrorViewModel>(
            builder: (context, viewModel, _) =>
                TechnicalErrorView(viewModel: viewModel),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.verificationProgress,
        builder: (context, state) => stub('verification-stub'),
      ),
      GoRoute(
        path: AppRoutes.livenessCapture,
        builder: (context, state) => stub('selfie-stub'),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => stub('welcome-stub'),
      ),
      GoRoute(
        path: AppRoutes.help,
        builder: (context, state) => stub('help-stub'),
      ),
      GoRoute(
        path: AppRoutes.agentEscalation,
        builder: (context, state) => stub('agent-stub'),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: child!,
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
  return h;
}

/// Disposes the tree, and with it the ViewModel's timers.
Future<void> leave(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 2));
}

Future<void> tapVisible(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.pumpAndSettle();
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

bool _usesColor(WidgetTester tester, Color color) {
  bool matches(Color? c) => c != null && c.toARGB32() == color.toARGB32();
  return tester
          .widgetList<Icon>(find.byType(Icon))
          .any((i) => matches(i.color)) ||
      tester
          .widgetList<Container>(find.byType(Container))
          .any(
            (c) =>
                matches(c.color) ||
                (c.decoration is BoxDecoration &&
                    matches((c.decoration! as BoxDecoration).color)),
          );
}

void main() {
  group('US1', () {
    testWidgets(
      'a service failure is the service\'s, with a neutral treatment',
      (tester) async {
        await _pump(tester);

        expect(find.text('No pudimos completar la validación'), findsOneWidget);
        expect(find.text('Es un problema nuestro, no tuyo.'), findsOneWidget);
        expect(find.byIcon(Icons.home_repair_service_outlined), findsOneWidget);
        expect(_usesColor(tester, AppColors.slateTile), isTrue);
        expect(_usesColor(tester, AppColors.amber), isFalse);
        expect(_usesColor(tester, AppColors.amberTile), isFalse);
        expect(_usesColor(tester, Colors.red), isFalse);
        expect(
          find.textContaining('También puedes usar el control de documentos'),
          findsOneWidget,
        );
        await leave(tester);
      },
    );

    testWidgets(
      'a dead job says a new selfie is needed, and the 24-hour window',
      (tester) async {
        await _pump(tester);

        expect(
          find.textContaining('solo tendrás que tomarte una nueva selfie'),
          findsOneWidget,
        );
        expect(find.textContaining('próximas 24 horas'), findsOneWidget);
        expect(find.textContaining('sin repetir fotos'), findsNothing);
        await leave(tester);
      },
    );

    testWidgets('a job that may still finish says no photo is repeated', (
      tester,
    ) async {
      await _pump(tester, terminal: false);

      expect(find.textContaining('sin repetir fotos'), findsOneWidget);
      expect(find.textContaining('nueva selfie'), findsNothing);
      await leave(tester);
    });

    testWidgets(
      'without a confirmed identity record nothing is claimed as kept',
      (tester) async {
        await _pump(tester, identityConfirmed: false);

        expect(find.textContaining('quedaron guardados'), findsNothing);
        expect(find.textContaining('próximas 24 horas'), findsOneWidget);
        await leave(tester);
      },
    );

    testWidgets('Reintentar on a dead job goes to the selfie', (tester) async {
      await _pump(tester);
      await tapVisible(tester, 'Reintentar');
      expect(find.text('selfie-stub'), findsOneWidget);
      await leave(tester);
    });

    testWidgets('Reintentar otherwise goes back to verification', (
      tester,
    ) async {
      await _pump(tester, terminal: false);
      await tapVisible(tester, 'Reintentar');
      expect(find.text('verification-stub'), findsOneWidget);
      await leave(tester);
    });

    testWidgets('Salir goes to welcome', (tester) async {
      await _pump(tester);
      await tapVisible(tester, 'Salir');
      expect(find.text('welcome-stub'), findsOneWidget);
      await leave(tester);
    });

    testWidgets('the agent path is one tap away', (tester) async {
      await _pump(tester);
      await tapVisible(tester, 'Hablar con un agente');
      expect(find.text('agent-stub'), findsOneWidget);
      await leave(tester);
    });

    testWidgets('Ayuda opens help, and returning leaves the screen as it was', (
      tester,
    ) async {
      await _pump(tester);
      await tapVisible(tester, 'Ayuda');
      expect(find.text('help-stub'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Es un problema nuestro, no tuyo.'), findsOneWidget);
      await leave(tester);
    });

    testWidgets('the back gesture does not leave the screen', (tester) async {
      await _pump(tester);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Es un problema nuestro, no tuyo.'), findsOneWidget);
      await leave(tester);
    });

    testWidgets('the title and cause are announced on open', (tester) async {
      final h = await _pump(tester);
      expect(
        h.announcements,
        contains(
          'No pudimos completar la validación. Es un problema nuestro, no tuyo.',
        ),
      );
      await leave(tester);
    });
  });

  group('US2', () {
    testWidgets('a live status renders three text lines', (tester) async {
      await _pump(tester, statuses: [_status(selfie: StepHealth.degraded)]);

      expect(find.text('Estado del servicio'), findsOneWidget);
      expect(find.text('Escaneo de documento'), findsOneWidget);
      expect(find.text('Selfie'), findsOneWidget);
      expect(find.text('Emisión de tu identidad'), findsOneWidget);
      expect(find.text('Con fallas'), findsOneWidget);
      expect(find.text('Operativo'), findsNWidgets(2));
      expect(
        find.bySemanticsLabel(RegExp(r'Selfie[\s\S]*Con fallas')),
        findsOneWidget,
      );
      await leave(tester);
    });

    testWidgets('everything operational still shows the card', (tester) async {
      await _pump(tester, statuses: [_status()]);
      expect(find.text('Estado del servicio'), findsOneWidget);
      expect(find.text('Operativo'), findsNWidgets(3));
      await leave(tester);
    });

    testWidgets('no live status, no card', (tester) async {
      await _pump(tester);
      expect(find.text('Estado del servicio'), findsNothing);
      expect(find.text('Operativo'), findsNothing);
      await leave(tester);
    });

    testWidgets('the card is a live region', (tester) async {
      await _pump(tester, statuses: [_status()]);
      final card = find.ancestor(
        of: find.text('Estado del servicio'),
        matching: find.byWidgetPredicate(
          (w) => w is Semantics && (w.properties.liveRegion ?? false),
        ),
      );
      expect(card, findsOneWidget);
      await leave(tester);
    });

    testWidgets(
      'a held retry shows its countdown and is announced unavailable',
      (tester) async {
        await _pump(tester, previousArrivals: 1);

        expect(find.text('Reintentar en 15 s'), findsOneWidget);
        expect(
          find.bySemanticsLabel('Reintentar no disponible por 15 segundos'),
          findsOneWidget,
        );
        final button = tester.widget<FilledButton>(find.byType(FilledButton));
        expect(button.onPressed, isNull);
        await leave(tester);
      },
    );

    testWidgets('a retryAfter from the source is stated as a time', (
      tester,
    ) async {
      await _pump(
        tester,
        statuses: [
          _status(
            selfie: StepHealth.degraded,
            retryAfter: DateTime.utc(2026, 9, 23, 12, 5),
          ),
        ],
      );
      expect(find.textContaining('Puedes reintentar a las'), findsOneWidget);
      await leave(tester);
    });

    testWidgets('the notification claim shows only when an alert backs it', (
      tester,
    ) async {
      await _pump(tester, canClaim: true);
      expect(
        find.textContaining('Nuestro equipo ya fue notificado.'),
        findsOneWidget,
      );
      await leave(tester);

      await _pump(tester);
      expect(
        find.textContaining('Nuestro equipo ya fue notificado.'),
        findsNothing,
      );
      await leave(tester);
    });
  });

  group('US3', () {
    testWidgets(
      'a lost connection is worded as the connection, never the service',
      (tester) async {
        await _pump(
          tester,
          failureClass: ServiceFailureClass.connectivity,
          terminal: false,
          canClaim: true,
        );

        expect(find.text('No pudimos conectarnos'), findsOneWidget);
        expect(
          find.text('Parece que se perdió la conexión a internet.'),
          findsOneWidget,
        );
        expect(find.textContaining('Revisa tu conexión'), findsOneWidget);
        expect(find.textContaining('problema nuestro'), findsNothing);
        expect(find.textContaining('notificado'), findsNothing);
        await leave(tester);
      },
    );

    for (final failureClass in [ServiceFailureClass.undetermined, null]) {
      testWidgets(
        'an undetermined cause (${failureClass ?? 'nothing recorded'}) asserts none',
        (tester) async {
          await _pump(
            tester,
            failureClass: failureClass,
            terminal: false,
            canClaim: true,
          );

          expect(
            find.text('No pudimos completar la validación'),
            findsOneWidget,
          );
          expect(find.text('No fue por algo que hayas hecho.'), findsOneWidget);
          expect(find.textContaining('problema nuestro'), findsNothing);
          expect(find.textContaining('conexión'), findsNothing);
          expect(find.textContaining('notificado'), findsNothing);
          await leave(tester);
        },
      );
    }
  });

  group('goldens', () {
    testWidgets('technical_error.png', (tester) async {
      await _pump(tester);
      await expectLater(
        find.byType(TechnicalErrorView),
        matchesGoldenFile('goldens/technical_error.png'),
      );
      await leave(tester);
    });

    testWidgets('technical_error_status.png', (tester) async {
      await _pump(
        tester,
        canClaim: true,
        statuses: [_status(selfie: StepHealth.degraded)],
      );
      await expectLater(
        find.byType(TechnicalErrorView),
        matchesGoldenFile('goldens/technical_error_status.png'),
      );
      await leave(tester);
    });

    testWidgets('technical_error_text_2x.png', (tester) async {
      await _pump(
        tester,
        statuses: [_status(selfie: StepHealth.degraded)],
        textScaler: const TextScaler.linear(2),
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(TechnicalErrorView),
        matchesGoldenFile('goldens/technical_error_text_2x.png'),
      );
      await leave(tester);
    });
  });
}
