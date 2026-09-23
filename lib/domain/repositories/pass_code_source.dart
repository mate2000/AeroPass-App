import 'package:meta/meta.dart';

import '../../core/result.dart';
import '../entities/pass.dart';

/// Where each rotation window's code comes from (014-qr-pase,
/// contracts/pass-port.md). Phase A fetches it from the backend; phase B
/// derives it from a backend-issued secret, and is blocked until the
/// constitution amendment is ratified.
abstract class PassCodeSource {
  /// The code for the rotation window containing [instant]. An error means
  /// no code: a stale or guessed one is never returned.
  @useResult
  Future<Result<PassCode>> codeAt(Pass pass, DateTime instant);
}
