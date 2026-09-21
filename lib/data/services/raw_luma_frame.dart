import 'dart:typed_data';

/// A minimal, dependency-free raw grayscale raster: a 4-byte header (width,
/// height as little-endian `uint16`) followed by `width * height` luma
/// bytes (0-255), row-major.
///
/// This is the boundary format between [CameraCaptureService] and
/// `DocumentQualityAssessor` (research.md §2). It exists so
/// `DocumentQualityAssessor.assess()` can stay synchronous and
/// dependency-free, exactly as contracts/quality-assessor-port.md requires
/// ("no Future, no network, no I/O") — decoding a compressed image format
/// (JPEG/PNG) would require either an async `dart:ui` codec or a new
/// image-decoding package this feature does not add (plan.md: the
/// `camera` package is the one new dependency). `CameraCaptureService`
/// produces this format directly from the camera plugin's raw live-preview
/// frame planes (already-decoded pixel data, no codec involved), converted
/// to luma with a cheap per-pixel formula — see its own documentation.
class RawLumaFrame {
  const RawLumaFrame({
    required this.width,
    required this.height,
    required this.luma,
  });

  final int width;
  final int height;

  /// Row-major luma (brightness) samples, one byte (0-255) per pixel.
  final Uint8List luma;

  static const int headerLengthBytes = 4;

  Uint8List encode() {
    final bytes = Uint8List(headerLengthBytes + luma.length);
    final byteData = ByteData.sublistView(bytes);
    byteData.setUint16(0, width, Endian.little);
    byteData.setUint16(2, height, Endian.little);
    bytes.setRange(headerLengthBytes, bytes.length, luma);
    return bytes;
  }

  static RawLumaFrame decode(Uint8List bytes) {
    if (bytes.length < headerLengthBytes) {
      throw const FormatException('raw luma frame too short for header');
    }
    final byteData = ByteData.sublistView(bytes);
    final width = byteData.getUint16(0, Endian.little);
    final height = byteData.getUint16(2, Endian.little);
    final expectedLength = headerLengthBytes + width * height;
    if (bytes.length < expectedLength) {
      throw FormatException(
        'raw luma frame body shorter than width*height (expected '
        '$expectedLength, got ${bytes.length})',
      );
    }
    return RawLumaFrame(
      width: width,
      height: height,
      luma: Uint8List.sublistView(bytes, headerLengthBytes, expectedLength),
    );
  }

  int lumaAt(int x, int y) => luma[y * width + x];
}
