import 'package:meta/meta.dart';

import '../../core/result.dart';
import '../entities/credential_status.dart';

/// The domain-owned port `WelcomeViewModel` depends on to resolve
/// launch-time credential status, per
/// contracts/credential-status-port.md.
///
/// Constitution Principle II (adapter boundary) and Principle IX (Result
/// objects) both apply: no provider SDK type, DTO, or `dio` exception may
/// appear outside `data/services/` — consumers only ever see
/// `CredentialStatus`/`Result`.
abstract class CredentialRepository {
  /// Resolves the current credential status.
  ///
  /// Unreachability (network/timeout/pinning failure) is a classified,
  /// expected outcome represented as `Ok(Unreachable(...))`, not an
  /// `Error` — the UI has a defined state for it (FR-007). `Error` is
  /// reserved for truly unclassified failures the caller cannot recover
  /// from by showing last-known state.
  ///
  /// MUST complete within the app's overall splash budget (SC-003: ≤2s
  /// p90 including this call, on the minimum-spec device).
  @useResult
  Future<Result<CredentialStatus>> getStatus();
}
