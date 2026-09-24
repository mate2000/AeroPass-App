// 015-observabilidad-sentry T010: the six guarantees of
// contracts/privacy-filter.md. Written before the filter (Principle IV).
import 'package:aeropass_app/data/services/sentry_privacy_filter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

const _filter = SentryPrivacyFilter(alertEventTag: 'failure_class');

SentryUser _passenger() => SentryUser(
  id: 'u-1',
  email: 'pasajero@example.com',
  ipAddress: '203.0.113.7',
);

SentryLog _log(String body, Map<String, SentryAttribute> attributes) =>
    SentryLog(
      timestamp: DateTime.utc(2026, 9, 23),
      level: SentryLogLevel.info,
      body: body,
      attributes: attributes,
    );

SentryMetric _distribution(String name, Map<String, SentryAttribute> attrs) =>
    SentryDistributionMetric(
      timestamp: DateTime.utc(2026, 9, 23),
      name: name,
      value: 1200,
      traceId: SentryId.newId(),
      unit: 'millisecond',
      attributes: attrs,
    );

void main() {
  group('1. errors and crashes', () {
    test('lose the user, the IP and the request', () {
      final event = (_filter.beforeSend(
        SentryEvent(
          user: _passenger(),
          request: SentryRequest(url: 'https://api.test/v1/x?doc=123'),
        ),
        Hint(),
      ))!;

      expect(event.user, isNull);
      expect(event.request, isNull);
    });

    test('lose the device name, which can carry a person name', () {
      final event = SentryEvent(
        contexts: Contexts(
          device: SentryDevice(name: 'iPhone de Juan', model: 'iPhone15,2'),
        ),
      );

      final filtered = (_filter.beforeSend(event, Hint()))!;

      expect(filtered.contexts.device?.name, isNull);
      expect(filtered.contexts.device?.model, 'iPhone15,2');
    });

    test('keep only allowed breadcrumbs, filtered', () {
      final event = (_filter.beforeSend(
        SentryEvent(
          breadcrumbs: [
            Breadcrumb(category: 'console', message: 'Juan Pérez'),
            Breadcrumb(
              category: 'navigation',
              type: 'navigation',
              data: {'state': 'didPush', 'to': '/pass', 'to_arguments': 'x'},
            ),
          ],
        ),
        Hint(),
      ))!;

      expect(event.breadcrumbs, hasLength(1));
      expect(event.breadcrumbs!.single.data, {
        'state': 'didPush',
        'to': '/pass',
      });
    });
  });

  group('2 and 3. funnel logs', () {
    test('keep contract and SDK attributes, drop anything else', () {
      final log = (_filter.beforeSendLog(
        _log('capture_attempted', {
          'aeropass.event': SentryAttribute.string('capture_attempted'),
          'aeropass.session_id': SentryAttribute.string('s-1'),
          'aeropass.enrollment_attempt_id': SentryAttribute.string('a-1'),
          'aeropass.attempt_number': SentryAttribute.int(2),
          'aeropass.document_number': SentryAttribute.string('1020304050'),
          'user.id': SentryAttribute.string('u-1'),
          'user.email': SentryAttribute.string('pasajero@example.com'),
          'sentry.environment': SentryAttribute.string('demo'),
          'os.name': SentryAttribute.string('Android'),
          'device.model': SentryAttribute.string('Pixel 8'),
          'name': SentryAttribute.string('Juan Pérez'),
        }),
      ))!;

      expect(
        log.attributes.keys,
        unorderedEquals([
          'aeropass.event',
          'aeropass.session_id',
          'aeropass.enrollment_attempt_id',
          'aeropass.attempt_number',
          'sentry.environment',
          'os.name',
          'device.model',
        ]),
      );
    });

    test('a log whose message is not its event name is dropped', () {
      final log = _filter.beforeSendLog(
        _log('Juan Pérez, CC 1020304050', {
          'aeropass.event': SentryAttribute.string('capture_attempted'),
        }),
      );

      expect(log, isNull);
    });

    test('a log without an event name is dropped', () {
      expect(_filter.beforeSendLog(_log('hello', {})), isNull);
    });
  });

  group('4. metrics', () {
    test('the registration duration keeps only its allowed attributes', () {
      final metric = (_filter.beforeSendMetric(
        _distribution('enrollment.duration', {
          'aeropass.resumed': SentryAttribute.bool(false),
          'aeropass.enrollment_attempt_id': SentryAttribute.string('a-1'),
          'user.id': SentryAttribute.string('u-1'),
          'sentry.environment': SentryAttribute.string('prod'),
        }),
      ))!;

      expect(
        metric.attributes.keys,
        unorderedEquals(['aeropass.resumed', 'sentry.environment']),
      );
    });

    test('a metric that is not in the contract is dropped', () {
      expect(
        _filter.beforeSendMetric(_distribution('document.number', {})),
        isNull,
      );
    });
  });

  group('5. breadcrumbs', () {
    test('console and text input breadcrumbs are dropped', () {
      for (final category in ['console', 'ui.input', 'ui.click']) {
        expect(
          _filter.beforeBreadcrumb(
            Breadcrumb(category: category, message: 'Juan Pérez'),
            Hint(),
          ),
          isNull,
          reason: category,
        );
      }
    });

    test('navigation keeps the route names and loses the arguments', () {
      final crumb = _filter.beforeBreadcrumb(
        Breadcrumb(
          category: 'navigation',
          type: 'navigation',
          data: {
            'state': 'didPush',
            'from': '/enrollment/document-capture',
            'from_arguments': {'documentNumber': '1020304050'},
            'to': '/enrollment/document-confirmation',
            'to_arguments': {'name': 'Juan Pérez'},
            'data': {'extra': 'x'},
          },
        ),
        Hint(),
      )!;

      expect(crumb.data, {
        'state': 'didPush',
        'from': '/enrollment/document-capture',
        'to': '/enrollment/document-confirmation',
      });
    });

    test('app lifecycle breadcrumbs pass unchanged', () {
      final crumb = Breadcrumb(
        category: 'app.lifecycle',
        type: 'navigation',
        data: {'state': 'resumed'},
      );

      expect(_filter.beforeBreadcrumb(crumb, Hint()), same(crumb));
    });

    test('an HTTP breadcrumb loses its query string and its body', () {
      final crumb = _filter.beforeBreadcrumb(
        Breadcrumb(
          category: 'http',
          type: 'http',
          data: {
            'url': 'https://api.test/v1/passes?credencial=abc',
            'method': 'GET',
            'status_code': 200,
            'request_body': '{"doc":"1020304050"}',
          },
        ),
        Hint(),
      )!;

      expect(crumb.data, {
        'url': 'https://api.test/v1/passes',
        'method': 'GET',
        'status_code': 200,
      });
    });

    test('a null breadcrumb stays null', () {
      expect(_filter.beforeBreadcrumb(null, Hint()), isNull);
    });
  });

  test('6. the 011 operational alert keeps its tags and loses the user and '
      'every breadcrumb', () {
    final event = (_filter.beforeSend(
      SentryEvent(
        message: SentryMessage('verification_service_failure'),
        tags: {'failure_class': 'service', 'failure_stage': 'issuance'},
        user: _passenger(),
        breadcrumbs: [
          Breadcrumb(
            category: 'navigation',
            data: {'state': 'didPush', 'to': '/enrollment/technical-error'},
          ),
        ],
      ),
      Hint(),
    ))!;

    expect(event.tags, {
      'failure_class': 'service',
      'failure_stage': 'issuance',
    });
    expect(event.user, isNull);
    expect(event.breadcrumbs, isNull);
  });

  test('the allowlists match the telemetry contract envelope', () {
    expect(SentryPrivacyFilter.logEnvelopeAttributes, {
      'aeropass.event',
      'aeropass.session_id',
      'aeropass.enrollment_attempt_id',
    });
    expect(SentryPrivacyFilter.metricAttributes, {
      'enrollment.duration': {'aeropass.resumed'},
    });
  });
}
