import 'package:aeropass_app/data/services/screen_capture_guard.dart';

/// Records `enable`/`disable` calls (contracts/screen-capture-guard-port.md).
class FakeScreenCaptureGuard implements ScreenCaptureGuard {
  FakeScreenCaptureGuard({this.enableThrows = false});

  /// When true, [enable] throws, to prove the screen still renders.
  final bool enableThrows;
  int enableCount = 0;
  int disableCount = 0;

  @override
  Future<void> enable() async {
    enableCount++;
    if (enableThrows) throw StateError('screen capture guard unavailable');
  }

  @override
  Future<void> disable() async {
    disableCount++;
  }
}
