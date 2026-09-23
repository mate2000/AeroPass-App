import 'package:meta/meta.dart';

import '../../core/result.dart';

/// The informational chat (010-escalar-agente, contracts/agent-chat-port.md).
/// Text only: there is no method, parameter or type for an attachment
/// (FR-014), and nothing it returns is ever read as an escalation outcome
/// (FR-021).
abstract class AgentChatRepository {
  /// Sends [message] and returns the agent's reply.
  @useResult
  Future<Result<String>> send(String message);
}
