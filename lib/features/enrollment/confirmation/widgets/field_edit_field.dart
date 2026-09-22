import 'package:flutter/material.dart';

import '../../../../domain/entities/extraction_result.dart';

/// The in-place editor for one field (FR-004/FR-006). A plain text input
/// for every field except [FieldKey.expiryDate], which opens a date picker
/// instead of free text entry — keeping the value's canonical ISO-8601 form
/// intact (004's research.md §3) rather than asking the passenger to type
/// a date by hand.
class FieldEditField extends StatelessWidget {
  const FieldEditField({
    required this.fieldKey,
    required this.controller,
    required this.enabled,
    super.key,
  });

  final FieldKey fieldKey;
  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (fieldKey == FieldKey.expiryDate) {
      return _DateEditField(controller: controller, enabled: enabled);
    }
    return TextField(
      controller: controller,
      enabled: enabled,
      autofocus: true,
      keyboardType: fieldKey == FieldKey.documentNumber
          ? TextInputType.text
          : TextInputType.name,
      decoration: const InputDecoration(isDense: true),
    );
  }
}

class _DateEditField extends StatelessWidget {
  const _DateEditField({required this.controller, required this.enabled});

  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final current = DateTime.tryParse(controller.text);
    return OutlinedButton.icon(
      onPressed: enabled ? () => _pickDate(context, current) : null,
      icon: const Icon(Icons.calendar_month, size: 18),
      label: Text(controller.text.isEmpty ? '—' : controller.text),
    );
  }

  Future<void> _pickDate(BuildContext context, DateTime? current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text =
          '${picked.year.toString().padLeft(4, '0')}-'
          '${picked.month.toString().padLeft(2, '0')}-'
          '${picked.day.toString().padLeft(2, '0')}';
    }
  }
}
