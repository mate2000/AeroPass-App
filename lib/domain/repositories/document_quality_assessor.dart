import 'dart:typed_data';

import '../entities/capture_outcome.dart';

/// A pure, synchronous, on-device judgement over a captured frame's bytes
/// (research.md §2), per contracts/quality-assessor-port.md. Deliberately
/// not named `...Repository` — it has no state, no persistence, and isn't
/// a source of truth for anything; it's a domain service, not a
/// repository.
///
/// No `Future`, no network, no I/O (FR-006: assessed "on the device...
/// before anything is transmitted").
abstract class DocumentQualityAssessor {
  QualityAssessment assess(Uint8List frameBytes);
}
