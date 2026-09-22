import 'dart:typed_data';

import '../../core/result.dart';
import '../../domain/entities/extraction_result.dart';
import '../../domain/entities/field_reverification_outcome.dart';
import '../../domain/repositories/field_reverification_repository.dart';
import 'field_reverification_service.dart';

/// The real `FieldReverificationRepository` implementation, backed by
/// `FieldReverificationService`. Per
/// contracts/field-reverification-port.md: no `dio` exception, DTO, or raw
/// JSON shape may cross out of this class — callers only ever see
/// `FieldReverificationOutcome`/`Result`.
///
/// MUST satisfy the exact same contract test suite as
/// `FakeFieldReverificationRepository`, unmodified (Constitution Principle
/// X, Liskov) — see
/// test/contract/field_reverification_repository_contract_test.dart.
class FieldReverificationRepositoryImpl
    implements FieldReverificationRepository {
  FieldReverificationRepositoryImpl(this._service);

  final FieldReverificationService _service;

  @override
  Future<Result<FieldReverificationOutcome>> reverify({
    required Uint8List documentImageBytes,
    required FieldKey field,
    required String candidateValue,
  }) async {
    try {
      final response = await _service.reverify(
        documentImageBytes: documentImageBytes,
        field: field,
        candidateValue: candidateValue,
      );
      // A missing/malformed `confirmed` key (contract case 4) falls back to
      // `disagreed()` rather than throwing — the same "fail safe, never
      // crash" discipline `_mapReason` already applies to an unrecognized
      // rejection code.
      return Result.ok(
        response.confirmed == true
            ? const FieldReverificationOutcome.confirmed()
            : const FieldReverificationOutcome.disagreed(),
      );
    } catch (e, st) {
      // Offline, timeout, non-2xx, or TLS/pinning failure — treated by the
      // caller identically to `disagreed()` (research.md §6), but still
      // surfaced as `Error` here so a genuine transport failure is never
      // silently indistinguishable from a considered "no" at this layer
      // (Principle IX: no bare exception crossing into the ViewModel).
      return Result.error(e, st);
    }
  }
}
