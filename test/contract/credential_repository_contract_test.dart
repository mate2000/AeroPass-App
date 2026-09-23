// Contract: CredentialRepository (contracts/credential-status-port.md).
//
// The same 6-case suite runs against BOTH the fake and the real
// implementation, unmodified — Constitution Principle X's Liskov
// requirement ("the fake verification provider and the real one MUST
// satisfy the same contract test suite, unmodified"). Only each
// implementation's *harness* (how a scenario's preconditions are staged)
// differs; the assertions in `_runContractTests` are shared.
import 'dart:io';

import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/data/services/credential_repository_impl.dart';
import 'package:aeropass_app/data/services/credential_service.dart';
import 'package:aeropass_app/domain/entities/credential_status.dart';
import 'package:aeropass_app/domain/repositories/credential_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_credential_repository.dart';
import '../fakes/fake_http_client_adapter.dart';
import '../fakes/fake_secure_storage_platform.dart';

void main() {
  group('Fake implementation', () {
    _runContractTests(_FakeHarnessFactory());
  });

  group('Real implementation', () {
    _runContractTests(_RealHarnessFactory());

    // 012-mis-viajes T002: the home strip names a suspended credential.
    test(
      'a cached credential reported suspended -> ExpiredOrRevoked(suspended)',
      () async {
        final harness = _RealHarness();
        await harness.givenCachedCredentialReportedRevoked();
        harness._adapter.respondWith({'status': 'suspended'});

        final result = await harness.repository.getStatus();

        expect(
          result.valueOrNull,
          const CredentialStatus.expiredOrRevoked(
            reason: ExpiryReason.suspended,
          ),
        );
      },
    );
  });
}

void _runContractTests(_HarnessFactory factory) {
  test('1. no cached credential -> Ok(NoCredential)', () async {
    final harness = factory.create();
    await harness.givenNoCachedCredential();

    final result = await harness.repository.getStatus();

    expect(
      result,
      const Result<CredentialStatus>.ok(CredentialStatus.noCredential()),
    );
  });

  test(
    '2. cached credential confirmed valid -> Ok(Valid(validUntil))',
    () async {
      final harness = factory.create();
      final validUntil = DateTime.utc(2027, 1, 1);
      await harness.givenCachedCredentialConfirmedValid(validUntil);

      final result = await harness.repository.getStatus();

      expect(
        result,
        Result<CredentialStatus>.ok(
          CredentialStatus.valid(validUntil: validUntil),
        ),
      );
    },
  );

  test(
    '3. cached credential reported expired -> Ok(ExpiredOrRevoked(expired))',
    () async {
      final harness = factory.create();
      await harness.givenCachedCredentialReportedExpired();

      final result = await harness.repository.getStatus();

      expect(
        result,
        const Result<CredentialStatus>.ok(
          CredentialStatus.expiredOrRevoked(reason: ExpiryReason.expired),
        ),
      );
    },
  );

  test(
    '4. cached credential reported revoked -> Ok(ExpiredOrRevoked(revoked))',
    () async {
      final harness = factory.create();
      await harness.givenCachedCredentialReportedRevoked();

      final result = await harness.repository.getStatus();

      expect(
        result,
        const Result<CredentialStatus>.ok(
          CredentialStatus.expiredOrRevoked(reason: ExpiryReason.revoked),
        ),
      );
    },
  );

  test('5. cached credential exists, backend unreachable -> '
      'Ok(Unreachable(lastKnownStatus: <previously cached status>))', () async {
    final harness = factory.create();
    await harness.givenCachedCredentialButBackendUnreachable();

    final result = await harness.repository.getStatus();

    result.when(
      ok: (status) {
        expect(status, isA<Unreachable>());
        expect((status as Unreachable).lastKnownStatus, isNotNull);
      },
      error: (e, st) => fail('expected Ok(Unreachable(...)), got Error: $e'),
    );
  });

  test('6. no cached credential, backend unreachable -> '
      'Ok(Unreachable(lastKnownStatus: null))', () async {
    final harness = factory.create();
    await harness.givenNoCachedCredentialAndBackendUnreachable();

    final result = await harness.repository.getStatus();

    expect(
      result,
      const Result<CredentialStatus>.ok(
        CredentialStatus.unreachable(lastKnownStatus: null),
      ),
    );
  });
}

/// Stages a contract scenario's preconditions, independently of which
/// implementation backs [repository].
abstract class _Harness {
  CredentialRepository get repository;

  Future<void> givenNoCachedCredential();
  Future<void> givenCachedCredentialConfirmedValid(DateTime validUntil);
  Future<void> givenCachedCredentialReportedExpired();
  Future<void> givenCachedCredentialReportedRevoked();
  Future<void> givenCachedCredentialButBackendUnreachable();
  Future<void> givenNoCachedCredentialAndBackendUnreachable();
}

abstract class _HarnessFactory {
  _Harness create();
}

// --- Fake-backed harness ---------------------------------------------

class _FakeHarnessFactory implements _HarnessFactory {
  @override
  _Harness create() => _FakeHarness();
}

class _FakeHarness implements _Harness {
  final _repo = FakeCredentialRepository();

  @override
  CredentialRepository get repository => _repo;

  @override
  Future<void> givenNoCachedCredential() async {
    _repo.scriptResponse(const Result.ok(CredentialStatus.noCredential()));
  }

  @override
  Future<void> givenCachedCredentialConfirmedValid(DateTime validUntil) async {
    _repo.scriptResponse(
      Result.ok(CredentialStatus.valid(validUntil: validUntil)),
    );
  }

  @override
  Future<void> givenCachedCredentialReportedExpired() async {
    _repo.scriptResponse(
      const Result.ok(
        CredentialStatus.expiredOrRevoked(reason: ExpiryReason.expired),
      ),
    );
  }

  @override
  Future<void> givenCachedCredentialReportedRevoked() async {
    _repo.scriptResponse(
      const Result.ok(
        CredentialStatus.expiredOrRevoked(reason: ExpiryReason.revoked),
      ),
    );
  }

  @override
  Future<void> givenCachedCredentialButBackendUnreachable() async {
    _repo.scriptResponse(
      Result.ok(
        CredentialStatus.unreachable(
          lastKnownStatus: CredentialStatus.valid(
            validUntil: DateTime.utc(2027, 1, 1),
          ),
        ),
      ),
    );
  }

  @override
  Future<void> givenNoCachedCredentialAndBackendUnreachable() async {
    _repo.scriptResponse(
      const Result.ok(CredentialStatus.unreachable(lastKnownStatus: null)),
    );
  }
}

// --- Real-backed harness -----------------------------------------------

class _RealHarnessFactory implements _HarnessFactory {
  @override
  _Harness create() => _RealHarness();
}

class _RealHarness implements _Harness {
  _RealHarness() {
    FlutterSecureStoragePlatform.instance = _storagePlatform;
    _dio.httpClientAdapter = _adapter;
  }

  final _storagePlatform = FakeSecureStoragePlatform();
  final _adapter = FakeHttpClientAdapter();
  final _dio = Dio(BaseOptions(baseUrl: 'https://api.test.aeropass.example'));

  late final _service = CredentialService(
    dio: _dio,
    secureStorage: const FlutterSecureStorage(),
  );
  late final CredentialRepositoryImpl _repo = CredentialRepositoryImpl(
    _service,
  );

  @override
  CredentialRepository get repository => _repo;

  @override
  Future<void> givenNoCachedCredential() async {
    _adapter.respondWith({'status': 'no_credential'});
  }

  @override
  Future<void> givenCachedCredentialConfirmedValid(DateTime validUntil) async {
    _storagePlatform.seed({
      CredentialService.tokenKey: 'tok-1',
      CredentialService.validUntilKey: validUntil.toIso8601String(),
    });
    _adapter.respondWith({
      'status': 'valid',
      'validUntil': validUntil.toIso8601String(),
    });
  }

  @override
  Future<void> givenCachedCredentialReportedExpired() async {
    _storagePlatform.seed({
      CredentialService.tokenKey: 'tok-1',
      CredentialService.validUntilKey: DateTime.utc(
        2020,
        1,
        1,
      ).toIso8601String(),
    });
    _adapter.respondWith({'status': 'expired'});
  }

  @override
  Future<void> givenCachedCredentialReportedRevoked() async {
    _storagePlatform.seed({
      CredentialService.tokenKey: 'tok-1',
      CredentialService.validUntilKey: DateTime.utc(
        2027,
        1,
        1,
      ).toIso8601String(),
    });
    _adapter.respondWith({'status': 'revoked'});
  }

  @override
  Future<void> givenCachedCredentialButBackendUnreachable() async {
    _storagePlatform.seed({
      CredentialService.tokenKey: 'tok-1',
      CredentialService.validUntilKey: DateTime.utc(
        2027,
        1,
        1,
      ).toIso8601String(),
    });
    _adapter.failWith(const SocketException('unreachable'));
  }

  @override
  Future<void> givenNoCachedCredentialAndBackendUnreachable() async {
    _adapter.failWith(const SocketException('unreachable'));
  }
}
