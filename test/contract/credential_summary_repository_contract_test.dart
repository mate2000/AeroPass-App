// 012-mis-viajes T008: Contract — CredentialSummaryRepository
// (contracts/credential-summary-port.md). "ACTIVA" needs a backend answer;
// an unreachable backend is never read as a confirmed credential (FR-003).
import 'dart:io';

import 'package:aeropass_app/core/clock.dart';
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/data/dev/dev_credential_summary_repository.dart';
import 'package:aeropass_app/data/services/credential_service.dart';
import 'package:aeropass_app/data/services/credential_summary_repository_impl.dart';
import 'package:aeropass_app/domain/entities/credential_summary.dart';
import 'package:aeropass_app/domain/repositories/credential_summary_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_http_client_adapter.dart';
import '../fakes/fake_secure_storage_platform.dart';

class _Clock implements Clock {
  @override
  DateTime now() => DateTime.utc(2026, 9, 23, 12);
}

class _Harness {
  _Harness({bool withToken = true, Map<String, String> fields = const {}}) {
    FlutterSecureStoragePlatform.instance = storage;
    dio.httpClientAdapter = adapter;
    storage.seed({
      if (withToken) CredentialService.tokenKey: 'tok-1',
      if (withToken)
        CredentialService.validUntilKey: DateTime.utc(2031).toIso8601String(),
      ...fields,
    });
  }

  final storage = FakeSecureStoragePlatform();
  final adapter = FakeHttpClientAdapter();
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test.aeropass.example'));

  late final service = CredentialService(
    dio: dio,
    secureStorage: const FlutterSecureStorage(),
  );
  late final repository = CredentialSummaryRepositoryImpl(
    service,
    clock: _Clock(),
  );

  Future<String?> read(String key) => storage.read(key: key, options: const {});
}

const _storedFields = {
  CredentialService.holderNameKey: 'Nombre Guardado',
  CredentialService.documentLast4Key: '1111',
};

void main() {
  group('Real implementation', () {
    test(
      '1. valid with fields: active, confirmed, and the fields stored',
      () async {
        final h = _Harness()
          ..adapter.respondWith({
            'status': 'valid',
            'validUntil': '2031-01-01T00:00:00Z',
            'holderName': 'Mateo González',
            'documentLast4': '4821',
          });

        final summary = (await h.repository.getSummary()).valueOrNull!;

        expect(summary.state, CredentialDisplayState.active);
        expect(summary.confirmed, isTrue);
        expect(summary.showsActive, isTrue);
        expect(summary.holderName, 'Mateo González');
        expect(summary.documentLast4, '4821');
        expect(await h.read(CredentialService.holderNameKey), 'Mateo González');
        expect(await h.read(CredentialService.documentLast4Key), '4821');
      },
    );

    test('2. valid without fields falls back to the stored ones', () async {
      final h = _Harness(fields: _storedFields)
        ..adapter.respondWith({'status': 'valid'});

      final summary = (await h.repository.getSummary()).valueOrNull!;

      expect(summary.holderName, 'Nombre Guardado');
      expect(summary.documentLast4, '1111');
      expect(summary.showsActive, isTrue);
    });

    for (final (wire, state) in [
      ('suspended', CredentialDisplayState.suspended),
      ('revoked', CredentialDisplayState.revoked),
      ('expired', CredentialDisplayState.expired),
      ('something_new', CredentialDisplayState.expired),
    ]) {
      test('3. "$wire" is ${state.name}, confirmed, never active', () async {
        final h = _Harness()..adapter.respondWith({'status': wire});

        final summary = (await h.repository.getSummary()).valueOrNull!;

        expect(summary.state, state);
        expect(summary.confirmed, isTrue);
        expect(summary.showsActive, isFalse);
      });
    }

    test('4. unreachable with a stored token: inferred, unconfirmed, never '
        'ACTIVA', () async {
      final h = _Harness(fields: _storedFields)
        ..adapter.failWith(const SocketException('offline'));

      final summary = (await h.repository.getSummary()).valueOrNull!;

      expect(summary.state, CredentialDisplayState.active);
      expect(summary.confirmed, isFalse);
      expect(summary.showsActive, isFalse);
      expect(summary.holderName, 'Nombre Guardado');
    });

    test('4. unreachable with nothing stored is an error', () async {
      final h = _Harness(withToken: false)
        ..adapter.failWith(const SocketException('offline'));
      expect((await h.repository.getSummary()).isError, isTrue);
    });

    test(
      'the backend says there is no credential: NoCredentialFailure',
      () async {
        final h = _Harness(withToken: false)
          ..adapter.respondWith({'status': 'no_credential'});

        final result = await h.repository.getSummary();

        expect(
          result,
          isA<Error<CredentialSummary>>().having(
            (e) => e.error,
            'error',
            isA<NoCredentialFailure>(),
          ),
        );
      },
    );

    for (final bad in ['48211', '48a1', '']) {
      test('5. a malformed last four ("$bad") is treated as absent', () async {
        final h = _Harness()
          ..adapter.respondWith({'status': 'valid', 'documentLast4': bad});

        final summary = (await h.repository.getSummary()).valueOrNull!;

        expect(summary.documentLast4, isNull);
        expect(await h.read(CredentialService.documentLast4Key), isNull);
      });
    }

    test('6. clearCachedCredential removes all four keys', () async {
      final h = _Harness(fields: _storedFields);

      await h.service.clearCachedCredential();

      for (final key in [
        CredentialService.tokenKey,
        CredentialService.validUntilKey,
        CredentialService.holderNameKey,
        CredentialService.documentLast4Key,
      ]) {
        expect(await h.read(key), isNull, reason: key);
      }
    });
  });

  group('Dev fake', () {
    test('a stored token is affirmed active with the stored fields', () async {
      final h = _Harness(fields: _storedFields);
      final dev = DevCredentialSummaryRepository(credentialService: h.service);

      final summary = (await dev.getSummary()).valueOrNull!;

      expect(summary.showsActive, isTrue);
      expect(summary.documentLast4, '1111');
    });

    test('no stored token is NoCredentialFailure', () async {
      final h = _Harness(withToken: false);
      final dev = DevCredentialSummaryRepository(credentialService: h.service);

      final result = await dev.getSummary();

      expect(
        result,
        isA<Error<CredentialSummary>>().having(
          (e) => e.error,
          'error',
          isA<NoCredentialFailure>(),
        ),
      );
    });
  });
}
