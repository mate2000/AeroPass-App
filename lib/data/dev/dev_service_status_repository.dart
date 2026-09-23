import '../../core/result.dart';
import '../../domain/entities/service_status.dart';
import '../../domain/repositories/service_status_repository.dart';

/// Happy-path stand-in for the live status source (011-error-tecnico,
/// spec deferral table). There is no status source in development, so every
/// read fails and the card is never rendered. A hard-coded "Operativo" would
/// be worse than no card.
class DevServiceStatusRepository implements ServiceStatusRepository {
  const DevServiceStatusRepository();

  @override
  Future<Result<ServiceStatus>> getStatus() async =>
      Result.error(StateError('no status source in development'));
}
