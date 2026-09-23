import 'package:meta/meta.dart';

import '../../core/result.dart';
import '../entities/issuance_outcome.dart';

/// The issue-only port through which the app learns that a credential was
/// issued (contracts/credential-issuance-port.md, 008-identidad-activa).
/// Every active credential this app ever displays originates here (FR-001,
/// SC-001).
///
/// Kept separate from the read-only `CredentialRepository` on purpose:
/// Constitution Principle X's interface segregation — "a ViewModel that
/// needs to read a credential MUST NOT receive an interface that can also
/// issue or revoke one" (research.md §1). Only `VerificationProgressViewModel`
/// receives this port.
abstract class CredentialIssuanceRepository {
  /// Requests issuance for the current enrollment attempt.
  ///
  /// On `Ok(IssuanceOutcome.activated(...))`, the credential token and its
  /// validity have **already** been written to secure storage; if that
  /// write fails, the result is `Result.error`, never `activated`. On any
  /// other outcome nothing is written. No DTO, `dio` type or backend error
  /// code crosses out of the implementation (Principle II).
  @useResult
  Future<Result<IssuanceOutcome>> requestIssuance();
}
