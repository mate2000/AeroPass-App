import 'package:freezed_annotation/freezed_annotation.dart';

import 'activated_credential.dart';
import 'credential_lifecycle_status.dart';

part 'issuance_outcome.freezed.dart';

/// What a credential-issuance request resolved to (data-model.md,
/// research.md §2). Returned inside `Result<IssuanceOutcome>`; a transport
/// or storage failure is `Result.error`, not a variant here.
@freezed
sealed class IssuanceOutcome with _$IssuanceOutcome {
  /// The backend issued an active credential with every display field
  /// present and valid, and its token is already in secure storage.
  const factory IssuanceOutcome.activated({
    required ActivatedCredential credential,
  }) = IssuanceActivated;

  /// The backend issued a credential in a non-active state. [status] is
  /// never [CredentialLifecycleStatus.active].
  const factory IssuanceOutcome.notActive({
    required CredentialLifecycleStatus status,
  }) = IssuanceNotActive;

  /// The backend's response was missing or had malformed required data
  /// (e.g. no validity window, or an unrecognized status).
  const factory IssuanceOutcome.incomplete() = IssuanceIncomplete;
}

/// The classification `AnalyticsEmitter.credentialIssuanceOutcome` carries
/// (contracts/analytics-events.md) — never a payload, only the bucket.
enum IssuanceOutcomeKind { activated, notActive, incomplete, transportError }
