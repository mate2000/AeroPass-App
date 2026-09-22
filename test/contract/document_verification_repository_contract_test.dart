// Contract: DocumentVerificationRepository
// (contracts/document-verification-port.md).
//
// The same 7-case suite runs against BOTH the fake and the real
// implementation, unmodified — Constitution Principle X's Liskov
// requirement. Only each implementation's *harness* (how a scenario's
// preconditions are staged) differs; the assertions in `_runContractTests`
// are shared.
import 'dart:io';
import 'dart:typed_data';

import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/data/services/document_verification_repository_impl.dart';
import 'package:aeropass_app/data/services/document_verification_service.dart';
import 'package:aeropass_app/domain/entities/capture_outcome.dart';
import 'package:aeropass_app/domain/entities/extraction_result.dart';
import 'package:aeropass_app/domain/repositories/document_verification_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_document_verification_repository.dart';
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
    '1. Submission accepted by the processor -> Ok(CaptureOutcome.accepted) '
    'with every field present (contracts/document-verification-port-addendum.md)',
    () async {
      final harness = factory.create();
      harness.givenAccepted();

      final result = await harness.repository.submit(_sampleBytes);

      expect(
        result,
        const Result<CaptureOutcome>.ok(
          CaptureOutcome.accepted(
            extraction: ExtractionResult(
              fields: [
                ExtractedField.present(
                  key: FieldKey.fullName,
                  value: 'Mateo González Restrepo',
                  confidence: 0.98,
                ),
                ExtractedField.present(
                  key: FieldKey.documentNumber,
                  value: 'CC 1.234.567.890',
                  confidence: 0.97,
                ),
                ExtractedField.present(
                  key: FieldKey.nationality,
                  value: 'Colombiana',
                  confidence: 0.99,
                ),
                ExtractedField.present(
                  key: FieldKey.expiryDate,
                  value: '2031-03-14',
                  confidence: 0.95,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  test(
    '1b. Submission accepted with one field absent from the response -> '
    'that field maps to ExtractedField.missing, others unaffected',
    () async {
      final harness = factory.create();
      harness.givenAcceptedWithMissingField(FieldKey.nationality);

      final result = await harness.repository.submit(_sampleBytes);

      final outcome = result.valueOrNull;
      expect(outcome, isA<CaptureOutcomeAccepted>());
      final extraction = (outcome as CaptureOutcomeAccepted).extraction;
      expect(
        extraction.fieldFor(FieldKey.nationality),
        const ExtractedField.missing(key: FieldKey.nationality),
      );
      expect(extraction.fieldFor(FieldKey.fullName), isA<ExtractedFieldPresent>());
    },
  );

  test(
    '2. Submission rejected for blur -> '
    'Ok(CaptureOutcome.rejected(CaptureRejectionReason.blur))',
    () async {
      final harness = factory.create();
      harness.givenRejected('blur');

      final result = await harness.repository.submit(_sampleBytes);

      expect(
        result,
        const Result<CaptureOutcome>.ok(
          CaptureOutcome.rejected(reason: CaptureRejectionReason.blur),
        ),
      );
    },
  );

  test(
    '3. Submission rejected for glare -> '
    'Ok(CaptureOutcome.rejected(CaptureRejectionReason.glare))',
    () async {
      final harness = factory.create();
      harness.givenRejected('glare');

      final result = await harness.repository.submit(_sampleBytes);

      expect(
        result,
        const Result<CaptureOutcome>.ok(
          CaptureOutcome.rejected(reason: CaptureRejectionReason.glare),
        ),
      );
    },
  );

  test(
    '4. Submission rejected as wrong document -> '
    'Ok(CaptureOutcome.rejected(CaptureRejectionReason.wrongDocument))',
    () async {
      final harness = factory.create();
      harness.givenRejected('wrong_document');

      final result = await harness.repository.submit(_sampleBytes);

      expect(
        result,
        const Result<CaptureOutcome>.ok(
          CaptureOutcome.rejected(reason: CaptureRejectionReason.wrongDocument),
        ),
      );
    },
  );

  test(
    '5. Submission rejected for a processor-only reason with no device-side '
    'equivalent -> Ok(CaptureOutcome.rejected(CaptureRejectionReason.unreadable))',
    () async {
      final harness = factory.create();
      harness.givenRejected('illegible_document');

      final result = await harness.repository.submit(_sampleBytes);

      expect(
        result,
        const Result<CaptureOutcome>.ok(
          CaptureOutcome.rejected(reason: CaptureRejectionReason.unreadable),
        ),
      );
    },
  );

  test('6. Offline / transport failure -> Error', () async {
    final harness = factory.create();
    harness.givenTransportFailure();

    final result = await harness.repository.submit(_sampleBytes);

    expect(result.isError, isTrue);
  });

  test(
    '7. A malformed/unrecognized processor error code -> the mapping still '
    'resolves to a defined CaptureRejectionReason (falls back to '
    'unreadable), never an unhandled exception',
    () async {
      final harness = factory.create();
      harness.givenRejected(null);

      final result = await harness.repository.submit(_sampleBytes);

      expect(
        result,
        const Result<CaptureOutcome>.ok(
          CaptureOutcome.rejected(reason: CaptureRejectionReason.unreadable),
        ),
      );
    },
  );
}

/// Stages a contract scenario's preconditions, independently of which
/// implementation backs [repository].
abstract class _Harness {
  DocumentVerificationRepository get repository;

  void givenAccepted();
  void givenAcceptedWithMissingField(FieldKey missingField);
  void givenRejected(String? reasonCode);
  void givenTransportFailure();
}

/// The 4-field accepted-response fixture shared by both harnesses.
const _acceptedFieldsJson = [
  {'key': 'full_name', 'value': 'Mateo González Restrepo', 'confidence': 0.98},
  {'key': 'document_number', 'value': 'CC 1.234.567.890', 'confidence': 0.97},
  {'key': 'nationality', 'value': 'Colombiana', 'confidence': 0.99},
  {'key': 'expiry_date', 'value': '2031-03-14', 'confidence': 0.95},
];

String _jsonKeyFor(FieldKey key) => switch (key) {
  FieldKey.fullName => 'full_name',
  FieldKey.documentNumber => 'document_number',
  FieldKey.nationality => 'nationality',
  FieldKey.expiryDate => 'expiry_date',
};

abstract class _HarnessFactory {
  _Harness create();
}

// --- Fake-backed harness -------------------------------------------------

class _FakeHarnessFactory implements _HarnessFactory {
  @override
  _Harness create() => _FakeHarness();
}

class _FakeHarness implements _Harness {
  final _repo = FakeDocumentVerificationRepository();

  @override
  DocumentVerificationRepository get repository => _repo;

  @override
  void givenAccepted() {
    _repo.scriptSubmit(
      const Result.ok(
        CaptureOutcome.accepted(
          extraction: ExtractionResult(
            fields: [
              ExtractedField.present(
                key: FieldKey.fullName,
                value: 'Mateo González Restrepo',
                confidence: 0.98,
              ),
              ExtractedField.present(
                key: FieldKey.documentNumber,
                value: 'CC 1.234.567.890',
                confidence: 0.97,
              ),
              ExtractedField.present(
                key: FieldKey.nationality,
                value: 'Colombiana',
                confidence: 0.99,
              ),
              ExtractedField.present(
                key: FieldKey.expiryDate,
                value: '2031-03-14',
                confidence: 0.95,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void givenAcceptedWithMissingField(FieldKey missingField) {
    _repo.scriptSubmit(
      Result.ok(
        CaptureOutcome.accepted(
          extraction: ExtractionResult(
            fields: [
              for (final key in FieldKey.values)
                if (key == missingField)
                  ExtractedField.missing(key: key)
                else
                  ExtractedField.present(
                    key: key,
                    value: 'fixture',
                    confidence: 0.98,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void givenRejected(String? reasonCode) {
    final reason = switch (reasonCode) {
      'blur' => CaptureRejectionReason.blur,
      'glare' => CaptureRejectionReason.glare,
      'wrong_document' => CaptureRejectionReason.wrongDocument,
      _ => CaptureRejectionReason.unreadable,
    };
    _repo.scriptSubmit(Result.ok(CaptureOutcome.rejected(reason: reason)));
  }

  @override
  void givenTransportFailure() {
    _repo.scriptSubmit(Result.error(const SocketException('offline')));
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

  late final _service = DocumentVerificationService(dio: _dio);
  late final DocumentVerificationRepositoryImpl _repo =
      DocumentVerificationRepositoryImpl(_service);

  @override
  DocumentVerificationRepository get repository => _repo;

  @override
  void givenAccepted() {
    _adapter.respondWith({'outcome': 'accepted', 'fields': _acceptedFieldsJson});
  }

  @override
  void givenAcceptedWithMissingField(FieldKey missingField) {
    final missingJsonKey = _jsonKeyFor(missingField);
    _adapter.respondWith({
      'outcome': 'accepted',
      'fields': [
        for (final field in _acceptedFieldsJson)
          if (field['key'] != missingJsonKey) field,
      ],
    });
  }

  @override
  void givenRejected(String? reasonCode) {
    _adapter.respondWith({'outcome': 'rejected', 'reason': ?reasonCode});
  }

  @override
  void givenTransportFailure() {
    _adapter.failWith(const SocketException('unreachable'));
  }
}
