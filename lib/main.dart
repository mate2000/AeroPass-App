import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app/app.dart';
import 'app/composition_root.dart';
import 'core/happy_path_flags.dart';
import 'core/sentry_config.dart';

Future<void> main() async {
  // Constitution v1.4.0: a release build produced with a happy-path
  // relaxation flag enabled refuses to run rather than silently shipping
  // it (005-instrucciones-selfie, research.md §4).
  HappyPathFlags.assertReleaseSafe();

  const app = CompositionRoot(child: AeroPassApp());

  if (!SentryConfig.isEnabled) {
    runApp(app);
    return;
  }

  await SentryFlutter.init(
    SentryConfig.configure,
    appRunner: () => runApp(SentryWidget(child: app)),
  );

  if (SentryConfig.sendTestEvent) {
    try {
      throw StateError('Sentry test error from AeroPass app');
    } catch (exception, stackTrace) {
      await Sentry.captureException(exception, stackTrace: stackTrace);
    }
  }
}
