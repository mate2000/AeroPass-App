import 'dart:io' show Platform;

import '../../domain/entities/device_capability.dart';
import '../../domain/repositories/device_capability_checker.dart';

/// The real `DeviceCapabilityChecker`, checked against the interim
/// minimum-spec baseline from research.md §2 (Android 8.0 / API 26, iOS
/// 15.0) pending the product team's formal minimum-spec device
/// publication.
///
/// Camera-hardware presence detection needs a camera-access plugin, which
/// is not a dependency this pre-consent screen takes (FR-003: no camera
/// permission is requested here at all — this only needs to know a usable
/// camera *exists*, not access it). Until such a plugin is introduced by
/// the capture feature that actually uses the camera, [hasUsableCamera]
/// conservatively reports `true`; the false branch (FR-012's
/// no-usable-camera messaging) is exercised by
/// `FakeDeviceCapabilityChecker` in tests and is ready to wire up to a
/// real hardware check as soon as that dependency is justified.
class DeviceCapabilityService implements DeviceCapabilityChecker {
  const DeviceCapabilityService();

  static const int _minAndroidSdkMajorVersion = 8;
  static const int _minIosMajorVersion = 15;

  @override
  Future<DeviceCapability> check() async {
    return DeviceCapability(
      hasUsableCamera: true,
      osVersionSupported: _osVersionSupported(),
    );
  }

  bool _osVersionSupported() {
    try {
      if (Platform.isAndroid) {
        return _androidVersionSupported(Platform.operatingSystemVersion);
      }
      if (Platform.isIOS) {
        return _iosVersionSupported(Platform.operatingSystemVersion);
      }
      return true;
    } catch (_) {
      // Unable to determine — fail open rather than blocking enrollment
      // on a parsing failure; the credential-status/network paths are
      // where real failures already have a defined UX (FR-007).
      return true;
    }
  }

  bool _androidVersionSupported(String rawVersion) {
    final match = RegExp(r'(\d+)').firstMatch(rawVersion);
    if (match == null) return true;
    final major = int.tryParse(match.group(1)!);
    if (major == null) return true;
    return major >= _minAndroidSdkMajorVersion;
  }

  bool _iosVersionSupported(String rawVersion) {
    final match = RegExp(r'(\d+)\.(\d+)').firstMatch(rawVersion);
    if (match == null) return true;
    final major = int.tryParse(match.group(1)!);
    if (major == null) return true;
    return major >= _minIosMajorVersion;
  }
}
