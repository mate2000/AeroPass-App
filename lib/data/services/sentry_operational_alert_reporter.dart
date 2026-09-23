import 'dart:async' show unawaited;

import 'package:sentry_flutter/sentry_flutter.dart';

import '../../core/sentry_config.dart';
import '../../domain/entities/verification_stage.dart';
import '../../domain/repositories/operational_alert_reporter.dart';

/// Sends 011's operational alert as one Sentry error event
/// (contracts/operational-alert-port.md). An alert rule on the
/// `failure_class:service` tag turns it into a notification to the team.
///
/// The event carries a message, two tags and a fingerprint, and nothing
/// about the passenger. `stripAlertEventPii` removes the user, request and
/// breadcrumbs that the global options would otherwise attach (FR-018).
class SentryOperationalAlertReporter implements OperationalAlertReporter {
  const SentryOperationalAlertReporter();

  static const _message = 'verification_service_failure';
  static const _stageTag = 'failure_stage';
  static const _fingerprintRoot = 'verification-service-failure';

  @override
  bool get canClaimNotification =>
      SentryConfig.isEnabled && SentryConfig.alertRuleConfirmed;

  @override
  void reportServiceFailure({required VerificationStage stage}) {
    final stageName = _wireStage(stage);
    unawaited(
      Sentry.captureMessage(
        _message,
        level: SentryLevel.error,
        withScope: (scope) async {
          await scope.setUser(null);
          await scope.setTag(SentryConfig.alertEventTag, 'service');
          await scope.setTag(_stageTag, stageName);
          scope.fingerprint = [_fingerprintRoot, stageName];
        },
      ),
    );
  }

  static String _wireStage(VerificationStage stage) => switch (stage) {
    VerificationStage.documentCheck => 'document_check',
    VerificationStage.faceComparison => 'face_comparison',
    VerificationStage.issuance => 'issuance',
  };
}

/// Used when Sentry is not configured: nothing is sent, so nothing may be
/// claimed.
class NoopOperationalAlertReporter implements OperationalAlertReporter {
  const NoopOperationalAlertReporter();

  @override
  bool get canClaimNotification => false;

  @override
  void reportServiceFailure({required VerificationStage stage}) {}
}
