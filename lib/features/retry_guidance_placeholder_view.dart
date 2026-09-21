import 'package:flutter/material.dart';

/// Navigation target only. The retry-guidance screen itself (screen 09)
/// is out of scope for this feature (spec.md Out of Scope) — this route
/// exists so `CaptureViewModel`'s attempt-limit-reached path (FR-009) has
/// somewhere real to advance to.
class RetryGuidancePlaceholderView extends StatelessWidget {
  const RetryGuidancePlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Guía de reintento (placeholder) — implementado por la '
            'pantalla 09.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
