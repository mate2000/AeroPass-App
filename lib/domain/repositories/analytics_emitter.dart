import '../entities/capture_outcome.dart' show CaptureRejectionReason;
import '../entities/consent_unavailable_reason.dart' show UnavailableReason;
import '../entities/welcome_content_variant.dart'
    show DeviceUnsupportedReason, WelcomeScreenVariant;

export '../entities/capture_outcome.dart' show CaptureRejectionReason;
export '../entities/consent_unavailable_reason.dart' show UnavailableReason;
export '../entities/welcome_content_variant.dart'
    show DeviceUnsupportedReason, WelcomeScreenVariant;

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
}
