import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

/// 015 DEC-03: with no airline integration, the passenger types the flight
/// code, and the pass is issued for it. The code is checked on the device
/// against the backend's format before anything is sent (FR-010, V-06).
class FlightCodeEntry extends StatefulWidget {
  const FlightCodeEntry({
    required this.initialValue,
    required this.invalid,
    required this.enabled,
    required this.onChanged,
    required this.onSubmit,
    super.key,
  });

  final String initialValue;
  final bool invalid;

  /// False while the credential is not confirmed and active. The strip
  /// above already says why.
  final bool enabled;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  @override
  State<FlightCodeEntry> createState() => _FlightCodeEntryState();
}

class _FlightCodeEntryState extends State<FlightCodeEntry> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.tripsFlightCodeHeading,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('flight-code-field'),
          controller: _controller,
          enabled: widget.enabled,
          textCapitalization: TextCapitalization.characters,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.go,
          onChanged: widget.onChanged,
          onSubmitted: (_) => widget.onSubmit(),
          decoration: InputDecoration(
            labelText: l10n.tripsFlightCodeLabel,
            hintText: l10n.tripsFlightCodeHint,
            errorText: widget.invalid ? l10n.tripsFlightCodeInvalid : null,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          key: const Key('show-pass'),
          onPressed: widget.enabled ? widget.onSubmit : null,
          child: Text(l10n.tripsShowPass),
        ),
      ],
    );
  }
}
