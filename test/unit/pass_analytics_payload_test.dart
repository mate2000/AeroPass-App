// 014-qr-pase T037: no pass event carries the payload, a pass id, a flight
// or a date (FR-015, FR-017, contracts/analytics-events.md).
import 'package:aeropass_app/domain/entities/pass.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_analytics_emitter.dart';

final _payloadPrefix = RegExp('AP1');
final _flightNumber = RegExp(r'\b[A-Z0-9]{2} ?\d{1,4}\b');
final _date = RegExp(r'\d{4}-\d{2}-\d{2}');

void main() {
  test('every pass payload is an enum name, a bool or an int', () {
    final analytics = FakeAnalyticsEmitter();
    for (final checkpoint in Checkpoint.values) {
      analytics
        ..passDisplayed(checkpoint: checkpoint, offlineCapable: false)
        ..passRotated(checkpoint: checkpoint)
        ..passValidated(checkpoint: checkpoint, secondsSinceOpened: 42);
    }
    for (final reason in PassUnavailableReason.values) {
      analytics.passUnavailable(reason: reason);
    }
    analytics
      ..passReissueRequested(succeeded: true)
      ..passHelpOpened();

    final enumNames = {
      ...Checkpoint.values.map((c) => c.name),
      ...PassUnavailableReason.values.map((r) => r.name),
    };
    for (final event in analytics.events) {
      for (final MapEntry(:key, :value) in event.payload.entries) {
        expect(
          value is bool || value is int || value is String,
          isTrue,
          reason: '${event.name}.$key',
        );
        if (value is String) {
          expect(enumNames, contains(value), reason: '${event.name}.$key');
          expect(value, isNot(matches(_payloadPrefix)));
          expect(value, isNot(matches(_flightNumber)));
          expect(value, isNot(matches(_date)));
        }
      }
    }
  });
}
