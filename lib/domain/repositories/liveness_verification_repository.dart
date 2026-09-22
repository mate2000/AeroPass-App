import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../core/result.dart';
import '../entities/liveness_sample_outcome.dart';

/// The one port through which every liveness/attack-detection
/// classification this app ever displays or records originates
/// (contracts/liveness-verification-port.md, research.md §1) — FR-002's
/// "device never decides liveness" security boundary lives here
/// structurally, not by convention: `LivenessCaptureViewModel` never
/// inspects frame content, only relays this port's classification.
abstract class LivenessVerificationRepository {
  /// Begins one attempt. `Result.error` is a transport failure (offline,
  /// timeout, pinning failure) — before any frame has been sent, nothing
  /// has been risked.
  @useResult
  Future<Result<String>> startSession();

  /// Called repeatedly, once per sampled frame, until it returns
  /// `Ok(LivenessSampleOutcome.completed(...))`. [frameBytes] is never
  /// retained by the caller after this call returns (FR-008).
  ///
  /// `Result.error` is a transport failure mid-attempt — the ViewModel
  /// treats it as a non-terminal hiccup up to a small retry bound, and as
  /// `LivenessOutcome.unclassifiedFailure()` if retries are exhausted —
  /// never as `LivenessOutcome.attackDetected()`, since a transport failure
  /// carries no security signal at all.
  @useResult
  Future<Result<LivenessSampleOutcome>> submitSample({
    required String sessionId,
    required Uint8List frameBytes,
  });
}
