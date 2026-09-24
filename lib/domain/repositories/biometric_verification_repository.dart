import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../core/result.dart';
import '../entities/verification_result.dart';

/// Sends one selfie for verification (`POST /v1/biometrics/verifications`,
/// 015 research.md §7). The call is synchronous: the result comes back in
/// the response.
///
/// Every documented backend answer is `Ok` with a [VerificationResult].
/// `Error` means the answer never arrived: a `TransportFailure`, a
/// `SessionUnavailable`, or an undocumented `BackendError`. The caller drops
/// [selfieJpeg] as soon as this returns (Principle I).
abstract class BiometricVerificationRepository {
  @useResult
  Future<Result<VerificationResult>> verify(Uint8List selfieJpeg);
}
