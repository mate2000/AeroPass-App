// 014-qr-pase T009/T034: Contract — PassRepository and the backend code
// source (contracts/pass-port.md). An unknown state is never "active", a
// missing server time is an error, and no secret is ever read in phase A.
import 'package:aeropass_app/app/clock_trust_monitor.dart';
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/data/services/backend_pass_code_source.dart';
import 'package:aeropass_app/data/services/pass_repository_impl.dart';
import 'package:aeropass_app/data/services/pass_service.dart';
import 'package:aeropass_app/domain/entities/consent_record.dart';
import 'package:aeropass_app/domain/entities/enrollment_attempt_id.dart';
import 'package:aeropass_app/domain/entities/pass.dart';
import 'package:aeropass_app/domain/entities/processing_scope.dart';
import 'package:aeropass_app/domain/entities/transport_failure.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_clock.dart';
import '../fakes/fake_consent_repository.dart';
import '../fakes/fake_http_client_adapter.dart';

final _now = DateTime.utc(2026, 9, 23, 12);

class _Harness {
  _Harness({bool withConsent = true}) {
    dio.httpClientAdapter = adapter;
    consent.seedLocalRecord(
      withConsent
          ? ConsentRecord(
              textVersionId: 'v1',
              enrollmentAttemptId: const EnrollmentAttemptId('attempt-1'),
              scope: ProcessingScope.identityVerification,
              confirmedAt: DateTime.utc(2026, 9, 1),
              status: ConsentRecordStatus.active,
            )
          : null,
    );
  }

  final adapter = FakeHttpClientAdapter();
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test.aeropass.example'));
  final consent = FakeConsentRepository();
  final clock = FakeClock(_now);
  late final trust = ClockTrustMonitor(
    clock: clock,
    monotonicNow: () => Duration.zero,
  );
  late final service = PassService(dio: dio);
  late final repository = PassRepositoryImpl(
    service,
    consentRepository: consent,
    clockTrustMonitor: trust,
    clock: clock,
  );
  late final codes = BackendPassCodeSource(service, clockTrust: trust);
}

Map<String, dynamic> _issue({
  String? validUntil = '2026-09-23T20:00:00Z',
  String? serverTime = '2026-09-23T12:00:05Z',
  String? next = 'security',
  int? rotation = 30,
}) => {
  'passId': 'pass-1',
  'nextCheckpoint': ?next,
  'validUntil': ?validUntil,
  'rotationSeconds': ?rotation,
  'serverTime': ?serverTime,
  'secret': 'must-never-be-read',
};

Future<Pass> _issued(_Harness h) async {
  h.adapter.respondWith(_issue());
  return (await h.repository.issue('trip-1')).valueOrNull!;
}

void main() {
  group('issue', () {
    test(
      '1. maps every field and hands the server time to the clock monitor',
      () async {
        final h = _Harness();
        final pass = await _issued(h);

        expect(pass.passId, 'pass-1');
        expect(pass.tripId, 'trip-1');
        expect(pass.nextCheckpoint, Checkpoint.security);
        expect(pass.validated, isEmpty);
        expect(pass.validUntil, DateTime.utc(2026, 9, 23, 20));
        expect(pass.rotation, const Duration(seconds: 30));
        expect(
          h.trust.current,
          const ClockTrust.trusted(offset: Duration(seconds: 5)),
        );
        expect(h.repository.activePassFor('trip-1'), pass);

        final body = h.adapter.lastRequest!.data as Map;
        expect(body, {'enrollmentAttemptId': 'attempt-1', 'tripId': 'trip-1'});
      },
    );

    test('1. a validity longer than 24 h is clamped', () async {
      final h = _Harness()
        ..adapter.respondWith(_issue(validUntil: '2026-09-26T12:00:00Z'));
      final pass = (await h.repository.issue('trip-1')).valueOrNull!;
      expect(pass.validUntil, DateTime.utc(2026, 9, 24, 12, 0, 5));
    });

    for (final (name, body) in [
      ('no server time', _issue(serverTime: null)),
      ('an unknown checkpoint', _issue(next: 'lounge')),
      ('no validity', _issue(validUntil: null)),
      ('a rotation under 10 s', _issue(rotation: 5)),
      ('a rotation over 60 s', _issue(rotation: 120)),
    ]) {
      test('1. $name is an error, and nothing becomes active', () async {
        final h = _Harness()..adapter.respondWith(body);
        expect((await h.repository.issue('trip-1')).isError, isTrue);
        expect(h.repository.activePassFor('trip-1'), isNull);
      });
    }

    test('no consent: an error, and no request is sent', () async {
      final h = _Harness(withConsent: false)..adapter.respondWith(_issue());
      expect((await h.repository.issue('trip-1')).isError, isTrue);
      expect(h.adapter.requestCount, 0);
    });

    test('a transport failure is wrapped', () async {
      final h = _Harness()
        ..adapter.failWith(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.connectionError,
          ),
        );
      final result = await h.repository.issue('trip-1');
      expect(
        result,
        isA<Error<Pass>>().having(
          (e) => e.error,
          'error',
          isA<ConnectivityFailure>(),
        ),
      );
    });
  });

  group('status', () {
    test('2. active maps the validated checkpoints and the next one', () async {
      final h = _Harness();
      await _issued(h);
      h.adapter.respondWith({
        'state': 'active',
        'validated': ['security', 'lounge'],
        'nextCheckpoint': 'boarding',
        'flightStatus': 'on_time',
        'serverTime': '2026-09-23T12:10:00Z',
      });

      final state = (await h.repository.status('pass-1')).valueOrNull!;

      final pass = (state as PassActive).pass;
      expect(pass.validated, {Checkpoint.security});
      expect(pass.nextCheckpoint, Checkpoint.boarding);
      expect(
        h.repository.activePassFor('trip-1')?.nextCheckpoint,
        Checkpoint.boarding,
      );
    });

    for (final (wire, flight, expected) in [
      ('boarded', 'on_time', const PassState.boarded()),
      ('expired', 'on_time', const PassState.expired()),
      ('revoked', 'on_time', const PassState.revoked()),
      ('active', 'cancelled', const PassState.flightChanged(cancelled: true)),
      ('active', 'changed', const PassState.flightChanged(cancelled: false)),
    ]) {
      test(
        '2. $wire with flight $flight maps to ${expected.runtimeType}',
        () async {
          final h = _Harness();
          await _issued(h);
          h.adapter.respondWith({
            'state': wire,
            'validated': <String>[],
            'nextCheckpoint': 'security',
            'flightStatus': flight,
            'serverTime': '2026-09-23T12:10:00Z',
          });
          expect((await h.repository.status('pass-1')).valueOrNull, expected);
        },
      );
    }

    for (final (name, body) in [
      (
        'an unknown state',
        {'state': 'paused', 'serverTime': '2026-09-23T12:10:00Z'},
      ),
      ('no server time', {'state': 'active', 'nextCheckpoint': 'security'}),
    ]) {
      test('2. $name is an error, never active', () async {
        final h = _Harness();
        await _issued(h);
        h.adapter.respondWith(body);
        expect((await h.repository.status('pass-1')).isError, isTrue);
      });
    }
  });

  group('code source (phase A)', () {
    test('4. returns the backend code for the window', () async {
      final h = _Harness();
      final pass = await _issued(h);
      h.adapter.respondWith({
        'payload': 'AP1.server-code',
        'windowStartsAt': '2026-09-23T12:00:00Z',
        'windowEndsAt': '2026-09-23T12:00:30Z',
        'serverTime': '2026-09-23T12:00:10Z',
      });

      final code = (await h.codes.codeAt(pass, _now)).valueOrNull!;

      expect(code.payload, 'AP1.server-code');
      expect(code.windowEndsAt, DateTime.utc(2026, 9, 23, 12, 0, 30));
      expect(h.adapter.lastRequest!.path, '/v1/passes/pass-1/code');
    });

    test('4. offline is an error, never a stale payload', () async {
      final h = _Harness();
      final pass = await _issued(h);
      h.adapter.failWith(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.connectionError,
        ),
      );
      expect((await h.codes.codeAt(pass, _now)).isError, isTrue);
    });
  });

  group('forget and expiry', () {
    test('5. forget removes the active pass', () async {
      final h = _Harness();
      await _issued(h);
      await h.repository.forget('pass-1');
      expect(h.repository.activePassFor('trip-1'), isNull);
    });

    test('a pass past its validity is no longer active', () async {
      final h = _Harness();
      await _issued(h);
      h.clock.set(DateTime.utc(2026, 9, 23, 20));
      expect(h.repository.activePassFor('trip-1'), isNull);
    });
  });
}
