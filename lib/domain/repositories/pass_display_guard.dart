/// The pass screen's display mode (014-qr-pase FR-006, FR-007,
/// contracts/pass-display-and-posture.md): full brightness, screen kept
/// awake, and screen capture blocked while a code is shown.
abstract class PassDisplayGuard {
  Future<void> enterPassMode();

  /// Restores the brightness and flags [enterPassMode] changed.
  Future<void> exitPassMode();
}
