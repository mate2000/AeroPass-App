// 007-validando: VerificationProgressView — the checklist, the step
// indicator, announcements, the back gesture, failure display, the slow
// notice and help, and goldens.
import 'package:aeropass_app/app/technical_error_controller.dart';
import 'package:aeropass_app/app/activated_credential_handoff.dart';
import 'package:aeropass_app/app/enrollment_session_controller.dart';
import 'package:aeropass_app/app/pending_document_controller.dart';
import 'package:aeropass_app/app/router.dart' show AppRoutes;
import 'package:aeropass_app/core/clock.dart';
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/activated_credential.dart';
import 'package:aeropass_app/domain/entities/issuance_outcome.dart';
import 'package:aeropass_app/domain/entities/verification_job_status.dart';
import 'package:aeropass_app/domain/entities/verification_outcome.dart';
import 'package:aeropass_app/domain/entities/verification_stage.dart';
import 'package:aeropass_app/features/enrollment/verification/verification_progress_view.dart';
import 'package:aeropass_app/features/enrollment/verification/verification_progress_viewmodel.dart';
import 'package:aeropass_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../fakes/fake_analytics_emitter.dart';
import '../fakes/fake_capture_attempt_counter_repository.dart';
import '../fakes/fake_credential_issuance_repository.dart';
import '../fakes/fake_verification_job_repository.dart';

class _MutableClock implements Clock {
  _MutableClock(this.current);
  DateTime current;
  @override
  DateTime now() => current;
}

const _poll = Duration(milliseconds: 100);
const _pause = Duration(milliseconds: 300);

Result<VerificationJobStatus> _inProgress(StageStatus doc, StageStatus face) =>
    Result.ok(
      VerificationJobStatus.inProgress(
        documentCheck: doc,
        faceComparison: face,
      ),
    );

Result<VerificationJobStatus> _completed(
  VerificationOutcome outcome, {
  StageStatus face = StageStatus.failed,
}) => Result.ok(
  VerificationJobStatus.completed(
    outcome: outcome,
    documentCheck: StageStatus.passed,
    faceComparison: outcome is VerificationMatched ? StageStatus.passed : face,
  ),
);

class _Harness {
  final job = FakeVerificationJobRepository();
  final issuance = FakeCredentialIssuanceRepository();
  final analytics = FakeAnalyticsEmitter();
  final clock = _MutableClock(DateTime.utc(2026, 9, 23, 12));
  final announcements = <String>[];
  late VerificationProgressViewModel viewModel;
}

Future<_Harness> _pump(
  WidgetTester tester, {
  required List<Result<VerificationJobStatus>> script,
  Result<IssuanceOutcome>? issuance,
  Duration slowNoticeAfter = const Duration(seconds: 10),
  Duration hardTimeoutAfter = const Duration(seconds: 30),
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  final h = _Harness();
  h.job.scriptResults(script);
  if (issuance != null) h.issuance.scriptResult(issuance);

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

  final session = EnrollmentSessionController(clock: h.clock)..startOrResume();
  h.viewModel = VerificationProgressViewModel(
    jobRepository: h.job,
    issuanceRepository: h.issuance,
    handoff: ActivatedCredentialHandoff(),
    enrollmentSessionController: session,
    pendingDocumentController: PendingDocumentController(),
    attemptCounterRepository: FakeCaptureAttemptCounterRepository(),
    analyticsEmitter: h.analytics,
    technicalErrorController: TechnicalErrorController(),
    clock: h.clock,
    pollInterval: _poll,
    slowNoticeAfter: slowNoticeAfter,
    hardTimeoutAfter: hardTimeoutAfter,
    failureDisplayPause: _pause,
  );

  Widget stub(String name) => Scaffold(body: Center(child: Text(name)));
  final router = GoRouter(
    initialLocation: AppRoutes.verificationProgress,
    routes: [
      GoRoute(
        path: AppRoutes.verificationProgress,
        // Owned by the tree, as the real router does, so leaving the route
        // or disposing the tree disposes the view model and its timers.
        builder: (context, state) =>
            ChangeNotifierProvider<VerificationProgressViewModel>(
              create: (_) => h.viewModel,
              child: Consumer<VerificationProgressViewModel>(
                builder: (context, viewModel, _) =>
                    VerificationProgressView(viewModel: viewModel),
              ),
            ),
      ),
      for (final (path, name) in [
        (AppRoutes.credentialActivated, 'credential-activated-stub'),
        (AppRoutes.credentialNotActive, 'credential-not-active-stub'),
        (AppRoutes.documentCapture, 'document-capture-stub'),
        (AppRoutes.retryGuidance, 'retry-guidance-stub'),
        (AppRoutes.technicalError, 'technical-error-stub'),
        (AppRoutes.help, 'help-stub'),
      ])
        GoRoute(path: path, builder: (context, state) => stub(name)),
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
  return h;
}

/// Advances fake time in poll-sized steps so each poll's future resolves.
Future<void> _advance(WidgetTester tester, Duration total) async {
  var elapsed = Duration.zero;
  while (elapsed < total) {
    await tester.pump(_poll);
    elapsed += _poll;
  }
}

final _credential = ActivatedCredential(
  holderName: 'Mateo González Restrepo',
  documentLast4: '7890',
  issuingCountry: 'COL',
  issuedAt: DateTime.utc(2026, 9, 23),
  validUntil: DateTime.utc(2031, 9, 23),
);

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

  group('US1', () {
    testWidgets(
      'renders the header, title, subtitle and three pending stages',
      (tester) async {
        await _pump(
          tester,
          script: [_inProgress(StageStatus.pending, StageStatus.pending)],
        );

        expect(find.text('Verificando'), findsOneWidget);
        expect(find.text('Estamos validando tu identidad'), findsOneWidget);
        expect(
          find.text('Esto toma unos segundos. No cierres la aplicación.'),
          findsOneWidget,
        );
        expect(find.text('Verificando documento'), findsOneWidget);
        expect(find.text('Comparando rostro'), findsOneWidget);
        expect(find.text('Creando identidad digital'), findsOneWidget);
        expect(find.byType(Image), findsNothing);
      },
    );

    testWidgets('the step indicator shows Listo pending', (tester) async {
      await _pump(
        tester,
        script: [_inProgress(StageStatus.pending, StageStatus.pending)],
      );

      expect(find.bySemanticsLabel(RegExp('pendiente')), findsOneWidget);
    });

    testWidgets('stage labels switch to completed wording only when passed, '
        'and each change is announced', (tester) async {
      final h = await _pump(
        tester,
        script: [
          _inProgress(StageStatus.running, StageStatus.pending),
          _inProgress(StageStatus.passed, StageStatus.running),
        ],
      );
      await _advance(tester, _poll * 3);

      expect(find.text('Documento verificado'), findsOneWidget);
      expect(find.text('Rostro verificado'), findsNothing);
      expect(find.text('Comparando rostro'), findsOneWidget);
      expect(h.announcements, contains('Documento verificado'));
      expect(h.announcements, contains('Comparando rostro'));
    });

    testWidgets('the system back gesture does nothing', (tester) async {
      await _pump(
        tester,
        script: [_inProgress(StageStatus.running, StageStatus.pending)],
      );

      await tester.binding.handlePopRoute();
      await tester.pump();

      expect(find.text('Estamos validando tu identidad'), findsOneWidget);
    });

    testWidgets('R1 navigates to the activated credential screen', (
      tester,
    ) async {
      await _pump(
        tester,
        script: [_completed(const VerificationOutcome.matched())],
        issuance: Result.ok(IssuanceOutcome.activated(credential: _credential)),
      );
      await _advance(tester, _poll * 3);
      await tester.pumpAndSettle();

      expect(find.text('credential-activated-stub'), findsOneWidget);
    });

    group('goldens', () {
      for (final (name, scaler) in [
        ('verification_progress.png', TextScaler.noScaling),
        ('verification_progress_text_2x.png', const TextScaler.linear(2)),
      ]) {
        testWidgets(name, (tester) async {
          await _pump(
            tester,
            script: [_inProgress(StageStatus.passed, StageStatus.running)],
            textScaler: scaler,
          );
          await _advance(tester, _poll * 2);

          await expectLater(
            find.byType(VerificationProgressView),
            matchesGoldenFile('goldens/$name'),
          );
        });
      }
    });
  });

  // T027
  group('US2', () {
    testWidgets('a failure shows the failure icon and the generic line, '
        'announces it, then navigates after the pause', (tester) async {
      final h = await _pump(
        tester,
        script: [_completed(const VerificationOutcome.faceMismatch())],
      );
      await _advance(tester, _poll * 2);

      expect(find.text('No pudimos completar la verificación'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(h.announcements, contains('No pudimos completar la verificación'));
      expect(find.text('retry-guidance-stub'), findsNothing);

      await _advance(tester, _pause);
      await tester.pumpAndSettle();
      expect(find.text('retry-guidance-stub'), findsOneWidget);
    });

    testWidgets('face mismatch and attack detection render identically', (
      tester,
    ) async {
      final texts = <String>[];
      for (final outcome in const [
        VerificationOutcome.faceMismatch(),
        VerificationOutcome.attackDetected(),
      ]) {
        final h = await _pump(tester, script: [_completed(outcome)]);
        await _advance(tester, _poll * 2);
        texts.add(
          tester
              .widgetList<Text>(find.byType(Text))
              .map((t) => t.data)
              .join('|'),
        );
        texts.add(h.announcements.join('|'));
        await tester.pumpWidget(const SizedBox());
        await tester.pump(_pause);
      }

      expect(texts[0], texts[2]);
      expect(texts[1], texts[3]);
    });
  });

  // T033
  group('US3', () {
    testWidgets('no control appears before the notice; the notice offers '
        '"Seguir esperando" and "Ayuda"', (tester) async {
      await _pump(
        tester,
        script: [_inProgress(StageStatus.running, StageStatus.pending)],
        slowNoticeAfter: const Duration(milliseconds: 500),
      );

      expect(find.byType(TextButton), findsNothing);
      expect(find.byType(FilledButton), findsNothing);
      expect(find.text('Seguir esperando'), findsNothing);

      await _advance(tester, const Duration(milliseconds: 600));

      expect(find.text('Está tardando más de lo habitual'), findsOneWidget);
      expect(find.text('Seguir esperando'), findsOneWidget);
      expect(find.text('Ayuda'), findsOneWidget);

      await tester.tap(find.text('Seguir esperando'));
      await tester.pump();
      expect(find.text('Seguir esperando'), findsNothing);
      expect(find.text('Estamos validando tu identidad'), findsOneWidget);
    });

    testWidgets('"Ayuda" opens help and records it', (tester) async {
      final h = await _pump(
        tester,
        script: [_inProgress(StageStatus.running, StageStatus.pending)],
        slowNoticeAfter: const Duration(milliseconds: 200),
      );
      await _advance(tester, const Duration(milliseconds: 300));

      await tester.tap(find.text('Ayuda'));
      await tester.pumpAndSettle();

      expect(find.text('help-stub'), findsOneWidget);
      expect(
        h.analytics.events.map((e) => e.name),
        contains('verification_help_opened'),
      );
    });

    testWidgets('an outcome that arrives while help is open waits until help '
        'closes', (tester) async {
      final h = await _pump(
        tester,
        script: [_inProgress(StageStatus.running, StageStatus.pending)],
        slowNoticeAfter: const Duration(milliseconds: 200),
        issuance: Result.ok(IssuanceOutcome.activated(credential: _credential)),
      );
      await _advance(tester, const Duration(milliseconds: 300));
      await tester.tap(find.text('Ayuda'));
      await tester.pumpAndSettle();

      h.job.scriptResults([_completed(const VerificationOutcome.matched())]);
      await _advance(tester, _poll * 3);

      expect(find.text('help-stub'), findsOneWidget);
      expect(find.text('credential-activated-stub'), findsNothing);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('credential-activated-stub'), findsOneWidget);
    });
  });
}
