// 015 T052 (FR-017, SC-003, research.md §13): no bearer token, Authorization
// header, image bytes, typed name or document number reaches a log, a print
// or a Sentry event.
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/core/sentry_config.dart';
import 'package:aeropass_app/data/auth/auth_interceptor.dart';
import 'package:aeropass_app/data/services/backend_identity_record_repository.dart';
import 'package:aeropass_app/data/services/credential_service.dart';
import 'package:aeropass_app/data/services/passenger_service.dart';
import 'package:aeropass_app/domain/entities/extraction_result.dart';
import 'package:aeropass_app/domain/entities/identity_record.dart';
import 'package:aeropass_app/domain/entities/passenger_record.dart';
import 'package:aeropass_app/domain/repositories/session_token_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../fakes/fake_secure_storage_platform.dart';
import '../fakes/scripted_backend_adapter.dart';

const _token = 'eyJSECRET.TOKEN.VALUE';

class _Tokens implements SessionTokenProvider {
  @override
  Future<Result<String>> token() async => const Result.ok(_token);
  @override
  Future<Result<void>> reestablish() async => const Result.ok(null);
  @override
  Future<void> signOut() async {}
}

void main() {
  test('a full registration prints nothing sensitive', () async {
    FlutterSecureStoragePlatform.instance = FakeSecureStoragePlatform();
    final backend = ScriptedBackendAdapter()
      ..enqueue(ScriptedResponse.error('no_autenticado'))
      ..enqueue(ScriptedResponse.fixture('pasajero_pendiente', status: 201));
    final dio = dioOver(backend);
    dio.interceptors.add(AuthInterceptor(tokens: _Tokens(), dio: dio));
    final repository = BackendIdentityRecordRepository(
      PassengerService(dio: dio),
      credentialService: CredentialService(
        secureStorage: const FlutterSecureStorage(),
      ),
    );

    final printed = <String>[];
    await Zone.current
        .fork(
          specification: ZoneSpecification(
            print: (_, _, _, line) => printed.add(line),
          ),
        )
        .run(
          () => repository.confirm(
            const IdentityRecord(
              documentType: DocumentType.cc,
              fields: [
                ConfirmedField(
                  key: FieldKey.fullName,
                  value: 'Ana Prueba',
                  source: FieldSource.passengerCorrected,
                ),
                ConfirmedField(
                  key: FieldKey.documentNumber,
                  value: '1020304050',
                  source: FieldSource.passengerCorrected,
                ),
                ConfirmedField(
                  key: FieldKey.expiryDate,
                  value: '2030-01-31',
                  source: FieldSource.passengerCorrected,
                ),
              ],
            ),
            documentPhoto: Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xD9]),
          ),
        );

    final all = printed.join('\n');
    for (final secret in [_token, 'Bearer', 'Authorization', '1020304050']) {
      expect(all, isNot(contains(secret)), reason: secret);
    }
  });

  test('no dio logging interceptor exists anywhere in lib/', () {
    final offenders = [
      for (final f in Directory('lib').listSync(recursive: true))
        if (f is File &&
            f.path.endsWith('.dart') &&
            f.readAsStringSync().contains('LogInterceptor'))
          f.path,
    ];
    expect(offenders, isEmpty);
  });

  group('Sentry', () {
    SentryEvent eventWith({Map<String, String>? tags}) => SentryEvent(
      tags: tags,
      request: SentryRequest(
        url: 'https://aeropass-lac.vercel.app/v1/identity',
        headers: {'Authorization': 'Bearer $_token'},
      ),
      breadcrumbs: [
        Breadcrumb.http(
          url: Uri.parse('https://aeropass-lac.vercel.app/v1/identity'),
          method: 'POST',
        ),
        Breadcrumb(message: 'navigated', category: 'navigation'),
      ],
    );

    test('every event loses its request and its HTTP breadcrumbs', () {
      final event = scrubEvent(eventWith(), Hint())!;
      expect(event.request, isNull);
      expect(event.breadcrumbs!.map((b) => b.category), ['navigation']);
      expect(event.toJson().toString(), isNot(contains(_token)));
    });

    test('an alert event also loses its user and breadcrumbs', () {
      final event = scrubEvent(
        eventWith(tags: {SentryConfig.alertEventTag: 'service'}),
        Hint(),
      )!;
      expect(event.request, isNull);
      expect(event.breadcrumbs, isNull);
    });

    test('HTTP breadcrumbs are dropped before they are recorded', () {
      expect(
        dropHttpBreadcrumb(
          Breadcrumb.http(url: Uri.parse('https://x.test'), method: 'GET'),
          Hint(),
        ),
        isNull,
      );
      final navigation = Breadcrumb(message: 'n', category: 'navigation');
      expect(dropHttpBreadcrumb(navigation, Hint()), same(navigation));
    });
  });
}
