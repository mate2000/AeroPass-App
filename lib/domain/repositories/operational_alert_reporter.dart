import '../entities/verification_stage.dart';

/// Raises the operational alert behind "Nuestro equipo ya fue notificado"
/// (011-error-tecnico, contracts/operational-alert-port.md).
abstract class OperationalAlertReporter {
  /// True only when a report actually becomes a notification to the team:
  /// reporting is enabled AND the alert rule is confirmed to exist. The
  /// screen shows the notification sentence only when this is true
  /// (FR-006, SC-003).
  bool get canClaimNotification;

  /// Sends one report for a known service failure on [stage]. Fire and
  /// forget. It carries no personal data (FR-018).
  void reportServiceFailure({required VerificationStage stage});
}
