import 'dart:async';

import 'package:aeropass_app/app/enrollment_session_controller.dart';
import 'package:aeropass_app/app/router.dart' show AppRoutes;
import 'package:aeropass_app/core/clock.dart';
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/credential_status.dart';
import 'package:aeropass_app/domain/repositories/credential_repository.dart';
import 'package:aeropass_app/features/enrollment/welcome/welcome_view.dart';
import 'package:aeropass_app/features/enrollment/welcome/welcome_viewmodel.dart';
import 'package:aeropass_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../fakes/fake_analytics_emitter.dart';
import '../fakes/fake_credential_repository.dart';
import '../fakes/fake_device_capability_checker.dart';

/// A `CredentialRepository` double whose [getStatus] doesn't resolve until
/// [complete] is called — used to deterministically observe
/// `WelcomeView`'s loading/splash state, rather than relying on how many
/// microtask ticks a plain `async` fake happens to take.
class _PendingCredentialRepository implements CredentialRepository {
  final _completer = Completer<Result<CredentialStatus>>();

  void complete(Result<CredentialStatus> result) => _completer.complete(result);

  @override
  Future<Result<CredentialStatus>> getStatus() => _completer.future;
}

class _FixedClock implements Clock {
  const _FixedClock();
  @override
  DateTime now() => DateTime.utc(2026, 1, 1);
}

/// Wraps `WelcomeView` in a self-contained `MaterialApp.router` with just
/// the routes its navigation touches — deliberately independent of the
/// app's real `router.dart` (which itself composes `WelcomeViewModel` from
/// `Provider`), so this widget test only depends on `WelcomeView`'s own
/// contract: a `WelcomeViewModel` passed in, and pushes to `AppRoutes`.
Future<void> _pumpWelcomeView(
  WidgetTester tester, {
  required WelcomeViewModel viewModel,
}) async {
  final router = GoRouter(
    initialLocation: AppRoutes.welcome,
    routes: [
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => WelcomeView(viewModel: viewModel),
      ),
      GoRoute(
        path: AppRoutes.consent,
        builder: (context, state) => const Scaffold(body: Text('consent-stub')),
      ),
      GoRoute(
        path: AppRoutes.recovery,
        builder: (context, state) =>
            const Scaffold(body: Text('recovery-stub')),
      ),
      GoRoute(
        path: AppRoutes.terms,
        builder: (context, state) => const Scaffold(body: Text('terms-stub')),
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
}

void main() {
  late FakeCredentialRepository credentialRepository;
  late FakeDeviceCapabilityChecker deviceCapabilityChecker;
  late FakeAnalyticsEmitter analyticsEmitter;
  late EnrollmentSessionController sessionController;

  setUp(() {
    credentialRepository = FakeCredentialRepository();
    deviceCapabilityChecker = FakeDeviceCapabilityChecker();
    analyticsEmitter = FakeAnalyticsEmitter();
    sessionController = EnrollmentSessionController(clock: const _FixedClock());
  });

  WelcomeViewModel buildViewModel() => WelcomeViewModel(
    credentialRepository: credentialRepository,
    deviceCapabilityChecker: deviceCapabilityChecker,
    enrollmentSessionController: sessionController,
    analyticsEmitter: analyticsEmitter,
  );

  group('T022 [US1]', () {
    testWidgets('shows a loading/splash state while the check is in flight', (
      tester,
    ) async {
      final pendingRepository = _PendingCredentialRepository();
      final viewModel = WelcomeViewModel(
        credentialRepository: pendingRepository,
        deviceCapabilityChecker: deviceCapabilityChecker,
        enrollmentSessionController: sessionController,
        analyticsEmitter: analyticsEmitter,
      );
      await _pumpWelcomeView(tester, viewModel: viewModel);

      // The credential check hasn't resolved yet: still the checking
      // state's loading presentation.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Comenzar'), findsNothing);

      pendingRepository.complete(
        const Result.ok(CredentialStatus.noCredential()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Comenzar'), findsOneWidget);
    });

    testWidgets('renders populated first_run content once resolved', (
      tester,
    ) async {
      credentialRepository.scriptResponse(
        const Result.ok(CredentialStatus.noCredential()),
      );
      await _pumpWelcomeView(tester, viewModel: buildViewModel());
      await tester.pumpAndSettle();

      expect(find.text('Comenzar'), findsOneWidget);
      expect(find.text('Ya tengo cuenta'), findsOneWidget);
      expect(find.text('Tu identidad, una sola vez.'), findsOneWidget);
    });

    testWidgets('primary-action tap navigates to the consent route', (
      tester,
    ) async {
      credentialRepository.scriptResponse(
        const Result.ok(CredentialStatus.noCredential()),
      );
      await _pumpWelcomeView(tester, viewModel: buildViewModel());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Comenzar'));
      await tester.pumpAndSettle();

      expect(find.text('consent-stub'), findsOneWidget);
    });
  });

  group('T032 [US2]', () {
    testWidgets('secondary-action tap navigates to the recovery route', (
      tester,
    ) async {
      credentialRepository.scriptResponse(
        const Result.ok(CredentialStatus.noCredential()),
      );
      await _pumpWelcomeView(tester, viewModel: buildViewModel());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ya tengo cuenta'));
      await tester.pumpAndSettle();

      expect(find.text('recovery-stub'), findsOneWidget);
    });
  });

  group('T040 [US3]', () {
    testWidgets('the privacy-terms link navigates to the terms route, and back '
        'navigation returns to the welcome screen with no state lost', (
      tester,
    ) async {
      credentialRepository.scriptResponse(
        const Result.ok(CredentialStatus.noCredential()),
      );
      final viewModel = buildViewModel();
      await _pumpWelcomeView(tester, viewModel: viewModel);
      await tester.pumpAndSettle();

      // The hero pushes the scrollable content down enough that, at the
      // test surface's default size, this link sits below the fold —
      // scroll it into view first, as a real user would.
      await tester.ensureVisible(find.text('Cómo tratamos tus datos'));
      await tester.tap(find.text('Cómo tratamos tus datos'));
      await tester.pumpAndSettle();

      expect(find.text('terms-stub'), findsOneWidget);
      expect(sessionController.current, isNull);

      // Navigate back: the underlying router's Navigator pops.
      final navigator = tester.state<NavigatorState>(
        find.byType(Navigator).first,
      );
      navigator.pop();
      await tester.pumpAndSettle();

      expect(find.text('Comenzar'), findsOneWidget);
      expect(sessionController.current, isNull);
    });
  });

  group('T047: offline rendering (FR-009)', () {
    testWidgets(
      'renders full, readable content when the credential check reports '
      'Unreachable — no network dependency, no blank/error screen',
      (tester) async {
        credentialRepository.scriptResponse(
          const Result.ok(CredentialStatus.unreachable(lastKnownStatus: null)),
        );
        await _pumpWelcomeView(tester, viewModel: buildViewModel());
        await tester.pumpAndSettle();

        // Static content still renders fully, plus the unrefreshed
        // indicator — never a blank screen or an unhandled error.
        expect(find.text('Tu identidad, una sola vez.'), findsOneWidget);
        expect(find.text('Comenzar'), findsOneWidget);
        expect(
          find.text(
            'No pudimos actualizar tu información. Mostramos el último estado conocido.',
          ),
          findsOneWidget,
        );
      },
    );
  });

  group('T048: accessibility (FR-014, SC-007)', () {
    testWidgets('every interactive element has a semantic label', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      credentialRepository.scriptResponse(
        const Result.ok(CredentialStatus.noCredential()),
      );
      await _pumpWelcomeView(tester, viewModel: buildViewModel());
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      handle.dispose();
    });

    testWidgets('text meets WCAG AA contrast in the default theme', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      credentialRepository.scriptResponse(
        const Result.ok(CredentialStatus.noCredential()),
      );
      await _pumpWelcomeView(tester, viewModel: buildViewModel());
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(textContrastGuideline));

      handle.dispose();
    });
  });
}
