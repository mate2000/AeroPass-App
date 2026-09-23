import 'package:flutter/foundation.dart';

import '../../../domain/repositories/agent_chat_repository.dart';

/// One message in the chat, held in memory only (010-escalar-agente).
@immutable
class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.fromAgent,
    this.failed = false,
  });

  final String text;
  final bool fromAgent;

  /// The passenger's message could not be sent.
  final bool failed;
}

/// The informational chat (010, contracts/agent-chat-port.md). Text only;
/// messages live for the screen's lifetime and are never persisted. Nothing
/// here can produce or influence an escalation outcome (FR-021).
class AgentChatViewModel extends ChangeNotifier {
  AgentChatViewModel({required AgentChatRepository chatRepository})
    : _chatRepository = chatRepository;

  final AgentChatRepository _chatRepository;
  final List<ChatMessage> _messages = [];
  bool _sending = false;
  bool _disposed = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get sending => _sending;

  Future<void> send(String text) async {
    final message = text.trim();
    if (message.isEmpty || _sending) return;
    _sending = true;
    final index = _messages.length;
    _messages.add(ChatMessage(text: message, fromAgent: false));
    _notify();

    final result = await _chatRepository.send(message);
    _sending = false;
    if (_disposed) return;
    result.when(
      ok: (reply) => _messages.add(ChatMessage(text: reply, fromAgent: true)),
      error: (_, _) => _messages[index] = ChatMessage(
        text: message,
        fromAgent: false,
        failed: true,
      ),
    );
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
