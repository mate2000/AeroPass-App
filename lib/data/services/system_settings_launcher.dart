import 'package:flutter/services.dart' show MethodChannel, PlatformException;

/// FR-014: "offer the route to the system settings" for a permanently
/// denied camera permission. Neither the `camera` plugin nor the Flutter
/// SDK exposes this directly, and this feature adds no new pub dependency
/// beyond `camera` (plan.md) — so this is a minimal platform channel, not
/// a new package, with small native handlers in
/// `android/.../MainActivity.kt` and `ios/Runner/AppDelegate.swift`.
///
/// An abstract class (not `...Repository` — infrastructure, same spirit as
/// `CameraCaptureService`) so `CaptureViewModel` can be constructor-injected
/// with a fake in tests.
abstract class SystemSettingsLauncher {
  Future<void> open();
}

/// The real, platform-channel-backed [SystemSettingsLauncher].
class PlatformSystemSettingsLauncher implements SystemSettingsLauncher {
  const PlatformSystemSettingsLauncher();

  static const _channel = MethodChannel('aeropass/system_settings');

  @override
  Future<void> open() async {
    try {
      await _channel.invokeMethod<void>('openAppSettings');
    } on PlatformException {
      // Best-effort: if the platform can't honor this (e.g. an
      // unsupported OS version), the passenger still has the
      // conventional-airport-process statement (FR-014) as their way
      // forward — this is never the only path out of the screen.
    }
  }
}
