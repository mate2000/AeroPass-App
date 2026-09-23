import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/service_status.dart';
import 'package:aeropass_app/domain/repositories/service_status_repository.dart';

/// Scripted `ServiceStatusRepository` (011-error-tecnico). Each read takes
/// the next scripted result, then repeats the last one. With nothing
/// scripted, every read fails, so the card is omitted.
class FakeServiceStatusRepository implements ServiceStatusRepository {
  final List<Result<ServiceStatus>> _queue = [];
  Result<ServiceStatus>? _last;
  int callCount = 0;

  void scriptResults(List<Result<ServiceStatus>> results) {
    _queue
      ..clear()
      ..addAll(results);
  }

  @override
  Future<Result<ServiceStatus>> getStatus() async {
    callCount++;
    if (_queue.isNotEmpty) _last = _queue.removeAt(0);
    return _last ??
        Result.error(
          StateError('FakeServiceStatusRepository: nothing scripted'),
        );
  }
}
