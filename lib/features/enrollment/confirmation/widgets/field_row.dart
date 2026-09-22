import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../document_confirmation_view_state.dart';
import 'field_edit_field.dart';

/// One row of the confirmation screen: a read-only label+value by default,
/// with an explicit edit affordance (FR-003), an inline editor while
/// editing, and the field's correction status (FR-004–FR-007).
class FieldRow extends StatefulWidget {
  const FieldRow({
    required this.state,
    required this.label,
    required this.onEdit,
    super.key,
  });

  final FieldRowState state;
  final String label;
  final void Function(FieldKey key, String value) onEdit;

  @override
  State<FieldRow> createState() => _FieldRowState();
}

class _FieldRowState extends State<FieldRow> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.state.currentValue,
  );
  bool _isEditing = false;

  @override
  void didUpdateWidget(covariant FieldRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.currentValue != _controller.text &&
        widget.state.status is! FieldCorrectionReverifying) {
      _controller.text = widget.state.currentValue;
    }
    // Auto-close the editor once an edit resolves successfully or is
    // reverted back to the original value — the passenger's job here is
    // done, nothing left to confirm on this field.
    final status = widget.state.status;
    if (status is FieldCorrectionUnedited ||
        status is FieldCorrectionAcceptedLowConfidence ||
        status is FieldCorrectionAcceptedReverified) {
      _isEditing = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    widget.onEdit(widget.state.key, _controller.text);
  }

  void _cancel() {
    setState(() {
      _controller.text = widget.state.currentValue;
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final busy = widget.state.status is FieldCorrectionReverifying;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 2),
                    if (_isEditing)
                      FieldEditField(
                        fieldKey: widget.state.key,
                        controller: _controller,
                        enabled: !busy,
                      )
                    else
                      Text(
                        _displayValue(widget.state, l10n),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                  ],
                ),
              ),
              if (_isEditing) ...[
                if (busy)
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else ...[
                  IconButton(
                    onPressed: _submit,
                    icon: const Icon(Icons.check),
                    tooltip: l10n.confirmationSaveEditLabel,
                  ),
                  IconButton(
                    onPressed: _cancel,
                    icon: const Icon(Icons.close),
                    tooltip: l10n.confirmationCancelEditLabel,
                  ),
                ],
              ] else
                Semantics(
                  label: '${l10n.confirmationEditActionLabel} ${widget.label}',
                  button: true,
                  excludeSemantics: true,
                  child: IconButton(
                    onPressed: () => setState(() => _isEditing = true),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ),
            ],
          ),
          if (widget.state.status is FieldCorrectionInvalidFormat)
            _StatusMessage(text: l10n.confirmationInvalidFormatMessage, error: true),
          if (widget.state.status is FieldCorrectionUnresolved)
            _StatusMessage(text: l10n.confirmationUnresolvedMessage, error: true),
          if (busy)
            _StatusMessage(text: l10n.confirmationReverifyingLabel, error: false),
        ],
      ),
    );
  }

  String _displayValue(FieldRowState state, AppLocalizations l10n) {
    if (state.key == FieldKey.expiryDate) {
      final parsed = DateTime.tryParse(state.currentValue);
      if (parsed != null) {
        return DateFormat('d MMM y', 'es').format(parsed);
      }
    }
    return state.currentValue;
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.text, required this.error});

  final String text;
  final bool error;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Icon(
              error ? Icons.error_outline : Icons.info_outline,
              size: 14,
              color: error ? Theme.of(context).colorScheme.error : Colors.grey,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: error ? Theme.of(context).colorScheme.error : Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
