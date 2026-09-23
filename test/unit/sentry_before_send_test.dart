// 011-error-tecnico T027: the operational alert event carries no personal
// data, even with sendDefaultPii on (FR-018, contracts/operational-alert-port.md).
import 'package:aeropass_app/core/sentry_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

SentryEvent _event({Map<String, String>? tags}) => SentryEvent(
  tags: tags,
  user: SentryUser(id: 'u-1', ipAddress: '203.0.113.7'),
  request: SentryRequest(url: 'https://api.test/v1/x'),
  breadcrumbs: [Breadcrumb(message: 'navigated')],
);

void main() {
  test('an alert event loses its user, request and breadcrumbs', () {
    final event = stripAlertEventPii(
      _event(
        tags: {
          SentryConfig.alertEventTag: 'service',
          'failure_stage': 'issuance',
        },
      ),
      Hint(),
    )!;

    expect(event.user, isNull);
    expect(event.request, isNull);
    expect(event.breadcrumbs, isNull);
    expect(event.tags, {
      SentryConfig.alertEventTag: 'service',
      'failure_stage': 'issuance',
    });
  });

  test('any other event passes through unchanged', () {
    final original = _event(tags: {'other': 'x'});
    final event = stripAlertEventPii(original, Hint())!;

    expect(event, same(original));
    expect(event.user?.id, 'u-1');
    expect(event.request, isNotNull);
    expect(event.breadcrumbs, hasLength(1));
  });

  test('an event without tags passes through', () {
    final original = _event();
    expect(stripAlertEventPii(original, Hint()), same(original));
  });
}
