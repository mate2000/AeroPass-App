/// Which state the retry screen shows (009-reintento, data-model.md),
/// derived from the attempt counters rather than from how the screen was
/// reached (research.md §1). Also the payload of the screen's analytics.
enum RetryGuidanceState {
  /// A biometric failure below the limit: generic message, advice, retry.
  selfieRetry,

  /// The selfie counter is at the limit: no retry, agent route.
  selfieLimit,

  /// The document counter is at the limit: no retry, agent route.
  documentLimit,
}
