// Contract: ConsentRepository (contracts/consent-repository-port.md).
//
// The 9-case suite runs against the fake. 015 T048: the network-backed
// implementation went with the invented contract (DEC-02). Release uses
// `LocalConsentRepository`, which has its own test, because several of the
// suite's cases are network failures a local store cannot have.
import 'dart:io';

import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/data/dev/dev_consent_repository.dart';
import 'package:aeropass_app/data/services/credential_service.dart';
import 'package:aeropass_app/domain/entities/consent_record.dart';
import 'package:aeropass_app/domain/entities/consent_text_version.dart';
import 'package:aeropass_app/domain/entities/enrollment_attempt_id.dart';
import 'package:aeropass_app/domain/entities/processing_scope.dart';
import 'package:aeropass_app/domain/repositories/consent_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_consent_repository.dart';
import '../fakes/fake_secure_storage_platform.dart';

void main() {
  group('Fake implementation', () {
    _runContractTests(_FakeHarnessFactory());
  });

  // 015 T048: the network-backed implementation went with the invented
  // contract (DEC-02); `LocalConsentRepository` has its own test.
  group('Dev repository: withdrawal clears the cached credential', () {
    _runDevWithdrawalTest();
  });
}

// 008-identidad-activa, contracts/consent-withdrawal-addendum.md: the dev
// repository's one case (A6).
void _runDevWithdrawalTest() {
  late CredentialService credentialService;

  setUp(() {
    FlutterSecureStoragePlatform.instance = FakeSecureStoragePlatform();
    credentialService = CredentialService(
      secureStorage: const FlutterSecureStorage(),
    );
  });

  test('A6. the dev repository also clears the cached credential', () async {
    final dev = DevConsentRepository(credentialService: credentialService);
    await dev.recordConsent(textVersionId: 'dev-demo-v1');

    final result = await dev.withdraw();

    expect(result.isOk, isTrue);
    expect(await credentialService.readCachedCredential(), isNull);
  });
}

void _runContractTests(_HarnessFactory factory) {
  test('1. getCurrentText() succeeds -> Ok(ConsentTextVersion) with all '
      'fields populated', () async {
    final harness = factory.create();
    await harness.givenCurrentTextAvailable();

    final result = await harness.repository.getCurrentText();

    result.when(
      ok: (text) {
        expect(text.id, isNotEmpty);
        expect(text.points, isNotEmpty);
        expect(text.rightsStatement, isNotEmpty);
        expect(text.optionalityStatement, isNotEmpty);
        expect(text.processorDisclosure, isNotEmpty);
        expect(text.privacyPolicyUrl, isNotEmpty);
        expect(text.termsUrl, isNotEmpty);
      },
      error: (e, st) => fail('expected Ok(ConsentTextVersion), got Error: $e'),
    );
  });

  test('2. getCurrentText() fails (network/parse) -> Error', () async {
    final harness = factory.create();
    await harness.givenCurrentTextFetchFails();

    final result = await harness.repository.getCurrentText();

    expect(result.isError, isTrue);
  });

  test('3. recordConsent() while online, backend accepts -> Ok(ConsentRecord) '
      'with status=active, a freshly-generated enrollmentAttemptId, and the '
      'local copy persisted', () async {
    final harness = factory.create();
    await harness.givenRecordConsentSucceeds();

    final result = await harness.repository.recordConsent(textVersionId: 'v1');

    final record = result.when(
      ok: (r) => r,
      error: (e, st) => fail('expected Ok(ConsentRecord), got Error: $e'),
    );
    expect(record.status, ConsentRecordStatus.active);
    expect(record.textVersionId, 'v1');
    expect(record.enrollmentAttemptId.value, isNotEmpty);

    final localResult = await harness.repository.getLocalRecord();
    expect(localResult, Result<ConsentRecord?>.ok(record));
  });

  test('4. recordConsent() while offline/backend rejects -> Error; '
      'getLocalRecord() afterward still returns Ok(null)', () async {
    final harness = factory.create();
    await harness.givenRecordConsentFails();

    final result = await harness.repository.recordConsent(textVersionId: 'v1');
    expect(result.isError, isTrue);

    final localResult = await harness.repository.getLocalRecord();
    expect(localResult, const Result<ConsentRecord?>.ok(null));
  });

  test('5. getLocalRecord() with no prior consent -> Ok(null)', () async {
    final harness = factory.create();
    await harness.givenNoLocalRecord();

    final result = await harness.repository.getLocalRecord();

    expect(result, const Result<ConsentRecord?>.ok(null));
  });

  test('6. withdraw() with an active local record, backend reachable -> '
      'Ok(ConsentRecord) whose status is no longer active immediately after '
      'the call returns', () async {
    final harness = factory.create();
    await harness.givenActiveLocalRecordAndReachableBackend();

    final result = await harness.repository.withdraw();

    final record = result.when(
      ok: (r) => r,
      error: (e, st) => fail('expected Ok(ConsentRecord), got Error: $e'),
    );
    expect(record.status, isNot(ConsentRecordStatus.active));
    expect(
      record.status,
      anyOf(
        ConsentRecordStatus.withdrawn,
        ConsentRecordStatus.withdrawalPending,
      ),
    );
  });

  test('7. withdraw() with no local record -> Error', () async {
    final harness = factory.create();
    await harness.givenNoLocalRecord();

    final result = await harness.repository.withdraw();

    expect(result.isError, isTrue);
  });

  test(
    '8. retryPendingWithdrawal() with a withdrawalPending local record and '
    'a now-reachable backend -> the local record status becomes withdrawn',
    () async {
      final harness = factory.create();
      await harness.givenWithdrawalPendingLocalRecordAndReachableBackend();

      await harness.repository.retryPendingWithdrawal();

      final localResult = await harness.repository.getLocalRecord();
      final record = localResult.when(
        ok: (r) => r,
        error: (e, st) => fail('expected Ok(record), got Error: $e'),
      );
      expect(record, isNotNull);
      expect(record!.status, ConsentRecordStatus.withdrawn);
    },
  );

  test('9. retryPendingWithdrawal() with no withdrawalPending record -> no-op, '
      "doesn't throw", () async {
    final harness = factory.create();
    await harness.givenNoLocalRecord();

    await expectLater(harness.repository.retryPendingWithdrawal(), completes);
  });
}

/// Stages a contract scenario's preconditions, independently of which
/// implementation backs [repository].
abstract class _Harness {
  ConsentRepository get repository;

  Future<void> givenCurrentTextAvailable();
  Future<void> givenCurrentTextFetchFails();
  Future<void> givenRecordConsentSucceeds();
  Future<void> givenRecordConsentFails();
  Future<void> givenNoLocalRecord();
  Future<void> givenActiveLocalRecordAndReachableBackend();
  Future<void> givenWithdrawalPendingLocalRecordAndReachableBackend();
}

abstract class _HarnessFactory {
  _Harness create();
}

// --- Fake-backed harness -------------------------------------------------

class _FakeHarnessFactory implements _HarnessFactory {
  @override
  _Harness create() => _FakeHarness();
}

class _FakeHarness implements _Harness {
  final _repo = FakeConsentRepository();

  @override
  ConsentRepository get repository => _repo;

  ConsentTextVersion get _sampleText => ConsentTextVersion(
    id: 'v1',
    points: const [
      ConsentPoint(
        icon: ConsentPointIcon.camera,
        heading: '[PLACEHOLDER] Qué se captura',
        body: '[PLACEHOLDER LEGAL TEXT]',
      ),
    ],
    rightsStatement: '[PLACEHOLDER] Tus derechos',
    optionalityStatement: '[PLACEHOLDER] Es opcional',
    processorDisclosure: '[PLACEHOLDER] Procesador externo',
    privacyPolicyUrl: 'https://example.test/privacy',
    termsUrl: 'https://example.test/terms',
    publishedAt: DateTime.utc(2026, 1, 1),
  );

  @override
  Future<void> givenCurrentTextAvailable() async {
    _repo.scriptCurrentText(Result.ok(_sampleText));
  }

  @override
  Future<void> givenCurrentTextFetchFails() async {
    _repo.scriptCurrentText(Result.error(const SocketException('offline')));
  }

  @override
  Future<void> givenRecordConsentSucceeds() async {
    // Leave unscripted: the fake generates a fresh Ok(ConsentRecord) by
    // default.
  }

  @override
  Future<void> givenRecordConsentFails() async {
    _repo.scriptRecordConsent(Result.error(const SocketException('offline')));
  }

  @override
  Future<void> givenNoLocalRecord() async {
    _repo.seedLocalRecord(null);
  }

  @override
  Future<void> givenActiveLocalRecordAndReachableBackend() async {
    _repo.seedLocalRecord(_activeRecord());
    _repo.failWithdrawalDelivery(fails: false);
  }

  @override
  Future<void> givenWithdrawalPendingLocalRecordAndReachableBackend() async {
    _repo.seedLocalRecord(
      _activeRecord().copyWith(
        status: ConsentRecordStatus.withdrawalPending,
        withdrawalRequestedAt: DateTime.utc(2026, 1, 2),
      ),
    );
    _repo.failWithdrawalDelivery(fails: false);
  }

  ConsentRecord _activeRecord() => ConsentRecord(
    textVersionId: 'v1',
    enrollmentAttemptId: EnrollmentAttemptId.generate(),
    scope: ProcessingScope.identityVerification,
    confirmedAt: DateTime.utc(2026, 1, 1),
    status: ConsentRecordStatus.active,
  );
}
