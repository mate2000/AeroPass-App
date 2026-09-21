import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/design/app_colors.dart';
import '../l10n/generated/app_localizations.dart';
import 'router.dart';

/// The app's `MaterialApp`, theme, and localization wiring (FR-016: a
/// localization layer from this screen onward, defaulting to Spanish
/// (es-CO) and detecting the device's system language when supported —
/// handled by `AppLocalizations`'s generated locale-resolution alongside
/// `MaterialApp.router`'s own `localeListResolutionCallback` default,
/// which already prefers the first supported device locale).
///
/// Visual design tokens (color, typography, spacing, radii, motion
/// durations) are meant to come from a single generated token source
/// derived from the AeroPass design file per the Constitution's
/// Development Workflow — no generated token source exists yet, so
/// [AppColors] holds best-effort values read off the Figma mockup by hand.
/// Swapping in the generated token source is a follow-up, not part of this
/// feature's scope.
class AeroPassApp extends StatefulWidget {
  const AeroPassApp({super.key});

  @override
  State<AeroPassApp> createState() => _AeroPassAppState();
}

class _AeroPassAppState extends State<AeroPassApp> {
  late final GoRouter _router = buildAppRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
    );
  }
}

ThemeData _buildTheme(Brightness brightness) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.navy,
    brightness: brightness,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.surface,
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 26,
        height: 1.2,
        color: AppColors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(color: AppColors.textSecondary, height: 1.4),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.link,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
  );
}
