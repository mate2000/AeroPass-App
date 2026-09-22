import 'package:flutter/material.dart';

/// Navigation target only. The verification-progress screen itself
/// (screen 07) is out of scope for this feature (spec.md Out of Scope) —
/// this route exists so `LivenessCaptureViewModel`'s successful-outcome
/// path (FR-011) has somewhere real to advance to.
class VerificationProgressPlaceholderView extends StatelessWidget {
  const VerificationProgressPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Verificación en progreso (placeholder) — implementado por la '
            'pantalla 07.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
