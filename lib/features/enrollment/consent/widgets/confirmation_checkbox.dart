import 'package:flutter/material.dart';

/// The gate's blocking confirmation control (FR-004: unchecked on
/// presentation, never pre-selected or bundled). Both the checkbox itself
/// and a tap anywhere on the label toggle it — as two sibling tap targets,
/// not nested ones, so a single tap never double-toggles.
class ConfirmationCheckbox extends StatelessWidget {
  const ConfirmationCheckbox({
    required this.checked,
    required this.onChanged,
    required this.label,
    super.key,
  });

  final bool checked;
  final ValueChanged<bool> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    // MergeSemantics combines the Checkbox's own control semantics
    // (checked/enabled/tappable) with the adjacent label text into one
    // node, so assistive technology announces a single labeled control
    // rather than an unlabeled checkbox next to separate static text.
    return MergeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: checked,
            onChanged: (value) => onChanged(value ?? false),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(!checked),
              child: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
