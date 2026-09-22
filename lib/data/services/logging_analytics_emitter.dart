import 'dart:developer' as developer;

import '../../core/analytics_session.dart';
import '../../core/clock.dart';
import '../../domain/repositories/analytics_emitter.dart';

/// The composition root's real `AnalyticsEmitter`: logs each funnel event
/// as a structured line keyed by the in-memory [AnalyticsSessionId],
/// per contracts/analytics-events.md and Constitution Principle VII
/// (observability without PII — no payload field here ever carries a
/// credential token, document data, or name).
///
/// This screen has no analytics backend integration in scope (see spec.md
/// Out of Scope); wiring this sink to a real telemetry pipeline is a
/// follow-up for whichever feature owns that pipeline.
class LoggingAnalyticsEmitter implements AnalyticsEmitter {
  LoggingAnalyticsEmitter({required this.sessionId, required this.clock});

  final AnalyticsSessionId sessionId;
  final Clock clock;

  void _log(String eventName, [Map<String, Object?> payload = const {}]) {
    developer.log(
      <String, Object?>{
        'event': eventName,
        'sessionId': sessionId.value,
        'timestamp': clock.now().toIso8601String(),
        ...payload,
      }.toString(),
      name: 'aeropass.analytics',
    );
  }

  @override
  void welcomeScreenShown(WelcomeScreenVariant variant) {
    _log('welcome_screen_shown', {'variant': variant.name});
  }

  @override
  void welcomePrimaryActionTapped(WelcomeScreenVariant variant) {
    _log('welcome_primary_action_tapped', {'variant': variant.name});
  }

  @override
  void welcomeSecondaryActionTapped() {
    _log('welcome_secondary_action_tapped');
  }

  @override
  void welcomePrivacyTermsOpened() {
    _log('welcome_privacy_terms_opened');
  }

  @override
  void welcomeDeviceUnsupportedShown(DeviceUnsupportedReason reason) {
    _log('welcome_device_unsupported_shown', {'reason': reason.name});
  }

  @override
  void consentGateShown({required bool hasPriorRecord}) {
    _log('consent_gate_shown', {'hasPriorRecord': hasPriorRecord});
  }

  @override
  void consentGateUnavailableShown({required UnavailableReason reason}) {
    _log('consent_gate_unavailable_shown', {'reason': reason.name});
  }

  @override
  void consentConfirmed({required String textVersionId}) {
    _log('consent_confirmed', {'textVersionId': textVersionId});
  }

  @override
  void consentConfirmFailed() {
    _log('consent_confirm_failed');
  }

  @override
  void consentDeclined() {
    _log('consent_declined');
  }

  @override
  void consentDismissed() {
    _log('consent_dismissed');
  }

  @override
  void captureStepEntered() {
    _log('capture_step_entered');
  }

  @override
  void capturePermissionDeniedShown({required bool permanent}) {
    _log('capture_permission_denied_shown', {'permanent': permanent});
  }

  @override
  void captureAttempted({required int attemptNumber}) {
    _log('capture_attempted', {'attemptNumber': attemptNumber});
  }

  @override
  void captureDeviceRejected({required CaptureRejectionReason reason}) {
    _log('capture_device_rejected', {'reason': reason.name});
  }

  @override
  void captureVerificationRejected({required CaptureRejectionReason reason}) {
    _log('capture_verification_rejected', {'reason': reason.name});
  }

  @override
  void captureAccepted() {
    _log('capture_accepted');
  }

  @override
  void captureAttemptLimitReached() {
    _log('capture_attempt_limit_reached');
  }

  @override
  void captureStepAbandoned() {
    _log('capture_step_abandoned');
  }

  @override
  void confirmationStepEntered() {
    _log('confirmation_step_entered');
  }

  @override
  void confirmationFieldEdited({required FieldKey field}) {
    _log('confirmation_field_edited', {'field': field.name});
  }

  @override
  void confirmationFieldReverified({
    required FieldKey field,
    required bool confirmed,
  }) {
    _log('confirmation_field_reverified', {
      'field': field.name,
      'confirmed': confirmed,
    });
  }

  @override
  void confirmationCorrectionAttemptLimitReached() {
    _log('confirmation_correction_attempt_limit_reached');
  }

  @override
  void confirmationRescanned() {
    _log('confirmation_rescanned');
  }

  @override
  void confirmationBlockedUnusableDocument({
    required DocumentBlockReason reason,
  }) {
    _log('confirmation_blocked_unusable_document', {'reason': reason.name});
  }

  @override
  void confirmationConfirmed() {
    _log('confirmation_confirmed');
  }

  @override
  void confirmationConfirmFailed() {
    _log('confirmation_confirm_failed');
  }

  @override
  void confirmationStepAbandoned() {
    _log('confirmation_step_abandoned');
  }

  @override
  void selfieInstructionsStepEntered() {
    _log('selfie_instructions_step_entered');
  }

  @override
  void selfieInstructionsAdvanced() {
    _log('selfie_instructions_advanced');
  }

  @override
  void selfieInstructionsHelpOpened() {
    _log('selfie_instructions_help_opened');
  }

  @override
  void selfieInstructionsStepAbandoned() {
    _log('selfie_instructions_step_abandoned');
  }

  @override
  void livenessStepEntered() {
    _log('liveness_step_entered');
  }

  @override
  void livenessPhaseReached({
    required int phaseIndex,
    required int totalPhases,
  }) {
    _log('liveness_phase_reached', {
      'phaseIndex': phaseIndex,
      'totalPhases': totalPhases,
    });
  }

  @override
  void livenessOutcome({
    required LivenessOutcomeKind outcome,
    LivenessQualityReason? reason,
  }) {
    _log('liveness_outcome', {
      'outcome': outcome.name,
      if (reason != null) 'reason': reason.name,
    });
  }

  @override
  void livenessAttemptCount({required int attemptNumber}) {
    _log('liveness_attempt_count', {'attemptNumber': attemptNumber});
  }

  @override
  void livenessAttemptLimitReached() {
    _log('liveness_attempt_limit_reached');
  }

  @override
  void livenessStalled() {
    _log('liveness_stalled');
  }

  @override
  void livenessStepAbandoned() {
    _log('liveness_step_abandoned');
  }
}
