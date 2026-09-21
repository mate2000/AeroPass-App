import 'dart:io';

import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/consent_record.dart';
import 'package:aeropass_app/domain/entities/consent_text_version.dart';
import 'package:aeropass_app/domain/entities/enrollment_attempt_id.dart';
import 'package:aeropass_app/domain/entities/processing_scope.dart';
import 'package:aeropass_app/features/enrollment/consent/consent_view_state.dart';
import 'package:aeropass_app/features/enrollment/consent/consent_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_analytics_emitter.dart';
import '../fakes/fake_consent_repository.dart';

ConsentTextVersion _sampleText({String id = 'v1'}) => ConsentTextVersion(
  id: id,
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

  group('User Story 1: text fetch (T011)', () {
    test('loading state, then ready once the text fetch resolves', () async {
      consentRepository.scriptCurrentText(Result.ok(_sampleText()));
      final viewModel = buildViewModel();

      expect(viewModel.state, const ConsentViewState.loading());

      await pumpEventQueue();

      expect(viewModel.state, isA<ConsentViewReady>());
      final state = viewModel.state as ConsentViewReady;
      expect(state.text.id, 'v1');
      expect(state.checkboxChecked, isFalse);
      expect(
        analyticsEmitter.events,
        contains(
          isA<RecordedAnalyticsEvent>().having(
            (e) => e.name,
            'name',
            'consent_gate_shown',
          ),
        ),
      );
    });

    test('a text-fetch failure renders the unavailable state', () async {
      consentRepository.scriptCurrentText(
        Result.error(const SocketException('offline')),
      );
      final viewModel = buildViewModel();
      await pumpEventQueue();

      expect(
        viewModel.state,
        const ConsentViewState.unavailable(reason: UnavailableReason.offline),
      );
      expect(
        analyticsEmitter.events,
        contains(
          isA<RecordedAnalyticsEvent>().having(
            (e) => e.name,
            'name',
            'consent_gate_unavailable_shown',
          ),
        ),
      );
    });

    test(
      'a non-connectivity fetch failure is classified as fetchError',
      () async {
        consentRepository.scriptCurrentText(
          Result.error(const FormatException('bad json')),
        );
        final viewModel = buildViewModel();
        await pumpEventQueue();

        expect(
          viewModel.state,
          const ConsentViewState.unavailable(
            reason: UnavailableReason.fetchError,
          ),
        );
      },
    );
  });

  group('User Story 1: checkbox gates the primary action (T011)', () {
    test('the checkbox is unchecked by default and canConfirm is false '
        '(FR-004, FR-006)', () async {
      consentRepository.scriptCurrentText(Result.ok(_sampleText()));
      final viewModel = buildViewModel();
      await pumpEventQueue();

      expect(viewModel.canConfirm, isFalse);

      viewModel.toggleCheckbox(true);

      expect(viewModel.canConfirm, isTrue);
      expect((viewModel.state as ConsentViewReady).checkboxChecked, isTrue);

      viewModel.toggleCheckbox(false);
      expect(viewModel.canConfirm, isFalse);
    });
  });

  group('User Story 1: confirming consent (T011)', () {
    test(
      'a successful confirm persists a record with status=active and a '
      'freshly-generated EnrollmentAttemptId (FR-007)',
      () async {
        consentRepository.scriptCurrentText(Result.ok(_sampleText()));
        final viewModel = buildViewModel();
        await pumpEventQueue();
        viewModel.toggleCheckbox(true);

        await viewModel.confirm.run();

        expect(viewModel.confirm.completed, isTrue);
        final localResult = await consentRepository.getLocalRecord();
        final record = localResult.valueOrNull;
        expect(record, isNotNull);
        expect(record!.status, ConsentRecordStatus.active);
        expect(record.textVersionId, 'v1');
        expect(record.enrollmentAttemptId.value, isNotEmpty);
        expect(
          analyticsEmitter.events,
          contains(
            isA<RecordedAnalyticsEvent>().having(
              (e) => e.name,
              'name',
              'consent_confirmed',
            ),
          ),
        );
      },
    );

    test(
      'an offline/failed confirm does not advance and surfaces the '
      'blocked-start message (FR-008)',
      () async {
        consentRepository.scriptCurrentText(Result.ok(_sampleText()));
        consentRepository.scriptRecordConsent(
          Result.error(const SocketException('offline')),
        );
        final viewModel = buildViewModel();
        await pumpEventQueue();
        viewModel.toggleCheckbox(true);

        await viewModel.confirm.run();

        expect(viewModel.confirm.error, isTrue);
        final localResult = await consentRepository.getLocalRecord();
        expect(localResult.valueOrNull, isNull);
        expect(
          analyticsEmitter.events,
          contains(
            isA<RecordedAnalyticsEvent>().having(
              (e) => e.name,
              'name',
              'consent_confirm_failed',
            ),
          ),
        );
      },
    );

    test(
      'confirm is a defensive no-op while the checkbox is unchecked',
      () async {
        consentRepository.scriptCurrentText(Result.ok(_sampleText()));
        final viewModel = buildViewModel();
        await pumpEventQueue();

        await viewModel.confirm.run();

        expect(consentRepository.recordConsentCallCount, 0);
      },
    );
  });

  group('User Story 2: decline and dismissal (T024)', () {
    test('the decline command creates no record and emits consent_declined '
        '(explicit decline, FR-009)', () async {
      consentRepository.scriptCurrentText(Result.ok(_sampleText()));
      final viewModel = buildViewModel();
      await pumpEventQueue();

      await viewModel.decline.run(false);

      final localResult = await consentRepository.getLocalRecord();
      expect(localResult.valueOrNull, isNull);
      expect(
        analyticsEmitter.events.map((e) => e.name),
        contains('consent_declined'),
      );
      expect(
        analyticsEmitter.events.map((e) => e.name),
        isNot(contains('consent_dismissed')),
      );
    });

    test(
      'the dismissal-equivalent path creates no record and is never '
      'recorded as consent (FR-010)',
      () async {
        consentRepository.scriptCurrentText(Result.ok(_sampleText()));
        final viewModel = buildViewModel();
        await pumpEventQueue();

        await viewModel.decline.run(true);

        final localResult = await consentRepository.getLocalRecord();
        expect(localResult.valueOrNull, isNull);
        expect(
          analyticsEmitter.events.map((e) => e.name),
          contains('consent_dismissed'),
        );
        expect(
          analyticsEmitter.events.map((e) => e.name),
          isNot(contains('consent_declined')),
        );
      },
    );
  });

  group('User Story 3: superseded-version re-presentation (T030)', () {
    test(
      'a local record for a superseded version sets hasPriorRecord=true '
      '(FR-014)',
      () async {
        consentRepository.seedLocalRecord(
          ConsentRecord(
            textVersionId: 'v1',
            enrollmentAttemptId: EnrollmentAttemptId.generate(),
            scope: ProcessingScope.identityVerification,
            confirmedAt: DateTime.utc(2025, 1, 1),
            status: ConsentRecordStatus.active,
          ),
        );
        consentRepository.scriptCurrentText(Result.ok(_sampleText(id: 'v2')));
        final viewModel = buildViewModel();
        await pumpEventQueue();

        final state = viewModel.state as ConsentViewReady;
        expect(state.hasPriorRecord, isTrue);
        expect(
          analyticsEmitter.events,
          contains(
            isA<RecordedAnalyticsEvent>()
                .having((e) => e.name, 'name', 'consent_gate_shown')
                .having(
                  (e) => e.payload['hasPriorRecord'],
                  'hasPriorRecord',
                  true,
                ),
          ),
        );
      },
    );

    test(
      'a local record already matching the current version sets '
      'hasPriorRecord=false',
      () async {
        consentRepository.seedLocalRecord(
          ConsentRecord(
            textVersionId: 'v1',
            enrollmentAttemptId: EnrollmentAttemptId.generate(),
            scope: ProcessingScope.identityVerification,
            confirmedAt: DateTime.utc(2025, 1, 1),
            status: ConsentRecordStatus.active,
          ),
        );
        consentRepository.scriptCurrentText(Result.ok(_sampleText(id: 'v1')));
        final viewModel = buildViewModel();
        await pumpEventQueue();

        final state = viewModel.state as ConsentViewReady;
        expect(state.hasPriorRecord, isFalse);
      },
    );
  });
}
