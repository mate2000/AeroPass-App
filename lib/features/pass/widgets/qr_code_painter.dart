import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

import '../../../core/design/app_colors.dart';

/// Draws a pass payload as a QR code (014-qr-pase research.md §3), at error
/// correction level H so the AeroPass mark in the centre does not break
/// decoding. The payload is only ever drawn: it is never exposed to
/// semantics, logs or events (FR-015).
class QrCodeView extends StatelessWidget {
  const QrCodeView({
    required this.payload,
    required this.semanticLabel,
    super.key,
  });

  final String payload;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final image = QrImage(
      QrCode(
        payload: QrPayload.fromString(payload),
        errorCorrectLevel: QrErrorCorrectLevel.high,
      ),
    );
    return Semantics(
      label: semanticLabel,
      image: true,
      excludeSemantics: true,
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(child: CustomPaint(painter: _QrPainter(image))),
            FractionallySizedBox(
              widthFactor: 0.2,
              heightFactor: 0.2,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const FittedBox(
                      child: Icon(Icons.navigation, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  _QrPainter(this.image);

  final QrImage image;

  /// Four modules of quiet zone, as the QR standard requires.
  static const _quietModules = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final count = image.moduleCount + 2 * _quietModules;
    final module = size.shortestSide / count;
    final dark = Paint()..color = AppColors.navy;
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    for (var row = 0; row < image.moduleCount; row++) {
      for (var col = 0; col < image.moduleCount; col++) {
        if (!image.isDark(row, col)) continue;
        canvas.drawRect(
          Rect.fromLTWH(
            (col + _quietModules) * module,
            (row + _quietModules) * module,
            module + 0.5,
            module + 0.5,
          ),
          dark,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_QrPainter oldDelegate) =>
      !identical(oldDelegate.image, image);
}
