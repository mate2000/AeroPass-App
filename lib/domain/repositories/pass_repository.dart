import 'package:meta/meta.dart';

import '../../core/result.dart';
import '../entities/pass.dart';

/// Pass issuance and status (014-qr-pase, contracts/pass-port.md). The
/// backend is the only issuer and the only authority on validity (FR-002).
abstract class PassRepository {
  /// Asks the backend to issue a pass for the started trip [tripId].
  @useResult
  Future<Result<Pass>> issue(String tripId);

  /// Reads the backend's current word on [passId]. An unknown state is an
  /// error, never "active".
  @useResult
  Future<Result<PassState>> status(String passId);

  /// The pass issued for [tripId] in this app session, if it is still
  /// within its validity. Phase A keeps it in memory only.
  Pass? activePassFor(String tripId);

  /// Drops [passId] from the device: after boarding, expiry, or a request
  /// for a new code.
  Future<void> forget(String passId);
}
