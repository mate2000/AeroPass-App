import '../core/clock.dart';
import '../domain/entities/pass.dart';

final Stopwatch _uptime = Stopwatch()..start();

/// Whether the device clock can be trusted for pass codes (014-qr-pase
/// FR-014, research.md §5).
///
/// Every backend response carries its time. The monitor keeps the offset
/// from the last one, and the monotonic time of that contact, so a wall
/// clock moved by hand is caught even without a network. In memory only.
class ClockTrustMonitor {
  ClockTrustMonitor({required Clock clock, Duration Function()? monotonicNow})
    : _clock = clock,
      _monotonicNow = monotonicNow ?? (() => _uptime.elapsed);

  final Clock _clock;
  final Duration Function() _monotonicNow;

  Duration? _offset;
  DateTime? _deviceAtContact;
  Duration? _monotonicAtContact;

  /// Records a time the backend reported just now.
  void observeServerTime(DateTime serverTime) {
    final deviceNow = _clock.now();
    _offset = serverTime.toUtc().difference(deviceNow.toUtc());
    _deviceAtContact = deviceNow;
    _monotonicAtContact = _monotonicNow();
  }

  ClockTrust get current {
    final offset = _offset;
    final deviceAtContact = _deviceAtContact;
    final monotonicAtContact = _monotonicAtContact;
    if (offset == null ||
        deviceAtContact == null ||
        monotonicAtContact == null) {
      return const ClockTrust.untrusted(ClockDistrustReason.noContact);
    }
    if (offset.abs() > clockTolerance) {
      return const ClockTrust.untrusted(ClockDistrustReason.drift);
    }
    final wallElapsed = _clock.now().difference(deviceAtContact);
    final realElapsed = _monotonicNow() - monotonicAtContact;
    if ((wallElapsed - realElapsed).abs() > clockTolerance) {
      return const ClockTrust.untrusted(ClockDistrustReason.jump);
    }
    return ClockTrust.trusted(offset: offset);
  }

  bool get isTrusted => current is ClockTrusted;

  /// The backend's time now, as best known: the device clock plus the last
  /// observed offset.
  DateTime serverNow() => _clock.now().add(_offset ?? Duration.zero);
}
