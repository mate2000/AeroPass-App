// 011-error-tecnico T024: Contract — ServiceStatusRepository
// (contracts/service-status-port.md). The mapping is strict: a card with one
// guessed line is a card that is not true (FR-007).
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/data/dev/dev_service_status_repository.dart';
import 'package:aeropass_app/data/services/service_status_repository_impl.dart';
import 'package:aeropass_app/data/services/service_status_service.dart';
import 'package:aeropass_app/domain/entities/consent_record.dart';
import 'package:aeropass_app/domain/entities/enrollment_attempt_id.dart';
import 'package:aeropass_app/domain/entities/processing_scope.dart';
import 'package:aeropass_app/domain/entities/service_status.dart';
import 'package:aeropass_app/domain/entities/transport_failure.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_consent_repository.dart';
import '../fakes/fake_http_client_adapter.dart';

class _Harness {
  _Harness({bool withConsent = true}) {
    dio.httpClientAdapter = adapter;
    consent.seedLocalRecord(
      withConsent
          ? ConsentRecord(
              textVersionId: 'v1',
              enrollmentAttemptId: const EnrollmentAttemptId('attempt-1'),
              scope: ProcessingScope.identityVerification,
              confirmedAt: DateTime.utc(2026, 9, 23),
              status: ConsentRecordStatus.active,
            )
          : null,
    );
  }

  final adapter = FakeHttpClientAdapter();
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test.aeropass.example'));
  final consent = FakeConsentRepository();

  late final repository = ServiceStatusRepositoryImpl(
    ServiceStatusService(dio: dio),
    consentRepository: consent,
  );
}

Map<String, dynamic> _step(String step, String health) => {
  'step': step,
  'health': health,
};

Map<String, dynamic> _body({
  List<Map<String, dynamic>>? steps,
  String? retryAfter = '2026-09-23T18:42:00Z',
}) => {
  'steps':
      steps ??
      [
        _step('document_scan', 'operational'),
        _step('selfie', 'degraded'),
        _step('issuance', 'unavailable'),
      ],
  'retryAfter': ?retryAfter,
};

void main() {
  group('Real implementation', () {
    test('1. a valid body maps all three steps and retryAfter', () async {
      final h = _Harness()..adapter.respondWith(_body());

      final status = (await h.repository.getStatus()).valueOrNull!;

      expect(status.steps, {
        JourneyStep.documentScan: StepHealth.operational,
        JourneyStep.selfie: StepHealth.degraded,
        JourneyStep.issuance: StepHealth.unavailable,
      });
      expect(status.retryAfter, DateTime.utc(2026, 9, 23, 18, 42));
      expect(status.worst, StepHealth.unavailable);
    });

    test('2. everything operational still maps', () async {
      final h = _Harness()
        ..adapter.respondWith(
          _body(
            steps: [
              _step('document_scan', 'operational'),
              _step('selfie', 'operational'),
              _step('issuance', 'operational'),
            ],
          ),
        );

      final status = (await h.repository.getStatus()).valueOrNull;

      expect(status?.worst, StepHealth.operational);
    });

    for (final (name, steps) in [
      (
        'a missing step',
        [_step('document_scan', 'operational'), _step('selfie', 'operational')],
      ),
      (
        'a duplicate step',
        [
          _step('document_scan', 'operational'),
          _step('selfie', 'operational'),
          _step('selfie', 'degraded'),
          _step('issuance', 'operational'),
        ],
      ),
      (
        'an unknown step',
        [
          _step('document_scan', 'operational'),
          _step('selfie', 'operational'),
          _step('identity_servers', 'operational'),
        ],
      ),
      (
        'an unknown health',
        [
          _step('document_scan', 'operational'),
          _step('selfie', 'wobbly'),
          _step('issuance', 'operational'),
        ],
      ),
    ]) {
      test('3. $name fails the whole read', () async {
        final h = _Harness()..adapter.respondWith(_body(steps: steps));

        final result = await h.repository.getStatus();

        expect(result.isError, isTrue);
      });
    }

    test('3. a body without steps fails the read', () async {
      final h = _Harness()..adapter.respondWith(const {});
      expect((await h.repository.getStatus()).isError, isTrue);
    });

    test(
      '4. a missing or unparsable retryAfter is null and still maps',
      () async {
        final h = _Harness()..adapter.respondWith(_body(retryAfter: null));
        expect(
          (await h.repository.getStatus()).valueOrNull?.retryAfter,
          isNull,
        );

        h.adapter.respondWith(_body(retryAfter: 'soon'));
        expect(
          (await h.repository.getStatus()).valueOrNull?.retryAfter,
          isNull,
        );
      },
    );

    test('5. no consent record: an error, and no request is sent', () async {
      final h = _Harness(withConsent: false)..adapter.respondWith(_body());

      expect((await h.repository.getStatus()).isError, isTrue);
      expect(h.adapter.requestCount, 0);
    });

    test(
      '6. the request carries the attempt id as a query and no body',
      () async {
        final h = _Harness()..adapter.respondWith(_body());

        final _ = await h.repository.getStatus();

        final request = h.adapter.lastRequest!;
        expect(request.method, 'GET');
        expect(request.path, '/v1/service-status');
        expect(request.queryParameters, {'enrollmentAttemptId': 'attempt-1'});
        expect(request.data, isNull);
      },
    );

    test('a transport failure is wrapped', () async {
      final h = _Harness()
        ..adapter.failWith(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.connectionError,
          ),
        );

      final result = await h.repository.getStatus();

      expect(
        result,
        isA<Error<ServiceStatus>>().having(
          (e) => e.error,
          'error',
          isA<ConnectivityFailure>(),
        ),
      );
    });
  });

  group('Dev fake', () {
    test('there is never a status in development', () async {
      final result = await const DevServiceStatusRepository().getStatus();
      expect(result.isError, isTrue);
    });
  });
}
