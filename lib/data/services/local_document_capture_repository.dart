import 'dart:typed_data';

import '../../core/result.dart';
import '../../domain/entities/capture_outcome.dart';
import '../../domain/entities/extraction_result.dart';
import '../../domain/repositories/document_verification_repository.dart';

/// 003's [DocumentVerificationRepository] against the real backend, which
/// reads nothing from a document (015 V-07, research.md §8, Q1).
///
/// The on-device quality check has already passed by the time this is
/// called, so every capture is accepted locally, with **empty** fields for
/// the passenger to type on 004 (FR-002a). Nationality is absent: the
/// backend never asks for it, so the app does not collect it. The photo
/// itself travels on in memory, through `PendingDocumentController`, to the
/// registration call. Nothing is sent from here.
class LocalDocumentCaptureRepository implements DocumentVerificationRepository {
  const LocalDocumentCaptureRepository();

  /// The fields 004 asks the passenger to type, in screen order.
  static const typedFields = [
    FieldKey.fullName,
    FieldKey.documentNumber,
    FieldKey.expiryDate,
  ];

  @override
  Future<Result<CaptureOutcome>> submit(Uint8List documentImageBytes) async =>
      Result.ok(
        CaptureOutcome.accepted(
          extraction: ExtractionResult(
            fields: [
              for (final key in typedFields)
                ExtractedField.present(key: key, value: '', confidence: 0),
            ],
          ),
        ),
      );
}
