import 'package:freezed_annotation/freezed_annotation.dart';

import 'verification_stage.dart';

part 'service_failure.freezed.dart';

/// What the app knows about why verification could not finish
/// (011-error-tecnico, research.md §1). It decides the wording on screen 11,
/// never blame.
enum ServiceFailureClass {
  /// The backend answered and said the service failed.
  service,

  /// Every request that could have answered failed to reach the server.
  connectivity,

  /// The evidence does not say whose problem it was (FR-010).
  undetermined,
}

/// Where "Reintentar" on screen 11 sends the passenger (research.md §4).
enum TechnicalErrorRetryDestination {
  /// Back to 007, which re-reads the same job; nothing is resubmitted.
  verification,

  /// To 006, for a new selfie, because the failed job can never finish.
  selfie,
}

/// One failure, recorded by 007 just before it opens screen 11
/// (data-model.md). Held in memory only.
@freezed
sealed class ServiceFailure with _$ServiceFailure {
  const factory ServiceFailure({
    required ServiceFailureClass failureClass,
    required VerificationStage stage,

    /// True only when the job completed with `serviceFailure`: that job can
    /// never finish, so a retry needs a new selfie (FR-004).
    required bool jobTerminal,
    required DateTime occurredAt,
  }) = _ServiceFailure;
}
