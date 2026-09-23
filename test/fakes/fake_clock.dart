import 'package:aeropass_app/core/clock.dart';

/// A clock tests move by hand (011-error-tecnico).
class FakeClock implements Clock {
  FakeClock([DateTime? start]) : _now = start ?? DateTime.utc(2026, 9, 23, 12);

  DateTime _now;

  @override
  DateTime now() => _now;

  void advance(Duration by) => _now = _now.add(by);

  void set(DateTime to) => _now = to;
}
