import '../../core/result.dart';
import '../../domain/entities/service_status.dart';
import '../../domain/repositories/consent_repository.dart';
import '../../domain/repositories/service_status_repository.dart';
import '../models/service_status_response.dart';
import 'service_status_service.dart';
import 'transport_error_mapper.dart';

/// The real `ServiceStatusRepository` (011-error-tecnico,
/// contracts/service-status-port.md). The mapping is strict. A missing,
/// duplicated or unknown step, or an unknown health, fails the whole read,
/// because a card with one guessed line is a card that is not true (FR-007).
class ServiceStatusRepositoryImpl implements ServiceStatusRepository {
  ServiceStatusRepositoryImpl(
    this._service, {
    required ConsentRepository consentRepository,
  }) : _consentRepository = consentRepository;

  final ServiceStatusService _service;
  final ConsentRepository _consentRepository;

  @override
  Future<Result<ServiceStatus>> getStatus() async {
    final attemptId = (await _consentRepository.getLocalRecord())
        .valueOrNull
        ?.enrollmentAttemptId
        .value;
    if (attemptId == null) {
      return Result.error(
        StateError('no local consent record scopes the service status'),
      );
    }
    try {
      final response = await _service.fetchStatus(
        enrollmentAttemptId: attemptId,
      );
      final status = _map(response);
      return status == null
          ? Result.error(const FormatException('service status malformed'))
          : Result.ok(status);
    } catch (e, st) {
      return Result.error(mapTransportError(e), st);
    }
  }

  ServiceStatus? _map(ServiceStatusResponse response) {
    final steps = <JourneyStep, StepHealth>{};
    for (final wire in response.steps ?? const <ServiceStepResponse>[]) {
      final step = _step(wire.step);
      final health = _health(wire.health);
      if (step == null || health == null || steps.containsKey(step)) {
        return null;
      }
      steps[step] = health;
    }
    if (steps.length != JourneyStep.values.length) return null;
    return ServiceStatus(
      steps: steps,
      retryAfter: DateTime.tryParse(response.retryAfter ?? ''),
    );
  }

  static JourneyStep? _step(String? wire) => switch (wire) {
    'document_scan' => JourneyStep.documentScan,
    'selfie' => JourneyStep.selfie,
    'issuance' => JourneyStep.issuance,
    _ => null,
  };

  static StepHealth? _health(String? wire) => switch (wire) {
    'operational' => StepHealth.operational,
    'degraded' => StepHealth.degraded,
    'unavailable' => StepHealth.unavailable,
    _ => null,
  };
}
