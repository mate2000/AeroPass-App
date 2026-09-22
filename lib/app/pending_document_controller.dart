import 'package:flutter/foundation.dart';

import '../domain/entities/extraction_result.dart';

/// App-process-scoped, in-memory holder of the document image bytes and
/// extraction result an accepted capture (003-escanear-documento) hands
/// forward to data confirmation (004-confirmar-datos) — mirroring
/// `EnrollmentSessionController`'s shape and lifecycle rules exactly
/// (004's research.md §1).
///
/// **Never persisted, never logged.** Nothing here survives the app process
/// being terminated — the same rule that governs the raw capture bytes
/// themselves (FR-011). Cleared on: confirmation recorded, re-scan,
/// explicit back navigation, and (implicitly) app termination.
class PendingDocumentController extends ChangeNotifier {
  Uint8List? _documentImageBytes;
  ExtractionResult? _extraction;

  Uint8List? get documentImageBytes => _documentImageBytes;
  ExtractionResult? get extraction => _extraction;

  /// True once a capture has handed off its bytes and extraction, and until
  /// [clear] is called.
  bool get hasPendingDocument => _documentImageBytes != null && _extraction != null;

  void set(Uint8List documentImageBytes, ExtractionResult extraction) {
    _documentImageBytes = documentImageBytes;
    _extraction = extraction;
    notifyListeners();
  }

  void clear() {
    _documentImageBytes = null;
    _extraction = null;
    notifyListeners();
  }
}
