// 007-validando T011: Contract — VerificationJobRepository
// (contracts/verification-job-port.md). The real implementation runs all
// ten cases; the schedule-driven dev fake always ends `matched`
// (research.md §14), so it runs cases 1–3 in time order.
import 'dart:io';

import 'package:aeropass_app/domain/entities/transport_failure.dart';
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/data/dev/dev_verification_job_repository.dart';
import 'package:aeropass_app/data/services/verification_job_repository_impl.dart';
import 'package:aeropass_app/data/services/verification_job_service.dart';
import 'package:aeropass_app/domain/entities/consent_record.dart';
import 'package:aeropass_app/domain/entities/enrollment_attempt_id.dart';
import 'package:aeropass_app/domain/entities/processing_scope.dart';
import 'package:aeropass_app/domain/entities/verification_job_status.dart';
import 'package:aeropass_app/domain/entities/verification_outcome.dart';
import 'package:aeropass_app/domain/entities/verification_stage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_consent_repository.dart';
import '../fakes/fake_http_client_adapter.dart';

ConsentRecord _activeConsent() => ConsentRecord(
  textVersionId: 'v1',
  enrollmentAttemptId: const EnrollmentAttemptId('attempt-1'),
  scope: ProcessingScope.identityVerification,
  confirmedAt: DateTime.utc(2026, 9, 23),
  status: ConsentRecordStatus.active,
);

class _Harness {
  _Harness() {
    dio.httpClientAdapter = adapter;
    consent.seedLocalRecord(_activeConsent());
  }

  final adapter = FakeHttpClientAdapter();
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test.aeropass.example'));
  final consent = FakeConsentRepository();

  late final repository = VerificationJobRepositoryImpl(
    VerificationJobService(dio: dio),
    consentRepository: consent,
  );
}

Map<String, dynamic> _completed(String outcome) => {
  'state': 'completed',
  'documentCheck': 'passed',
  'faceComparison': outcome == 'document_rejected' ? 'pending' : 'passed',
  'outcome': outcome,
};

void main() {
  group('Real implementation', () {
    test('1. in progress, document running', () async {
      final h = _Harness()
        ..adapter.respondWith({
          'state': 'in_progress',
          'documentCheck': 'running',
          'faceComparison': 'pending',
        });

      final result = await h.repository.getStatus();

      expect(
        result.valueOrNull,
        const VerificationJobStatus.inProgress(
          documentCheck: StageStatus.running,
          faceComparison: StageStatus.pending,
        ),
      );
      expect(h.adapter.lastRequest!.path, '/v1/verification/jobs/current');
      expect(h.adapter.lastRequest!.queryParameters, {
        'enrollmentAttemptId': 'attempt-1',
      });
    });

    test('2. in progress, document passed and face running', () async {
      final h = _Harness()
        ..adapter.respondWith({
          'state': 'in_progress',
          'documentCheck': 'passed',
          'faceComparison': 'running',
        });

      final result = await h.repository.getStatus();

      expect(
        result.valueOrNull,
        const VerificationJobStatus.inProgress(
          documentCheck: StageStatus.passed,
          faceComparison: StageStatus.running,
        ),
      );
    });

    test('3. completed and matched', () async {
      final h = _Harness()..adapter.respondWith(_completed('matched'));

      final result = await h.repository.getStatus();

      expect(
        result.valueOrNull,
        const VerificationJobStatus.completed(
          outcome: VerificationOutcome.matched(),
          documentCheck: StageStatus.passed,
          faceComparison: StageStatus.passed,
        ),
      );
    });

    test('4. each rejection code maps to its outcome', () async {
      const expected = <String, VerificationOutcome>{
        'document_rejected': VerificationOutcome.documentRejected(),
        'face_mismatch': VerificationOutcome.faceMismatch(),
        'liveness_rejected': VerificationOutcome.livenessRejected(),
        'service_failure': VerificationOutcome.serviceFailure(),
      };
      for (final entry in expected.entries) {
        final h = _Harness()..adapter.respondWith(_completed(entry.key));

        final status = (await h.repository.getStatus()).valueOrNull;

        expect(
          (status! as VerificationJobCompleted).outcome,
          entry.value,
          reason: entry.key,
        );
      }
    });

    test('5. attack_detected is distinct from face_mismatch', () async {
      final h = _Harness()..adapter.respondWith(_completed('attack_detected'));

      final status = (await h.repository.getStatus()).valueOrNull;
      final outcome = (status! as VerificationJobCompleted).outcome;

      expect(outcome, const VerificationOutcome.attackDetected());
      expect(outcome, isNot(const VerificationOutcome.faceMismatch()));
    });

    test('6. an unrecognized outcome code is serviceFailure', () async {
      final h = _Harness()..adapter.respondWith(_completed('quantum_error'));

      final status = (await h.repository.getStatus()).valueOrNull;

      expect(
        (status! as VerificationJobCompleted).outcome,
        const VerificationOutcome.serviceFailure(),
      );
    });

    test('7. an unrecognized state is completed(serviceFailure)', () async {
      final h = _Harness()..adapter.respondWith({'state': 'paused'});

      final status = (await h.repository.getStatus()).valueOrNull;

      expect(status, isA<VerificationJobCompleted>());
      expect(
        (status! as VerificationJobCompleted).outcome,
        const VerificationOutcome.serviceFailure(),
      );
    });

    test('8. an unrecognized stage status is pending, never passed', () async {
      final h = _Harness()
        ..adapter.respondWith({
          'state': 'in_progress',
          'documentCheck': 'mostly_done',
          'faceComparison': null,
        });

      final status = (await h.repository.getStatus()).valueOrNull;

      expect(
        status,
        const VerificationJobStatus.inProgress(
          documentCheck: StageStatus.pending,
          faceComparison: StageStatus.pending,
        ),
      );
    });

    test('9. transport failure is an Error', () async {
      final h = _Harness()..adapter.failWith(const SocketException('offline'));

      final result = await h.repository.getStatus();

      expect(result.isError, isTrue);
    });

    test('9b. a non-2xx response is an Error', () async {
      final h = _Harness()..adapter.respondWith(const {}, statusCode: 503);

      final result = await h.repository.getStatus();

      expect(result.isError, isTrue);
    });

    test(
      '10. no local consent record is an Error, and no request is sent',
      () async {
        final h = _Harness()..adapter.respondWith(_completed('matched'));
        h.consent.seedLocalRecord(null);

        final result = await h.repository.getStatus();

        expect(result.isError, isTrue);
        expect(h.adapter.requestCount, 0);
      },
    );
  });

  group('Dev fake', () {
    test(
      '1–3. document, then face, then matched, on its own schedule',
      () async {
        var now = DateTime.utc(2026, 9, 23, 12);
        final dev = DevVerificationJobRepository(now: () => now);

        final first = (await dev.getStatus()).valueOrNull;
        expect(
          first,
          const VerificationJobStatus.inProgress(
            documentCheck: StageStatus.running,
            faceComparison: StageStatus.pending,
          ),
        );

        now = now.add(const Duration(milliseconds: 1600));
        expect(
          (await dev.getStatus()).valueOrNull,
          const VerificationJobStatus.inProgress(
            documentCheck: StageStatus.passed,
            faceComparison: StageStatus.running,
          ),
        );

        now = now.add(const Duration(milliseconds: 1600));
        expect(
          (await dev.getStatus()).valueOrNull,
          const VerificationJobStatus.completed(
            outcome: VerificationOutcome.matched(),
            documentCheck: StageStatus.passed,
            faceComparison: StageStatus.passed,
          ),
        );
      },
    );
  });

  // 011-error-tecnico T021/T037: contracts/transport-failure-addendum.md.
  group('011: transport failures and the resume window', () {
    DioException dioError(DioExceptionType type) =>
        DioException(requestOptions: RequestOptions(), type: type);

    test('1. a connectionError is the connection', () async {
      final h = _Harness()
        ..adapter.failWith(dioError(DioExceptionType.connectionError));
      final result = await h.repository.getStatus();
      expect(
        result,
        isA<Error<VerificationJobStatus>>().having(
          (e) => e.error,
          'error',
          isA<ConnectivityFailure>(),
        ),
      );
    });

    test('1. a 503 is the service', () async {
      final h = _Harness()..adapter.respondWith(const {}, statusCode: 503);
      final result = await h.repository.getStatus();
      expect(
        result,
        isA<Error<VerificationJobStatus>>().having(
          (e) => e.error,
          'error',
          isA<ServiceSideFailure>(),
        ),
      );
    });

    test('1. a pinning failure is the service', () async {
      final h = _Harness()
        ..adapter.failWith(dioError(DioExceptionType.badCertificate));
      final result = await h.repository.getStatus();
      expect(
        result,
        isA<Error<VerificationJobStatus>>().having(
          (e) => e.error,
          'error',
          isA<ServiceSideFailure>(),
        ),
      );
    });

    test('4. resumableUntil maps when present', () async {
      final h = _Harness()
        ..adapter.respondWith({
          ..._completed('service_failure'),
          'resumableUntil': '2026-09-24T12:00:00Z',
        });
      final status = (await h.repository.getStatus()).valueOrNull;
      expect(status?.resumableUntil, DateTime.utc(2026, 9, 24, 12));
    });

    test('4. resumableUntil is null when absent or unparsable', () async {
      final h = _Harness()..adapter.respondWith(_completed('matched'));
      expect(
        (await h.repository.getStatus()).valueOrNull?.resumableUntil,
        isNull,
      );

      h.adapter.respondWith({
        'state': 'in_progress',
        'documentCheck': 'running',
        'faceComparison': 'pending',
        'resumableUntil': 'tomorrow',
      });
      final status = (await h.repository.getStatus()).valueOrNull;
      expect(status, isA<VerificationJobInProgress>());
      expect(status?.resumableUntil, isNull);
    });
  });
}
