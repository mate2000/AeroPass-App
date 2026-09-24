// 015 T060 (DEC-02, research.md §14 and §15): consent is local only. The
// text is bundled, the record is kept in secure storage, and withdrawal
// clears the device and signs the session out. Nothing is sent.
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/data/services/bundled_consent_text.dart';
import 'package:aeropass_app/data/services/consent_service.dart';
import 'package:aeropass_app/data/services/credential_service.dart';
import 'package:aeropass_app/data/services/local_consent_repository.dart';
import 'package:aeropass_app/domain/entities/consent_record.dart';
import 'package:aeropass_app/domain/repositories/session_token_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_clock.dart';
import '../fakes/fake_secure_storage_platform.dart';

class _Session implements SessionTokenProvider {
  int signOuts = 0;
  @override
  Future<Result<String>> token() async => const Result.ok('t');
  @override
  Future<Result<void>> reestablish() async => const Result.ok(null);
  @override
  Future<void> signOut() async => signOuts++;
}

void main() {
  late FakeSecureStoragePlatform storage;
  late _Session session;
  late LocalConsentRepository repository;
  late FakeClock clock;

  setUp(() {
    storage = FakeSecureStoragePlatform();
    FlutterSecureStoragePlatform.instance = storage;
    session = _Session();
    clock = FakeClock();
    repository = LocalConsentRepository(
      ConsentService(secureStorage: const FlutterSecureStorage()),
      credentialService: CredentialService(
        secureStorage: const FlutterSecureStorage(),
      ),
      sessionTokenProvider: session,
      clock: clock,
    );
  });

  test('the text is the bundled version', () async {
    final text = (await repository.getCurrentText()).valueOrNull!;
    expect(text.id, bundledConsentTextVersionId);
    expect(text.points, isNotEmpty);
  });

  test('consent is recorded locally, with its version and time', () async {
    final record = (await repository.recordConsent(
      textVersionId: bundledConsentTextVersionId,
    )).valueOrNull!;
    expect(record.status, ConsentRecordStatus.active);
    expect(record.confirmedAt, clock.now());
    final stored = (await repository.getLocalRecord()).valueOrNull!;
    expect(stored.textVersionId, bundledConsentTextVersionId);
  });

  test('consent to a version the app does not carry is refused', () async {
    final result = await repository.recordConsent(textVersionId: 'otra');
    expect(result.isError, isTrue);
    expect((await repository.getLocalRecord()).valueOrNull, isNull);
  });

  test('a storage failure leaves the gate closed', () async {
    storage.writeError = StateError('keystore');
    final result = await repository.recordConsent(
      textVersionId: bundledConsentTextVersionId,
    );
    expect(result.isError, isTrue);
  });

  test('withdrawal clears the credential and signs the session out', () async {
    await repository.recordConsent(textVersionId: bundledConsentTextVersionId);
    storage.seed({CredentialService.tokenKey: 'identity-1'});

    final withdrawn = (await repository.withdraw()).valueOrNull!;

    expect(withdrawn.status, ConsentRecordStatus.withdrawn);
    expect(
      await storage.read(key: CredentialService.tokenKey, options: const {}),
      isNull,
    );
    expect(session.signOuts, 1);
  });

  test(
    'withdrawing with no record is an error, and signs nothing out',
    () async {
      expect((await repository.withdraw()).isError, isTrue);
      expect(session.signOuts, 0);
    },
  );
}
