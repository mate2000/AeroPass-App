import 'package:clerk_flutter/clerk_flutter.dart' show ClerkAuthState;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app/app.dart';
import 'app/composition_root.dart';
import 'core/diagnostics.dart';
import 'core/happy_path_flags.dart';
import 'core/sentry_config.dart';
import 'data/auth/clerk_diagnostics.dart';
import 'data/auth/clerk_setup.dart';
import 'data/services/pinned_dio_factory.dart';

Future<void> main() async {
  // Constitution v1.4.0: a release build produced with a happy-path
  // relaxation flag enabled refuses to run rather than silently shipping
  // it (005-instrucciones-selfie, research.md §4).
  HappyPathFlags.assertReleaseSafe();

  // 015 research.md §4: the TLS trust anchors are assets, so they are loaded
  // before the composition root builds its pinned client.
  WidgetsFlutterBinding.ensureInitialized();
  final trustAnchors = await TrustAnchors.load(rootBundle);

  Future<Widget> buildApp() async {
    const Diagnostics().info('app_start', {
      'environment': SentryConfig.environment,
      'api_host': Uri.tryParse(const String.fromEnvironment('API_BASE_URL'))
          ?.host,
      'auth_mode': HappyPathFlags.authMode.name,
      'clerk_required': _clerkRequired,
      'synthetic_capture': HappyPathFlags.syntheticCapture,
      'biometric_mock': HappyPathFlags.biometricProviderMock,
    });
    // 015, the backend's authentication document: Clerk's embedded sign-in,
    // in the flavors that need it. It starts before the first frame, after
    // Sentry, so its start-up is in the production logs.
    final clerkAuthState = _clerkRequired
        ? await ClerkAuthState.create(
            config: aeroPassClerkConfig(
              publishableKey: _clerkPublishableKey,
              trustAnchors: trustAnchors,
            ),
          )
        : null;
    if (clerkAuthState != null) {
      _clerkDiagnostics = ClerkDiagnostics(clerkAuthState);
    }
    return CompositionRoot(
      trustAnchors: trustAnchors,
      clerkAuthState: clerkAuthState,
      child: const AeroPassApp(),
    );
  }

  if (!SentryConfig.isEnabled) {
    runApp(await buildApp());
    return;
  }

  await SentryFlutter.init(
    SentryConfig.configure,
    appRunner: () async => runApp(SentryWidget(child: await buildApp())),
  );

  if (SentryConfig.sendTestEvent) {
    try {
      throw StateError('Sentry test error from AeroPass app');
    } catch (exception, stackTrace) {
      await Sentry.captureException(exception, stackTrace: stackTrace);
    }
  }
}

/// The Clerk instance's publishable key (`pk_…`). It is public by design. A
/// secret key (`sk_…`) must never be in the app.
const _clerkPublishableKey = String.fromEnvironment('CLERK_PUBLISHABLE_KEY');

/// Sign-in is required in the Clerk flavors (staging, prod), and not in dev
/// (`test:` tokens) or the offline demo.
const _clerkRequired =
    HappyPathFlags.authMode == AuthMode.clerk &&
    _clerkPublishableKey != '' &&
    !HappyPathFlags.useFakeVerificationBackend;

/// Logs Clerk's errors and sign-in steps for the life of the app.
// ignore: unused_element
ClerkDiagnostics? _clerkDiagnostics;
