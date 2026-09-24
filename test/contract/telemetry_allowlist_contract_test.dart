// 015-observabilidad-sentry T017: the payload keys the emitter sends and
// the allowlist the privacy filter lets through are the same set
// (contracts/telemetry-events.md §1). Adding a payload key without adding it
// to the contract fails here, before it can reach Sentry or be silently
// dropped by the filter.
import 'dart:io';

import 'package:aeropass_app/data/services/sentry_log_analytics_sink.dart';
import 'package:aeropass_app/data/services/sentry_privacy_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every emitter payload key has an allowlisted attribute and back', () {
    final source = File('lib/data/services/logging_analytics_emitter.dart')
        .readAsStringSync();
    final emittedAttributes = RegExp(r"'([a-zA-Z]+)':")
        .allMatches(source)
        .map((match) => SentryLogAnalyticsSink.attributeName(match.group(1)!))
        .toSet();

    expect(emittedAttributes, isNotEmpty);
    expect(emittedAttributes, SentryPrivacyFilter.logPayloadAttributes);
  });

  test('payload keys map to aeropass.<snake_case> attribute names', () {
    expect(
      SentryLogAnalyticsSink.attributeName('attemptNumber'),
      'aeropass.attempt_number',
    );
    expect(SentryLogAnalyticsSink.attributeName('reason'), 'aeropass.reason');
    expect(
      SentryLogAnalyticsSink.attributeName('secondsSinceOpened'),
      'aeropass.seconds_since_opened',
    );
  });
}
