// Contract: FieldReverificationRepository
// (contracts/field-reverification-port.md).
//
// The same 4-case suite runs against BOTH the fake and the real
// implementation, unmodified — Constitution Principle X's Liskov
// requirement.
import 'dart:io';
import 'dart:typed_data';

import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/data/services/field_reverification_repository_impl.dart';
import 'package:aeropass_app/data/services/field_reverification_service.dart';
import 'package:aeropass_app/domain/entities/extraction_result.dart';
import 'package:aeropass_app/domain/entities/field_reverification_outcome.dart';
import 'package:aeropass_app/domain/repositories/field_reverification_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_field_reverification_repository.dart';
import '../fakes/fake_http_client_adapter.dart';

void main() {
  group('Fake implementation', () {
    _runContractTests(_FakeHarnessFactory());
  });

  group('Real implementation', () {
    _runContractTests(_RealHarnessFactory());
  });
}

Uint8List get _sampleBytes => Uint8List.fromList(List.filled(16, 1));

void _runContractTests(_HarnessFactory factory) {
  test(
    '1. Candidate value matches what the retained image shows -> '
    'Ok(FieldReverificationOutcome.confirmed())',
    () async {
      final harness = factory.create();
      harness.givenConfirmed();

      final result = await harness.repository.reverify(
        documentImageBytes: _sampleBytes,
        field: FieldKey.fullName,
        candidateValue: 'Mateo González Restrepo',
      );

      expect(
        result,
        const Result<FieldReverificationOutcome>.ok(
          FieldReverificationOutcome.confirmed(),
        ),
      );
    },
  );

  test(
    '2. Candidate value does not match -> Ok(FieldReverificationOutcome.disagreed())',
    () async {
      final harness = factory.create();
      harness.givenDisagreed();

      final result = await harness.repository.reverify(
        documentImageBytes: _sampleBytes,
        field: FieldKey.documentNumber,
        candidateValue: 'CC 9.999.999.999',
      );

      expect(
        result,
        const Result<FieldReverificationOutcome>.ok(
          FieldReverificationOutcome.disagreed(),
        ),
      );
    },
  );

  test('3. Offline / transport failure -> Error', () async {
    final harness = factory.create();
    harness.givenTransportFailure();

    final result = await harness.repository.reverify(
      documentImageBytes: _sampleBytes,
      field: FieldKey.nationality,
      candidateValue: 'Colombiana',
    );

    expect(result.isError, isTrue);
  });

  test(
    '4. A field the processor cannot re-read -> the mapping still resolves '
    'to disagreed(), never an unhandled exception',
    () async {
      final harness = factory.create();
      harness.givenUnrecognizedResponse();

      final result = await harness.repository.reverify(
        documentImageBytes: _sampleBytes,
        field: FieldKey.expiryDate,
        candidateValue: '2031-03-14',
      );

      expect(
        result,
        const Result<FieldReverificationOutcome>.ok(
          FieldReverificationOutcome.disagreed(),
        ),
      );
    },
  );
}

/// Stages a contract scenario's preconditions, independently of which
/// implementation backs [repository].
abstract class _Harness {
  FieldReverificationRepository get repository;

  void givenConfirmed();
  void givenDisagreed();
  void givenTransportFailure();
  void givenUnrecognizedResponse();
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
  final _repo = FakeFieldReverificationRepository();

  @override
  FieldReverificationRepository get repository => _repo;

  @override
  void givenConfirmed() {
    _repo.scriptReverify(
      const Result.ok(FieldReverificationOutcome.confirmed()),
    );
  }

  @override
  void givenDisagreed() {
    _repo.scriptReverify(
      const Result.ok(FieldReverificationOutcome.disagreed()),
    );
  }

  @override
  void givenTransportFailure() {
    _repo.scriptReverify(Result.error(const SocketException('offline')));
  }

  @override
  void givenUnrecognizedResponse() {
    _repo.scriptReverify(
      const Result.ok(FieldReverificationOutcome.disagreed()),
    );
  }
}

// --- Real-backed harness --------------------------------------------------

class _RealHarnessFactory implements _HarnessFactory {
  @override
  _Harness create() => _RealHarness();
}

class _RealHarness implements _Harness {
  _RealHarness() {
    _dio.httpClientAdapter = _adapter;
  }

  final _adapter = FakeHttpClientAdapter();
  final _dio = Dio(BaseOptions(baseUrl: 'https://api.test.aeropass.example'));

  late final _service = FieldReverificationService(dio: _dio);
  late final FieldReverificationRepositoryImpl _repo =
      FieldReverificationRepositoryImpl(_service);

  @override
  FieldReverificationRepository get repository => _repo;

  @override
  void givenConfirmed() {
    _adapter.respondWith({'confirmed': true});
  }

  @override
  void givenDisagreed() {
    _adapter.respondWith({'confirmed': false});
  }

  @override
  void givenTransportFailure() {
    _adapter.failWith(const SocketException('unreachable'));
  }

  @override
  void givenUnrecognizedResponse() {
    // No `confirmed` key at all — the real mapping must still resolve to
    // `disagreed()`, never throw (contract case 4).
    _adapter.respondWith({});
  }
}
