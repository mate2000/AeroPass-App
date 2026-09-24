// 015 T031 (research.md §6, FR-018): synthetic marker images are valid
// enough for the backend's format check, carry the mock's marker, and are
// unreachable while SYNTHETIC_CAPTURE is off.
import 'dart:convert';

import 'package:aeropass_app/core/synthetic_marker.dart';
import 'package:aeropass_app/data/dev/synthetic_image_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => SyntheticImageSource.allowInTestsForTesting = false);

  test('off by default: no synthetic image can be produced', () {
    expect(SyntheticImageSource.document, throwsStateError);
    expect(
      () => SyntheticImageSource.selfie(SyntheticSelfieMarker.ok),
      throwsStateError,
    );
  });

  group('when allowed', () {
    setUp(() => SyntheticImageSource.allowInTestsForTesting = true);

    test("starts with the JPEG magic the backend sniffs, FF D8 FF", () {
      final bytes = SyntheticImageSource.document();
      expect(bytes.sublist(0, 3), [0xFF, 0xD8, 0xFF]);
      expect(bytes.sublist(bytes.length - 2), [0xFF, 0xD9]);
    });

    test('carries MOCK:<marker> for every marker and the document', () {
      expect(
        latin1.decode(SyntheticImageSource.document()),
        contains('MOCK:documento'),
      );
      for (final marker in SyntheticSelfieMarker.values) {
        expect(
          latin1.decode(SyntheticImageSource.selfie(marker)),
          contains('MOCK:${marker.name}'),
        );
      }
    });

    test('the COM segment length is the text plus its two length bytes', () {
      final bytes = SyntheticImageSource.selfie(SyntheticSelfieMarker.spoof);
      final length = (bytes[4] << 8) | bytes[5];
      expect(length, 'MOCK:spoof'.length + 2);
      expect(bytes.length, 2 + 2 + length + 2);
    });
  });
}
