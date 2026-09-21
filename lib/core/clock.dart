/// Injected behind an interface everywhere it's needed (Constitution
/// Principle X, Dependency inversion: "the clock in particular, because
/// pass expiry is untestable otherwise"). This feature uses it for
/// analytics-event timestamps and `EnrollmentSession.startedAt`, both of
/// which need to be deterministic in tests.
abstract class Clock {
  DateTime now();
}

/// The real, wall-clock-backed [Clock], wired at the composition root.
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}
