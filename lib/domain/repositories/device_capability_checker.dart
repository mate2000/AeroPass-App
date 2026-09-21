import '../entities/device_capability.dart';

/// Evaluates whether this device can complete enrollment, before the
/// passenger commits time (FR-012). Its own port, separate from
/// `CredentialRepository`, per Constitution Principle X's interface
/// segregation — a consumer that only needs device capability shouldn't
/// receive a credential-shaped interface, and vice versa.
abstract class DeviceCapabilityChecker {
  Future<DeviceCapability> check();
}
