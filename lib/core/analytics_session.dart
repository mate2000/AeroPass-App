import 'uuid.dart';

/// A single id generated once per app launch by the composition root and
/// injected into whatever emits FR-013's funnel events for the welcome
/// screen, per data-model.md ("AnalyticsSessionId (in-memory only)") and
/// contracts/analytics-events.md.
///
/// **Never persisted, never reused across launches** — this is the
/// narrowing the Constitution Check in plan.md required to keep Principle
/// I's persisted-state allowlist satisfied. It exists only in memory for
/// the lifetime of the current app process.
class AnalyticsSessionId {
  AnalyticsSessionId._(this.value);

  factory AnalyticsSessionId.generate() =>
      AnalyticsSessionId._(generateUuidV4());

  final String value;

  @override
  String toString() => value;
}
