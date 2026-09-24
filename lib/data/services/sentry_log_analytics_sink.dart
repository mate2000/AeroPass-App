import 'dart:async' show unawaited;

import 'package:sentry_flutter/sentry_flutter.dart';

import '../../core/analytics_session.dart';
import 'analytics_sink.dart';
import 'current_enrollment_attempt.dart';
import 'enrollment_duration_tracker.dart';
import 'sentry_privacy_filter.dart';

/// Writes one Sentry log with [body] and [attributes]. Injectable so tests
/// run without the SDK.
typedef SentryLogWriter = void Function(
  String body,
  Map<String, SentryAttribute> attributes,
);

/// Sends each funnel event to Sentry as one structured `info` log
/// (015 research §1, contracts/telemetry-events.md §1). The privacy filter
/// then applies the attribute allowlist before anything leaves the device.
class SentryLogAnalyticsSink implements AnalyticsSink {
  SentryLogAnalyticsSink({
    required AnalyticsSessionId sessionId,
    required CurrentEnrollmentAttempt attempt,
    SentryLogWriter? writeLog,
    EnrollmentDurationTracker? durationTracker,
  }) : _sessionId = sessionId,
       _attempt = attempt,
       _writeLog = writeLog ?? _writeToSentry,
       _durationTracker = durationTracker;

  final AnalyticsSessionId _sessionId;
  final CurrentEnrollmentAttempt _attempt;
  final SentryLogWriter _writeLog;
  final EnrollmentDurationTracker? _durationTracker;

  static const _attributePrefix = 'aeropass.';

  /// The funnel's first and last events (spec FR-007).
  static const enrollmentStartEvent = 'capture_step_entered';
  static const enrollmentEndEvent = 'credential_activated_shown';

  /// `attemptNumber` → `aeropass.attempt_number`: the one naming rule shared
  /// by this sink and the allowlist contract test.
  static String attributeName(String payloadKey) =>
      _attributePrefix +
      payloadKey.replaceAllMapped(
        RegExp('[A-Z]'),
        (match) => '_${match.group(0)!.toLowerCase()}',
      );

  @override
  void record(String eventName, Map<String, Object?> payload) {
    _writeLog(eventName, {
      SentryPrivacyFilter.eventAttribute: SentryAttribute.string(eventName),
      '${_attributePrefix}session_id': SentryAttribute.string(_sessionId.value),
      '${_attributePrefix}enrollment_attempt_id': ?_toAttribute(
        _attempt.value?.value,
      ),
      for (final entry in payload.entries)
        attributeName(entry.key): ?_toAttribute(entry.value),
    });
    switch (eventName) {
      case enrollmentStartEvent:
        _durationTracker?.attemptStarted(_attempt.value);
      case enrollmentEndEvent:
        _durationTracker?.attemptCompleted(_attempt.value);
    }
  }

  /// Only the value types the emitter's payloads use; anything else is left
  /// out rather than stringified.
  static SentryAttribute? _toAttribute(Object? value) => switch (value) {
    final String v => SentryAttribute.string(v),
    final bool v => SentryAttribute.bool(v),
    final int v => SentryAttribute.int(v),
    final double v => SentryAttribute.double(v),
    final Enum v => SentryAttribute.string(v.name),
    _ => null,
  };

  static void _writeToSentry(
    String body,
    Map<String, SentryAttribute> attributes,
  ) {
    final pending = Sentry.logger.info(body, attributes: attributes);
    if (pending is Future<void>) unawaited(pending);
  }
}
