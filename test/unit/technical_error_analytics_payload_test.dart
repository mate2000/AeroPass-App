// 011-error-tecnico T044: the five new events carry no field Principle VII
// forbids (contracts/analytics-events.md).
import 'package:aeropass_app/domain/entities/service_failure.dart';
import 'package:aeropass_app/domain/entities/service_status.dart';
import 'package:aeropass_app/domain/entities/verification_stage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_analytics_emitter.dart';

const _forbidden = [
  'document',
  'name',
  'birth',
  'face',
  'token',
  'qr',
  'provider',
  'raw',
  'image',
  'photo',
];

void main() {
  test(
    'every 011 payload is enums, booleans and integers, with no forbidden key',
    () {
      final analytics = FakeAnalyticsEmitter()
        ..technicalErrorShown(
          failureClass: ServiceFailureClass.service,
          stage: VerificationStage.issuance,
          jobTerminal: false,
        )
        ..technicalErrorShown(
          failureClass: ServiceFailureClass.undetermined,
          stage: null,
          jobTerminal: false,
        )
        ..technicalErrorStatusShown(
          documentScan: StepHealth.operational,
          selfie: StepHealth.degraded,
          issuance: StepHealth.unavailable,
        )
        ..technicalErrorRetry(
          destination: TechnicalErrorRetryDestination.selfie,
          arrival: 2,
        )
        ..technicalErrorExit()
        ..technicalErrorResolved(elapsedSeconds: 90);

      expect(analytics.events.map((e) => e.name), [
        'technical_error_shown',
        'technical_error_shown',
        'technical_error_status_shown',
        'technical_error_retry',
        'technical_error_exit',
        'technical_error_resolved',
      ]);

      // `documentScan` names a journey step, not a document: it is allowed.
      const allowed = {'documentScan'};
      for (final event in analytics.events) {
        for (final MapEntry(:key, :value) in event.payload.entries) {
          if (!allowed.contains(key)) {
            for (final word in _forbidden) {
              expect(
                key.toLowerCase(),
                isNot(contains(word)),
                reason: '${event.name}.$key',
              );
            }
          }
          expect(
            value == null || value is String || value is bool || value is int,
            isTrue,
            reason: '${event.name}.$key is ${value.runtimeType}',
          );
          if (value is String) {
            expect(
              value,
              matches(RegExp(r'^[a-zA-Z]+$')),
              reason: 'enum names only',
            );
          }
        }
      }
    },
  );
}
