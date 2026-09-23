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

  /// 008-identidad-activa: the success marker and "ACTIVA" badge.
  static const turquoise = Color(0xFF1DB9A6);

  /// 008-identidad-activa: the credential card's gradient, navy to blue.
  static const credentialCardGradientEnd = Color(0xFF1F5A9E);

  /// 009-reintento: the retry screen's warning icon and its tile —
  /// deliberately amber, never red (FR-002).
  static const amber = Color(0xFFE8A13A);
  static const amberTile = Color(0xFFFDF1DC);

  /// 011-error-tecnico: the service-failure icon and its tile. Deliberately
  /// neutral slate, neither amber nor red: the failure is not the
  /// passenger's (FR-001).
  static const slate = Color(0xFF475467);
  static const slateTile = Color(0xFFE4E8EE);
}
