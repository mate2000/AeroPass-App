import 'package:sentry_flutter/sentry_flutter.dart';

import '../../core/clock.dart';
import '../../domain/entities/enrollment_attempt_id.dart';

/// Writes one distribution metric. Injectable so tests run without the SDK.
typedef DistributionWriter = void Function(
  String name,
  num value, {
  String? unit,
  Map<String, SentryAttribute>? attributes,
});

/// Times each enrollment attempt from its first document-capture screen to
/// the active credential, for the p90 of KR A1.4 (015 research §3).
///
/// Start times live in memory only. An attempt resumed after a restart has
/// no start here, so it emits no duration: storing the start would need a
/// Principle I amendment, and its wall-clock time would include hours with
/// the app closed (spec FR-007).
class EnrollmentDurationTracker {
  EnrollmentDurationTracker({
    required Clock clock,
    DistributionWriter? writeDistribution,
  }) : _clock = clock,
       _writeDistribution = writeDistribution ?? _writeToSentry;

  static const metricName = 'enrollment.duration';
  static const _unit = 'millisecond';

  final Clock _clock;
  final DistributionWriter _writeDistribution;
  final _startedAt = <EnrollmentAttemptId, DateTime>{};

  /// On `capture_step_entered`: only the first one of an attempt counts.
  void attemptStarted(EnrollmentAttemptId? attemptId) {
    if (attemptId == null) return;
    _startedAt.putIfAbsent(attemptId, _clock.now);
  }

  /// On `credential_activated_shown`.
  void attemptCompleted(EnrollmentAttemptId? attemptId) {
    final startedAt = _startedAt.remove(attemptId);
    if (startedAt == null) return;
    _writeDistribution(
      metricName,
      _clock.now().difference(startedAt).inMilliseconds,
      unit: _unit,
      attributes: {'aeropass.resumed': SentryAttribute.bool(false)},
    );
  }

  static void _writeToSentry(
    String name,
    num value, {
    String? unit,
    Map<String, SentryAttribute>? attributes,
  }) => Sentry.metrics.distribution(
    name,
    value,
    unit: unit,
    attributes: attributes,
  );
}
