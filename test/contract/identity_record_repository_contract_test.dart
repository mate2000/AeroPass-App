// Contract: IdentityRecordRepository
// (contracts/identity-record-repository-port.md).
//
// The same 2-case suite runs against BOTH the fake and the real
// implementation, unmodified — Constitution Principle X's Liskov
// requirement. Case 1 also asserts on the local display-only cache: exactly
// the confirmed fields' key+value pairs, never source/original/reverified
// data (research.md §5).
import 'dart:io';

import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/data/services/identity_record_repository_impl.dart';
import 'package:aeropass_app/data/services/identity_record_service.dart';
import 'package:aeropass_app/domain/entities/extraction_result.dart';
import 'package:aeropass_app/domain/entities/identity_record.dart';
import 'package:aeropass_app/domain/repositories/identity_record_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_http_client_adapter.dart';
import '../fakes/fake_identity_record_repository.dart';
import '../fakes/fake_secure_storage_platform.dart';

void main() {
  group('Fake implementation', () {
    _runContractTests(_FakeHarnessFactory());
  });

  group('Real implementation', () {
    _runContractTests(_RealHarnessFactory());
  });
}

const _record = IdentityRecord(
  fields: [
    ConfirmedField(
      key: FieldKey.fullName,
      value: 'Mateo González Restrepo',
      source: FieldSource.machineRead,
    ),
    ConfirmedField(
      key: FieldKey.documentNumber,
      value: 'CC 1.234.567.890',
      source: FieldSource.passengerCorrected,
      originalValue: 'CC 1.234.567.980',
      reverified: true,
    ),
  ],
);

void _runContractTests(_HarnessFactory factory) {
  test(
    '1. Backend accepts the record -> Ok(IdentityRecord), and the local '
    'display-only cache holds exactly the confirmed key+value pairs — no '
    'source/original/reverified data',
    () async {
      final harness = factory.create();
      harness.givenBackendAccepts();

      final result = await harness.repository.confirm(_record);

      expect(result.isOk, isTrue);
      final cached = await harness.readLocalCache();
      expect(cached, {
        'fullName': 'Mateo González Restrepo',
        'documentNumber': 'CC 1.234.567.890',
      });
    },
  );

  test(
    '2. Backend rejects or is unreachable -> Error; the local cache is '
    'untouched (no partial write)',
    () async {
      final harness = factory.create();
      harness.givenBackendFails();

      final result = await harness.repository.confirm(_record);

      expect(result.isError, isTrue);
      final cached = await harness.readLocalCache();
      expect(cached, isEmpty);
    },
  );
}

/// Stages a contract scenario's preconditions, independently of which
/// implementation backs [repository].
abstract class _Harness {
  IdentityRecordRepository get repository;

  void givenBackendAccepts();
  void givenBackendFails();

  /// Reads back whatever the implementation wrote to its local display-only
  /// cache, as a plain `{fieldKeyName: value}` map (empty if nothing was
  /// ever written).
  Future<Map<String, String>> readLocalCache();
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
  final _repo = FakeIdentityRecordRepository();

  @override
  IdentityRecordRepository get repository => _repo;

  @override
  void givenBackendAccepts() {
    _repo.scriptConfirm(Result.ok(_record));
  }

  @override
  void givenBackendFails() {
    _repo.scriptConfirm(Result.error(const SocketException('offline')));
  }

  @override
  Future<Map<String, String>> readLocalCache() async => _repo.cachedSubset;
}

// --- Real-backed harness --------------------------------------------------

class _RealHarnessFactory implements _HarnessFactory {
  @override
  _Harness create() => _RealHarness();
}

class _RealHarness implements _Harness {
  _RealHarness() {
    FlutterSecureStoragePlatform.instance = _storagePlatform;
    _dio.httpClientAdapter = _adapter;
  }

  final _adapter = FakeHttpClientAdapter();
  final _dio = Dio(BaseOptions(baseUrl: 'https://api.test.aeropass.example'));
  final _storagePlatform = FakeSecureStoragePlatform();

  late final _service = IdentityRecordService(
    dio: _dio,
    secureStorage: const FlutterSecureStorage(),
  );
  late final IdentityRecordRepositoryImpl _repo = IdentityRecordRepositoryImpl(
    _service,
  );

  @override
  IdentityRecordRepository get repository => _repo;

  @override
  void givenBackendAccepts() {
    _adapter.respondWith({'status': 'ok'});
  }

  @override
  void givenBackendFails() {
    _adapter.failWith(const SocketException('unreachable'));
  }

  @override
  Future<Map<String, String>> readLocalCache() =>
      _service.readDisplaySubsetForTesting();
}
