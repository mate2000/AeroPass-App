// 008-identidad-activa T016/T017: screen 08's settled state — card fields,
// masking and its spoken form, no coverage claims, no portrait, the two
// onward routes, the back gesture to trips, screenshot blocking, and goldens.
import 'package:aeropass_app/app/activated_credential_handoff.dart';
import 'package:aeropass_app/app/router.dart' show AppRoutes;
import 'package:aeropass_app/domain/entities/activated_credential.dart';
import 'package:aeropass_app/features/enrollment/credential_activated/credential_activated_view.dart';
import 'package:aeropass_app/features/enrollment/credential_activated/credential_activated_viewmodel.dart';
import 'package:aeropass_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../fakes/fake_analytics_emitter.dart';
import '../fakes/fake_screen_capture_guard.dart';

ActivatedCredential _credential({
  String holderName = 'Mateo González Restrepo',
  String issuingCountry = 'COL',
}) => ActivatedCredential(
  holderName: holderName,
  documentLast4: '7890',
  issuingCountry: issuingCountry,
  issuedAt: DateTime.utc(2026, 9, 16, 12),
  validUntil: DateTime.utc(2031, 9, 16, 12),
);

class _Harness {
  _Harness(this.analytics, this.guard);
  final FakeAnalyticsEmitter analytics;
  final FakeScreenCaptureGuard guard;
}

Future<_Harness> _pump(
  WidgetTester tester, {
  ActivatedCredential? credential,
  FakeScreenCaptureGuard? guard,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  final handoff = ActivatedCredentialHandoff()
    ..set(credential ?? _credential());
  final analytics = FakeAnalyticsEmitter();
  final screenCaptureGuard = guard ?? FakeScreenCaptureGuard();
  final viewModel = CredentialActivatedViewModel(
    handoff: handoff,
    analyticsEmitter: analytics,
    screenCaptureGuard: screenCaptureGuard,
  );
  final router = GoRouter(
    initialLocation: AppRoutes.credentialActivated,
    routes: [
      GoRoute(
        path: AppRoutes.credentialActivated,
        builder: (context, state) =>
            CredentialActivatedView(viewModel: viewModel),
      ),
      GoRoute(
        path: AppRoutes.trips,
        builder: (context, state) => const Scaffold(body: Text('trips-stub')),
      ),
      GoRoute(
        path: AppRoutes.credentialDetail,
        builder: (context, state) =>
            const Scaffold(body: Text('credential-detail-stub')),
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
  return _Harness(analytics, screenCaptureGuard);
}

void main() {
  setUp(() {
    // A phone-sized surface, matching the reference.
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

  testWidgets('renders the title, qualified subtitle, card and both actions', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('Tu identidad digital está activa'), findsOneWidget);
    expect(
      find.textContaining('donde AeroPass está disponible'),
      findsOneWidget,
    );
    expect(find.text('IDENTIDAD DIGITAL'), findsOneWidget);
    expect(find.text('Mateo González Restrepo'), findsOneWidget);
    expect(find.text('•••• 7890 · COL'), findsOneWidget);
    expect(find.text('Creada el 16 sept 2026'), findsOneWidget);
    expect(find.text('Válida hasta 16 sept 2031'), findsOneWidget);
    expect(find.text('ACTIVA'), findsOneWidget);
    expect(find.text('Ir a mis viajes'), findsOneWidget);
    expect(find.text('Ver mi identidad'), findsOneWidget);
  });

  testWidgets('makes no coverage claim and shows the creation date once', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.textContaining('Aeropuertos'), findsNothing);
    expect(find.textContaining('Aerolíneas'), findsNothing);
    expect(find.textContaining('hoy'), findsNothing);
    expect(find.textContaining('Creada'), findsOneWidget);
  });

  testWidgets('shows a generic icon and never an image in the portrait spot', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.byType(Image), findsNothing);
    expect(find.bySemanticsLabel('Imagen genérica de perfil'), findsOneWidget);
  });

  testWidgets('announces the masked document as words', (tester) async {
    await _pump(tester);

    expect(
      find.bySemanticsLabel('Documento terminado en 7890, Colombia'),
      findsOneWidget,
    );
  });

  testWidgets('spells out an unmapped country code for assistive technology', (
    tester,
  ) async {
    await _pump(tester, credential: _credential(issuingCountry: 'PER'));

    expect(
      find.bySemanticsLabel('Documento terminado en 7890, P E R'),
      findsOneWidget,
    );
  });

  testWidgets('wraps a long name to two lines and announces it in full', (
    tester,
  ) async {
    const longName =
        'María de los Ángeles Fernández de Castro Villamizar Restrepo';
    await _pump(tester, credential: _credential(holderName: longName));

    final nameText = tester.widget<Text>(find.text(longName));
    expect(nameText.maxLines, 2);
    expect(nameText.overflow, TextOverflow.ellipsis);
    expect(find.bySemanticsLabel(longName), findsOneWidget);
  });

  testWidgets('renders no back button', (tester) async {
    await _pump(tester);

    expect(find.byType(BackButton), findsNothing);
    expect(find.byIcon(Icons.chevron_left), findsNothing);
    expect(find.byIcon(Icons.arrow_back), findsNothing);
  });

  testWidgets('the system back gesture goes to trips and is recorded', (
    tester,
  ) async {
    final harness = await _pump(tester);
    harness.analytics.events.clear();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('trips-stub'), findsOneWidget);
    expect(harness.analytics.events.single.payload, {
      'route': 'backGestureToTrips',
    });
  });

  testWidgets('"Ir a mis viajes" goes to trips', (tester) async {
    final harness = await _pump(tester);
    harness.analytics.events.clear();

    await tester.tap(find.text('Ir a mis viajes'));
    await tester.pumpAndSettle();

    expect(find.text('trips-stub'), findsOneWidget);
    expect(harness.analytics.events.single.payload, {'route': 'trips'});
  });

  testWidgets('"Ver mi identidad" goes to the credential detail', (
    tester,
  ) async {
    final harness = await _pump(tester);
    harness.analytics.events.clear();

    await tester.tap(find.text('Ver mi identidad'));
    await tester.pumpAndSettle();

    expect(find.text('credential-detail-stub'), findsOneWidget);
    expect(harness.analytics.events.single.payload, {
      'route': 'credentialDetail',
    });
  });

  testWidgets('blocks screen capture while shown and releases it on leave', (
    tester,
  ) async {
    final harness = await _pump(tester);
    expect(harness.guard.enableCount, 1);
    expect(harness.guard.disableCount, 0);

    await tester.tap(find.text('Ir a mis viajes'));
    await tester.pumpAndSettle();

    expect(harness.guard.disableCount, 1);
  });

  testWidgets('still renders when screen capture blocking fails', (
    tester,
  ) async {
    await _pump(tester, guard: FakeScreenCaptureGuard(enableThrows: true));

    expect(find.text('Tu identidad digital está activa'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('goldens', () {
    testWidgets('settled screen, default text scale', (tester) async {
      await _pump(tester);
      await expectLater(
        find.byType(CredentialActivatedView),
        matchesGoldenFile('goldens/credential_activated.png'),
      );
    });

    testWidgets('settled screen, 200% text scale', (tester) async {
      await _pump(tester, textScaler: const TextScaler.linear(2));
      await expectLater(
        find.byType(CredentialActivatedView),
        matchesGoldenFile('goldens/credential_activated_text_2x.png'),
      );
    });
  });
}
