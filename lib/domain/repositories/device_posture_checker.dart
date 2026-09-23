import '../entities/pass.dart';

/// Detects a compromised device before any pass is requested (constitution
/// Security & Compliance; 014-qr-pase FR-023). The checks are heuristic;
/// backend attestation is the robust answer (research.md §8).
abstract class DevicePostureChecker {
  Future<DevicePosture> check();
}
