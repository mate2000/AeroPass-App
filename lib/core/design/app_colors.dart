import 'package:flutter/material.dart';

/// Best-effort color values read off the AeroPass Figma welcome-screen
/// mockup (no exported design-token file exists yet — see the
/// Constitution's Development Workflow "Design fidelity" requirement).
/// Swap these for the real generated token source once one exists; treat
/// this file as that future source's only current caller.
abstract final class AppColors {
  /// Hero background and the primary action button.
  static const navy = Color(0xFF0B2A4A);

  /// Logo mark and illustration accent.
  static const teal = Color(0xFF17A576);

  /// Step-icon chip background.
  static const mintChipBackground = Color(0xFFDCF3E8);

  static const textPrimary = Color(0xFF10182B);
  static const textSecondary = Color(0xFF475467);

  /// "Ya tengo cuenta" link text. Chosen for AA contrast on white, not
  /// sampled from the mock (the link's exact hue wasn't legible in the
  /// screenshot).
  static const link = Color(0xFF1D4ED8);

  static const surface = Colors.white;
}
