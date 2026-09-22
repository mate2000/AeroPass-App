import 'dart:typed_data';

import '../../core/result.dart';
import '../../domain/entities/capture_outcome.dart';
import '../../domain/entities/extraction_result.dart';
import '../../domain/repositories/document_verification_repository.dart';
import '../models/document_verification_response.dart';
import 'document_verification_service.dart';

/// The real `DocumentVerificationRepository` implementation, backed by
/// `DocumentVerificationService`. Per
/// contracts/document-verification-port.md: no `dio` exception, DTO, or raw
/// JSON shape may cross out of this class — callers only ever see
/// `CaptureOutcome`/`Result`. Owns the processor error-code ->
/// `CaptureRejectionReason` mapping (research.md §4) so no other layer
/// needs a second copy of it.
///
/// MUST satisfy the exact same contract test suite as
/// `FakeDocumentVerificationRepository`, unmodified (Constitution Principle
/// X, Liskov) — see
/// test/contract/document_verification_repository_contract_test.dart.
class DocumentVerificationRepositoryImpl
    implements DocumentVerificationRepository {
  DocumentVerificationRepositoryImpl(this._service);

  final DocumentVerificationService _service;

  @override
  Future<Result<CaptureOutcome>> submit(
    Uint8List documentImageBytes,
  ) async {
    try {
      final response = await _service.submit(documentImageBytes);
      return Result.ok(_mapResponse(response));
    } catch (e, st) {
      // Offline, timeout, non-2xx, or TLS/pinning failure — FR-015's
      // "verification cannot be sent yet" transport-failure state. Never a
      // bare exception crossing into CaptureViewModel (Principle IX).
      return Result.error(e, st);
    }
  }

  CaptureOutcome _mapResponse(DocumentVerificationResponse response) {
    if (response.outcome == 'accepted') {
      return CaptureOutcome.accepted(extraction: _mapExtraction(response));
    }
    return CaptureOutcome.rejected(reason: _mapReason(response.reason));
  }

  /// Maps the wire field list into `ExtractionResult` (004-confirmar-datos
  /// research.md §2/§3, contracts/document-verification-port-addendum.md).
  /// A key the mapping doesn't recognize is skipped, mirroring
  /// `_mapReason`'s "fall back rather than throw" discipline; a
  /// `FieldKey` the response never mentions at all becomes
  /// `ExtractedField.missing` (FR-009's explicit gap, never inferred as an
  /// empty value).
  ExtractionResult _mapExtraction(DocumentVerificationResponse response) {
    final byKey = <FieldKey, ExtractedFieldResponse>{
      for (final field in response.fields ?? const <ExtractedFieldResponse>[])
        if (_mapFieldKey(field.key) != null) _mapFieldKey(field.key)!: field,
    };
    return ExtractionResult(
      fields: [
        for (final key in FieldKey.values)
          if (byKey[key] case final field?)
            ExtractedField.present(
              key: key,
              value: field.value,
              confidence: field.confidence,
            )
          else
            ExtractedField.missing(key: key),
      ],
    );
  }

  FieldKey? _mapFieldKey(String raw) => switch (raw) {
    'full_name' => FieldKey.fullName,
    'document_number' => FieldKey.documentNumber,
    'nationality' => FieldKey.nationality,
    'expiry_date' => FieldKey.expiryDate,
    _ => null,
  };

  /// Maps the processor's own error taxonomy into the fixed, small
  /// `CaptureRejectionReason` vocabulary shared with device-side rejections
  /// (research.md §4). An unrecognized or missing code falls back to
  /// `unreadable` rather than throwing (contract case 7) — a processor
  /// error the mapping doesn't recognize is a defect to fix here, not
  /// something the UI has to handle generically.
  CaptureRejectionReason _mapReason(String? raw) {
    return switch (raw) {
      'blur' => CaptureRejectionReason.blur,
      'glare' => CaptureRejectionReason.glare,
      'framing' => CaptureRejectionReason.framing,
      'wrong_document' => CaptureRejectionReason.wrongDocument,
      'low_resolution' => CaptureRejectionReason.lowResolution,
      _ => CaptureRejectionReason.unreadable,
    };
  }
}
