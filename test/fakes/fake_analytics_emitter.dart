import 'package:aeropass_app/domain/entities/pass.dart';
import 'package:aeropass_app/domain/entities/trip.dart';
import 'package:aeropass_app/domain/entities/service_failure.dart';
import 'package:aeropass_app/domain/entities/service_status.dart';
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
      const RecordedAnalyticsEvent(
        'confirmation_correction_attempt_limit_reached',
      ),
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
    events.add(
      const RecordedAnalyticsEvent('selfie_instructions_step_entered'),
    );
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

  @override
  void credentialIssuanceRequested() {
    events.add(const RecordedAnalyticsEvent('credential_issuance_requested'));
  }

  @override
  void credentialIssuanceOutcome({required IssuanceOutcomeKind kind}) {
    events.add(
      RecordedAnalyticsEvent('credential_issuance_outcome', {
        'kind': kind.name,
      }),
    );
  }

  @override
  void credentialActivatedShown() {
    events.add(const RecordedAnalyticsEvent('credential_activated_shown'));
  }

  @override
  void credentialActivatedRouteTaken({required OnwardRoute route}) {
    events.add(
      RecordedAnalyticsEvent('credential_activated_route_taken', {
        'route': route.name,
      }),
    );
  }

  @override
  void verificationStepEntered() {
    events.add(const RecordedAnalyticsEvent('verification_step_entered'));
  }

  @override
  void verificationStageReached({
    required VerificationStage stage,
    required StageStatus status,
  }) {
    events.add(
      RecordedAnalyticsEvent('verification_stage_reached', {
        'stage': stage.name,
        'status': status.name,
      }),
    );
  }

  @override
  void verificationSlowNoticeShown() {
    events.add(const RecordedAnalyticsEvent('verification_slow_notice_shown'));
  }

  @override
  void verificationHelpOpened() {
    events.add(const RecordedAnalyticsEvent('verification_help_opened'));
  }

  @override
  void verificationTimedOut() {
    events.add(const RecordedAnalyticsEvent('verification_timed_out'));
  }

  @override
  void verificationOutcome({
    required VerificationOutcomeKind kind,
    required int elapsedSeconds,
  }) {
    events.add(
      RecordedAnalyticsEvent('verification_outcome', {
        'kind': kind.name,
        'elapsedSeconds': elapsedSeconds,
      }),
    );
  }

  @override
  void retryGuidanceShown({required RetryGuidanceState state}) {
    events.add(
      RecordedAnalyticsEvent('retry_guidance_shown', {'state': state.name}),
    );
  }

  @override
  void retryGuidanceRetryTaken() {
    events.add(const RecordedAnalyticsEvent('retry_guidance_retry_taken'));
  }

  @override
  void retryGuidanceAgentRouteTaken({required RetryGuidanceState state}) {
    events.add(
      RecordedAnalyticsEvent('retry_guidance_agent_route_taken', {
        'state': state.name,
      }),
    );
  }

  @override
  void escalationShown({required EscalationArrival arrival}) {
    events.add(
      RecordedAnalyticsEvent('escalation_shown', {'arrival': arrival.name}),
    );
  }

  @override
  void escalationChannelsOffered({
    required bool moduleAvailable,
    required bool chatAvailable,
  }) {
    events.add(
      RecordedAnalyticsEvent('escalation_channels_offered', {
        'moduleAvailable': moduleAvailable,
        'chatAvailable': chatAvailable,
      }),
    );
  }

  @override
  void escalationChannelSelected({required AgentChannelKind channel}) {
    events.add(
      RecordedAnalyticsEvent('escalation_channel_selected', {
        'channel': channel.name,
      }),
    );
  }

  @override
  void escalationHandoffStarted({required AgentChannelKind channel}) {
    events.add(
      RecordedAnalyticsEvent('escalation_handoff_started', {
        'channel': channel.name,
      }),
    );
  }

  @override
  void escalationOutcome({
    required EscalationOutcomeKind kind,
    required int elapsedSeconds,
  }) {
    events.add(
      RecordedAnalyticsEvent('escalation_outcome', {
        'kind': kind.name,
        'elapsedSeconds': elapsedSeconds,
      }),
    );
  }

  @override
  void technicalErrorShown({
    required ServiceFailureClass failureClass,
    required VerificationStage? stage,
    required bool jobTerminal,
  }) {
    events.add(
      RecordedAnalyticsEvent('technical_error_shown', {
        'failureClass': failureClass.name,
        'stage': stage?.name,
        'jobTerminal': jobTerminal,
      }),
    );
  }

  @override
  void technicalErrorStatusShown({
    required StepHealth documentScan,
    required StepHealth selfie,
    required StepHealth issuance,
  }) {
    events.add(
      RecordedAnalyticsEvent('technical_error_status_shown', {
        'documentScan': documentScan.name,
        'selfie': selfie.name,
        'issuance': issuance.name,
      }),
    );
  }

  @override
  void technicalErrorRetry({
    required TechnicalErrorRetryDestination destination,
    required int arrival,
  }) {
    events.add(
      RecordedAnalyticsEvent('technical_error_retry', {
        'destination': destination.name,
        'arrival': arrival,
      }),
    );
  }

  @override
  void technicalErrorExit() {
    events.add(RecordedAnalyticsEvent('technical_error_exit', {}));
  }

  @override
  void technicalErrorResolved({required int elapsedSeconds}) {
    events.add(
      RecordedAnalyticsEvent('technical_error_resolved', {
        'elapsedSeconds': elapsedSeconds,
      }),
    );
  }

  @override
  void tripsHomeShown({
    required bool hasNextTrip,
    required bool credentialConfirmed,
  }) {
    events.add(
      RecordedAnalyticsEvent('trips_home_shown', {
        'hasNextTrip': hasNextTrip,
        'credentialConfirmed': credentialConfirmed,
      }),
    );
  }

  @override
  void tripDisplayed({
    required TripStatus status,
    required bool live,
    required bool withinWindow,
  }) {
    events.add(
      RecordedAnalyticsEvent('trip_displayed', {
        'status': status.name,
        'live': live,
        'withinWindow': withinWindow,
      }),
    );
  }

  @override
  void tripStarted({required int completedTripsLast90Days}) {
    events.add(
      RecordedAnalyticsEvent('trip_started', {
        'completedTripsLast90Days': completedTripsLast90Days,
      }),
    );
  }

  @override
  void tripsHistoryViewed({required int rowCount}) {
    events.add(
      RecordedAnalyticsEvent('trips_history_viewed', {'rowCount': rowCount}),
    );
  }

  @override
  void tripsEmptyShown() {
    events.add(RecordedAnalyticsEvent('trips_empty_shown', {}));
  }

  @override
  void passDisplayed({
    required Checkpoint checkpoint,
    required bool offlineCapable,
  }) {
    events.add(
      RecordedAnalyticsEvent('pass_displayed', {
        'checkpoint': checkpoint.name,
        'offlineCapable': offlineCapable,
      }),
    );
  }

  @override
  void passRotated({required Checkpoint checkpoint}) {
    events.add(
      RecordedAnalyticsEvent('pass_rotated', {'checkpoint': checkpoint.name}),
    );
  }

  @override
  void passValidated({
    required Checkpoint checkpoint,
    required int secondsSinceOpened,
  }) {
    events.add(
      RecordedAnalyticsEvent('pass_validated', {
        'checkpoint': checkpoint.name,
        'secondsSinceOpened': secondsSinceOpened,
      }),
    );
  }

  @override
  void passUnavailable({required PassUnavailableReason reason}) {
    events.add(RecordedAnalyticsEvent('pass_expired', {'reason': reason.name}));
  }

  @override
  void passReissueRequested({required bool succeeded}) {
    events.add(
      RecordedAnalyticsEvent('pass_reissue_requested', {
        'succeeded': succeeded,
      }),
    );
  }

  @override
  void passHelpOpened() {
    events.add(RecordedAnalyticsEvent('pass_help_opened', {}));
  }
}
