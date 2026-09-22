import 'package:meta/meta.dart';

import '../../core/result.dart';
import '../entities/identity_record.dart';

/// The domain-owned port `DocumentConfirmationViewModel` depends on to
/// record confirmation durably (FR-017), per
/// contracts/identity-record-repository-port.md.
abstract class IdentityRecordRepository {
  /// Submits the full record — every field's value, `FieldSource`, and, for
  /// a corrected field, its original value and whether it was automatically
  /// re-verified — to the backend, mirroring
  /// `ConsentRepositoryImpl.recordConsent()`'s "submit first, only durable
  /// on backend success" shape (research.md §5).
  ///
  /// On `Ok`, the real implementation additionally writes a
  /// **display-only subset** (each field's key+value only — no source,
  /// original, or reverified data) to secure storage, the one persisted-
  /// state category this feature introduces, already named in the
  /// Constitution's Principle I allowlist. On `Error` (offline, timeout,
  /// backend rejection), nothing is written locally — FR-017's "where it
  /// cannot be recorded, the flow MUST NOT advance."
  @useResult
  Future<Result<IdentityRecord>> confirm(IdentityRecord record);
}
