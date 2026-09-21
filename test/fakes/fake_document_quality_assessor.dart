import 'dart:typed_data';

import 'package:aeropass_app/domain/entities/capture_outcome.dart';
import 'package:aeropass_app/domain/repositories/document_quality_assessor.dart';

/// Returns a pre-scripted `QualityAssessment` regardless of input bytes,
/// per contracts/quality-assessor-port.md — for widget/unit tests that only
/// care about how `CaptureViewModel` reacts to each outcome, not the real
/// heuristic's behavior.
class FakeDocumentQualityAssessor implements DocumentQualityAssessor {
  QualityAssessment _next = const QualityAssessment.usable();
  int assessCallCount = 0;
  Uint8List? lastAssessedBytes;

  /// Sets the value the next (and subsequent, until re-scripted) call to
  /// [assess] returns.
  void scriptAssessment(QualityAssessment assessment) {
    _next = assessment;
  }

  @override
  QualityAssessment assess(Uint8List frameBytes) {
    assessCallCount++;
    lastAssessedBytes = frameBytes;
    return _next;
  }
}
