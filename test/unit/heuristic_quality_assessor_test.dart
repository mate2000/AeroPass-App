// Contract: DocumentQualityAssessor (contracts/quality-assessor-port.md),
// run against the real heuristic implementation with synthetic fixtures
// (test/fixtures/document_quality_fixtures.dart). No widget pump required
// — HeuristicQualityAssessor is a pure, synchronous function over bytes
// (research.md §2).
//
// Lenient by decision (2026-09-23): only plainly unusable captures are
// refused. A soft photo, a small reflection, a cropped edge or an odd shape
// passes, because the backend reads nothing from the document.
import 'package:aeropass_app/data/services/heuristic_quality_assessor.dart';
import 'package:aeropass_app/domain/entities/capture_outcome.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/document_quality_fixtures.dart';

void main() {
  final assessor = const HeuristicQualityAssessor();

  group('passes', () {
    for (final (name, fixture) in [
      ('1. a sharp, well-framed cédula', sharpWellFramedCedulaFixture),
      ('2. a soft (blurred) photo', heavilyBlurredFixture),
      ('3. a photo with a reflection patch', largeGlarePatchFixture),
      ('4. a document cropped at the frame edge', croppedAtEdgeFixture),
      ('5. a document of an unexpected shape', wrongShapeFixture),
    ]) {
      test(name, () {
        expect(assessor.assess(fixture()), const QualityAssessment.usable());
      });
    }
  });

  group('refused', () {
    test('6. below the minimum resolution -> lowResolution', () {
      expect(
        assessor.assess(belowMinimumResolutionFixture()),
        const QualityAssessment.rejected(
          reason: QualityRejectionReason.lowResolution,
        ),
      );
    });

    test('7. a frame with no detail (covered lens) -> blur', () {
      expect(
        assessor.assess(blankFrameFixture()),
        const QualityAssessment.rejected(reason: QualityRejectionReason.blur),
      );
    });

    test('8. a frame mostly blown out by light -> glare', () {
      expect(
        assessor.assess(mostlyBlownOutFixture()),
        const QualityAssessment.rejected(reason: QualityRejectionReason.glare),
      );
    });
  });
}
