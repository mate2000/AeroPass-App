import '../../domain/entities/pass.dart';
import '../../domain/repositories/device_posture_checker.dart';

/// Happy-path stand-in, behind `USE_FAKE_VERIFICATION_BACKEND`: development
/// runs on emulators, which the real check rightly refuses. A release build
/// cannot enable the flag, so it always uses the platform check.
class DevDevicePostureChecker implements DevicePostureChecker {
  const DevDevicePostureChecker();

  @override
  Future<DevicePosture> check() async => const DevicePosture.trusted();
}
