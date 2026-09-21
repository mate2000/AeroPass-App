import 'package:aeropass_app/app/router.dart' show AppRoutes;
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/consent_text_version.dart';
import 'package:aeropass_app/features/enrollment/consent/consent_view.dart';
import 'package:aeropass_app/features/enrollment/consent/consent_viewmodel.dart';
import 'package:aeropass_app/l10n/generated/app_localizations.dart';
import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../fakes/fake_analytics_emitter.dart';
import '../fakes/fake_consent_repository.dart';

ConsentTextVersion _sampleText() => ConsentTextVersion(
  id: 'v1',
  points: const [
    ConsentPoint(
      icon: ConsentPointIcon.camera,
      heading: '[PLACEHOLDER] Qué se captura',
      body: '[PLACEHOLDER LEGAL TEXT]',
    ),
    ConsentPoint(
      icon: ConsentPointIcon.clock,
      heading: '[PLACEHOLDER] Tiempo de conservación',
      body: '[PLACEHOLDER LEGAL TEXT]',
    ),
    ConsentPoint(
      icon: ConsentPointIcon.share,
      heading: '[PLACEHOLDER] Con quién se comparte',
      body: '[PLACEHOLDER LEGAL TEXT]',
    ),
  ],
  rightsStatement: '[PLACEHOLDER] Tus derechos',
  optionalityStatement: '[PLACEHOLDER] Es opcional',
  processorDisclosure: '[PLACEHOLDER] Procesador externo',
  privacyPolicyUrl: 'https://example.test/privacy',
  termsUrl: 'https://example.test/terms',
  publishedAt: DateTime.utc(2026, 1, 1),
);

/// Wraps `ConsentView` in a self-contained `MaterialApp.router`, independent
/// of the app's real `router.dart` — mirroring `welcome_view_test.dart`'s
/// own isolation pattern.
Future<void> _pumpConsentView(
  WidgetTester tester, {
  required ConsentViewModel viewModel,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  final router = GoRouter(
    initialLocation: AppRoutes.welcome,
    routes: [
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) =>
            const Scaffold(body: Text('welcome-stub')),
      ),
      GoRoute(
        path: AppRoutes.consent,
        builder: (context, state) => ConsentView(viewModel: viewModel),
      ),
      GoRoute(
        path: AppRoutes.documentCapture,
        builder: (context, state) =>
            const Scaffold(body: Text('document-capture-stub')),
      ),
    ],
  );

  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: child!,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
  router.push(AppRoutes.consent);
  await tester.pumpAndSettle();
}

void main() {
  late FakeConsentRepository consentRepository;
  late FakeAnalyticsEmitter analyticsEmitter;

  setUp(() {
    consentRepository = FakeConsentRepository();
    analyticsEmitter = FakeAnalyticsEmitter();
  });

  ConsentViewModel buildViewModel() => ConsentViewModel(
    consentRepository: consentRepository,
    analyticsEmitter: analyticsEmitter,
  );

  group('T012 [US1] unavailable state', () {
    testWidgets('renders the blocking unavailable message when the text '
        'fetch fails', (tester) async {
      consentRepository.scriptCurrentText(
        Result.error(Exception('fetch failed')),
      );
      await _pumpConsentView(tester, viewModel: buildViewModel());

      expect(find.text('No pudimos cargar esta información'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
      // Neither the checkbox nor the actions render in this state.
      expect(find.byType(Checkbox), findsNothing);
      expect(find.text('Acepto y continúo'), findsNothing);
    });
  });

  group('T012 [US1] ready state', () {
    testWidgets(
      'the primary action is disabled until the checkbox is checked, and '
      'the disabled reason is exposed to semantics',
      (tester) async {
        final handle = tester.ensureSemantics();
        consentRepository.scriptCurrentText(Result.ok(_sampleText()));
        final viewModel = buildViewModel();
        await _pumpConsentView(tester, viewModel: viewModel);

        expect(find.text('Acepto y continúo'), findsOneWidget);
        final filledButtonFinder = find.widgetWithText(
          FilledButton,
          'Acepto y continúo',
        );
        var button = tester.widget<FilledButton>(filledButtonFinder);
        expect(button.onPressed, isNull);

        final semanticsNode = tester.getSemantics(
          find.ancestor(
            of: filledButtonFinder,
            matching: find.byType(Semantics),
          ).first,
        );
        expect(
          semanticsNode.flagsCollection.isEnabled,
          isNot(Tristate.none),
        );
        expect(semanticsNode.flagsCollection.isEnabled, Tristate.isFalse);

        await tester.ensureVisible(find.byType(Checkbox));
        await tester.tap(find.byType(Checkbox));
        await tester.pumpAndSettle();

        button = tester.widget<FilledButton>(filledButtonFinder);
        expect(button.onPressed, isNotNull);

        handle.dispose();
      },
    );

    testWidgets(
      'a successful confirm navigates to the document-capture route',
      (tester) async {
        consentRepository.scriptCurrentText(Result.ok(_sampleText()));
        await _pumpConsentView(tester, viewModel: buildViewModel());

        await tester.ensureVisible(find.byType(Checkbox));
        await tester.tap(find.byType(Checkbox));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Acepto y continúo'));
        await tester.pumpAndSettle();

        expect(find.text('document-capture-stub'), findsOneWidget);
      },
    );
  });

  group('T025 [US2] decline and dismissal parity', () {
    testWidgets('"Ahora no" tap navigates back to welcome with no record '
        'created', (tester) async {
      consentRepository.scriptCurrentText(Result.ok(_sampleText()));
      await _pumpConsentView(tester, viewModel: buildViewModel());

      await tester.tap(find.text('Ahora no'));
      await tester.pumpAndSettle();

      expect(find.text('welcome-stub'), findsOneWidget);
      final localResult = await consentRepository.getLocalRecord();
      expect(localResult.valueOrNull, isNull);
    });

    testWidgets(
      'the system back gesture navigates back to welcome with no record '
      'created (PopScope interception)',
      (tester) async {
        consentRepository.scriptCurrentText(Result.ok(_sampleText()));
        await _pumpConsentView(tester, viewModel: buildViewModel());

        final navigator = tester.state<NavigatorState>(
          find.byType(Navigator).first,
        );
        navigator.maybePop();
        await tester.pumpAndSettle();

        expect(find.text('welcome-stub'), findsOneWidget);
        final localResult = await consentRepository.getLocalRecord();
        expect(localResult.valueOrNull, isNull);
      },
    );

    testWidgets(
      'tapping the dimmed barrier area outside the sheet navigates back to '
      'welcome with no record created',
      (tester) async {
        consentRepository.scriptCurrentText(Result.ok(_sampleText()));
        await _pumpConsentView(tester, viewModel: buildViewModel());

        // The barrier occupies the top of the screen, above the bottom
        // sheet.
        await tester.tapAt(const Offset(200, 20));
        await tester.pumpAndSettle();

        expect(find.text('welcome-stub'), findsOneWidget);
        final localResult = await consentRepository.getLocalRecord();
        expect(localResult.valueOrNull, isNull);
      },
    );
  });

  group('T037: accessibility (FR-006, FR-013, SC-008)', () {
    testWidgets('every interactive element has a semantic label', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      consentRepository.scriptCurrentText(Result.ok(_sampleText()));
      await _pumpConsentView(tester, viewModel: buildViewModel());

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      handle.dispose();
    });

    testWidgets('text meets WCAG AA contrast in the default theme', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      consentRepository.scriptCurrentText(Result.ok(_sampleText()));
      await _pumpConsentView(tester, viewModel: buildViewModel());

      await expectLater(tester, meetsGuideline(textContrastGuideline));

      handle.dispose();
    });

    testWidgets(
      'the full consent text remains reachable by scrolling and both '
      'actions remain reachable at the platform maximum text size '
      '(FR-013)',
      (tester) async {
        consentRepository.scriptCurrentText(Result.ok(_sampleText()));
        await _pumpConsentView(
          tester,
          viewModel: buildViewModel(),
          textScaler: const TextScaler.linear(3.0),
        );

        // The confirmation checkbox and both actions must still be
        // reachable by scrolling, not clipped or pushed off-screen.
        await tester.ensureVisible(find.byType(Checkbox));
        expect(find.byType(Checkbox), findsOneWidget);
        await tester.ensureVisible(find.text('Acepto y continúo'));
        expect(find.text('Acepto y continúo'), findsOneWidget);
        await tester.ensureVisible(find.text('Ahora no'));
        expect(find.text('Ahora no'), findsOneWidget);
      },
    );
  });
}
