/// The backend's status for an issued credential (data-model.md,
/// 008-identidad-activa). Mapped from the wire value at the data boundary;
/// an unrecognized wire value never becomes one of these — it becomes
/// `IssuanceOutcome.incomplete()` instead (research.md §2).
enum CredentialLifecycleStatus {
  active,
  expired,
  revoked,
  suspended,
  withdrawn,
}
