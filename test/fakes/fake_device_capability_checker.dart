import 'package:aeropass_app/domain/entities/device_capability.dart';
import 'package:aeropass_app/domain/repositories/device_capability_checker.dart';

/// A scripted `DeviceCapabilityChecker` double. Defaults to a fully
/// capable device so tests that don't care about FR-012 don't need to set
/// this up explicitly.
class FakeDeviceCapabilityChecker implements DeviceCapabilityChecker {
  DeviceCapability response = const DeviceCapability(
    hasUsableCamera: true,
    osVersionSupported: true,
  );

  @override
  Future<DeviceCapability> check() async => response;
}
