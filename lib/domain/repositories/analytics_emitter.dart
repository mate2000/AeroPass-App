import '../entities/capture_outcome.dart' show CaptureRejectionReason;
import '../entities/consent_unavailable_reason.dart' show UnavailableReason;
import '../entities/document_validity.dart' show DocumentBlockReason;
import '../entities/escalation.dart'
    show AgentChannelKind, EscalationArrival, EscalationOutcomeKind;
import '../entities/extraction_result.dart' show FieldKey;
import '../entities/issuance_outcome.dart' show IssuanceOutcomeKind;
import '../entities/liveness_outcome.dart' show LivenessQualityReason;
import '../entities/onward_route.dart' show OnwardRoute;
import '../entities/retry_guidance_state.dart' show RetryGuidanceState;
import '../entities/pass.dart' show Checkpoint, PassUnavailableReason;
import '../entities/service_failure.dart'
    show ServiceFailureClass, TechnicalErrorRetryDestination;
import '../entities/service_status.dart' show StepHealth;
import '../entities/trip.dart' show TripStatus;
import '../entities/verification_outcome.dart' show VerificationOutcomeKind;
import '../entities/verification_stage.dart'
    show StageStatus, VerificationStage;
import '../entities/welcome_content_variant.dart'
    show DeviceUnsupportedReason, WelcomeScreenVariant;

export '../entities/capture_outcome.dart' show CaptureRejectionReason;
export '../entities/consent_unavailable_reason.dart' show UnavailableReason;
export '../entities/document_validity.dart' show DocumentBlockReason;
export '../entities/escalation.dart'
    show AgentChannelKind, EscalationArrival, EscalationOutcomeKind;
export '../entities/extraction_result.dart' show FieldKey;
export '../entities/issuance_outcome.dart' show IssuanceOutcomeKind;
export '../entities/liveness_outcome.dart' show LivenessQualityReason;
export '../entities/onward_route.dart' show OnwardRoute;
export '../entities/retry_guidance_state.dart' show RetryGuidanceState;
export '../entities/verification_outcome.dart' show VerificationOutcomeKind;
export '../entities/verification_stage.dart'
    show StageStatus, VerificationStage;
export '../entities/welcome_content_variant.dart'
    show DeviceUnsupportedReason, WelcomeScreenVariant;

/// The classification `AnalyticsEmitter.livenessOutcome` carries — a
/// narrower vocabulary than `LivenessOutcome` itself since analytics never
/// needs the outcome's payload, only which terminal bucket it fell into
/// (contracts/analytics-events.md).
enum LivenessOutcomeKind {
  success,
  qualityFailure,
  unclassifiedFailure,
  attackDetected,
}

/// The funnel-event port this screen emits through, per FR-013 and
/// contracts/analytics-events.md. A narrow, typed interface (Constitution
/// Principle X: interface segregation) rather than a stringly-typed
/// `emit(name, payload)` — each method corresponds 1:1 to one contract
/// event, so an event name or payload shape can never drift between the
/// contract and the call sites.
///
/// Every event is keyed by the in-memory, per-launch
/// [AnalyticsSessionId](../../core/analytics_session.dart) and MUST carry
/// no personal data (Constitution Principle VII) — implementations attach
/// the session id and a timestamp; callers never pass either.
abstract class AnalyticsEmitter {
  /// The welcome content actually renders (not the launch splash, and not
  /// when the passenger is routed straight to trips).
  void welcomeScreenShown(WelcomeScreenVariant variant);

  /// The primary action ("begin enrollment") is activated, once per
  /// created `EnrollmentSession` (FR-004's single-session guarantee
  /// applies here too).
  void welcomePrimaryActionTapped(WelcomeScreenVariant variant);

  /// The secondary action (account recovery on a new device) is
  /// activated.
  void welcomeSecondaryActionTapped();

  /// The passenger navigates to the privacy/data-handling terms from this
  /// screen (User Story 3).
  void welcomePrivacyTermsOpened();

  /// The device-capability check fails and the unsupported-device message
  /// is shown instead of the normal welcome content (FR-012).
  void welcomeDeviceUnsupportedShown(DeviceUnsupportedReason reason);

  /// The consent gate's content renders (text successfully fetched),
  /// per contracts/analytics-events.md.
  void consentGateShown({required bool hasPriorRecord});

  /// The text fetch fails and the blocking unavailable state renders
  /// instead.
  void consentGateUnavailableShown({required UnavailableReason reason});

  /// `recordConsent()` returns `Ok` (SC-002's "identifies the exact text
  /// version" measurement).
  void consentConfirmed({required String textVersionId});

  /// `recordConsent()` returns `Error` (FR-008's blocked-advance path).
  void consentConfirmFailed();

  /// The passenger taps "Ahora no".
  void consentDeclined();

  /// Back gesture / barrier tap / system navigation (FR-010).
  void consentDismissed();

  // --- 003-escanear-documento: contracts/analytics-events.md -------------

  /// The capture screen opens and passes the consent-currency gate
  /// (FR-001).
  void captureStepEntered();

  /// The camera permission is denied, temporary or permanent (FR-014).
  void capturePermissionDeniedShown({required bool permanent});

  /// The passenger activates the capture control (FR-016).
  /// [attemptNumber] is the current `CaptureAttemptCounter.count + 1`.
  void captureAttempted({required int attemptNumber});

  /// The on-device quality assessment rejects the capture (FR-006).
  void captureDeviceRejected({required CaptureRejectionReason reason});

  /// The verification processor rejects a device-passed capture (FR-008).
  void captureVerificationRejected({required CaptureRejectionReason reason});

  /// The verification processor accepts the capture.
  void captureAccepted();

  /// The 3rd failure routes to retry guidance (FR-009).
  void captureAttemptLimitReached();

  /// The screen is left (back navigation) with no outcome recorded.
  void captureStepAbandoned();

  // --- 004-confirmar-datos: contracts/analytics-events.md ----------------

  /// The confirmation screen opens with a non-empty
  /// `PendingDocumentController` (FR-016).
  void confirmationStepEntered();

  /// The passenger edits a field. Never the value.
  void confirmationFieldEdited({required FieldKey field});

  /// A field's automated re-check (FR-005) completes.
  void confirmationFieldReverified({
    required FieldKey field,
    required bool confirmed,
  });

  /// The 3rd unresolved correction attempt routes to re-scan (FR-019).
  void confirmationCorrectionAttemptLimitReached();

  /// The passenger chooses "Escanear de nuevo".
  void confirmationRescanned();

  /// The screen opens to an expired document or a missing required field
  /// (FR-008/FR-009).
  void confirmationBlockedUnusableDocument({
    required DocumentBlockReason reason,
  });

  /// `IdentityRecordRepository.confirm()` returns `Ok`.
  void confirmationConfirmed();

  /// `IdentityRecordRepository.confirm()` returns `Error` (FR-017).
  void confirmationConfirmFailed();

  /// The screen is left (back navigation) with no outcome recorded.
  void confirmationStepAbandoned();

  // --- 005-instrucciones-selfie: contracts/analytics-events.md ------------

  /// The screen opens (FR-010).
  void selfieInstructionsStepEntered();

  /// The passenger activates "Tomar selfie".
  void selfieInstructionsAdvanced();

  /// The passenger activates "Ayuda".
  void selfieInstructionsHelpOpened();

  /// The screen is left (back navigation) with no advance recorded.
  void selfieInstructionsStepAbandoned();

  // --- 006-selfie-liveness: contracts/analytics-events.md ----------------

  /// The screen opens and passes the reachability guard.
  void livenessStepEntered();

  /// A new phase begins (FR-007: index only ever increases).
  void livenessPhaseReached({
    required int phaseIndex,
    required int totalPhases,
  });

  /// An attempt reaches a terminal outcome. [reason] is present only when
  /// [outcome] is [LivenessOutcomeKind.qualityFailure]. Per research.md §8:
  /// carries the *full* classification (including `attackDetected`
  /// specifically) — a security-monitoring signal, never shown to the
  /// passenger, and the local half of SC-007's audit obligation.
  void livenessOutcome({
    required LivenessOutcomeKind outcome,
    LivenessQualityReason? reason,
  });

  /// Alongside each [livenessOutcome] for a non-success result.
  void livenessAttemptCount({required int attemptNumber});

  /// The 3rd failed attempt routes to retry guidance.
  void livenessAttemptLimitReached();

  /// FR-013's time limit elapses with no terminal outcome.
  void livenessStalled();

  /// The screen is left (back navigation) with no outcome recorded.
  void livenessStepAbandoned();

  // --- 008-identidad-activa: contracts/analytics-events.md ---------------
  // No event carries a name, document digits, country, date, token or
  // enrollment attempt id (FR-015, not relaxable in any mode).

  /// Each issuance request, including retries.
  void credentialIssuanceRequested();

  /// Each issuance result, as a bucket only.
  void credentialIssuanceOutcome({required IssuanceOutcomeKind kind});

  /// Screen 08 is created (once per issued credential, FR-009).
  void credentialActivatedShown();

  /// The passenger leaves screen 08 by one of its onward routes.
  void credentialActivatedRouteTaken({required OnwardRoute route});

  // --- 007-validando: contracts/analytics-events.md ----------------------
  // Enum and integer payloads only; attack detection is folded into
  // `biometricRejected` (FR-015, SC-007).

  /// The verification screen opens.
  void verificationStepEntered();

  /// A stage becomes running, passed or failed.
  void verificationStageReached({
    required VerificationStage stage,
    required StageStatus status,
  });

  /// The 10-second "taking longer than usual" notice appears.
  void verificationSlowNoticeShown();

  /// "Ayuda" is tapped from the notice.
  void verificationHelpOpened();

  /// The 30-second hard timeout is reached.
  void verificationTimedOut();

  /// Once, when the screen routes onward. [elapsedSeconds] is rounded and
  /// measured from the screen opening (FR-016).
  void verificationOutcome({
    required VerificationOutcomeKind kind,
    required int elapsedSeconds,
  });

  // --- 009-reintento: contracts/analytics-events.md ----------------------
  // The state is the failure class: which capture, and whether at the limit.
  // No event distinguishes attack detection (FR-015, SC-003).

  /// The retry screen opens and its state is known.
  void retryGuidanceShown({required RetryGuidanceState state});

  /// "Intentar de nuevo" is tapped.
  void retryGuidanceRetryTaken();

  /// "Hablar con un agente" is tapped.
  void retryGuidanceAgentRouteTaken({required RetryGuidanceState state});

  // --- 010-escalar-agente: contracts/analytics-events.md -----------------
  // No personal data; the agent's document-number lookup never passes
  // through the app (FR-017, FR-023).

  /// The escalation is open and shown.
  void escalationShown({required EscalationArrival arrival});

  /// Channels are first shown, or their availability changes.
  void escalationChannelsOffered({
    required bool moduleAvailable,
    required bool chatAvailable,
  });

  /// The passenger selects a channel.
  void escalationChannelSelected({required AgentChannelKind channel});

  /// The primary action is tapped.
  void escalationHandoffStarted({required AgentChannelKind channel});

  /// Once, when an outcome or expiry is shown (FR-018).
  void escalationOutcome({
    required EscalationOutcomeKind kind,
    required int elapsedSeconds,
  });

  // --- 011-error-tecnico (contracts/analytics-events.md) --------------------

  /// Once, when screen 11 opens (FR-015).
  void technicalErrorShown({
    required ServiceFailureClass failureClass,
    required VerificationStage? stage,
    required bool jobTerminal,
  });

  /// Once, on the first successful live status read (FR-015).
  void technicalErrorStatusShown({
    required StepHealth documentScan,
    required StepHealth selfie,
    required StepHealth issuance,
  });

  /// When "Reintentar" is taken; [arrival] counts screen 11 visits this run.
  void technicalErrorRetry({
    required TechnicalErrorRetryDestination destination,
    required int arrival,
  });

  /// When "Salir" is taken.
  void technicalErrorExit();

  /// When a credential activates after an earlier technical error this run.
  void technicalErrorResolved({required int elapsedSeconds});

  // --- 012-mis-viajes (contracts/analytics-events.md) -----------------------
  // No payload carries a flight number, route, airport, date, seat or trip id.

  /// Once per visit, when the home screen first shows content.
  void tripsHomeShown({
    required bool hasNextTrip,
    required bool credentialConfirmed,
  });

  /// Once per visit, when a next trip is shown.
  void tripDisplayed({
    required TripStatus status,
    required bool live,
    required bool withinWindow,
  });

  /// When "Iniciar viaje" is taken. The count makes repeat use derivable
  /// from events alone (research.md §9).
  void tripStarted({required int completedTripsLast90Days});

  /// Once per visit, when the history section first scrolls into view.
  void tripsHistoryViewed({required int rowCount});

  /// Once per visit, when there is no next trip.
  void tripsEmptyShown();

  // --- 014-qr-pase (contracts/analytics-events.md) --------------------------
  // No payload carries a pass payload, pass id, secret, flight or date.

  /// When a code is first shown in a visit.
  void passDisplayed({
    required Checkpoint checkpoint,
    required bool offlineCapable,
  });

  /// At each rotation.
  void passRotated({required Checkpoint checkpoint});

  /// When the backend reports a checkpoint validated. [secondsSinceOpened]
  /// is FR-018's time to validation.
  void passValidated({
    required Checkpoint checkpoint,
    required int secondsSinceOpened,
  });

  /// When the pass stops being usable, and why.
  void passUnavailable({required PassUnavailableReason reason});

  /// When a new code is requested.
  void passReissueRequested({required bool succeeded});

  /// When help is opened from the pass.
  void passHelpOpened();
}
