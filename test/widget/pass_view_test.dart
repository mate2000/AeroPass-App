// 014-qr-pase T011/T033: the pass screen — the header, the two-step
// journey, the QR only while usable, the footer per checkpoint, the
// checkpoint line in every state, unavailable states with their actions,
// no dev control without its flag, and goldens.
import 'package:aeropass_app/app/clock_trust_monitor.dart';
import 'package:aeropass_app/app/router.dart' show AppRoutes;
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/pass.dart';
import 'package:aeropass_app/domain/entities/trip.dart';
import 'package:aeropass_app/features/pass/pass_view.dart';
import 'package:aeropass_app/features/pass/pass_viewmodel.dart';
import 'package:aeropass_app/features/pass/widgets/qr_code_painter.dart';
import 'package:aeropass_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../fakes/fake_analytics_emitter.dart';
import '../fakes/fake_clock.dart';
import '../fakes/fake_pass_display.dart';
import '../fakes/fake_pass_repository.dart';

const _bogota = Duration(hours: -5);

/// 12:00:04 UTC: 26 s left in the 30 s window, as in the reference.
final _now = DateTime.utc(2026, 9, 23, 12, 0, 4);

final _trip = Trip(
  id: 'trip-1',
  origin: const Airport(code: 'BOG', city: 'Bogotá'),
  destination: const Airport(code: 'MDE', city: 'Medellín'),
  flightNumber: 'AV 9201',
  departureUtc: DateTime.utc(2026, 9, 23, 19, 35),
  departureOffset: _bogota,
  status: TripStatus.onTime,
  live: true,
  gate: 'D12',
  seat: '22A',
);

Pass _pass({
  Checkpoint next = Checkpoint.security,
  Set<Checkpoint> validated = const {},
}) => Pass(
  passId: 'pass-1',
  tripId: 'trip-1',
  nextCheckpoint: next,
  validated: validated,
  validUntil: DateTime.utc(2026, 9, 23, 15),
);

class _Harness {
  final clock = FakeClock(_now);
  late final trust = ClockTrustMonitor(
    clock: clock,
    monotonicNow: () => Duration.zero,
  )..observeServerTime(_now);
  final passes = FakePassRepository();
  final codes = FakePassCodeSource();
  final display = FakePassDisplayGuard();
  late FakeDevicePostureChecker posture;
  final analytics = FakeAnalyticsEmitter();
  late PassViewModel viewModel;
}

Future<_Harness> _pump(
  WidgetTester tester, {
  List<Result<Pass>>? issues,
  DevicePosture posture = const DevicePosture.trusted(),
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  final h = _Harness()..posture = FakeDevicePostureChecker(posture);
  h.passes.scriptIssues(issues ?? [Result.ok(_pass())]);

  Widget stub(String name) => Scaffold(body: Center(child: Text(name)));
  final router = GoRouter(
    initialLocation: '/start',
    routes: [
      GoRoute(path: '/start', builder: (context, state) => stub('trips-stub')),
      GoRoute(
        path: AppRoutes.trips,
        builder: (context, state) => stub('trips-stub'),
      ),
      GoRoute(
        path: AppRoutes.help,
        builder: (context, state) => stub('help-stub'),
      ),
      GoRoute(
        path: AppRoutes.agentEscalation,
        builder: (context, state) => stub('agent-stub'),
      ),
      GoRoute(
        path: AppRoutes.pass,
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => h.viewModel = PassViewModel(
            tripId: 'trip-1',
            trip: _trip,
            loadHolderName: () async => 'Mateo González',
            passRepository: h.passes,
            codeSource: h.codes,
            displayGuard: h.display,
            postureChecker: h.posture,
            clockTrust: h.trust,
            analyticsEmitter: h.analytics,
            clock: h.clock,
            deviceOffset: () => _bogota,
            tick: const Duration(hours: 1),
            statusPollInterval: const Duration(hours: 1),
            observeLifecycle: false,
          ),
          child: Consumer<PassViewModel>(
            builder: (context, viewModel, _) => PassView(viewModel: viewModel),
          ),
        ),
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
  router.push(AppRoutes.pass);
  await tester.pumpAndSettle();
  return h;
}

Future<void> leave(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(hours: 2));
}

void main() {
  group('US1', () {
    testWidgets('the header, the two-step journey, the QR and the countdown', (
      tester,
    ) async {
      final h = await _pump(tester);

      expect(find.text('Mateo González'), findsOneWidget);
      expect(find.text('AV 9201 · BOG → MDE · Hoy · 14:35'), findsOneWidget);
      expect(find.text('Asiento 22A'), findsOneWidget);
      expect(find.textContaining('Fila'), findsNothing);
      expect(find.text('Seguridad'), findsOneWidget);
      expect(find.text('Embarque'), findsOneWidget);
      expect(find.text('Sala'), findsNothing);
      expect(find.byType(QrCodeView), findsOneWidget);
      expect(find.text('Se actualiza en 00:26'), findsOneWidget);
      expect(
        find.text('Presenta este código en el lector de seguridad'),
        findsOneWidget,
      );
      expect(
        find.textContaining('control habitual con tu documento'),
        findsOneWidget,
      );
      expect(h.display.on, isTrue);
      await leave(tester);
    });

    testWidgets('the payload is never exposed to assistive technology', (
      tester,
    ) async {
      await _pump(tester);
      expect(find.bySemanticsLabel(RegExp('TEST')), findsNothing);
      expect(find.bySemanticsLabel('Código de tu pase'), findsOneWidget);
      await leave(tester);
    });

    testWidgets(
      'after security, the footer names boarding and Seguridad is done',
      (tester) async {
        final h = await _pump(tester);
        h.passes.scriptStatuses([
          Result.ok(
            PassState.active(
              _pass(
                next: Checkpoint.boarding,
                validated: {Checkpoint.security},
              ),
            ),
          ),
        ]);
        await h.viewModel.pollStatus();
        await tester.pump();

        expect(
          find.text('Presenta este código en el lector de embarque'),
          findsOneWidget,
        );
        expect(find.bySemanticsLabel('Seguridad, completado'), findsOneWidget);
        expect(find.bySemanticsLabel('Embarque, siguiente'), findsOneWidget);
        await leave(tester);
      },
    );

    testWidgets('boarding: no QR, "Abordaje confirmado · Buen viaje"', (
      tester,
    ) async {
      final h = await _pump(tester);
      h.passes.scriptStatuses([const Result.ok(PassState.boarded())]);
      await h.viewModel.pollStatus();
      await tester.pump();

      expect(find.byType(QrCodeView), findsNothing);
      expect(find.text('Abordaje confirmado'), findsOneWidget);
      expect(find.text('Buen viaje'), findsOneWidget);
      expect(h.display.on, isFalse);
      await leave(tester);
    });

    testWidgets('"Atrás" leaves the pass and pass mode', (tester) async {
      final h = await _pump(tester);
      await tester.tap(find.text('Atrás'));
      await tester.pumpAndSettle();

      expect(find.text('trips-stub'), findsOneWidget);
      expect(h.display.on, isFalse);
      await leave(tester);
    });

    testWidgets('"Ayuda" opens help and is recorded', (tester) async {
      final h = await _pump(tester);
      await tester.tap(find.text('Ayuda'));
      await tester.pumpAndSettle();

      expect(find.text('help-stub'), findsOneWidget);
      expect(
        h.analytics.events.map((e) => e.name),
        contains('pass_help_opened'),
      );
      await leave(tester);
    });
  });

  group('US3', () {
    Future<void> expectUnavailable(
      WidgetTester tester,
      _Harness h, {
      required String title,
      required String action,
    }) async {
      expect(find.byType(QrCodeView), findsNothing);
      expect(find.text(title), findsOneWidget);
      expect(find.text(action), findsOneWidget);
      expect(
        find.textContaining('control habitual con tu documento'),
        findsOneWidget,
      );
      expect(h.display.on, isFalse);
    }

    for (final (state, title, action) in [
      (
        const PassState.expired(),
        'Este código expiró',
        'Solicitar nuevo código',
      ),
      (
        const PassState.revoked(),
        'Tu identidad ya no está activa',
        'Volver a Mis viajes',
      ),
      (
        const PassState.flightChanged(cancelled: true),
        'Tu vuelo fue cancelado',
        'Volver a Mis viajes',
      ),
      (
        const PassState.flightChanged(cancelled: false),
        'Tu vuelo cambió',
        'Volver a Mis viajes',
      ),
    ]) {
      testWidgets('${state.runtimeType}: no code, the reason and the action', (
        tester,
      ) async {
        final h = await _pump(tester);
        h.passes.scriptStatuses([Result.ok(state)]);
        await h.viewModel.pollStatus();
        await tester.pump();

        await expectUnavailable(tester, h, title: title, action: action);
        await leave(tester);
      });
    }

    testWidgets('an untrusted clock says so, with no code', (tester) async {
      final h = await _pump(tester);
      expect(find.byType(QrCodeView), findsOneWidget);

      h.trust.observeServerTime(_now.add(const Duration(minutes: 2)));
      h.viewModel.onAppResumed();
      await tester.pump();
      await tester.pump();

      expect(find.byType(QrCodeView), findsNothing);
      expect(find.text('La hora de tu teléfono no coincide'), findsOneWidget);
      expect(find.textContaining('hora automática'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
      await leave(tester);
    });

    testWidgets('a compromised device offers an agent, and never a code', (
      tester,
    ) async {
      final h = await _pump(
        tester,
        posture: const DevicePosture.compromised(['su_binary']),
      );

      await expectUnavailable(
        tester,
        h,
        title: 'No podemos mostrar tu pase en este dispositivo',
        action: 'Hablar con un agente',
      );
      await tester.tap(find.text('Hablar con un agente'));
      await tester.pumpAndSettle();
      expect(find.text('agent-stub'), findsOneWidget);
      await leave(tester);
    });

    testWidgets('a code that cannot be fetched says so, with no QR', (
      tester,
    ) async {
      final h = await _pump(tester);
      h.codes.failing = true;
      h.viewModel.onAppResumed();
      await tester.pump();
      await tester.pump();

      expect(find.byType(QrCodeView), findsNothing);
      expect(
        find.textContaining('No pudimos emitir tu código'),
        findsOneWidget,
      );
      await leave(tester);
    });

    testWidgets('"Simular expirado" is absent without its flag', (
      tester,
    ) async {
      await _pump(tester);
      expect(find.text('Simular expirado'), findsNothing);
      await leave(tester);
    });
  });

  group('goldens', () {
    testWidgets('pass.png', (tester) async {
      await _pump(tester);
      await expectLater(
        find.byType(PassView),
        matchesGoldenFile('goldens/pass.png'),
      );
      await leave(tester);
    });

    testWidgets('pass_expired.png', (tester) async {
      final h = await _pump(tester);
      h.passes.scriptStatuses([const Result.ok(PassState.expired())]);
      await h.viewModel.pollStatus();
      await tester.pump();
      await expectLater(
        find.byType(PassView),
        matchesGoldenFile('goldens/pass_expired.png'),
      );
      await leave(tester);
    });

    testWidgets('pass_boarded.png', (tester) async {
      final h = await _pump(tester);
      h.passes.scriptStatuses([const Result.ok(PassState.boarded())]);
      await h.viewModel.pollStatus();
      await tester.pump();
      await expectLater(
        find.byType(PassView),
        matchesGoldenFile('goldens/pass_boarded.png'),
      );
      await leave(tester);
    });

    testWidgets('pass_text_2x.png', (tester) async {
      await _pump(tester, textScaler: const TextScaler.linear(2));
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(PassView),
        matchesGoldenFile('goldens/pass_text_2x.png'),
      );
      await leave(tester);
    });
  });

  // 015 T066 (FR-012, FR-015, FR-024): the pass on the real backend's model.
  group('015', () {
    Pass boardingOnly() => Pass(
      passId: 'c-1',
      tripId: 'trip-1',
      nextCheckpoint: Checkpoint.boarding,
      validUntil: DateTime.utc(2026, 9, 23, 15),
      checkpoints: const {Checkpoint.boarding},
    );

    testWidgets('a boarding-only pass shows Embarque and no security step', (
      tester,
    ) async {
      await _pump(tester, issues: [Result.ok(boardingOnly())]);
      expect(find.text('Embarque'), findsOneWidget);
      expect(find.text('Seguridad'), findsNothing);
      expect(
        find.text('Presenta este código en el lector de embarque'),
        findsOneWidget,
      );
      expect(find.textContaining('lector de seguridad'), findsNothing);
      await leave(tester);
    });

    testWidgets('a failed renewal keeps the code and says so', (tester) async {
      final h = await _pump(tester, issues: [Result.ok(boardingOnly())]);
      h.codes.renewalPending = true;
      h.viewModel.onAppResumed();
      await tester.pumpAndSettle();
      expect(find.byType(QrCodeView), findsOneWidget);
      expect(find.text('Actualizando código…'), findsOneWidget);
      await leave(tester);
    });

    testWidgets('an expired document shows no code, and the agent path', (
      tester,
    ) async {
      await _pump(
        tester,
        issues: [
          const Result.error(
            PassIssueRefused(PassIssueRefusal.documentExpired),
          ),
        ],
      );
      expect(find.byType(QrCodeView), findsNothing);
      expect(find.text('Tu documento está vencido'), findsOneWidget);
      expect(find.text('Hablar con un agente'), findsOneWidget);
      await leave(tester);
    });
  });
}
