import 'dart:async' show unawaited;

import 'package:sentry_flutter/sentry_flutter.dart';

/// Marks the current screen as fully displayed, for Sentry's time to full
/// display (015 research §8). Injected at the route boundary so no view
/// reaches Sentry itself (Principle IX).
abstract interface class FullDisplayReporter {
  void reportFullyDisplayed();
}

class SentryFullDisplayReporter implements FullDisplayReporter {
  const SentryFullDisplayReporter();

  @override
  void reportFullyDisplayed() {
    final display = SentryFlutter.currentDisplay();
    if (display != null) unawaited(display.reportFullyDisplayed());
  }
}

/// Used when Sentry is not configured.
class NoopFullDisplayReporter implements FullDisplayReporter {
  const NoopFullDisplayReporter();

  @override
  void reportFullyDisplayed() {}
}
