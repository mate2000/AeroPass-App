import '../../core/result.dart';
import '../../domain/entities/escalation.dart';
import '../../domain/repositories/escalation_repository.dart';

/// A local, no-network `EscalationRepository` used only when the app is
/// launched with `USE_FAKE_VERIFICATION_BACKEND=true` (010-escalar-agente) —
/// never reachable from production wiring.
///
/// It opens one escalation and keeps it open, with the module and the chat
/// both available and no wait supplied. The channel data is a stand-in for
/// the operational data the backend will provide: replace the airport with
/// the contracted one. It never reports an outcome, so the demo can reach the
/// screen but never manufactures an agent decision (FR-011).
class DevEscalationRepository implements EscalationRepository {
  DevEscalationRepository({DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  EscalationCase? _case;

  static const _channels = [
    AgentChannel(
      kind: AgentChannelKind.module,
      available: true,
      hours: 'Lun–Vie 6:00am–10:00pm · Sáb–Dom 7:00am–9:00pm',
      locationName: 'Aeropuerto Internacional José María Córdova (MDE)',
      locationDetail:
          'Terminal nacional, segundo piso, junto a la entrada de seguridad',
    ),
    AgentChannel(
      kind: AgentChannelKind.chat,
      available: true,
      hours: 'Todos los días, 6:00am–10:00pm',
    ),
  ];

  @override
  Future<Result<EscalationCase>> openOrResume({
    required EscalationArrival arrival,
  }) async {
    return Result.ok(
      _case ??= EscalationCase(openedAt: _now().toUtc(), arrival: arrival),
    );
  }

  @override
  Future<Result<EscalationStatus>> getStatus() async {
    final escalation = _case;
    if (escalation == null) {
      return Result.error(StateError('no escalation opened yet'));
    }
    return Result.ok(
      EscalationStatus.open(escalation: escalation, channels: _channels),
    );
  }
}
