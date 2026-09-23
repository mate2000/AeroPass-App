// Contract: DocumentQualityAssessor (contracts/quality-assessor-port.md),
// run against the real heuristic implementation with synthetic fixtures
// (test/fixtures/document_quality_fixtures.dart). No widget pump required
// — HeuristicQualityAssessor is a pure, synchronous function over bytes
// (research.md §2).
import 'package:aeropass_app/data/services/heuristic_quality_assessor.dart';
import 'package:aeropass_app/domain/entities/capture_outcome.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/document_quality_fixtures.dart';

void main() {
  final assessor = const HeuristicQualityAssessor();

  test(
    '1. sharp, well-lit, correctly-framed cédula-shaped fixture -> usable',
    () {
      final result = assessor.assess(sharpWellFramedCedulaFixture());
      expect(result, const QualityAssessment.usable());
    },
  );

  test('2. heavily blurred fixture -> rejected(blur)', () {
    final result = assessor.assess(heavilyBlurredFixture());
    expect(
      result,
      const QualityAssessment.rejected(reason: QualityRejectionReason.blur),
    );
  });

  test(
    '3. fixture with a large blown-out highlight region -> rejected(glare)',
    () {
      final result = assessor.assess(largeGlarePatchFixture());
      expect(
        result,
        const QualityAssessment.rejected(reason: QualityRejectionReason.glare),
      );
    },
  );

  test('4. fixture cropped at the frame edge -> rejected(framing)', () {
    final result = assessor.assess(croppedAtEdgeFixture());
    expect(
      result,
      const QualityAssessment.rejected(reason: QualityRejectionReason.framing),
    );
  });

  test('5. fixture with a shape matching neither accepted document ratio -> '
      'rejected(wrongDocument)', () {
    final result = assessor.assess(wrongShapeFixture());
    expect(
      result,
      const QualityAssessment.rejected(
        reason: QualityRejectionReason.wrongDocument,
      ),
    );
  });

  test(
    '6. fixture below the minimum resolution floor -> rejected(lowResolution)',
    () {
      final result = assessor.assess(belowMinimumResolutionFixture());
      expect(
        result,
        const QualityAssessment.rejected(
          reason: QualityRejectionReason.lowResolution,
        ),
      );
    },
  );
}
