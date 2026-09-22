import 'package:aeropass_app/domain/repositories/analytics_emitter.dart';

/// A single recorded funnel-event call, for widget/unit test assertions.
class RecordedAnalyticsEvent {
  const RecordedAnalyticsEvent(this.name, [this.payload = const {}]);

  final String name;
  final Map<String, Object?> payload;

  @override
  String toString() => '$name($payload)';
}

/// An in-memory `AnalyticsEmitter` double: records every call instead of
/// sending it anywhere, per Constitution Principle II's testability
/// requirement extended to this port.
class FakeAnalyticsEmitter implements AnalyticsEmitter {
  final List<RecordedAnalyticsEvent> events = [];

  @override
  void welcomeScreenShown(WelcomeScreenVariant variant) {
    events.add(
      RecordedAnalyticsEvent('welcome_screen_shown', {'variant': variant.name}),
    );
  }

  @override
  void welcomePrimaryActionTapped(WelcomeScreenVariant variant) {
    events.add(
      RecordedAnalyticsEvent('welcome_primary_action_tapped', {
        'variant': variant.name,
      }),
    );
  }

  @override
  void welcomeSecondaryActionTapped() {
    events.add(const RecordedAnalyticsEvent('welcome_secondary_action_tapped'));
  }

  @override
  void welcomePrivacyTermsOpened() {
    events.add(const RecordedAnalyticsEvent('welcome_privacy_terms_opened'));
  }

  @override
  void welcomeDeviceUnsupportedShown(DeviceUnsupportedReason reason) {
    events.add(
      RecordedAnalyticsEvent('welcome_device_unsupported_shown', {
        'reason': reason.name,
      }),
    );
  }

  @override
  void consentGateShown({required bool hasPriorRecord}) {
    events.add(
      RecordedAnalyticsEvent('consent_gate_shown', {
        'hasPriorRecord': hasPriorRecord,
      }),
    );
  }

  @override
  void consentGateUnavailableShown({required UnavailableReason reason}) {
    events.add(
      RecordedAnalyticsEvent('consent_gate_unavailable_shown', {
        'reason': reason.name,
      }),
    );
  }

  @override
  void consentConfirmed({required String textVersionId}) {
    events.add(
      RecordedAnalyticsEvent('consent_confirmed', {
        'textVersionId': textVersionId,
      }),
    );
  }

  @override
  void consentConfirmFailed() {
    events.add(const RecordedAnalyticsEvent('consent_confirm_failed'));
  }

  @override
  void consentDeclined() {
    events.add(const RecordedAnalyticsEvent('consent_declined'));
  }

  @override
  void consentDismissed() {
    events.add(const RecordedAnalyticsEvent('consent_dismissed'));
  }

  @override
  void captureStepEntered() {
    events.add(const RecordedAnalyticsEvent('capture_step_entered'));
  }

  @override
  void capturePermissionDeniedShown({required bool permanent}) {
    events.add(
      RecordedAnalyticsEvent('capture_permission_denied_shown', {
        'permanent': permanent,
      }),
    );
  }

  @override
  void captureAttempted({required int attemptNumber}) {
    events.add(
      RecordedAnalyticsEvent('capture_attempted', {
        'attemptNumber': attemptNumber,
      }),
    );
  }

  @override
  void captureDeviceRejected({required CaptureRejectionReason reason}) {
    events.add(
      RecordedAnalyticsEvent('capture_device_rejected', {
        'reason': reason.name,
      }),
    );
  }

  @override
  void captureVerificationRejected({required CaptureRejectionReason reason}) {
    events.add(
      RecordedAnalyticsEvent('capture_verification_rejected', {
        'reason': reason.name,
      }),
    );
  }

  @override
  void captureAccepted() {
    events.add(const RecordedAnalyticsEvent('capture_accepted'));
  }

  @override
  void captureAttemptLimitReached() {
    events.add(const RecordedAnalyticsEvent('capture_attempt_limit_reached'));
  }

  @override
  void captureStepAbandoned() {
    events.add(const RecordedAnalyticsEvent('capture_step_abandoned'));
  }

  @override
  void confirmationStepEntered() {
    events.add(const RecordedAnalyticsEvent('confirmation_step_entered'));
  }

  @override
  void confirmationFieldEdited({required FieldKey field}) {
    events.add(
      RecordedAnalyticsEvent('confirmation_field_edited', {
        'field': field.name,
      }),
    );
  }

  @override
  void confirmationFieldReverified({
    required FieldKey field,
    required bool confirmed,
  }) {
    events.add(
      RecordedAnalyticsEvent('confirmation_field_reverified', {
        'field': field.name,
        'confirmed': confirmed,
      }),
    );
  }

  @override
  void confirmationCorrectionAttemptLimitReached() {
    events.add(
      const RecordedAnalyticsEvent('confirmation_correction_attempt_limit_reached'),
    );
  }

  @override
  void confirmationRescanned() {
    events.add(const RecordedAnalyticsEvent('confirmation_rescanned'));
  }

  @override
  void confirmationBlockedUnusableDocument({
    required DocumentBlockReason reason,
  }) {
    events.add(
      RecordedAnalyticsEvent('confirmation_blocked_unusable_document', {
        'reason': reason.name,
      }),
    );
  }

  @override
  void confirmationConfirmed() {
    events.add(const RecordedAnalyticsEvent('confirmation_confirmed'));
  }

  @override
  void confirmationConfirmFailed() {
    events.add(const RecordedAnalyticsEvent('confirmation_confirm_failed'));
  }

  @override
  void confirmationStepAbandoned() {
    events.add(const RecordedAnalyticsEvent('confirmation_step_abandoned'));
  }

  @override
  void selfieInstructionsStepEntered() {
    events.add(const RecordedAnalyticsEvent('selfie_instructions_step_entered'));
  }

  @override
  void selfieInstructionsAdvanced() {
    events.add(const RecordedAnalyticsEvent('selfie_instructions_advanced'));
  }

  @override
  void selfieInstructionsHelpOpened() {
    events.add(const RecordedAnalyticsEvent('selfie_instructions_help_opened'));
  }

  @override
  void selfieInstructionsStepAbandoned() {
    events.add(
      const RecordedAnalyticsEvent('selfie_instructions_step_abandoned'),
    );
  }

  @override
  void livenessStepEntered() {
    events.add(const RecordedAnalyticsEvent('liveness_step_entered'));
  }

  @override
  void livenessPhaseReached({
    required int phaseIndex,
    required int totalPhases,
  }) {
    events.add(
      RecordedAnalyticsEvent('liveness_phase_reached', {
        'phaseIndex': phaseIndex,
        'totalPhases': totalPhases,
      }),
    );
  }

  @override
  void livenessOutcome({
    required LivenessOutcomeKind outcome,
    LivenessQualityReason? reason,
  }) {
    events.add(
      RecordedAnalyticsEvent('liveness_outcome', {
        'outcome': outcome.name,
        if (reason != null) 'reason': reason.name,
      }),
    );
  }

  @override
  void livenessAttemptCount({required int attemptNumber}) {
    events.add(
      RecordedAnalyticsEvent('liveness_attempt_count', {
        'attemptNumber': attemptNumber,
      }),
    );
  }

  @override
  void livenessAttemptLimitReached() {
    events.add(const RecordedAnalyticsEvent('liveness_attempt_limit_reached'));
  }

  @override
  void livenessStalled() {
    events.add(const RecordedAnalyticsEvent('liveness_stalled'));
  }

  @override
  void livenessStepAbandoned() {
    events.add(const RecordedAnalyticsEvent('liveness_step_abandoned'));
  }
}
