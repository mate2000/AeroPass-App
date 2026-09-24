// 015-observabilidad-sentry T005: sampling rates come from the env files,
// with the prod values as defaults (research §7, data-model TelemetryConfig).
import 'package:aeropass_app/core/sentry_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseSampleRate', () {
    test('an absent variable uses the fallback', () {
      expect(parseSampleRate('', fallback: 0.2), 0.2);
    });

    test('a number in [0, 1] is used as is', () {
      expect(parseSampleRate('0', fallback: 0.2), 0);
      expect(parseSampleRate('0.35', fallback: 0.2), 0.35);
      expect(parseSampleRate('1.0', fallback: 0.2), 1);
    });

    test('a value out of range fails in debug builds', () {
      expect(
        () => parseSampleRate('1.5', fallback: 0.2),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => parseSampleRate('-0.1', fallback: 0.2),
        throwsA(isA<AssertionError>()),
      );
    });

    test('a value that is not a number fails in debug builds', () {
      expect(
        () => parseSampleRate('high', fallback: 0.2),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  test('without env values the prod defaults apply', () {
    expect(SentryConfig.tracesSampleRate, SentryConfig.defaultTracesSampleRate);
    expect(
      SentryConfig.profilesSampleRate,
      SentryConfig.defaultProfilesSampleRate,
    );
    expect(
      SentryConfig.replaySessionSampleRate,
      SentryConfig.defaultReplaySessionSampleRate,
    );
    expect(
      SentryConfig.replayOnErrorSampleRate,
      SentryConfig.defaultReplayOnErrorSampleRate,
    );
    expect(SentryConfig.defaultTracesSampleRate, 0.2);
    expect(SentryConfig.defaultProfilesSampleRate, 0.2);
    expect(SentryConfig.defaultReplaySessionSampleRate, 0.1);
    expect(SentryConfig.defaultReplayOnErrorSampleRate, 1.0);
  });
}
