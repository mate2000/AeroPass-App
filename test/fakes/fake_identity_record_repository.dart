import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/identity_record.dart';
import 'package:aeropass_app/domain/repositories/identity_record_repository.dart';

/// A scripted, no-network `IdentityRecordRepository` double, per
/// contracts/identity-record-repository-port.md. Used by widget/unit tests
/// and by the contract test suite. Mirrors the real implementation's "only
/// cache the display-only subset after a successful confirm" rule, so tests
/// can assert on [cachedSubset] the same way they would against
/// `IdentityRecordService.readDisplaySubsetForTesting()`.
class FakeIdentityRecordRepository implements IdentityRecordRepository {
  Result<IdentityRecord>? _response;
  int confirmCallCount = 0;
  IdentityRecord? lastSubmittedRecord;
  Map<String, String> cachedSubset = {};

  /// Sets the value the next (and subsequent, until re-scripted) call to
  /// [confirm] returns.
  void scriptConfirm(Result<IdentityRecord> response) {
    _response = response;
  }

  @override
  Future<Result<IdentityRecord>> confirm(IdentityRecord record) async {
    confirmCallCount++;
    lastSubmittedRecord = record;
    final response =
        _response ?? Result.error(StateError('no confirm() response scripted'));
    if (response.isOk) {
      cachedSubset = {for (final field in record.fields) field.key.name: field.value};
    }
    return response;
  }
}
