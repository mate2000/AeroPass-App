// 010-escalar-agente T007/T021/T025: Contract — EscalationRepository
// (contracts/escalation-port.md). The real implementation runs every case;
// the dev fake, which opens once and stays open, runs cases 1–3.
import 'dart:io';

import 'package:aeropass_app/data/dev/dev_escalation_repository.dart';
import 'package:aeropass_app/data/services/escalation_repository_impl.dart';
import 'package:aeropass_app/data/services/escalation_service.dart';
import 'package:aeropass_app/domain/entities/capture_attempt_counter.dart';
import 'package:aeropass_app/domain/entities/consent_record.dart';
import 'package:aeropass_app/domain/entities/enrollment_attempt_id.dart';
import 'package:aeropass_app/domain/entities/escalation.dart';
import 'package:aeropass_app/domain/entities/processing_scope.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_consent_repository.dart';
import '../fakes/fake_http_client_adapter.dart';

class _Harness {
  _Harness() {
    dio.httpClientAdapter = adapter;
    consent.seedLocalRecord(
      ConsentRecord(
        textVersionId: 'v1',
        enrollmentAttemptId: const EnrollmentAttemptId('attempt-1'),
        scope: ProcessingScope.identityVerification,
        confirmedAt: DateTime.utc(2026, 9, 23),
        status: ConsentRecordStatus.active,
      ),
    );
  }

  final adapter = FakeHttpClientAdapter();
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test.aeropass.example'));
  final consent = FakeConsentRepository();

  late final repository = EscalationRepositoryImpl(
    EscalationService(dio: dio),
    consentRepository: consent,
  );
}

Map<String, dynamic> _moduleJson({bool available = true}) => {
  'kind': 'module',
  'available': available,
  if (!available) 'nextOpensAt': '2026-09-24T11:00:00Z',
  'hours': 'Lun–Vie 6:00am–10:00pm',
  'locationName': 'Aeropuerto de prueba',
  'locationDetail': 'Segundo piso',
};

Map<String, dynamic> _chatJson({bool withWait = true}) => {
  'kind': 'chat',
  'available': true,
  if (withWait) 'waitMinMinutes': 2,
  if (withWait) 'waitMaxMinutes': 5,
  'hours': 'Todos los días',
};

Map<String, dynamic> _openJson({List<Map<String, dynamic>>? channels}) => {
  'state': 'open',
  'openedAt': '2026-09-23T12:00:00Z',
  'arrival': 'afterLimit',
  'channels': channels ?? [_moduleJson(), _chatJson()],
};

void main() {
  group('Real implementation', () {
    test(
      '1–2. openOrResume returns the open case, with its original openedAt',
      () async {
        final h = _Harness()
          ..adapter.respondWith({
            'openedAt': '2026-09-23T12:00:00Z',
            'arrival': 'byChoice',
          });

        final result = await h.repository.openOrResume(
          arrival: EscalationArrival.byChoice,
        );

        expect(
          result.valueOrNull,
          EscalationCase(
            openedAt: DateTime.utc(2026, 9, 23, 12),
            arrival: EscalationArrival.byChoice,
          ),
        );
        expect(h.adapter.lastRequest!.method, 'POST');
        expect(h.adapter.lastRequest!.data, {
          'enrollmentAttemptId': 'attempt-1',
          'arrival': 'byChoice',
        });
      },
    );

    test('3. an open case returns both channels with their fields', () async {
      final h = _Harness()..adapter.respondWith(_openJson());

      final status = (await h.repository.getStatus()).valueOrNull;

      expect(status, isA<EscalationOpen>());
      final channels = (status! as EscalationOpen).channels;
      final module = channels.firstWhere(
        (c) => c.kind == AgentChannelKind.module,
      );
      expect(module.available, isTrue);
      expect(module.locationName, 'Aeropuerto de prueba');
      expect(module.locationDetail, 'Segundo piso');
      expect(module.hours, 'Lun–Vie 6:00am–10:00pm');
      expect(h.adapter.lastRequest!.queryParameters, {
        'enrollmentAttemptId': 'attempt-1',
      });
    });

    test('4. a wait range maps to estimatedWait; none maps to null', () async {
      final withWait = _Harness()..adapter.respondWith(_openJson());
      final noWait = _Harness()
        ..adapter.respondWith(
          _openJson(channels: [_moduleJson(), _chatJson(withWait: false)]),
        );

      AgentChannel chatOf(EscalationStatus? s) => (s! as EscalationOpen)
          .channels
          .firstWhere((c) => c.kind == AgentChannelKind.chat);

      expect(
        chatOf((await withWait.repository.getStatus()).valueOrNull)
            .estimatedWait,
        const WaitEstimate(minMinutes: 2, maxMinutes: 5),
      );
      expect(
        chatOf((await noWait.repository.getStatus()).valueOrNull).estimatedWait,
        isNull,
      );
    });

    test(
      '5. an unavailable channel keeps available: false and its nextOpensAt',
      () async {
        final h = _Harness()
          ..adapter.respondWith(
            _openJson(channels: [_moduleJson(available: false), _chatJson()]),
          );

        final status = (await h.repository.getStatus()).valueOrNull;
        final module = (status! as EscalationOpen).channels.firstWhere(
          (c) => c.kind == AgentChannelKind.module,
        );

        expect(module.available, isFalse);
        expect(module.nextOpensAt, DateTime.utc(2026, 9, 24, 11));
      },
    );

    test('6. a channel missing "available" maps to unavailable', () async {
      final h = _Harness()
        ..adapter.respondWith(
          _openJson(
            channels: [
              {..._moduleJson()}..remove('available'),
              _chatJson(),
            ],
          ),
        );

      final status = (await h.repository.getStatus()).valueOrNull;
      final module = (status! as EscalationOpen).channels.firstWhere(
        (c) => c.kind == AgentChannelKind.module,
      );

      expect(module.available, isFalse);
    });

    test('7. each resolved outcome maps to its variant, none carrying a credential', () async {
      const cases = <Map<String, dynamic>, EscalationOutcome>{
        {'state': 'resolved', 'outcome': 'credential_issued'}:
            EscalationOutcome.credentialIssued(),
        {'state': 'resolved', 'outcome': 'declined'}:
            EscalationOutcome.declined(),
        {
          'state': 'resolved',
          'outcome': 'attempts_reset',
          'resetScope': 'document',
        }: EscalationOutcome.attemptsReset(
          scope: AttemptCounterScope.documentCapture,
        ),
        {
          'state': 'resolved',
          'outcome': 'attempts_reset',
          'resetScope': 'selfie',
        }: EscalationOutcome.attemptsReset(
          scope: AttemptCounterScope.selfieLiveness,
        ),
      };
      for (final entry in cases.entries) {
        final h = _Harness()..adapter.respondWith(entry.key);

        final status = (await h.repository.getStatus()).valueOrNull;

        expect(
          status,
          EscalationStatus.resolved(outcome: entry.value),
          reason: '${entry.key}',
        );
      }
    });

    test(
      '8. an unknown outcome or state is a failed read, never an outcome',
      () async {
        for (final body in <Map<String, dynamic>>[
          {'state': 'resolved', 'outcome': 'approved_by_chat'},
          {
            'state': 'resolved',
            'outcome': 'attempts_reset',
            'resetScope': 'everything',
          },
          {'state': 'paused'},
        ]) {
          final h = _Harness()..adapter.respondWith(body);

          final result = await h.repository.getStatus();

          expect(result.isError, isTrue, reason: '$body');
        }
      },
    );

    test('9. expired maps to expired', () async {
      final h = _Harness()..adapter.respondWith({'state': 'expired'});

      expect(
        (await h.repository.getStatus()).valueOrNull,
        const EscalationStatus.expired(),
      );
    });

    test('10. transport failure is an Error', () async {
      final h = _Harness()..adapter.failWith(const SocketException('offline'));

      expect((await h.repository.getStatus()).isError, isTrue);
      expect(
        (await h.repository.openOrResume(arrival: EscalationArrival.byChoice))
            .isError,
        isTrue,
      );
    });

    test(
      '11. no local consent record is an Error, and no request is sent',
      () async {
        final h = _Harness()..adapter.respondWith(_openJson());
        h.consent.seedLocalRecord(null);

        expect((await h.repository.getStatus()).isError, isTrue);
        expect(
          (await h.repository.openOrResume(arrival: EscalationArrival.byChoice))
              .isError,
          isTrue,
        );
        expect(h.adapter.requestCount, 0);
      },
    );
  });

  group('Dev fake', () {
    test(
      '1–3. opens once, then reports an open case with both channels',
      () async {
        final dev = DevEscalationRepository(
          now: () => DateTime.utc(2026, 9, 23, 12),
        );

        final first = (await dev.openOrResume(
          arrival: EscalationArrival.afterLimit,
        )).valueOrNull;
        final second = (await dev.openOrResume(
          arrival: EscalationArrival.byChoice,
        )).valueOrNull;
        final status = (await dev.getStatus()).valueOrNull;

        expect(second, first);
        expect(status, isA<EscalationOpen>());
        final kinds = (status! as EscalationOpen).channels.map((c) => c.kind);
        expect(kinds, containsAll(AgentChannelKind.values));
        final module = (status as EscalationOpen).channels.firstWhere(
          (c) => c.kind == AgentChannelKind.module,
        );
        expect(module.locationName, isNotEmpty);
        expect(module.locationDetail, isNotEmpty);
      },
    );
  });
}
