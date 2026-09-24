// 008-identidad-activa T025: the dev issuance fake, always a success by
// design (research.md §14: happy-path mode's job is a walkable flow).
//
// 015 T048: the real implementation called `POST /v1/credential/issuance`,
// which the backend does not have. The backend creates the identity inside
// the verification itself, so release issuance reads `GET /v1/identity/me`
// (`PassengerIssuanceRepository`).
import 'package:aeropass_app/data/dev/dev_credential_issuance_repository.dart';
import 'package:aeropass_app/data/services/credential_service.dart';
import 'package:aeropass_app/domain/entities/activated_credential.dart';
import 'package:aeropass_app/domain/entities/issuance_outcome.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_secure_storage_platform.dart';

void main() {
  group('Dev fake', () {
    test('1. returns Ok(activated) with synthetic data and stores the token '
        'and validUntil', () async {
      final storage = FakeSecureStoragePlatform();
      FlutterSecureStoragePlatform.instance = storage;
      final dev = DevCredentialIssuanceRepository(
        credentialService: CredentialService(
          secureStorage: const FlutterSecureStorage(),
        ),
      );

      final result = await dev.requestIssuance();

      final outcome = result.valueOrNull;
      expect(outcome, isA<IssuanceActivated>());
      final credential = (outcome! as IssuanceActivated).credential;
      expect(credential.holderName, isNotEmpty);
      expect(credential.documentLast4, matches(RegExp(r'^\d{4}$')));
      expect(credential.issuingCountry, 'COL');
      expect(credential.validUntil.isAfter(credential.issuedAt), isTrue);
      expect(
        await storage.read(key: CredentialService.tokenKey, options: const {}),
        isNotNull,
      );
      expect(
        await storage.read(
          key: CredentialService.validUntilKey,
          options: const {},
        ),
        isNotNull,
      );
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
}
