// 009-reintento T007/T013: contracts/retry-guidance-screen.md — the three
// states, their routes, the absence of any count, comparison or detection
// wording, the amber (never red) styling, announcements, and goldens.
import 'package:aeropass_app/app/router.dart' show AppRoutes;
import 'package:aeropass_app/domain/entities/capture_attempt_counter.dart';
import 'package:aeropass_app/features/enrollment/retry/retry_guidance_view.dart';
import 'package:aeropass_app/features/enrollment/retry/retry_guidance_viewmodel.dart';
import 'package:aeropass_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../fakes/fake_analytics_emitter.dart';
import '../fakes/fake_capture_attempt_counter_repository.dart';

class _Harness {
  final analytics = FakeAnalyticsEmitter();
  final announcements = <String>[];
}

enum _Seed { belowLimit, selfieAtLimit, documentAtLimit }

Future<_Harness> _pump(
  WidgetTester tester, {
  _Seed seed = _Seed.belowLimit,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  final h = _Harness();
  final counters = FakeCaptureAttemptCounterRepository();
  void set(AttemptCounterScope scope, int count) => counters.seed(
    scope,
    CaptureAttemptCounter(count: count, lastResetAt: DateTime.utc(2026)),
  );
  switch (seed) {
    case _Seed.belowLimit:
      set(AttemptCounterScope.selfieLiveness, 1);
    case _Seed.selfieAtLimit:
      set(AttemptCounterScope.selfieLiveness, captureAttemptLimit);
    case _Seed.documentAtLimit:
      set(AttemptCounterScope.documentCapture, captureAttemptLimit);
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
    initialLocation: AppRoutes.retryGuidance,
    routes: [
      GoRoute(
        path: AppRoutes.retryGuidance,
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => RetryGuidanceViewModel(
            attemptCounterRepository: counters,
            analyticsEmitter: h.analytics,
          ),
          child: Consumer<RetryGuidanceViewModel>(
            builder: (context, viewModel, _) =>
                RetryGuidanceView(viewModel: viewModel),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.livenessCapture,
        builder: (context, state) => stub('liveness-capture-stub'),
      ),
      GoRoute(
        path: AppRoutes.agentEscalation,
        builder: (context, state) => stub('agent-escalation-stub'),
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
  await tester.pumpAndSettle();
  return h;
}

List<String> _allText(WidgetTester tester) => tester
    .widgetList<Text>(find.byType(Text))
    .map((t) => t.data ?? t.textSpan?.toPlainText() ?? '')
    .toList();

const _selfieTitle = 'No pudimos confirmar que eres tú';
const _selfieBody =
    'No logramos verificar tu identidad con esta selfie. ¡Sin problema, inténtalo otra vez!';
const _tips = [
  'Busca un lugar con buena iluminación, de preferencia natural.',
  'Asegúrate de que tu rostro esté descubierto y visible por completo.',
  'Sostén el teléfono a la altura de tus ojos y quédate quieto.',
];

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

  group('US1: the selfie retry state', () {
    testWidgets(
      'shows the help link, title, body, three selfie tips and both actions',
      (tester) async {
        await _pump(tester);

        expect(find.text('Ayuda'), findsOneWidget);
        expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
        expect(find.text(_selfieTitle), findsOneWidget);
        expect(find.text(_selfieBody), findsOneWidget);
        expect(
          find.text('Consejos para el siguiente intento:'),
          findsOneWidget,
        );
        for (final tip in _tips) {
          expect(find.text(tip), findsOneWidget);
        }
        expect(find.text('Intentar de nuevo'), findsOneWidget);
        expect(find.text('Hablar con un agente'), findsOneWidget);
      },
    );

    testWidgets(
      'never shows a count, comparison, threshold or document advice',
      (tester) async {
        await _pump(tester);

        for (final text in _allText(tester)) {
          expect(text, isNot(contains('coincide')), reason: text);
          expect(text, isNot(contains('suficiente')), reason: text);
          expect(text, isNot(contains('Intento ')), reason: text);
          expect(text, isNot(contains('documento')), reason: text);
          expect(text, isNot(matches(RegExp(r'\d'))), reason: text);
        }
      },
    );

    testWidgets('uses no red or error colour', (tester) async {
      await _pump(tester);

      final errorColor = Theme.of(tester.element(find.text(_selfieTitle)))
          .colorScheme
          .error;
      for (final icon in tester.widgetList<Icon>(find.byType(Icon))) {
        expect(icon.color, isNot(errorColor));
        expect(icon.color, isNot(Colors.red));
      }
      for (final text in tester.widgetList<Text>(find.byType(Text))) {
        expect(text.style?.color, isNot(errorColor));
      }
    });

    testWidgets('announces the title and body', (tester) async {
      final h = await _pump(tester);

      expect(h.announcements.join(' '), contains(_selfieTitle));
      expect(h.announcements.join(' '), contains(_selfieBody));
    });

    testWidgets('the back gesture does nothing', (tester) async {
      await _pump(tester);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text(_selfieTitle), findsOneWidget);
    });

    testWidgets('"Intentar de nuevo" goes straight to the selfie camera', (
      tester,
    ) async {
      final h = await _pump(tester);

      await tester.tap(find.text('Intentar de nuevo'));
      await tester.pumpAndSettle();

      expect(find.text('liveness-capture-stub'), findsOneWidget);
      expect(
        h.analytics.events.map((e) => e.name),
        contains('retry_guidance_retry_taken'),
      );
    });

    testWidgets('"Ayuda" opens help', (tester) async {
      await _pump(tester);

      await tester.tap(find.text('Ayuda'));
      await tester.pumpAndSettle();

      expect(find.text('help-stub'), findsOneWidget);
    });

    group('goldens', () {
      for (final (name, scaler) in [
        ('retry_guidance.png', TextScaler.noScaling),
        ('retry_guidance_text_2x.png', const TextScaler.linear(2)),
      ]) {
        testWidgets(name, (tester) async {
          await _pump(tester, textScaler: scaler);
          await expectLater(
            find.byType(RetryGuidanceView),
            matchesGoldenFile('goldens/$name'),
          );
        });
      }
    });
  });

  group('US2: the limit states and the human route', () {
    for (final (seed, title, body) in [
      (
        _Seed.selfieAtLimit,
        'Alcanzaste el número máximo de intentos',
        'Por ahora no puedes volver a tomar la selfie.',
      ),
      (
        _Seed.documentAtLimit,
        'Alcanzaste el número máximo de intentos con tu documento',
        'Por ahora no puedes volver a escanear tu documento.',
      ),
    ]) {
      testWidgets('${seed.name}: explains the limit, names the checkpoint, and '
          'offers only the agent route', (tester) async {
        await _pump(tester, seed: seed);

        expect(find.text(title), findsOneWidget);
        expect(find.textContaining(body), findsOneWidget);
        expect(
          find.textContaining('control de documentos habitual'),
          findsOneWidget,
        );
        expect(find.text('Intentar de nuevo'), findsNothing);
        expect(find.text('Consejos para el siguiente intento:'), findsNothing);
        expect(find.text('Hablar con un agente'), findsOneWidget);
      });
    }

    for (final seed in _Seed.values) {
      testWidgets('${seed.name}: the agent route opens and back returns here', (
        tester,
      ) async {
        final h = await _pump(tester, seed: seed);

        await tester.tap(find.text('Hablar con un agente'));
        await tester.pumpAndSettle();
        expect(find.text('agent-escalation-stub'), findsOneWidget);
        expect(
          h.analytics.events.map((e) => e.name),
          contains('retry_guidance_agent_route_taken'),
        );

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text('Hablar con un agente'), findsOneWidget);
      });
    }
  });
}
