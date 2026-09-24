// 011-error-tecnico T027, updated by 015-observabilidad-sentry T013: the
// operational alert event carries no personal data (FR-018,
// contracts/operational-alert-port.md), now through the app-wide
// SentryPrivacyFilter wired into SentryConfig. Since 015 every other event
// also loses its user and request (015 FR-002), with sendDefaultPii off.
import 'package:aeropass_app/core/sentry_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

SentryEvent _event({Map<String, String>? tags}) => SentryEvent(
  tags: tags,
  user: SentryUser(id: 'u-1', ipAddress: '203.0.113.7'),
  request: SentryRequest(url: 'https://api.test/v1/x'),
  breadcrumbs: [
    Breadcrumb(
      category: 'navigation',
      data: {'state': 'didPush', 'to': '/trips'},
    ),
  ],
);

void main() {
  const filter = SentryConfig.privacyFilter;

  test('an alert event loses its user, request and breadcrumbs', () {
    final event = (filter.beforeSend(
      _event(
        tags: {
          SentryConfig.alertEventTag: 'service',
          'failure_stage': 'issuance',
        },
      ),
      Hint(),
    ))!;

    expect(event.user, isNull);
    expect(event.request, isNull);
    expect(event.breadcrumbs, isNull);
    expect(event.tags, {
      SentryConfig.alertEventTag: 'service',
      'failure_stage': 'issuance',
    });
  });

  test('any other event also loses its user and request, and keeps its '
      'allowed breadcrumbs', () {
    final event = (filter.beforeSend(_event(tags: {'other': 'x'}), Hint()))!;

    expect(event.user, isNull);
    expect(event.request, isNull);
    expect(event.breadcrumbs, hasLength(1));
    expect(event.tags, {'other': 'x'});
  });

  test('SentryConfig sends no default personal data', () {
    final options = SentryFlutterOptions();
    SentryConfig.configure(options);

    expect(options.sendDefaultPii, isFalse);
    expect(options.attachScreenshot, isFalse);
    expect(options.beforeSend, isNotNull);
    expect(options.beforeSendTransaction, isNotNull);
    expect(options.beforeBreadcrumb, isNotNull);
    expect(options.beforeSendLog, isNotNull);
    expect(options.beforeSendMetric, isNotNull);
  });
}
