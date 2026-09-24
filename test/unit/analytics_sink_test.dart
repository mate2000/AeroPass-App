// 015-observabilidad-sentry T009: the emitter defines each event once and
// hands the same name and payload to every sink (research §11).
import 'package:aeropass_app/core/analytics_session.dart';
import 'package:aeropass_app/data/services/analytics_sink.dart';
import 'package:aeropass_app/data/services/logging_analytics_emitter.dart';
import 'package:aeropass_app/domain/repositories/analytics_emitter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_clock.dart';

class _RecordingSink implements AnalyticsSink {
  final records = <(String, Map<String, Object?>)>[];

  @override
  void record(String eventName, Map<String, Object?> payload) {
    records.add((eventName, payload));
  }
}

void main() {
  test('every sink receives the same event name and payload', () {
    final first = _RecordingSink();
    final second = _RecordingSink();
    LoggingAnalyticsEmitter(sinks: [first, second])
      ..captureAttempted(attemptNumber: 2)
      ..captureStepEntered();

    for (final sink in [first, second]) {
      expect(sink.records.map((r) => r.$1), [
        'capture_attempted',
        'capture_step_entered',
      ]);
      expect(sink.records[0].$2, {'attemptNumber': 2});
      expect(sink.records[1].$2, isEmpty);
    }
  });

  test('an emitter with no sinks emits nothing and does not fail', () {
    expect(
      () => LoggingAnalyticsEmitter(sinks: const []).captureStepEntered(),
      returnsNormally,
    );
  });

  test('the sink list cannot be changed after construction', () {
    final sinks = <AnalyticsSink>[];
    final emitter = LoggingAnalyticsEmitter(sinks: sinks);
    final late = _RecordingSink();
    sinks.add(late);

    emitter.welcomeScreenShown(WelcomeScreenVariant.values.first);

    expect(late.records, isEmpty);
  });

  test('the on-device log sink records without failing', () {
    final sink = DeveloperLogAnalyticsSink(
      sessionId: AnalyticsSessionId.generate(),
      clock: FakeClock(),
    );

    expect(
      () => sink.record('capture_attempted', {'attemptNumber': 1}),
      returnsNormally,
    );
  });
}
