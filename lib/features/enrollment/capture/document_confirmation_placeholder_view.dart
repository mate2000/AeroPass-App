import 'package:flutter/material.dart';

/// Navigation target only. The data-confirmation screen itself (screen 04)
/// is out of scope for this feature (spec.md Out of Scope: "Reviewing or
/// correcting the extracted data, specified with screen 04") — this route
/// exists purely so `CaptureViewModel`'s accepted-capture path has
/// somewhere real to advance to.
class DocumentConfirmationPlaceholderView extends StatelessWidget {
  const DocumentConfirmationPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Confirmación de datos (placeholder) — implementado por la '
            'pantalla 04.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
