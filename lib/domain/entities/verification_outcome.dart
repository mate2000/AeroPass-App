import 'package:freezed_annotation/freezed_annotation.dart';

part 'verification_outcome.freezed.dart';

/// A verification job's terminal result, normalized at the data boundary
/// (007-validando, research.md §4). An unrecognized backend code is always
/// [VerificationOutcome.serviceFailure], never a passenger rejection.
@freezed
sealed class VerificationOutcome with _$VerificationOutcome {
  /// Document and face both passed; issuance may be requested.
  const factory VerificationOutcome.matched() = VerificationMatched;

  const factory VerificationOutcome.documentRejected() =
      VerificationDocumentRejected;

  const factory VerificationOutcome.faceMismatch() = VerificationFaceMismatch;

  /// The backend rejected liveness after capture.
  const factory VerificationOutcome.livenessRejected() =
      VerificationLivenessRejected;

  /// Distinct for audit; identical to [VerificationOutcome.faceMismatch]
  /// for the passenger (FR-012, SC-007).
  const factory VerificationOutcome.attackDetected() =
      VerificationAttackDetected;

  const factory VerificationOutcome.serviceFailure() =
      VerificationServiceFailure;

  /// 015 FR-009: the backend put the passenger in manual review
  /// (`REQUIERE_REVISION_MANUAL`), or no attempts are left. It goes to the
  /// agent path, not to a retry.
  const factory VerificationOutcome.manualReview() = VerificationManualReview;
}

/// The bucket `AnalyticsEmitter.verificationOutcome` carries
/// (contracts/analytics-events.md). [biometricRejected] covers face
/// mismatch, liveness and attack detection together, so no event isolates
/// attack detection.
enum VerificationOutcomeKind {
  activated,
  notActive,
  documentRejected,
  biometricRejected,
  serviceFailure,
  timedOut,
}
