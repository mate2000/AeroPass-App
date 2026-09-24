// 015-observabilidad-sentry T019: each funnel event becomes one structured
// Sentry log (contracts/telemetry-events.md §1), written through an
// injected writer so no SDK is needed here.
import 'package:aeropass_app/core/analytics_session.dart';
import 'package:aeropass_app/data/services/current_enrollment_attempt.dart';
import 'package:aeropass_app/data/services/enrollment_duration_tracker.dart';
import 'package:aeropass_app/data/services/sentry_log_analytics_sink.dart';
import 'package:aeropass_app/domain/entities/enrollment_attempt_id.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../fakes/fake_clock.dart';
import '../fakes/fake_consent_repository.dart';

enum _Variant { standard }

void main() {
  late List<(String, Map<String, SentryAttribute>)> written;
  late CurrentEnrollmentAttempt attempt;
  late SentryLogAnalyticsSink sink;
  final sessionId = AnalyticsSessionId.generate();

  setUp(() {
    written = [];
    attempt = CurrentEnrollmentAttempt(
      consentRepository: FakeConsentRepository(),
    );
    sink = SentryLogAnalyticsSink(
      sessionId: sessionId,
      attempt: attempt,
      writeLog: (body, attributes) => written.add((body, attributes)),
    );
  });

  Map<String, Object?> valuesOf(Map<String, SentryAttribute> attributes) =>
      attributes.map((key, value) => MapEntry(key, value.value));

  test('the log message is the event name and the envelope is set', () {
    sink.record('capture_step_entered', const {});

    expect(written.single.$1, 'capture_step_entered');
    expect(valuesOf(written.single.$2), {
      'aeropass.event': 'capture_step_entered',
      'aeropass.session_id': sessionId.value,
    });
  });

  test('payload keys become aeropass.<snake_case> typed attributes', () {
    sink.record('capture_attempted', {
      'attemptNumber': 2,
      'permanent': true,
      'reason': 'blurry',
      'variant': _Variant.standard,
    });

    final attributes = written.single.$2;
    expect(attributes['aeropass.attempt_number']?.toJson()['type'], 'integer');
    expect(attributes['aeropass.permanent']?.toJson()['type'], 'boolean');
    expect(attributes['aeropass.reason']?.toJson()['type'], 'string');
    expect(valuesOf(attributes), containsPair('aeropass.variant', 'standard'));
    expect(valuesOf(attributes), containsPair('aeropass.attempt_number', 2));
  });

  test('a null payload value is left out', () {
    sink.record('liveness_outcome', {'outcome': 'success', 'reason': null});

    expect(written.single.$2.containsKey('aeropass.reason'), isFalse);
  });

  test('the current attempt id is added only while there is one', () {
    sink.record('welcome_screen_shown', const {});
    attempt.set(EnrollmentAttemptId('a-1'));
    sink.record('capture_step_entered', const {});
    attempt.clear();
    sink.record('consent_dismissed', const {});

    expect(written.map((w) => w.$2['aeropass.enrollment_attempt_id']?.value), [
      null,
      'a-1',
      null,
    ]);
  });

  group('registration duration (T027)', () {
    late FakeClock clock;
    late List<num> durations;
    late SentryLogAnalyticsSink timedSink;

    setUp(() {
      clock = FakeClock();
      durations = [];
      timedSink = SentryLogAnalyticsSink(
        sessionId: sessionId,
        attempt: attempt,
        writeLog: (_, _) {},
        durationTracker: EnrollmentDurationTracker(
          clock: clock,
          writeDistribution: (_, value, {unit, attributes}) =>
              durations.add(value),
        ),
      );
    });

    test('capture_step_entered starts and credential_activated_shown '
        'completes the current attempt', () {
      attempt.set(EnrollmentAttemptId('a-1'));
      timedSink.record('capture_step_entered', const {});
      clock.advance(const Duration(minutes: 2));
      timedSink.record('capture_attempted', {'attemptNumber': 1});
      timedSink.record('credential_activated_shown', const {});

      expect(durations, [120000]);
    });

    test('other events neither start nor complete an attempt', () {
      attempt.set(EnrollmentAttemptId('a-1'));
      timedSink.record('confirmation_step_entered', const {});
      timedSink.record('credential_activated_shown', const {});

      expect(durations, isEmpty);
    });
  });

  test('record returns without waiting for the writer', () {
    var calls = 0;
    SentryLogAnalyticsSink(
      sessionId: sessionId,
      attempt: attempt,
      writeLog: (_, _) => calls++,
    ).record('capture_step_entered', const {});

    expect(calls, 1);
  });
}
