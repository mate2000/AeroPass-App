import 'dart:convert';
import 'dart:typed_data';

import '../../core/happy_path_flags.dart';
import '../../core/synthetic_marker.dart';

/// Tiny JPEGs carrying a `MOCK:<marker>`, the Dart twin of the backend's
/// `adapters/fakes/images.py: make_image` (015 research.md §6).
///
/// The bytes are SOI (`FF D8`), one COM segment (`FF FE`, length, text) and
/// EOI (`FF D9`). That structure passes the backend's magic-number check
/// (`FF D8 FF`, V-02), and the mock reads the marker. No pixel is ever
/// produced, so no face can leave a dev or staging device.
///
/// Reachable only while `SYNTHETIC_CAPTURE` is on. The `const` flag lets the
/// compiler drop every caller from a prod build, and the release check
/// refuses the flag.
abstract final class SyntheticImageSource {
  static const _prefix = 'MOCK:';

  /// The document photo, the biometric reference.
  static Uint8List document() => _jpeg('documento');

  static Uint8List selfie(SyntheticSelfieMarker marker) => _jpeg(marker.name);

  static Uint8List _jpeg(String marker) {
    if (!HappyPathFlags.syntheticCapture && !_allowInTests) {
      throw StateError('synthetic capture is off');
    }
    final text = ascii.encode('$_prefix$marker');
    final length = text.length + 2;
    return Uint8List.fromList([
      0xFF, 0xD8, // SOI
      0xFF, 0xFE, (length >> 8) & 0xFF, length & 0xFF, ...text, // COM
      0xFF, 0xD9, // EOI
    ]);
  }

  /// Tests build these images without the flag. Nothing in `lib/` sets it.
  static bool _allowInTests = false;

  // ignore: avoid_setters_without_getters
  static set allowInTestsForTesting(bool allow) => _allowInTests = allow;
}
