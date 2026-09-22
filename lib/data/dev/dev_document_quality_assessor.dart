import 'dart:typed_data';

import '../../domain/entities/capture_outcome.dart';
import '../../domain/repositories/document_quality_assessor.dart';

/// A `DocumentQualityAssessor` used only when the app is launched with
/// `--dart-define=USE_FAKE_VERIFICATION_BACKEND=true` (see
/// `.vscode/launch.json`'s "dev, offline demo" config and
/// `composition_root.dart`). Always reports the frame as usable, regardless
/// of what the camera is actually pointed at — the real
/// `HeuristicQualityAssessor` runs on-device and rejects anything that
/// isn't framed like an actual cédula/passport (blur, glare, wrong
/// document, low resolution), which would otherwise make it impossible to
/// reach 004-confirmar-datos's confirmation screen without a physical
/// document in hand.
///
/// A deliberate, explicitly-flagged *substitute* for
/// `HeuristicQualityAssessor`, mirroring `DevConsentRepository`'s
/// precedent — the on-device quality gate itself is untouched by this flag
/// in a real build.
class DevDocumentQualityAssessor implements DocumentQualityAssessor {
  const DevDocumentQualityAssessor();

  @override
  QualityAssessment assess(Uint8List frameBytes) {
    return const QualityAssessment.usable();
  }
}
