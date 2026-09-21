import 'dart:typed_data';

import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/capture_outcome.dart';
import 'package:aeropass_app/domain/repositories/document_verification_repository.dart';

/// A scripted, no-network `DocumentVerificationRepository` double, per
/// contracts/document-verification-port.md and Constitution Principle II's
/// "full test suite against a fake with no network linked" pattern. Used by
/// widget/unit tests and by the contract test suite.
class FakeDocumentVerificationRepository
    implements DocumentVerificationRepository {
  Result<CaptureOutcome>? _response;
  int submitCallCount = 0;
  Uint8List? lastSubmittedBytes;

  /// Sets the value the next (and subsequent, until re-scripted) call to
  /// [submit] returns.
  void scriptSubmit(Result<CaptureOutcome> response) {
    _response = response;
  }

  @override
  Future<Result<CaptureOutcome>> submit(Uint8List documentImageBytes) async {
    submitCallCount++;
    lastSubmittedBytes = documentImageBytes;
    return _response ??
        Result.error(StateError('no submit() response scripted'));
  }
}
