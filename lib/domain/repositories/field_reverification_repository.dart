import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../core/result.dart';
import '../entities/extraction_result.dart';
import '../entities/field_reverification_outcome.dart';

/// The domain-owned adapter boundary over the external verification
/// processor's field-level re-read capability (Constitution Principle II),
/// per contracts/field-reverification-port.md.
///
/// Called only for an edit to a field whose original processor-reported
/// confidence was >=0.95 and whose edited value materially differs from the
/// original (FR-005). A separate port from `DocumentVerificationRepository`
/// — narrower call shape, and interface segregation (Constitution Principle
/// X) argues against bolting a second method onto the port 003 depends on
/// (research.md §4).
abstract class FieldReverificationRepository {
  /// `Result.error` is reserved for transport failure, exactly as
  /// `DocumentVerificationRepository.submit` already reserves it. The
  /// caller treats `Error` identically to
  /// `FieldReverificationOutcome.disagreed()` — both mean "the re-check
  /// could not confirm the edit," and neither falls back to an agent
  /// (Clarifications: automated re-check only).
  @useResult
  Future<Result<FieldReverificationOutcome>> reverify({
    required Uint8List documentImageBytes,
    required FieldKey field,
    required String candidateValue,
  });
}
