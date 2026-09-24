import 'package:clerk_auth/clerk_auth.dart' as clerk show ClerkError;
import 'package:clerk_flutter/clerk_flutter.dart'
    show ClerkAuth, ClerkAuthState, ClerkErrorListener;
// The SDK's own error wording, which its listener uses; not exported.
// ignore: implementation_imports
import 'package:clerk_flutter/src/utils/localization_extensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/design/app_colors.dart';
import '../core/diagnostics.dart';
import '../l10n/generated/app_localizations.dart';
import '../core/happy_path_flags.dart';
import 'demo_ribbon.dart';
import 'router.dart';
import 'session_gate.dart';

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
  // 015: the session gate, when sign-in is required, re-runs the redirect.
  late final GoRouter _router = buildAppRouter(
    refreshListenable: context.read<SessionGate?>(),
  )..routerDelegate.addListener(_logRoute);

  String? _lastPath;

  /// Foreground/background changes, so a trail shows whether the app was
  /// left mid-flow (a paused app also pauses its timers and requests).
  late final AppLifecycleListener _lifecycle = AppLifecycleListener(
    onStateChange: (state) =>
        const Diagnostics().info('app_lifecycle', {'state': state.name}),
  );

  @override
  void initState() {
    super.initState();
    _lifecycle;
  }

  /// Each screen change, by path only (a query can carry `next`), so a
  /// production trail shows where the passenger is.
  void _logRoute() {
    final path = _router.routerDelegate.currentConfiguration.uri.path;
    if (path == _lastPath) return;
    _lastPath = path;
    const Diagnostics().info('route', {'path': path});
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _router.routerDelegate.removeListener(_logRoute);
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
      // 015 FR-020: every screen says the biometrics are simulated while
      // the mock provider is declared.
      builder: (context, child) {
        var page = child ?? const SizedBox.shrink();
        // 015: Clerk's embedded sign-in needs its auth state above every
        // route, and its error listener so errors are shown, not thrown.
        final clerk = context.read<ClerkAuthState?>();
        if (clerk != null) {
          page = ClerkAuth(
            authState: clerk,
            child: ClerkErrorListener(handler: showClerkError, child: page),
          );
        }
        return HappyPathFlags.biometricProviderMock
            ? DemoRibbon(child: page)
            : page;
      },
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

/// Shows a Clerk error as the SDK's listener would, except `session_exists`
/// ("You're already signed in"). That one comes from a second submit after
/// the sign-in has already succeeded, and the router is already leaving the
/// sign-in screen. Every error is still logged by `ClerkDiagnostics`.
void showClerkError(BuildContext context, clerk.ClerkError error) {
  if (isAlreadySignedIn(error)) return;
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
    SnackBar(
      content: Text(error.localizedMessage(ClerkAuth.localizationsOf(context))),
    ),
  );
}

/// Whether [error] only says a session already exists.
bool isAlreadySignedIn(clerk.ClerkError error) {
  final codes = [...?error.errors?.errors].map((e) => e.code).nonNulls;
  return codes.isNotEmpty && codes.every((code) => code == 'session_exists');
}
