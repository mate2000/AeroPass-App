import 'package:aeropass_app/domain/entities/verification_stage.dart';
import 'package:aeropass_app/domain/repositories/operational_alert_reporter.dart';

/// Records every report instead of sending it (011-error-tecnico).
class FakeOperationalAlertReporter implements OperationalAlertReporter {
  FakeOperationalAlertReporter({this.canClaimNotification = false});

  @override
  bool canClaimNotification;

  final List<VerificationStage> reported = [];

  @override
  void reportServiceFailure({required VerificationStage stage}) {
    reported.add(stage);
  }
}
