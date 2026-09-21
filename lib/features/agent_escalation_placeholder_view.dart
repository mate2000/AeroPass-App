import 'package:flutter/material.dart';

/// Navigation target only. The agent-escalation screen itself (screen 10)
/// is out of scope for this feature (spec.md Out of Scope) — this route
/// exists so FR-017's "alternative route into enrollment via the agent
/// path" has somewhere real to advance to.
class AgentEscalationPlaceholderView extends StatelessWidget {
  const AgentEscalationPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Escalamiento a agente (placeholder) — implementado por la '
            'pantalla 10.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
