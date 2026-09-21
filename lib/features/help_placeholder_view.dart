import 'package:flutter/material.dart';

/// Navigation target only, pushed on top of the capture route (FR-013):
/// popping it returns the passenger to the capture step with the
/// enrollment session intact — the real help content is out of this
/// feature's scope.
class HelpPlaceholderView extends StatelessWidget {
  const HelpPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Ayuda (placeholder). Cierra esta pantalla para volver a la '
            'captura de documento.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
