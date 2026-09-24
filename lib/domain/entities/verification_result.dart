/// One selfie verification's result, as the domain sees it (015
/// data-model.md, contracts/outcome-mapping.md "Verification").
///
/// Two things from the wire are deliberately missing:
///
/// - **Scores**: they stay in the data layer (FR-007).
/// - **The liveness reason**: `LIVENESS` and a null reason both become
///   [FailureReason.generic], so the attack-detection signal ends at the
///   mapper (FR-006).
sealed class VerificationResult {
  const VerificationResult();
}

/// `EXITOSO`. [identityId] may be null, and then 008 re-reads `/me`.
final class Verified extends VerificationResult {
  const Verified({this.identityId});

  final String? identityId;
}

enum FailureReason {
  /// `COMPARACION`: the face did not match the document photo.
  match,

  /// Any other reason, including `LIVENESS`.
  generic,
}

/// `FALLIDO` with attempts left. [remaining] is the backend's
/// `intentos_restantes`, the only retry budget (FR-008).
final class Failed extends VerificationResult {
  const Failed({required this.reason, required this.remaining});

  final FailureReason reason;
  final int remaining;
}

/// `NO_CONCLUYENTE`: the service could not decide. No attempt was consumed
/// (FR-005).
final class Inconclusive extends VerificationResult {
  const Inconclusive({this.retryAfter});

  final Duration? retryAfter;
}

/// `REQUIERE_REVISION_MANUAL`, or no attempts left: the agent path (FR-009).
final class NeedsReview extends VerificationResult {
  const NeedsReview();
}

/// 409 `ESTADO_NO_PERMITE_VERIFICACION`: the passenger is already verified or
/// in review. Re-read `/me` and route by state.
final class StateChanged extends VerificationResult {
  const StateChanged();
}

/// 404 `PASAJERO_NO_REGISTRADO`: there is no registration to verify against.
final class NotRegistered extends VerificationResult {
  const NotRegistered();
}

/// 413, 415 or 422: the selfie itself was unusable. Take it again.
final class RecaptureSelfie extends VerificationResult {
  const RecaptureSelfie();
}
