import 'package:meta/meta.dart';

import '../../core/result.dart';
import '../entities/service_status.dart';

/// The read-only live status source for screen 11 (011-error-tecnico,
/// contracts/service-status-port.md).
///
/// The backend scopes the status to the passenger's enrollment attempt, so
/// a regional outage is only reported to passengers it affects.
abstract class ServiceStatusRepository {
  /// Reads the current status of the three journey steps.
  ///
  /// `Result.error` means there is no status to show: the read failed, the
  /// response missed or duplicated a step, or it carried a value the app
  /// does not recognize. The card is then omitted; a guessed state is never
  /// shown (FR-007).
  @useResult
  Future<Result<ServiceStatus>> getStatus();
}
