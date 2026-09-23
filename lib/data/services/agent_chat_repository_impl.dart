import '../../core/result.dart';
import '../../domain/repositories/agent_chat_repository.dart';
import 'agent_chat_service.dart';

/// The real `AgentChatRepository` (010-escalar-agente). Converts every
/// failure to `Result.error`; its replies are never read as outcomes.
class AgentChatRepositoryImpl implements AgentChatRepository {
  AgentChatRepositoryImpl(this._service);

  final AgentChatService _service;

  @override
  Future<Result<String>> send(String message) async {
    try {
      return Result.ok(await _service.send(message));
    } catch (e, st) {
      return Result.error(e, st);
    }
  }
}
