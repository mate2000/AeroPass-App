// 010-escalar-agente T009/T023/T027: the escalation screen — copy by arrival,
// the named module, honest availability, the location sheet, the chat route,
// the declined and expired states, announcements, and goldens.
import 'package:aeropass_app/app/activated_credential_handoff.dart';
import 'package:aeropass_app/app/enrollment_session_controller.dart';
import 'package:aeropass_app/app/router.dart' show AppRoutes;
import 'package:aeropass_app/core/clock.dart';
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/capture_attempt_counter.dart';
import 'package:aeropass_app/domain/entities/escalation.dart';
import 'package:aeropass_app/features/enrollment/escalation/escalation_view.dart';
import 'package:aeropass_app/features/enrollment/escalation/escalation_viewmodel.dart';
import 'package:aeropass_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../fakes/fake_analytics_emitter.dart';
import '../fakes/fake_capture_attempt_counter_repository.dart';
import '../fakes/fake_credential_issuance_repository.dart';
import '../fakes/fake_escalation_repository.dart';

class _Clock implements Clock {
  @override
  DateTime now() => DateTime.utc(2026, 9, 23, 12);
}

const _poll = Duration(milliseconds: 100);

AgentChannel _module({bool available = true}) => AgentChannel(
  kind: AgentChannelKind.module,
  available: available,
  nextOpensAt: available ? null : DateTime.utc(2026, 9, 24, 11),
  hours: 'Lun–Vie 6:00am–10:00pm',
  locationName: 'Aeropuerto de prueba',
  locationDetail: 'Segundo piso, junto a seguridad',
);

AgentChannel _chat({bool available = true, WaitEstimate? wait}) => AgentChannel(
  kind: AgentChannelKind.chat,
  available: available,
  nextOpensAt: available ? null : DateTime.utc(2026, 9, 24, 8),
  estimatedWait: wait,
  hours: 'Todos los días',
);

class _Harness {
  final escalations = FakeEscalationRepository();
  final analytics = FakeAnalyticsEmitter();
  final announcements = <String>[];
}

Future<_Harness> _pump(
  WidgetTester tester, {
  required List<Result<EscalationStatus>> statuses,
  bool afterLimit = false,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  final h = _Harness();
  h.escalations
    ..openResult = Result.ok(
      EscalationCase(
        openedAt: DateTime.utc(2026, 9, 23, 12),
        arrival: afterLimit
            ? EscalationArrival.afterLimit
            : EscalationArrival.byChoice,
      ),
    )
    ..scriptStatuses(statuses);
  final counters = FakeCaptureAttemptCounterRepository();
  if (afterLimit) {
    counters.seed(
      AttemptCounterScope.selfieLiveness,
      CaptureAttemptCounter(
        count: captureAttemptLimit,
        lastResetAt: DateTime.utc(2026),
      ),
    );
  }

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
    initialLocation: '/previous',
    routes: [
      GoRoute(
        path: '/previous',
        builder: (context, state) => stub('previous-stub'),
      ),
      GoRoute(
        path: AppRoutes.agentEscalation,
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => EscalationViewModel(
            escalationRepository: h.escalations,
            issuanceRepository: FakeCredentialIssuanceRepository(),
            handoff: ActivatedCredentialHandoff(),
            enrollmentSessionController: EnrollmentSessionController(
              clock: _Clock(),
            ),
            attemptCounterRepository: counters,
            analyticsEmitter: h.analytics,
            clock: _Clock(),
            pollInterval: _poll,
          ),
          child: Consumer<EscalationViewModel>(
            builder: (context, viewModel, _) =>
                EscalationView(viewModel: viewModel),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.agentChat,
        builder: (context, state) => stub('chat-stub'),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => stub('welcome-stub'),
      ),
      GoRoute(
        path: AppRoutes.help,
        builder: (context, state) => stub('help-stub'),
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
  router.push(AppRoutes.agentEscalation);
  await tester.pumpAndSettle();
  await tester.pump(_poll);
  await tester.pumpAndSettle();
  return h;
}

Result<EscalationStatus> _open(List<AgentChannel> channels) => Result.ok(
  EscalationStatus.open(
    escalation: EscalationCase(
      openedAt: DateTime.utc(2026, 9, 23, 12),
      arrival: EscalationArrival.byChoice,
    ),
    channels: channels,
  ),
);

const _title = 'Necesitamos verificarte en persona';
const _byChoice =
    'Un agente en el módulo AeroPass puede ayudarte a completar tu verificación.';
const _afterLimit =
    'No pudimos confirmar tu identidad automáticamente. Un agente en el módulo '
    'AeroPass puede ayudarte a completar el proceso.';
const _checkpoint =
    'También puedes usar el control de documentos habitual en el aeropuerto.';

void main() {
  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(1080, 2340);
    view.devicePixelRatio = 3;
  });
  tearDown(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  Future<void> leave(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(_poll);
  }

  group('US1', () {
    testWidgets(
      'by choice: title, body without "agotaste", named module, chat, checkpoint',
      (tester) async {
        final h = await _pump(
          tester,
          statuses: [
            _open([_module(), _chat()]),
          ],
        );

        expect(find.text(_title), findsOneWidget);
        expect(find.text(_byChoice), findsOneWidget);
        expect(find.textContaining('gotaste'), findsNothing);
        expect(find.text('Módulo AeroPass'), findsOneWidget);
        expect(find.textContaining('Aeropuerto de prueba'), findsOneWidget);
        expect(find.textContaining('Lun–Vie 6:00am–10:00pm'), findsOneWidget);
        expect(find.text('Chat con un agente'), findsOneWidget);
        expect(find.textContaining('Resuelve tus dudas'), findsOneWidget);
        expect(find.text(_checkpoint), findsOneWidget);
        expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
        expect(h.announcements.join(' '), contains(_title));
        await leave(tester);
      },
    );

    testWidgets('after the limit: the after-limit body', (tester) async {
      await _pump(
        tester,
        statuses: [
          _open([_module(), _chat()]),
        ],
        afterLimit: true,
      );

      expect(find.text(_afterLimit), findsOneWidget);
      await leave(tester);
    });

    testWidgets('uses no red or error colour', (tester) async {
      await _pump(
        tester,
        statuses: [
          _open([_module(), _chat()]),
        ],
      );

      final error = Theme.of(tester.element(find.text(_title)))
          .colorScheme
          .error;
      for (final icon in tester.widgetList<Icon>(find.byType(Icon))) {
        expect(icon.color, isNot(error));
        expect(icon.color, isNot(Colors.red));
      }
      await leave(tester);
    });

    testWidgets('"Cómo llegar al módulo" opens the location sheet', (
      tester,
    ) async {
      await _pump(
        tester,
        statuses: [
          _open([_module(), _chat()]),
        ],
      );

      await tester.tap(find.text('Cómo llegar al módulo'));
      await tester.pumpAndSettle();

      expect(find.text('Dónde encontrar el módulo'), findsOneWidget);
      expect(
        find.textContaining('Segundo piso, junto a seguridad'),
        findsWidgets,
      );
      await leave(tester);
    });

    testWidgets('selecting the chat switches the action and opens the chat', (
      tester,
    ) async {
      await _pump(
        tester,
        statuses: [
          _open([_module(), _chat()]),
        ],
      );

      await tester.ensureVisible(find.text('Chat con un agente'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chat con un agente'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Iniciar chat'));
      await tester.pumpAndSettle();

      expect(find.text('chat-stub'), findsOneWidget);
      await leave(tester);
    });

    testWidgets('"Volver al inicio" goes to welcome', (tester) async {
      await _pump(
        tester,
        statuses: [
          _open([_module(), _chat()]),
        ],
      );

      await tester.tap(find.text('Volver al inicio'));
      await tester.pumpAndSettle();

      expect(find.text('welcome-stub'), findsOneWidget);
      await leave(tester);
    });

    testWidgets('the back gesture returns to the previous screen', (
      tester,
    ) async {
      await _pump(
        tester,
        statuses: [
          _open([_module(), _chat()]),
        ],
      );

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('previous-stub'), findsOneWidget);
      await leave(tester);
    });

    group('goldens', () {
      for (final (name, scaler) in [
        ('escalation.png', TextScaler.noScaling),
        ('escalation_text_2x.png', const TextScaler.linear(2)),
      ]) {
        testWidgets(name, (tester) async {
          await _pump(
            tester,
            statuses: [
              _open([_module(), _chat()]),
            ],
            textScaler: scaler,
          );
          await expectLater(
            find.byType(EscalationView),
            matchesGoldenFile('goldens/$name'),
          );
          await leave(tester);
        });
      }
    });
  });

  group('US2', () {
    testWidgets(
      'an unavailable card says so and when it opens, and cannot be selected',
      (tester) async {
        await _pump(
          tester,
          statuses: [
            _open([_module(), _chat(available: false)]),
          ],
        );

        expect(find.text('No disponible'), findsOneWidget);
        expect(find.textContaining('Abre '), findsOneWidget);
        await tester.ensureVisible(find.text('Chat con un agente'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Chat con un agente'));
        await tester.pumpAndSettle();
        expect(find.text('Iniciar chat'), findsNothing);
        expect(find.text('Cómo llegar al módulo'), findsOneWidget);
        await leave(tester);
      },
    );

    testWidgets('no wait is shown unless supplied; the range when it is', (
      tester,
    ) async {
      await _pump(
        tester,
        statuses: [
          _open([_module(), _chat()]),
        ],
      );
      expect(find.textContaining('Espera estimada'), findsNothing);
      await leave(tester);

      await _pump(
        tester,
        statuses: [
          _open([
            _module(),
            _chat(wait: const WaitEstimate(minMinutes: 2, maxMinutes: 5)),
          ]),
        ],
      );
      expect(find.text('Espera estimada: 2–5 minutos'), findsOneWidget);
      await leave(tester);
    });

    testWidgets(
      'with both closed: what to do now, the checkpoint, and home still work',
      (tester) async {
        await _pump(
          tester,
          statuses: [
            _open([_module(available: false), _chat(available: false)]),
          ],
        );

        expect(find.textContaining('no hay canales abiertos'), findsOneWidget);
        expect(find.text(_checkpoint), findsOneWidget);
        expect(find.text('Cómo llegar al módulo'), findsNothing);
        expect(find.text('Iniciar chat'), findsNothing);
        await tester.tap(find.text('Volver al inicio'));
        await tester.pumpAndSettle();
        expect(find.text('welcome-stub'), findsOneWidget);
        await leave(tester);
      },
    );
  });

  group('US3', () {
    testWidgets('declined: plain message, checkpoint, and a way home', (
      tester,
    ) async {
      await _pump(
        tester,
        statuses: [
          const Result.ok(
            EscalationStatus.resolved(outcome: EscalationOutcome.declined()),
          ),
        ],
      );

      expect(find.text('No pudimos completar tu verificación'), findsOneWidget);
      expect(
        find.textContaining('control de documentos habitual'),
        findsWidgets,
      );
      expect(find.text('Volver al inicio'), findsOneWidget);
      await leave(tester);
    });

    testWidgets('expired: explains the 24 hours and offers a new request', (
      tester,
    ) async {
      final h = await _pump(
        tester,
        statuses: [const Result.ok(EscalationStatus.expired())],
      );

      expect(find.text('Tu solicitud expiró'), findsOneWidget);
      expect(find.text(_checkpoint), findsOneWidget);

      h.escalations.scriptStatuses([
        _open([_module(), _chat()]),
      ]);
      await tester.tap(find.text('Abrir nueva solicitud'));
      await tester.pumpAndSettle();
      await tester.pump(_poll);
      await tester.pumpAndSettle();

      expect(h.escalations.openCallCount, 2);
      expect(find.text('Módulo AeroPass'), findsOneWidget);
      await leave(tester);
    });
  });
}
