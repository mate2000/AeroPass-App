import '../../core/result.dart';
import '../../domain/entities/identity_record.dart';
import '../../domain/repositories/identity_record_repository.dart';
import 'identity_record_service.dart';

/// The real `IdentityRecordRepository` implementation, backed by
/// `IdentityRecordService`. Per contracts/identity-record-repository-port.md:
/// no `dio` exception, DTO, or raw JSON shape may cross out of this class —
/// callers only ever see `IdentityRecord`/`Result`.
///
/// MUST satisfy the exact same contract test suite as
/// `FakeIdentityRecordRepository`, unmodified (Constitution Principle X,
/// Liskov) — see test/contract/identity_record_repository_contract_test.dart.
class IdentityRecordRepositoryImpl implements IdentityRecordRepository {
  IdentityRecordRepositoryImpl(this._service);

  final IdentityRecordService _service;

  @override
  Future<Result<IdentityRecord>> confirm(IdentityRecord record) async {
    try {
      await _service.submit(record);
    } catch (e, st) {
      // Offline, timeout, non-2xx, or TLS/pinning failure: nothing is
      // written locally — FR-017's "where it cannot be recorded, the flow
      // MUST NOT advance."
      return Result.error(e, st);
    }
    // Only a confirmed backend submission makes the display-only subset
    // durable locally (research.md §5) — never write it speculatively
    // ahead of the backend's own confirmation.
    await _service.writeDisplaySubset(record);
    return Result.ok(record);
  }
}
