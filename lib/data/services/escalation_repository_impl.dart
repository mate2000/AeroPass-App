import '../../core/result.dart';
import '../../domain/entities/capture_attempt_counter.dart';
import '../../domain/entities/escalation.dart';
import '../../domain/repositories/consent_repository.dart';
import '../../domain/repositories/escalation_repository.dart';
import '../models/escalation_status_response.dart';
import 'escalation_service.dart';

/// The real `EscalationRepository` (010-escalar-agente,
/// contracts/escalation-port.md). Owns all mapping from the wire response
/// (Principle II). Unknown values map to their safest reading: an unknown
/// state or outcome is a failed read, never an outcome; a channel without
/// `available` is unavailable.
class EscalationRepositoryImpl implements EscalationRepository {
  EscalationRepositoryImpl(
    this._service, {
    required ConsentRepository consentRepository,
  }) : _consentRepository = consentRepository;

  final EscalationService _service;
  final ConsentRepository _consentRepository;

  Future<String?> _attemptId() async =>
      (await _consentRepository.getLocalRecord())
          .valueOrNull
          ?.enrollmentAttemptId
          .value;

  @override
  Future<Result<EscalationCase>> openOrResume({
    required EscalationArrival arrival,
  }) async {
    final attemptId = await _attemptId();
    if (attemptId == null) return Result.error(_noConsent());
    try {
      final response = await _service.openOrResume(
        enrollmentAttemptId: attemptId,
        arrival: arrival.name,
      );
      final escalation = _case(response);
      return escalation == null
          ? Result.error(const FormatException('escalation case malformed'))
          : Result.ok(escalation);
    } catch (e, st) {
      return Result.error(e, st);
    }
  }

  @override
  Future<Result<EscalationStatus>> getStatus() async {
    final attemptId = await _attemptId();
    if (attemptId == null) return Result.error(_noConsent());
    try {
      final response = await _service.fetchCurrent(
        enrollmentAttemptId: attemptId,
      );
      final status = _status(response);
      return status == null
          ? Result.error(
              const FormatException('unrecognized escalation status'),
            )
          : Result.ok(status);
    } catch (e, st) {
      return Result.error(e, st);
    }
  }

  StateError _noConsent() =>
      StateError('no local consent record identifies the escalation');

  EscalationStatus? _status(EscalationStatusResponse response) {
    switch (response.state) {
      case 'open':
        final escalation = _case(response);
        if (escalation == null) return null;
        return EscalationStatus.open(
          escalation: escalation,
          channels: [
            for (final channel in response.channels ?? <AgentChannelResponse>[])
              ?_channel(channel),
          ],
        );
      case 'resolved':
        final outcome = _outcome(response);
        return outcome == null
            ? null
            : EscalationStatus.resolved(outcome: outcome);
      case 'expired':
        return const EscalationStatus.expired();
      default:
        return null;
    }
  }

  EscalationCase? _case(EscalationStatusResponse response) {
    final openedAt = DateTime.tryParse(response.openedAt ?? '');
    final arrival = switch (response.arrival) {
      'byChoice' => EscalationArrival.byChoice,
      'afterLimit' => EscalationArrival.afterLimit,
      _ => null,
    };
    if (openedAt == null || arrival == null) return null;
    return EscalationCase(openedAt: openedAt.toUtc(), arrival: arrival);
  }

  AgentChannel? _channel(AgentChannelResponse response) {
    final kind = switch (response.kind) {
      'module' => AgentChannelKind.module,
      'chat' => AgentChannelKind.chat,
      _ => null,
    };
    if (kind == null) return null;
    final min = response.waitMinMinutes;
    final max = response.waitMaxMinutes;
    return AgentChannel(
      kind: kind,
      available: response.available ?? false,
      nextOpensAt: DateTime.tryParse(response.nextOpensAt ?? '')?.toUtc(),
      estimatedWait: min != null && max != null && min >= 0 && max >= min
          ? WaitEstimate(minMinutes: min, maxMinutes: max)
          : null,
      hours: response.hours ?? '',
      locationName: response.locationName,
      locationDetail: response.locationDetail,
    );
  }

  EscalationOutcome? _outcome(EscalationStatusResponse response) =>
      switch (response.outcome) {
        'credential_issued' => const EscalationOutcome.credentialIssued(),
        'declined' => const EscalationOutcome.declined(),
        'attempts_reset' => switch (response.resetScope) {
          'document' => const EscalationOutcome.attemptsReset(
            scope: AttemptCounterScope.documentCapture,
          ),
          'selfie' => const EscalationOutcome.attemptsReset(
            scope: AttemptCounterScope.selfieLiveness,
          ),
          _ => null,
        },
        _ => null,
      };
}
