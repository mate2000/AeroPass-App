import 'package:camera/camera.dart' show CameraPreview;
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:sentry_flutter/sentry_flutter.dart';

import '../data/services/sentry_privacy_filter.dart';
import '../features/enrollment/liveness/widgets/liveness_oval_overlay.dart';
import '../features/enrollment/selfie/widgets/selfie_frame_preview.dart';
import '../features/pass/widgets/qr_code_painter.dart';

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

  /// 015 contracts/privacy-filter.md: the one gate every Sentry output
  /// passes through.
  static const privacyFilter = SentryPrivacyFilter(
    alertEventTag: alertEventTag,
  );

  // 015 research §7: sampling rates per environment, read from the env files.
  // The defaults are the prod values, used when a variable is absent.
  static const double defaultTracesSampleRate = 0.2;
  static const double defaultProfilesSampleRate = 0.2;
  static const double defaultReplaySessionSampleRate = 0.1;
  static const double defaultReplayOnErrorSampleRate = 1.0;

  static const String _tracesSampleRateValue = String.fromEnvironment(
    'SENTRY_TRACES_SAMPLE_RATE',
  );
  static const String _profilesSampleRateValue = String.fromEnvironment(
    'SENTRY_PROFILES_SAMPLE_RATE',
  );
  static const String _replaySessionSampleRateValue = String.fromEnvironment(
    'SENTRY_REPLAY_SESSION_SAMPLE_RATE',
  );
  static const String _replayOnErrorSampleRateValue = String.fromEnvironment(
    'SENTRY_REPLAY_ON_ERROR_SAMPLE_RATE',
  );

  static double get tracesSampleRate => parseSampleRate(
    _tracesSampleRateValue,
    fallback: defaultTracesSampleRate,
  );

  static double get profilesSampleRate => parseSampleRate(
    _profilesSampleRateValue,
    fallback: defaultProfilesSampleRate,
  );

  static double get replaySessionSampleRate => parseSampleRate(
    _replaySessionSampleRateValue,
    fallback: defaultReplaySessionSampleRate,
  );

  static double get replayOnErrorSampleRate => parseSampleRate(
    _replayOnErrorSampleRateValue,
    fallback: defaultReplayOnErrorSampleRate,
  );

  /// Sentry options: session replay, tracing, profiling, logs, session
  /// tracking and native crash tombstones.
  ///
  /// This app shows ID documents and selfies. Replay keeps its default
  /// masking of all text and images; the live camera preview and the
  /// widgets drawn with a CustomPainter that show passenger or pass data
  /// (the QR, the selfie frame and the liveness oval) are masked too, so
  /// none of them appears in a recording (015 research §6). Screenshots on
  /// errors stay off for the same reason.
  static void configure(SentryFlutterOptions options) {
    options
      ..dsn = dsn
      ..environment = environment
      ..replay.sessionSampleRate = replaySessionSampleRate
      ..replay.onErrorSampleRate = replayOnErrorSampleRate
      ..enableTombstone = true
      ..tracesSampleRate = tracesSampleRate
      // Profiling is experimental in the SDK but requested for this app.
      // ignore: experimental_member_use
      ..profilesSampleRate = profilesSampleRate
      ..enableAutoSessionTracking = true
      // 015 research §8: critical screens report when their content is ready.
      ..enableTimeToFullDisplayTracing = true
      // 015 FR-002: no IP address or user data on any event (Principle VII).
      ..sendDefaultPii = false
      ..enableLogs = true
      ..diagnosticLevel = SentryLevel.error
      ..attachScreenshot = false
      ..beforeSend = privacyFilter.beforeSend
      ..beforeSendTransaction = privacyFilter.beforeSendTransaction
      ..beforeBreadcrumb = privacyFilter.beforeBreadcrumb
      ..beforeSendLog = privacyFilter.beforeSendLog
      ..beforeSendMetric = privacyFilter.beforeSendMetric;
    // Experimental API, but the only way to hide these widgets in replays.
    options.privacy
      // ignore: experimental_member_use
      ..mask<CameraPreview>()
      // ignore: experimental_member_use
      ..mask<QrCodeView>()
      // ignore: experimental_member_use
      ..mask<SelfieFramePreview>()
      // ignore: experimental_member_use
      ..mask<LivenessOvalOverlay>();
  }
}

/// Reads a sampling rate from an env-file value. An empty value means the
/// variable is absent and [fallback] applies. A value that is not a number
/// in [0, 1] is a configuration mistake: it fails loudly in debug builds and
/// falls back quietly in release builds, where a wrong rate must not stop
/// the app.
double parseSampleRate(String value, {required double fallback}) {
  if (value.isEmpty) return fallback;
  final rate = double.tryParse(value);
  final isValid = rate != null && rate >= 0 && rate <= 1;
  assert(isValid, 'Sentry sample rate must be a number in [0, 1]: "$value"');
  return isValid ? rate : fallback;
}
