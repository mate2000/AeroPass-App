import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../core/result.dart';
import '../entities/capture_outcome.dart';

/// The domain-owned adapter boundary over the external verification
/// processor (Constitution Principle II: "that provider MUST sit behind a
/// domain-owned port"), per
/// contracts/document-verification-port.md.
///
/// Called only after `DocumentQualityAssessor.assess()` returns `usable`
/// (FR-006) — this port never sees a device-rejected capture.
/// [documentImageBytes] is never retained by the caller after this call
/// returns, by convention (FR-010).
abstract class DocumentVerificationRepository {
  /// `Result.error` is reserved for transport failure (offline, timeout,
  /// pinning failure) — FR-015's "verification cannot be sent yet" state.
  /// A processor-side *rejection* of the document is `Ok` wrapping
  /// `CaptureOutcome.rejected(...)` — an expected, classified outcome with
  /// its own defined UI state, not an exceptional one.
  @useResult
  Future<Result<CaptureOutcome>> submit(Uint8List documentImageBytes);
}
