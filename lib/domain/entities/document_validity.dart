/// Why this screen blocks confirmation outright (FR-008/FR-009), rather
/// than a per-field correction problem. A domain-level concept (not a
/// feature-private view detail) since `AnalyticsEmitter` also needs it.
enum DocumentBlockReason { expired, missingRequiredField }
