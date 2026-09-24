import 'dart:developer' as developer;

import '../../core/analytics_session.dart';
import '../../core/clock.dart';

/// One destination for the funnel events built by `LoggingAnalyticsEmitter`
/// (015 research §11). The emitter defines each event name and payload once;
/// every sink receives the same pair.
///
/// Implementations must return immediately: they never throw and never wait
/// for the network (015 FR-012).
abstract interface class AnalyticsSink {
  void record(String eventName, Map<String, Object?> payload);
}

/// The structured on-device log line every event has written since 001,
/// keyed by the in-memory [AnalyticsSessionId].
class DeveloperLogAnalyticsSink implements AnalyticsSink {
  const DeveloperLogAnalyticsSink({
    required this.sessionId,
    required this.clock,
  });

  final AnalyticsSessionId sessionId;
  final Clock clock;

  @override
  void record(String eventName, Map<String, Object?> payload) {
    developer.log(
      <String, Object?>{
        'event': eventName,
        'sessionId': sessionId.value,
        'timestamp': clock.now().toIso8601String(),
        ...payload,
      }.toString(),
      name: 'aeropass.analytics',
    );
  }
}
