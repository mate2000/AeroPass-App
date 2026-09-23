import 'package:meta/meta.dart';

import '../../core/result.dart';
import '../entities/credential_summary.dart';

/// The error `getSummary()` returns when the backend says there is no
/// credential, for example after consent withdrawal. The home screen then
/// goes to welcome.
final class NoCredentialFailure implements Exception {
  const NoCredentialFailure();

  @override
  String toString() => 'NoCredentialFailure';
}

/// The compact credential for Mis viajes (012-mis-viajes,
/// contracts/credential-summary-port.md).
abstract class CredentialSummaryRepository {
  /// Reads the credential's state from the backend, with the stored
  /// display fields as a fallback.
  ///
  /// When the backend cannot be reached but a credential is stored, this is
  /// `Result.ok` with `confirmed: false` and the state inferred from the
  /// stored validity. It is an error only when nothing at all is known, or
  /// with [NoCredentialFailure] when the backend says there is none.
  @useResult
  Future<Result<CredentialSummary>> getSummary();
}
