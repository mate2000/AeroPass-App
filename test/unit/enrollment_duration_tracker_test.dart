// 015-observabilidad-sentry T025: registration duration for the p90 of
// KR A1.4, measured only for attempts that start and finish in the same
// launch (research §3, data-model EnrollmentTiming, spec FR-007).
import 'package:aeropass_app/data/services/enrollment_duration_tracker.dart';
import 'package:aeropass_app/domain/entities/enrollment_attempt_id.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../fakes/fake_clock.dart';

typedef _Written = ({
  String name,
  num value,
  String? unit,
  Map<String, Object?> attributes,
});

void main() {
  late FakeClock clock;
  late List<_Written> written;
  late EnrollmentDurationTracker tracker;
  final attemptA = EnrollmentAttemptId('a');
  final attemptB = EnrollmentAttemptId('b');

  setUp(() {
    clock = FakeClock();
    written = [];
    tracker = EnrollmentDurationTracker(
      clock: clock,
      writeDistribution: (name, value, {unit, attributes}) => written.add((
        name: name,
        value: value,
        unit: unit,
        attributes: {
          for (final e
              in (attributes ?? const <String, SentryAttribute>{}).entries)
            e.key: e.value.value,
        },
      )),
    );
  });

  test('emits the duration in ms from start to completion', () {
    tracker.attemptStarted(attemptA);
    clock.advance(const Duration(minutes: 2, seconds: 30));
    tracker.attemptCompleted(attemptA);

    expect(written.single.name, 'enrollment.duration');
    expect(written.single.value, 150000);
    expect(written.single.unit, 'millisecond');
    expect(written.single.attributes, {'aeropass.resumed': false});
  });

  test('a later capture_step_entered does not move the start', () {
    tracker.attemptStarted(attemptA);
    clock.advance(const Duration(seconds: 40));
    tracker.attemptStarted(attemptA);
    clock.advance(const Duration(seconds: 20));
    tracker.attemptCompleted(attemptA);

    expect(written.single.value, 60000);
  });

  test('completion discards the start: a second completion emits nothing', () {
    tracker.attemptStarted(attemptA);
    tracker.attemptCompleted(attemptA);
    tracker.attemptCompleted(attemptA);

    expect(written, hasLength(1));
  });

  test('an attempt resumed from another launch emits no duration', () {
    tracker.attemptCompleted(attemptA);

    expect(written, isEmpty);
  });

  test('without a current attempt nothing is tracked or emitted', () {
    tracker.attemptStarted(null);
    tracker.attemptCompleted(null);

    expect(written, isEmpty);
  });

  test('the default writer does not fail when Sentry is not running', () {
    final sdkTracker = EnrollmentDurationTracker(clock: clock);

    expect(() {
      sdkTracker.attemptStarted(attemptA);
      clock.advance(const Duration(seconds: 30));
      sdkTracker.attemptCompleted(attemptA);
    }, returnsNormally);
  });

  test('attempts are timed independently', () {
    tracker.attemptStarted(attemptA);
    clock.advance(const Duration(seconds: 10));
    tracker.attemptStarted(attemptB);
    clock.advance(const Duration(seconds: 5));
    tracker
      ..attemptCompleted(attemptB)
      ..attemptCompleted(attemptA);

    expect(written.map((w) => w.value), [5000, 15000]);
  });
}
