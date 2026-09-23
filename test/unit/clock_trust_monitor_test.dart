// 014-qr-pase T007: the device clock is trusted only within 30 s of the
// backend's, and not after a wall-clock jump (FR-014, research.md §5).
import 'package:aeropass_app/app/clock_trust_monitor.dart';
import 'package:aeropass_app/domain/entities/pass.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_clock.dart';

void main() {
  late FakeClock clock;
  late Duration monotonic;
  late ClockTrustMonitor monitor;

  setUp(() {
    clock = FakeClock(DateTime.utc(2026, 9, 23, 12));
    monotonic = Duration.zero;
    monitor = ClockTrustMonitor(clock: clock, monotonicNow: () => monotonic);
  });

  void advanceBoth(Duration d) {
    clock.advance(d);
    monotonic += d;
  }

  test('no backend time observed yet is not trusted', () {
    expect(
      monitor.current,
      const ClockTrust.untrusted(ClockDistrustReason.noContact),
    );
  });

  test('an offset of 30 s is trusted; 31 s is drift', () {
    monitor.observeServerTime(clock.now().add(const Duration(seconds: 30)));
    expect(
      monitor.current,
      const ClockTrust.trusted(offset: Duration(seconds: 30)),
    );

    monitor.observeServerTime(
      clock.now().subtract(const Duration(seconds: 31)),
    );
    expect(
      monitor.current,
      const ClockTrust.untrusted(ClockDistrustReason.drift),
    );
  });

  test('serverNow applies the observed offset', () {
    monitor.observeServerTime(clock.now().add(const Duration(seconds: 12)));
    advanceBoth(const Duration(minutes: 5));
    expect(monitor.serverNow(), clock.now().add(const Duration(seconds: 12)));
  });

  test('time passing normally keeps trust', () {
    monitor.observeServerTime(clock.now());
    advanceBoth(const Duration(hours: 3));
    expect(monitor.current, isA<ClockTrusted>());
  });

  test(
    'a wall clock moved forward or back against monotonic time is a jump',
    () {
      monitor.observeServerTime(clock.now());
      advanceBoth(const Duration(minutes: 1));
      clock.advance(const Duration(minutes: 2));
      expect(
        monitor.current,
        const ClockTrust.untrusted(ClockDistrustReason.jump),
      );

      final back = ClockTrustMonitor(
        clock: clock,
        monotonicNow: () => monotonic,
      )..observeServerTime(clock.now());
      clock.advance(const Duration(minutes: -5));
      expect(
        back.current,
        const ClockTrust.untrusted(ClockDistrustReason.jump),
      );
    },
  );

  test('a jump within the tolerance is still trusted', () {
    monitor.observeServerTime(clock.now());
    clock.advance(const Duration(seconds: 20));
    expect(monitor.current, isA<ClockTrusted>());
  });

  test('a new trusted observation restores trust', () {
    monitor.observeServerTime(clock.now().add(const Duration(minutes: 3)));
    expect(monitor.current, isA<ClockUntrusted>());

    monitor.observeServerTime(clock.now().add(const Duration(seconds: 2)));
    expect(
      monitor.current,
      const ClockTrust.trusted(offset: Duration(seconds: 2)),
    );
  });
}
