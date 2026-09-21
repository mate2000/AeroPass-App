import 'package:flutter/material.dart';

/// Navigation target only — the trips-and-pass feature itself is out of
/// scope for spec 001-bienvenida (see spec.md Out of Scope). A passenger
/// holding a valid credential is routed here past the welcome screen
/// (FR-005); this view exists purely so that route resolves to something
/// during this feature's implementation.
class TripsPlaceholderView extends StatelessWidget {
  const TripsPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Trips (placeholder) — implemented by the trips-and-pass feature.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
