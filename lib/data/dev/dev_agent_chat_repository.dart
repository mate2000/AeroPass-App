import '../../core/result.dart';
import '../../domain/repositories/agent_chat_repository.dart';

/// A local, echoing `AgentChatRepository` used only when the app is launched
/// with `USE_FAKE_VERIFICATION_BACKEND=true` (010-escalar-agente) — enough to
/// walk the flow. Never reachable from production wiring.
class DevAgentChatRepository implements AgentChatRepository {
  const DevAgentChatRepository();

  @override
  Future<Result<String>> send(String message) async =>
      Result.ok('Agente de prueba: recibimos "$message".');
}
