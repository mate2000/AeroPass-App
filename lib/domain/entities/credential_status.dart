import 'package:freezed_annotation/freezed_annotation.dart';

part 'credential_status.freezed.dart';

/// Why a credential is no longer usable, per data-model.md.
/// 012-mis-viajes research.md §2: `suspended` added, so the home strip can
/// name it instead of calling it expired.
enum ExpiryReason { expired, revoked, suspended }

/// The classification `WelcomeViewModel` uses to decide what to render,
/// per data-model.md. Returned wrapped in `Result<CredentialStatus>` by
/// `CredentialRepository.getStatus()` (see
/// contracts/credential-status-port.md).
///
/// Modeled as a sealed type (Constitution Principle IX: "sealed types over
/// boolean flags") rather than a trio of `isLoading`/`hasError`/`isEmpty`
/// booleans, because the four variants below are the only states this
/// screen's credential check has.
@freezed
sealed class CredentialStatus with _$CredentialStatus {
  /// No cached credential exists on the device. First-run or
  /// never-enrolled passenger.
  const factory CredentialStatus.noCredential() = NoCredential;

  /// A credential exists and the backend confirms it is currently valid.
  const factory CredentialStatus.valid({required DateTime validUntil}) = Valid;

  /// A credential exists but the backend reports it is no longer usable.
  const factory CredentialStatus.expiredOrRevoked({
    required ExpiryReason reason,
  }) = ExpiredOrRevoked;

  /// The backend could not be reached to confirm status. Carries whatever
  /// status was last confirmed (nullable — never previously confirmed on
  /// this device).
  const factory CredentialStatus.unreachable({
    CredentialStatus? lastKnownStatus,
  }) = Unreachable;
}
