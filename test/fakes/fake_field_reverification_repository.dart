import 'dart:typed_data';

import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/extraction_result.dart';
import 'package:aeropass_app/domain/entities/field_reverification_outcome.dart';
import 'package:aeropass_app/domain/repositories/field_reverification_repository.dart';

/// A scripted, no-network `FieldReverificationRepository` double, per
/// contracts/field-reverification-port.md. Used by widget/unit tests and by
/// the contract test suite.
class FakeFieldReverificationRepository
    implements FieldReverificationRepository {
  Result<FieldReverificationOutcome>? _response;
  int reverifyCallCount = 0;
  FieldKey? lastField;
  String? lastCandidateValue;

  /// Sets the value the next (and subsequent, until re-scripted) call to
  /// [reverify] returns.
  void scriptReverify(Result<FieldReverificationOutcome> response) {
    _response = response;
  }

  @override
  Future<Result<FieldReverificationOutcome>> reverify({
    required Uint8List documentImageBytes,
    required FieldKey field,
    required String candidateValue,
  }) async {
    reverifyCallCount++;
    lastField = field;
    lastCandidateValue = candidateValue;
    return _response ??
        Result.error(StateError('no reverify() response scripted'));
  }
}
