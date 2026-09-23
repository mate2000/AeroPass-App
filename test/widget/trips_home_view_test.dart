// 012-mis-viajes T011/T029/T035: Mis viajes — the strip and its badge, the
// next trip and its action, freshness and flight status, the empty state,
// the plain 90-day history, announcements, and goldens.
import 'package:aeropass_app/app/router.dart' show AppRoutes;
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/credential_summary.dart';
import 'package:aeropass_app/domain/entities/pass.dart';
import 'package:aeropass_app/domain/entities/trip.dart';
import 'package:aeropass_app/domain/repositories/credential_summary_repository.dart';
import 'package:aeropass_app/features/trips/trips_home_view.dart';
import 'package:aeropass_app/features/trips/trips_home_viewmodel.dart';
import 'package:aeropass_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../fakes/fake_analytics_emitter.dart';
import '../fakes/fake_clock.dart';
import '../fakes/fake_credential_summary_repository.dart';
import '../fakes/fake_pass_repository.dart';
import '../fakes/fake_trip_repository.dart';

const _bogota = Duration(hours: -5);

/// 2026-09-23 14:00 UTC, 09:00 in Bogotá: a morning.
final _now = DateTime.utc(2026, 9, 23, 14);

Trip _trip({
  Duration departsIn = const Duration(hours: 5, minutes: 35),
  TripStatus status = TripStatus.onTime,
  bool live = true,
  Airport? connectsTo,
}) => Trip(
  id: 'next',
  origin: const Airport(code: 'BOG', city: 'Bogotá'),
  destination: const Airport(code: 'MDE', city: 'Medellín'),
  flightNumber: 'AV 9201',
  departureUtc: _now.add(departsIn),
  departureOffset: _bogota,
  status: status,
  live: live,
  gate: 'D12',
  seat: '22A',
  connectsTo: connectsTo,
);

Trip _past(
  String id,
  String from,
  String fromCity,
  String to,
  String toCity,
  String flight,
  int daysAgo,
) => Trip(
  id: id,
  origin: Airport(code: from, city: fromCity),
  destination: Airport(code: to, city: toCity),
  flightNumber: flight,
  departureUtc: _now.subtract(Duration(days: daysAgo)),
  departureOffset: _bogota,
  status: TripStatus.departed,
  live: true,
);

final _history = [
  _past('h1', 'BOG', 'Bogotá', 'MDE', 'Medellín', 'AV 9201', 21),
  _past('h2', 'MDE', 'Medellín', 'CTG', 'Cartagena', 'LA 4552', 36),
  _past('h3', 'BOG', 'Bogotá', 'CLO', 'Cali', 'AV 8811', 49),
];

Result<TripsSnapshot> _snapshot({Trip? next, List<Trip> history = const []}) =>
    Result.ok(TripsSnapshot(next: next, history: history, fetchedAt: _now));

Result<CredentialSummary> _summary({
  CredentialDisplayState state = CredentialDisplayState.active,
  bool confirmed = true,
}) => Result.ok(
  CredentialSummary(
    holderName: 'Mateo González',
    documentLast4: '4821',
    state: state,
    confirmed: confirmed,
  ),
);

class _Harness {
  final clock = FakeClock(_now);
  final summaries = FakeCredentialSummaryRepository();
  final trips = FakeTripRepository();
  final analytics = FakeAnalyticsEmitter();
  final passes = FakePassRepository();
  late TripsHomeViewModel viewModel;
}

Future<_Harness> _pump(
  WidgetTester tester, {
  Result<CredentialSummary>? summary,
  List<Result<TripsSnapshot>>? trips,
  Duration deviceOffset = _bogota,
  TextScaler textScaler = TextScaler.noScaling,
  bool seedPass = false,
}) async {
  final h = _Harness();
  if (seedPass) {
    h.passes.seedActive(
      Pass(
        passId: 'pass-1',
        tripId: 'next',
        nextCheckpoint: Checkpoint.security,
        validUntil: _now.add(const Duration(hours: 3)),
      ),
    );
  }
  h.summaries.scriptResults([summary ?? _summary()]);
  h.trips.scriptResults(trips ?? [_snapshot(next: _trip(), history: _history)]);

  Widget stub(String name) => Scaffold(body: Center(child: Text(name)));
  final router = GoRouter(
    initialLocation: AppRoutes.trips,
    routes: [
      GoRoute(
        path: AppRoutes.trips,
        builder: (context, state) => Scaffold(
          body: ChangeNotifierProvider(
            create: (_) => h.viewModel = TripsHomeViewModel(
              summaryRepository: h.summaries,
              tripRepository: h.trips,
              analyticsEmitter: h.analytics,
              clock: h.clock,
              passRepository: h.passes,
              deviceOffset: () => deviceOffset,
              observeLifecycle: false,
            ),
            child: Consumer<TripsHomeViewModel>(
              builder: (context, viewModel, _) =>
                  TripsHomeView(viewModel: viewModel),
            ),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.tripVerification,
        builder: (context, state) => stub('verification-013-stub'),
      ),
      GoRoute(
        path: AppRoutes.pass,
        builder: (context, state) => stub('pass-stub'),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => stub('welcome-stub'),
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
  await tester.pump(const Duration(minutes: 2));
}

void main() {
  group('US1', () {
    testWidgets('the greeting, the strip, and a masked number only', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.text('Buenos días,'), findsOneWidget);
      expect(find.text('Mateo'), findsOneWidget);
      expect(find.text('Mateo González'), findsOneWidget);
      expect(find.text('•••• 4821'), findsOneWidget);
      expect(find.text('MG'), findsWidgets);
      expect(find.text('ACTIVA'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(find.byType(CircleAvatar), findsNothing);
      await leave(tester);
    });

    for (final (name, summary, badge) in [
      ('unconfirmed', _summary(confirmed: false), 'SIN CONFIRMAR'),
      (
        'suspended',
        _summary(state: CredentialDisplayState.suspended),
        'SUSPENDIDA',
      ),
      ('expired', _summary(state: CredentialDisplayState.expired), 'VENCIDA'),
      ('revoked', _summary(state: CredentialDisplayState.revoked), 'REVOCADA'),
      (
        'suspended and unconfirmed',
        _summary(state: CredentialDisplayState.suspended, confirmed: false),
        'SUSPENDIDA · sin confirmar',
      ),
    ]) {
      testWidgets('an $name credential never shows "ACTIVA" alone', (
        tester,
      ) async {
        await _pump(tester, summary: summary);

        expect(find.textContaining('ACTIVA'), findsNothing);
        expect(find.text(badge), findsOneWidget);
        await leave(tester);
      });
    }

    testWidgets(
      'the next trip shows its route, flight, airport time and details',
      (tester) async {
        await _pump(tester);

        expect(find.text('PRÓXIMO VIAJE'), findsOneWidget);
        expect(find.text('BOG'), findsOneWidget);
        expect(find.text('MDE'), findsOneWidget);
        expect(find.text('Bogotá'), findsOneWidget);
        expect(find.text('Medellín'), findsOneWidget);
        expect(find.text('AV 9201'), findsOneWidget);
        expect(find.text('Hoy · 14:35'), findsOneWidget);
        expect(find.text('Puerta D12 · Asiento 22A'), findsOneWidget);
        await leave(tester);
      },
    );

    testWidgets('the route is announced with city names, not codes', (
      tester,
    ) async {
      await _pump(tester);

      expect(
        find.bySemanticsLabel(
          RegExp(r'^De Bogotá a Medellín, vuelo AV 9201, Hoy · 14:35'),
        ),
        findsOneWidget,
      );
      await leave(tester);
    });

    testWidgets(
      '"Iniciar viaje" opens the 013 placeholder and emits trip_started',
      (tester) async {
        final h = await _pump(tester);

        await tester.tap(find.text('Iniciar viaje'));
        await tester.pumpAndSettle();

        expect(find.text('verification-013-stub'), findsOneWidget);
        expect(
          h.analytics.events
              .where((e) => e.name == 'trip_started')
              .single
              .payload,
          {'completedTripsLast90Days': 3},
        );
        await leave(tester);
      },
    );

    for (final (name, summary, trip, reason) in [
      (
        'unconfirmed',
        _summary(confirmed: false),
        _trip(),
        'Sin conexión: no pudimos confirmar tu identidad',
      ),
      (
        'suspended',
        _summary(state: CredentialDisplayState.suspended),
        _trip(),
        'Tu identidad está suspendida',
      ),
      (
        'cancelled',
        _summary(),
        _trip(status: TripStatus.cancelled),
        'Vuelo cancelado',
      ),
      (
        'before the window',
        _summary(),
        _trip(departsIn: const Duration(hours: 30)),
        'Disponible desde el 23 de septiembre a las 15:00',
      ),
    ]) {
      testWidgets('$name: no button, the reason is stated', (tester) async {
        await _pump(
          tester,
          summary: summary,
          trips: [_snapshot(next: trip)],
        );

        expect(find.text('Iniciar viaje'), findsNothing);
        expect(find.byType(FilledButton), findsNothing);
        expect(find.textContaining(reason), findsWidgets);
        await leave(tester);
      });
    }

    testWidgets('no credential goes to welcome', (tester) async {
      await _pump(tester, summary: Result.error(const NoCredentialFailure()));
      await tester.pumpAndSettle();

      expect(find.text('welcome-stub'), findsOneWidget);
      await leave(tester);
    });

    testWidgets('a summary that cannot be read shows no badge, and no start', (
      tester,
    ) async {
      await _pump(tester, summary: Result.error(StateError('nothing known')));

      expect(find.text('ACTIVA'), findsNothing);
      expect(find.text('Iniciar viaje'), findsNothing);
      await leave(tester);
    });
  });

  group('US2', () {
    testWidgets('a stale snapshot is marked with its age', (tester) async {
      final h = await _pump(
        tester,
        trips: [
          _snapshot(next: _trip()),
          Result.error(StateError('offline')),
        ],
      );
      expect(find.textContaining('Actualizado hace'), findsNothing);

      h.clock.advance(const Duration(minutes: 4));
      await h.viewModel.refresh();
      await tester.pump();

      expect(find.text('Actualizado hace 4 min'), findsOneWidget);
      expect(find.text('AV 9201'), findsOneWidget);
      await leave(tester);
    });

    testWidgets('no live integration: details unavailable, even with a gate', (
      tester,
    ) async {
      await _pump(tester, trips: [_snapshot(next: _trip(live: false))]);

      expect(find.text('Detalles no disponibles'), findsOneWidget);
      expect(find.textContaining('D12'), findsNothing);
      await leave(tester);
    });

    for (final (status, chip) in [
      (TripStatus.delayed, 'Retrasado'),
      (TripStatus.cancelled, 'Vuelo cancelado'),
      (TripStatus.unknown, 'Estado no disponible'),
    ]) {
      testWidgets('status ${status.name} is surfaced on the card', (
        tester,
      ) async {
        await _pump(
          tester,
          trips: [_snapshot(next: _trip(status: status))],
        );
        expect(find.text(chip), findsWidgets);
        await leave(tester);
      });
    }

    testWidgets('a connecting segment says so', (tester) async {
      await _pump(
        tester,
        trips: [
          _snapshot(
            next: _trip(
              connectsTo: const Airport(code: 'CLO', city: 'Cali'),
            ),
          ),
        ],
      );
      expect(find.text('Conexión a Cali'), findsOneWidget);
      await leave(tester);
    });

    testWidgets('no trips read this session: unavailable, with a retry', (
      tester,
    ) async {
      final h = await _pump(
        tester,
        trips: [Result.error(StateError('offline'))],
      );

      expect(find.text('No pudimos cargar tus viajes'), findsOneWidget);
      expect(find.text('Aún no tienes viajes'), findsNothing);

      h.trips.scriptResults([_snapshot(next: _trip())]);
      await tester.tap(find.text('Reintentar'));
      await tester.pump();
      await tester.pump();
      expect(find.text('AV 9201'), findsOneWidget);
      await leave(tester);
    });

    testWidgets('a device in another zone names the airport clock', (
      tester,
    ) async {
      await _pump(tester, deviceOffset: Duration.zero);

      expect(find.text('Hoy · 14:35 (hora local de Bogotá)'), findsOneWidget);
      await leave(tester);
    });
  });

  group('US3', () {
    testWidgets('no trip: the empty state explains, and the strip stays', (
      tester,
    ) async {
      final h = await _pump(tester, trips: [_snapshot()]);

      expect(find.text('Aún no tienes viajes'), findsOneWidget);
      expect(
        find.textContaining('con el mismo documento con el que te registraste'),
        findsOneWidget,
      );
      expect(find.text('ACTIVA'), findsOneWidget);
      expect(find.text('VIAJES RECIENTES'), findsNothing);
      expect(find.textContaining('90 días'), findsNothing);
      expect(
        h.analytics.events.map((e) => e.name),
        contains('trips_empty_shown'),
      );
      await leave(tester);
    });

    testWidgets('history rows are plain text, with the 90-day line', (
      tester,
    ) async {
      await _pump(tester);
      await tester.scrollUntilVisible(find.textContaining('LA 4552'), 200);

      expect(find.text('VIAJES RECIENTES'), findsOneWidget);
      expect(find.text('BOG → MDE'), findsOneWidget);
      expect(find.text('MDE → CTG'), findsOneWidget);
      expect(
        find.text('Mostramos tus viajes de los últimos 90 días.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.chevron_right), findsNothing);

      final list = find.byType(ListView);
      for (final text in ['BOG → MDE', 'MDE → CTG', 'BOG → CLO']) {
        final row = find.ancestor(of: find.text(text), matching: list);
        expect(row, findsOneWidget);
        expect(
          find.ancestor(of: find.text(text), matching: find.byType(InkWell)),
          findsNothing,
        );
        expect(
          find.ancestor(
            of: find.text(text),
            matching: find.byType(GestureDetector),
          ),
          findsNothing,
        );
      }
      await leave(tester);
    });

    testWidgets(
      'scrolling the history into view emits trips_history_viewed once',
      (tester) async {
        final h = await _pump(tester);
        await tester.scrollUntilVisible(find.text('VIAJES RECIENTES'), 200);
        await tester.pump();
        await tester.drag(find.byType(ListView), const Offset(0, -50));
        await tester.pump();

        final events = h.analytics.events.where(
          (e) => e.name == 'trips_history_viewed',
        );
        expect(events, hasLength(1));
        expect(events.single.payload, {'rowCount': 3});
        await leave(tester);
      },
    );
  });

  group('goldens', () {
    testWidgets('trips_home.png', (tester) async {
      await _pump(tester);
      await expectLater(
        find.byType(TripsHomeView),
        matchesGoldenFile('goldens/trips_home.png'),
      );
      await leave(tester);
    });

    testWidgets('trips_home_empty.png', (tester) async {
      await _pump(tester, trips: [_snapshot()]);
      await expectLater(
        find.byType(TripsHomeView),
        matchesGoldenFile('goldens/trips_home_empty.png'),
      );
      await leave(tester);
    });

    testWidgets('trips_home_stale.png', (tester) async {
      final h = await _pump(
        tester,
        summary: _summary(confirmed: false),
        trips: [
          _snapshot(next: _trip()),
          Result.error(StateError('offline')),
        ],
      );
      h.clock.advance(const Duration(minutes: 4));
      await h.viewModel.refresh();
      await tester.pump();
      await expectLater(
        find.byType(TripsHomeView),
        matchesGoldenFile('goldens/trips_home_stale.png'),
      );
      await leave(tester);
    });

    testWidgets('trips_home_text_2x.png', (tester) async {
      await _pump(tester, textScaler: const TextScaler.linear(2));
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(TripsHomeView),
        matchesGoldenFile('goldens/trips_home_text_2x.png'),
      );
      await leave(tester);
    });
  });

  // 014-qr-pase T023: "Ver pase" opens the pass directly.
  group('014: "Ver pase"', () {
    testWidgets('an active pass shows "Ver pase", which opens the pass', (
      tester,
    ) async {
      final h = await _pump(
        tester,
        summary: _summary(confirmed: false),
        seedPass: true,
      );

      expect(find.text('Iniciar viaje'), findsNothing);
      await tester.tap(find.text('Ver pase'));
      await tester.pumpAndSettle();

      expect(find.text('pass-stub'), findsOneWidget);
      expect(
        h.analytics.events.map((e) => e.name),
        isNot(contains('trip_started')),
      );
      await leave(tester);
    });
  });
}
