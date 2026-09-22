import '../entities/capture_outcome.dart' show CaptureRejectionReason;
import '../entities/consent_unavailable_reason.dart' show UnavailableReason;
import '../entities/document_validity.dart' show DocumentBlockReason;
import '../entities/extraction_result.dart' show FieldKey;
import '../entities/liveness_outcome.dart' show LivenessQualityReason;
import '../entities/welcome_content_variant.dart'
    show DeviceUnsupportedReason, WelcomeScreenVariant;

export '../entities/capture_outcome.dart' show CaptureRejectionReason;
export '../entities/consent_unavailable_reason.dart' show UnavailableReason;
export '../entities/document_validity.dart' show DocumentBlockReason;
export '../entities/extraction_result.dart' show FieldKey;
export '../entities/liveness_outcome.dart' show LivenessQualityReason;
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
  void livenessPhaseReached({required int phaseIndex, required int totalPhases});

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
}
