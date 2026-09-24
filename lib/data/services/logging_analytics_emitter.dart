import '../../domain/entities/pass.dart';
import '../../domain/entities/service_failure.dart';
import '../../domain/entities/service_status.dart';
import '../../domain/entities/trip.dart';
import '../../domain/repositories/analytics_emitter.dart';
import 'analytics_sink.dart';

/// The composition root's real `AnalyticsEmitter`: defines each funnel
/// event's name and payload once, per contracts/analytics-events.md and
/// Constitution Principle VII (observability without PII — no payload field
/// here ever carries a credential token, document data, or name), and hands
/// every event to each of its [sinks] (015 research §11).
class LoggingAnalyticsEmitter implements AnalyticsEmitter {
  LoggingAnalyticsEmitter({required List<AnalyticsSink> sinks})
    : _sinks = List.unmodifiable(sinks);

  final List<AnalyticsSink> _sinks;

  void _log(String eventName, [Map<String, Object?> payload = const {}]) {
    for (final sink in _sinks) {
      sink.record(eventName, payload);
    }
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

  @override
  void credentialIssuanceRequested() {
    _log('credential_issuance_requested');
  }

  @override
  void credentialIssuanceOutcome({required IssuanceOutcomeKind kind}) {
    _log('credential_issuance_outcome', {'kind': kind.name});
  }

  @override
  void credentialActivatedShown() {
    _log('credential_activated_shown');
  }

  @override
  void credentialActivatedRouteTaken({required OnwardRoute route}) {
    _log('credential_activated_route_taken', {'route': route.name});
  }

  @override
  void verificationStepEntered() {
    _log('verification_step_entered');
  }

  @override
  void verificationStageReached({
    required VerificationStage stage,
    required StageStatus status,
  }) {
    _log('verification_stage_reached', {
      'stage': stage.name,
      'status': status.name,
    });
  }

  @override
  void verificationSlowNoticeShown() {
    _log('verification_slow_notice_shown');
  }

  @override
  void verificationHelpOpened() {
    _log('verification_help_opened');
  }

  @override
  void verificationTimedOut() {
    _log('verification_timed_out');
  }

  @override
  void verificationOutcome({
    required VerificationOutcomeKind kind,
    required int elapsedSeconds,
  }) {
    _log('verification_outcome', {
      'kind': kind.name,
      'elapsedSeconds': elapsedSeconds,
    });
  }

  @override
  void retryGuidanceShown({required RetryGuidanceState state}) {
    _log('retry_guidance_shown', {'state': state.name});
  }

  @override
  void retryGuidanceRetryTaken() {
    _log('retry_guidance_retry_taken');
  }

  @override
  void retryGuidanceAgentRouteTaken({required RetryGuidanceState state}) {
    _log('retry_guidance_agent_route_taken', {'state': state.name});
  }

  @override
  void escalationShown({required EscalationArrival arrival}) {
    _log('escalation_shown', {'arrival': arrival.name});
  }

  @override
  void escalationChannelsOffered({
    required bool moduleAvailable,
    required bool chatAvailable,
  }) {
    _log('escalation_channels_offered', {
      'moduleAvailable': moduleAvailable,
      'chatAvailable': chatAvailable,
    });
  }

  @override
  void escalationChannelSelected({required AgentChannelKind channel}) {
    _log('escalation_channel_selected', {'channel': channel.name});
  }

  @override
  void escalationHandoffStarted({required AgentChannelKind channel}) {
    _log('escalation_handoff_started', {'channel': channel.name});
  }

  @override
  void escalationOutcome({
    required EscalationOutcomeKind kind,
    required int elapsedSeconds,
  }) {
    _log('escalation_outcome', {
      'kind': kind.name,
      'elapsedSeconds': elapsedSeconds,
    });
  }

  @override
  void technicalErrorShown({
    required ServiceFailureClass failureClass,
    required VerificationStage? stage,
    required bool jobTerminal,
  }) {
    _log('technical_error_shown', {
      'failureClass': failureClass.name,
      'stage': stage?.name,
      'jobTerminal': jobTerminal,
    });
  }

  @override
  void technicalErrorStatusShown({
    required StepHealth documentScan,
    required StepHealth selfie,
    required StepHealth issuance,
  }) {
    _log('technical_error_status_shown', {
      'documentScan': documentScan.name,
      'selfie': selfie.name,
      'issuance': issuance.name,
    });
  }

  @override
  void technicalErrorRetry({
    required TechnicalErrorRetryDestination destination,
    required int arrival,
  }) {
    _log('technical_error_retry', {
      'destination': destination.name,
      'arrival': arrival,
    });
  }

  @override
  void technicalErrorExit() {
    _log('technical_error_exit', {});
  }

  @override
  void technicalErrorResolved({required int elapsedSeconds}) {
    _log('technical_error_resolved', {'elapsedSeconds': elapsedSeconds});
  }

  @override
  void tripsHomeShown({
    required bool hasNextTrip,
    required bool credentialConfirmed,
  }) {
    _log('trips_home_shown', {
      'hasNextTrip': hasNextTrip,
      'credentialConfirmed': credentialConfirmed,
    });
  }

  @override
  void tripDisplayed({
    required TripStatus status,
    required bool live,
    required bool withinWindow,
  }) {
    _log('trip_displayed', {
      'status': status.name,
      'live': live,
      'withinWindow': withinWindow,
    });
  }

  @override
  void tripStarted({required int completedTripsLast90Days}) {
    _log('trip_started', {
      'completedTripsLast90Days': completedTripsLast90Days,
    });
  }

  @override
  void tripsHistoryViewed({required int rowCount}) {
    _log('trips_history_viewed', {'rowCount': rowCount});
  }

  @override
  void tripsEmptyShown() {
    _log('trips_empty_shown', {});
  }

  @override
  void passDisplayed({
    required Checkpoint checkpoint,
    required bool offlineCapable,
  }) {
    _log('pass_displayed', {
      'checkpoint': checkpoint.name,
      'offlineCapable': offlineCapable,
    });
  }

  @override
  void passRotated({required Checkpoint checkpoint}) {
    _log('pass_rotated', {'checkpoint': checkpoint.name});
  }

  @override
  void passValidated({
    required Checkpoint checkpoint,
    required int secondsSinceOpened,
  }) {
    _log('pass_validated', {
      'checkpoint': checkpoint.name,
      'secondsSinceOpened': secondsSinceOpened,
    });
  }

  @override
  void passUnavailable({required PassUnavailableReason reason}) {
    _log('pass_expired', {'reason': reason.name});
  }

  @override
  void passReissueRequested({required bool succeeded}) {
    _log('pass_reissue_requested', {'succeeded': succeeded});
  }

  @override
  void passHelpOpened() {
    _log('pass_help_opened', {});
  }
}
