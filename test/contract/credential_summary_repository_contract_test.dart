// 012-mis-viajes T008: the dev credential summary, the offline demo's strip.
// 015 T048: the real implementation read `GET /v1/credential/status`, which
// the backend does not have. Release now reads `GET /v1/identity/me`
// (`PassengerBackedCredentialRepository`, tested in
// test/unit/passenger_backed_credential_repository_test.dart).
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/data/dev/dev_credential_summary_repository.dart';
import 'package:aeropass_app/data/services/credential_service.dart';
import 'package:aeropass_app/domain/entities/credential_summary.dart';
import 'package:aeropass_app/domain/repositories/credential_summary_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_secure_storage_platform.dart';

CredentialService _service({
  bool withToken = true,
  Map<String, String> fields = const {},
}) {
  final storage = FakeSecureStoragePlatform()
    ..seed({
      if (withToken) CredentialService.tokenKey: 'tok-1',
      if (withToken)
        CredentialService.validUntilKey: DateTime.utc(2031).toIso8601String(),
      ...fields,
    });
  FlutterSecureStoragePlatform.instance = storage;
  return CredentialService(secureStorage: const FlutterSecureStorage());
}

const _storedFields = {
  CredentialService.holderNameKey: 'Nombre Guardado',
  CredentialService.documentLast4Key: '1111',
};

void main() {
  group('Dev fake', () {
    test('a stored token is affirmed active with the stored fields', () async {
      final dev = DevCredentialSummaryRepository(
        credentialService: _service(fields: _storedFields),
      );

      final summary = (await dev.getSummary()).valueOrNull!;

      expect(summary.showsActive, isTrue);
      expect(summary.documentLast4, '1111');
    });

    test('no stored token is NoCredentialFailure', () async {
      final dev = DevCredentialSummaryRepository(
        credentialService: _service(withToken: false),
      );

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
