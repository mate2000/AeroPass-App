import 'package:camera/camera.dart' show CameraPreview;
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:sentry_flutter/sentry_flutter.dart';

/// Build-time Sentry settings, read from the env files in `env/` via
/// `--dart-define-from-file` (Constitution Principle X: "no magic
/// values"). With no [dsn] defined the SDK stays disabled, so plain runs
/// and tests never report to Sentry.
abstract final class SentryConfig {
  /// Project DSN from Sentry > Project Settings > Client Keys.
  static const String dsn = String.fromEnvironment('SENTRY_DSN');

  /// Environment tag shown in Sentry (e.g. `dev`, `prod`).
  static const String environment = String.fromEnvironment(
    'SENTRY_ENVIRONMENT',
    defaultValue: kReleaseMode ? 'prod' : 'dev',
  );

  /// When true, one test exception is reported at startup to verify the
  /// setup. Leave off in normal builds.
  static const bool sendTestEvent = bool.fromEnvironment(
    'SENTRY_SEND_TEST_EVENT',
  );

  static bool get isEnabled => dsn.isNotEmpty;

  /// 011-error-tecnico FR-006: true only once an alert rule exists in the
  /// Sentry project that notifies the team on `failure_class:service`. It is
  /// a statement of fact about the operations setup, set in an env file, and
  /// false by default. The "Nuestro equipo ya fue notificado." sentence is
  /// shown only when this and [isEnabled] are both true.
  static const bool alertRuleConfirmed = bool.fromEnvironment(
    'SENTRY_ALERT_RULE_CONFIRMED',
  );

  /// The tag that marks 011's operational alert events.
  static const String alertEventTag = 'failure_class';

  // Sampling rates (0.0 to 1.0), named here rather than inlined
  // (Constitution Principle X: "no magic values").
  static const double _replaySessionSampleRate = 0.6;
  static const double _replayOnErrorSampleRate = 1.0;
  static const double _tracesSampleRate = 0.9;
  static const double _profilesSampleRate = 1.0;

  /// Sentry options: session replay, tracing, profiling, logs, session
  /// tracking and native crash tombstones.
  ///
  /// This app shows ID documents and selfies. Replay keeps its default
  /// masking of all text and images, and the live camera preview is masked
  /// too, so document and face images never appear in a recording.
  /// Screenshots on errors stay off for the same reason.
  static void configure(SentryFlutterOptions options) {
    options
      ..dsn = dsn
      ..environment = environment
      ..replay.sessionSampleRate = _replaySessionSampleRate
      ..replay.onErrorSampleRate = _replayOnErrorSampleRate
      ..enableTombstone = true
      ..tracesSampleRate = _tracesSampleRate
      // Profiling is experimental in the SDK but requested for this app.
      // ignore: experimental_member_use
      ..profilesSampleRate = _profilesSampleRate
      ..enableAutoSessionTracking = true
      ..sendDefaultPii = true
      ..enableLogs = true
      ..diagnosticLevel = SentryLevel.error
      ..attachScreenshot = false
      ..beforeSend = scrubEvent
      ..beforeBreadcrumb = dropHttpBreadcrumb;
    // Experimental API, but the only way to hide the camera feed in replays.
    // ignore: experimental_member_use
    options.privacy.mask<CameraPreview>();
  }
}

/// 015 FR-017, research.md §13: no event carries a request (URL, headers,
/// body) or an HTTP breadcrumb, whatever its kind. The `Authorization`
/// header, a token or a registration form can then never reach Sentry, even
/// if an HTTP integration is added later. 011's alert stripping applies on
/// top.
SentryEvent? scrubEvent(SentryEvent event, Hint hint) {
  event
    ..request = null
    ..breadcrumbs = event.breadcrumbs
        ?.where((crumb) => !_isHttp(crumb))
        .toList();
  return stripAlertEventPii(event, hint);
}

/// 015 FR-017: an HTTP breadcrumb is dropped before it is recorded.
Breadcrumb? dropHttpBreadcrumb(Breadcrumb? crumb, Hint hint) =>
    crumb == null || _isHttp(crumb) ? null : crumb;

bool _isHttp(Breadcrumb crumb) =>
    crumb.type == 'http' || (crumb.category?.startsWith('http') ?? false);

/// 011-error-tecnico FR-018: an operational alert event carries no personal
/// data, even though `sendDefaultPii` is on for the rest of the app. Events
/// without the alert tag pass through unchanged.
///
/// `sendDefaultPii = true` still applies to every other event, including
/// crash reports; research.md §7 records that as a release gate for the
/// user to decide.
SentryEvent? stripAlertEventPii(SentryEvent event, Hint hint) {
  if (event.tags?[SentryConfig.alertEventTag] == null) return event;
  event
    ..user = null
    ..request = null
    ..breadcrumbs = null;
  return event;
}
