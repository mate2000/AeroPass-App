// 008-identidad-activa T025: Contract — CredentialIssuanceRepository
// (contracts/credential-issuance-port.md).
//
// The real implementation runs every case. The dev fake is always-success
// by design (research.md §14: happy-path mode's job is a walkable flow), so
// it runs the cases a success can exercise — the shape of `activated`, the
// storage write before success, and the absence of a token or full document
// number on the display type.
import 'dart:io';

import 'package:aeropass_app/domain/entities/transport_failure.dart';
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/data/dev/dev_credential_issuance_repository.dart';
import 'package:aeropass_app/data/services/credential_issuance_repository_impl.dart';
import 'package:aeropass_app/data/services/credential_issuance_service.dart';
import 'package:aeropass_app/data/services/credential_service.dart';
import 'package:aeropass_app/domain/entities/activated_credential.dart';
import 'package:aeropass_app/domain/entities/consent_record.dart';
import 'package:aeropass_app/domain/entities/credential_lifecycle_status.dart';
import 'package:aeropass_app/domain/entities/enrollment_attempt_id.dart';
import 'package:aeropass_app/domain/entities/issuance_outcome.dart';
import 'package:aeropass_app/domain/entities/processing_scope.dart';
import 'package:aeropass_app/domain/repositories/credential_issuance_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_consent_repository.dart';
import '../fakes/fake_http_client_adapter.dart';
import '../fakes/fake_secure_storage_platform.dart';

Map<String, dynamic> _completeActiveJson() => {
  'status': 'active',
  'token': 'tok-1',
  'holderName': 'Mateo González Restrepo',
  'documentLast4': '7890',
  'issuingCountry': 'COL',
  'issuedAt': '2026-09-16T12:00:00Z',
  'validUntil': '2031-09-16T12:00:00Z',
};

ConsentRecord _activeConsent() => ConsentRecord(
  textVersionId: 'v1',
  enrollmentAttemptId: const EnrollmentAttemptId('attempt-1'),
  scope: ProcessingScope.identityVerification,
  confirmedAt: DateTime.utc(2026, 9, 16),
  status: ConsentRecordStatus.active,
);

class _Harness {
  _Harness() {
    FlutterSecureStoragePlatform.instance = storage;
    dio.httpClientAdapter = adapter;
    consent.seedLocalRecord(_activeConsent());
  }

  final storage = FakeSecureStoragePlatform();
  final adapter = FakeHttpClientAdapter();
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test.aeropass.example'));
  final consent = FakeConsentRepository();

  late final credentialService = CredentialService(
    dio: dio,
    secureStorage: const FlutterSecureStorage(),
  );

  late final CredentialIssuanceRepository real =
      CredentialIssuanceRepositoryImpl(
        CredentialIssuanceService(dio: dio),
        credentialService: credentialService,
        consentRepository: consent,
      );

  late final CredentialIssuanceRepository dev = DevCredentialIssuanceRepository(
    credentialService: credentialService,
  );

  Future<String?> storedToken() =>
      storage.read(key: CredentialService.tokenKey, options: const {});
  Future<String?> storedValidUntil() =>
      storage.read(key: CredentialService.validUntilKey, options: const {});
}

Future<void> _expectNothingStored(_Harness h) async {
  expect(await h.storedToken(), isNull);
  expect(await h.storedValidUntil(), isNull);
}

void main() {
  group('Real implementation', () {
    test('1. complete active response -> Ok(activated), every field mapped, '
        'token and validUntil stored', () async {
      final h = _Harness()..adapter.respondWith(_completeActiveJson());

      final result = await h.real.requestIssuance();

      final outcome = result.valueOrNull;
      expect(outcome, isA<IssuanceActivated>());
      final credential = (outcome! as IssuanceActivated).credential;
      expect(credential.holderName, 'Mateo González Restrepo');
      expect(credential.documentLast4, '7890');
      expect(credential.issuingCountry, 'COL');
      expect(credential.issuedAt, DateTime.utc(2026, 9, 16, 12));
      expect(credential.validUntil, DateTime.utc(2031, 9, 16, 12));
      expect(await h.storedToken(), 'tok-1');
      expect(
        DateTime.parse((await h.storedValidUntil())!),
        DateTime.utc(2031, 9, 16, 12),
      );
    });

    test('2. suspended with complete fields -> Ok(notActive(suspended)), '
        'nothing stored', () async {
      final h = _Harness()
        ..adapter.respondWith({
          ..._completeActiveJson(),
          'status': 'suspended',
        });

      final result = await h.real.requestIssuance();

      expect(
        result.valueOrNull,
        const IssuanceOutcome.notActive(
          status: CredentialLifecycleStatus.suspended,
        ),
      );
      await _expectNothingStored(h);
    });

    test(
      '3. active without validUntil -> Ok(incomplete), nothing stored',
      () async {
        final h = _Harness()
          ..adapter.respondWith(
            {..._completeActiveJson()}..remove('validUntil'),
          );

        final result = await h.real.requestIssuance();

        expect(result.valueOrNull, const IssuanceOutcome.incomplete());
        await _expectNothingStored(h);
      },
    );

    test(
      '4. documentLast4 not exactly four digits -> Ok(incomplete)',
      () async {
        final h = _Harness()
          ..adapter.respondWith({
            ..._completeActiveJson(),
            'documentLast4': '12345',
          });

        final result = await h.real.requestIssuance();

        expect(result.valueOrNull, const IssuanceOutcome.incomplete());
        await _expectNothingStored(h);
      },
    );

    test('5. validUntil earlier than issuedAt -> Ok(incomplete)', () async {
      final h = _Harness()
        ..adapter.respondWith({
          ..._completeActiveJson(),
          'validUntil': '2020-01-01T00:00:00Z',
        });

      final result = await h.real.requestIssuance();

      expect(result.valueOrNull, const IssuanceOutcome.incomplete());
      await _expectNothingStored(h);
    });

    test(
      '6. unrecognized status -> Ok(incomplete), never a thrown exception',
      () async {
        final h = _Harness()
          ..adapter.respondWith({
            ..._completeActiveJson(),
            'status': 'pending_review',
          });

        final result = await h.real.requestIssuance();

        expect(result.valueOrNull, const IssuanceOutcome.incomplete());
        await _expectNothingStored(h);
      },
    );

    test(
      '6b. malformed fields (empty name, bad country) -> Ok(incomplete)',
      () async {
        for (final override in <Map<String, dynamic>>[
          {'holderName': '  '},
          {'issuingCountry': 'CO'},
          {'token': ''},
          {'issuedAt': 'not-a-date'},
        ]) {
          final h = _Harness()
            ..adapter.respondWith({..._completeActiveJson(), ...override});

          final result = await h.real.requestIssuance();

          expect(
            result.valueOrNull,
            const IssuanceOutcome.incomplete(),
            reason: 'override $override',
          );
        }
      },
    );

    test('7. transport failure -> Error, nothing stored', () async {
      final h = _Harness()
        ..adapter.failWith(const SocketException('unreachable'));

      final result = await h.real.requestIssuance();

      expect(result.isError, isTrue);
      await _expectNothingStored(h);
    });

    test('7b. non-2xx response -> Error', () async {
      final h = _Harness()
        ..adapter.respondWith(const {'error': 'x'}, statusCode: 503);

      final result = await h.real.requestIssuance();

      expect(result.isError, isTrue);
    });

    test('8. storage write fails on a complete active response -> Error, '
        'never Ok(activated)', () async {
      final h = _Harness()..adapter.respondWith(_completeActiveJson());
      h.storage.writeError = StateError('keystore unavailable');

      final result = await h.real.requestIssuance();

      expect(result.isError, isTrue);
    });

    test('10. no local consent record -> Error, no request sent', () async {
      final h = _Harness()..adapter.respondWith(_completeActiveJson());
      h.consent.seedLocalRecord(null);

      final result = await h.real.requestIssuance();

      expect(result.isError, isTrue);
      await _expectNothingStored(h);
    });
  });

  group('Dev fake', () {
    test('1. returns Ok(activated) with synthetic data and stores the token '
        'and validUntil', () async {
      final h = _Harness();

      final result = await h.dev.requestIssuance();

      final outcome = result.valueOrNull;
      expect(outcome, isA<IssuanceActivated>());
      final credential = (outcome! as IssuanceActivated).credential;
      expect(credential.holderName, isNotEmpty);
      expect(credential.documentLast4, matches(RegExp(r'^\d{4}$')));
      expect(credential.issuingCountry, 'COL');
      expect(credential.validUntil.isAfter(credential.issuedAt), isTrue);
      expect(await h.storedToken(), isNotNull);
      expect(await h.storedValidUntil(), isNotNull);
    });
  });

  test('9. ActivatedCredential structurally carries no token and no full '
      'document number', () {
    final credential = ActivatedCredential(
      holderName: 'x',
      documentLast4: '7890',
      issuingCountry: 'COL',
      issuedAt: DateTime.utc(2026),
      validUntil: DateTime.utc(2031),
    );
    final json = credential.toString();

    expect(json, isNot(contains('token')));
    expect(json, isNot(contains('documentNumber')));
  });

  // 011-error-tecnico T037: contracts/transport-failure-addendum.md.
  group('011: transport failures and idempotency', () {
    DioException dioError(DioExceptionType type) =>
        DioException(requestOptions: RequestOptions(), type: type);

    test('2. a connectionError is the connection', () async {
      final h = _Harness()
        ..adapter.failWith(dioError(DioExceptionType.connectionError));
      final result = await h.real.requestIssuance();
      expect(
        result,
        isA<Error<IssuanceOutcome>>().having(
          (e) => e.error,
          'error',
          isA<ConnectivityFailure>(),
        ),
      );
      await _expectNothingStored(h);
    });

    test('2. a 503 is the service', () async {
      final h = _Harness()..adapter.respondWith(const {}, statusCode: 503);
      final result = await h.real.requestIssuance();
      expect(
        result,
        isA<Error<IssuanceOutcome>>().having(
          (e) => e.error,
          'error',
          isA<ServiceSideFailure>(),
        ),
      );
    });

    test('2. a pinning failure is the service', () async {
      final h = _Harness()
        ..adapter.failWith(dioError(DioExceptionType.badCertificate));
      final result = await h.real.requestIssuance();
      expect(
        result,
        isA<Error<IssuanceOutcome>>().having(
          (e) => e.error,
          'error',
          isA<ServiceSideFailure>(),
        ),
      );
    });

    test('3. a retry after a request lost in transit gets the credential '
        'already issued, not a second one', () async {
      final h = _Harness()
        ..adapter.failWith(dioError(DioExceptionType.connectionError));
      final first = await h.real.requestIssuance();
      expect(first.isError, isTrue);

      // The backend issued on the first request; the second returns it.
      h.adapter.respondWith(_completeActiveJson());
      final second = await h.real.requestIssuance();

      expect(second.valueOrNull, isA<IssuanceActivated>());
      expect(await h.storedToken(), 'tok-1');
      expect(h.adapter.requestCount, 2);
      final body = h.adapter.lastRequest!.data as Map;
      expect(body['enrollmentAttemptId'], 'attempt-1');
    });
  });

  // 012-mis-viajes T014: the home strip's display fields are stored with the
  // token, and only them.
  group('012: display fields stored at issuance', () {
    test(
      'an activated credential stores the holder name and last four',
      () async {
        final h = _Harness()..adapter.respondWith(_completeActiveJson());

        final _ = await h.real.requestIssuance();

        expect(
          await h.storage.read(
            key: CredentialService.holderNameKey,
            options: const {},
          ),
          'Mateo González Restrepo',
        );
        expect(
          await h.storage.read(
            key: CredentialService.documentLast4Key,
            options: const {},
          ),
          '7890',
        );
      },
    );

    test('the dev fake stores them too', () async {
      final h = _Harness();
      final _ = await h.dev.requestIssuance();
      expect(
        await h.storage.read(
          key: CredentialService.documentLast4Key,
          options: const {},
        ),
        '7890',
      );
    });
  });
}
