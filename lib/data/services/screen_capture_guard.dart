import 'dart:developer' as developer;

import 'package:flutter/services.dart' show MethodChannel, PlatformException;

/// Blocks screenshots and screen recording while a credential is displayed
/// (FR-012; constitution, Security & Compliance Constraints), per
/// contracts/screen-capture-guard-port.md (008-identidad-activa).
///
/// Platform infrastructure rather than a domain port, mirroring
/// `SystemSettingsLauncher`'s placement. Calls are idempotent, and a
/// failure never blocks the screen: the app must never be the reason a
/// passenger cannot proceed.
abstract class ScreenCaptureGuard {
  Future<void> enable();
  Future<void> disable();
}

/// Android: toggles `FLAG_SECURE` on the activity window through the
/// `aeropass/screen_capture` channel in `MainActivity.kt` (research.md §13).
class PlatformScreenCaptureGuard implements ScreenCaptureGuard {
  const PlatformScreenCaptureGuard();

  static const _channel = MethodChannel('aeropass/screen_capture');

  @override
  Future<void> enable() => _invoke('setSecure');

  @override
  Future<void> disable() => _invoke('clearSecure');

  Future<void> _invoke(String method) async {
    try {
      await _channel.invokeMethod<void>(method);
    } on PlatformException catch (e) {
      // No personal data here: only the method name and platform error code.
      developer.log(
        'screen capture guard $method failed: ${e.code}',
        name: 'aeropass.screen_capture',
      );
    }
  }
}

/// iOS, for now: a no-op. iOS cannot block screenshots, and hiding content
/// while `UIScreen.isCaptured` is true is **deferred** under the spec's
/// FR-012 deferral — tracked in plan.md's Complexity Tracking, and required
/// before the airport pilot.
class NoopScreenCaptureGuard implements ScreenCaptureGuard {
  const NoopScreenCaptureGuard();

  @override
  Future<void> enable() async {}

  @override
  Future<void> disable() async {}
}
