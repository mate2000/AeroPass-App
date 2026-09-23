import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/repositories/agent_chat_repository.dart';

/// A scriptable `AgentChatRepository` double (contracts/agent-chat-port.md).
class FakeAgentChatRepository implements AgentChatRepository {
  final List<String> sent = [];
  Result<String> Function(String message) reply = (m) => Result.ok('eco: $m');

  @override
  Future<Result<String>> send(String message) async {
    sent.add(message);
    return reply(message);
  }
}
