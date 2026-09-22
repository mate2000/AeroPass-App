import 'dart:typed_data';

import '../../core/result.dart';
import '../../domain/entities/capture_outcome.dart';
import '../../domain/entities/extraction_result.dart';
import '../../domain/repositories/document_verification_repository.dart';

/// A local, no-network `DocumentVerificationRepository` used only when the
/// app is launched with `--dart-define=USE_FAKE_VERIFICATION_BACKEND=true`
/// (see `.vscode/launch.json`'s "dev, offline demo" config and
/// `composition_root.dart`). Lets 003-escanear-documento's capture step and
/// 004-confirmar-datos's confirmation step be visually reviewed end-to-end
/// before a real verification backend exists — every submitted capture is
/// accepted, with the same sample extraction the UI reference uses.
///
/// A deliberate, explicitly-flagged *substitute* for
/// `DocumentVerificationRepositoryImpl`, mirroring `DevConsentRepository`'s
/// precedent — never a fallback path reachable from production wiring.
class DevDocumentVerificationRepository
    implements DocumentVerificationRepository {
  @override
  Future<Result<CaptureOutcome>> submit(Uint8List documentImageBytes) async {
    return const Result.ok(
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
            // Deliberately below the 0.95 high-confidence threshold, so the
            // demo also shows the "low-confidence edit accepted
            // immediately, no reverify" path (FR-005/Clarifications).
            ExtractedField.present(
              key: FieldKey.nationality,
              value: 'Colombiana',
              confidence: 0.6,
            ),
            ExtractedField.present(
              key: FieldKey.expiryDate,
              value: '2031-03-14',
              confidence: 0.95,
            ),
          ],
        ),
      ),
    );
  }
}
