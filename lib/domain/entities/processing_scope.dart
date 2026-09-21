/// What a `ConsentRecord` covers, distinguishing it from any other purpose
/// that would require its own consent (FR-005, data-model.md). A plain
/// closed enum — adding a second purpose (analytics, communications) is a
/// spec amendment, not a new case slipped in here.
enum ProcessingScope {
  /// The only variant at this release. Identity verification by the
  /// external processor.
  identityVerification,
}
