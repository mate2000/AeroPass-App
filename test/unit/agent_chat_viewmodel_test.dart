// 010-escalar-agente T010: AgentChatViewModel — text only, in memory, and a
// failed send is marked rather than lost (contracts/agent-chat-port.md).
import 'dart:io';

import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/features/enrollment/escalation/agent_chat_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_agent_chat_repository.dart';

void main() {
  test('sending shows the message and the reply', () async {
    final chat = FakeAgentChatRepository();
    final vm = AgentChatViewModel(chatRepository: chat);

    await vm.send('¿Dónde queda el módulo?');

    expect(chat.sent, ['¿Dónde queda el módulo?']);
    expect(vm.messages.map((m) => (m.text, m.fromAgent, m.failed)), [
      ('¿Dónde queda el módulo?', false, false),
      ('eco: ¿Dónde queda el módulo?', true, false),
    ]);
  });

  test('a failed send marks the message as not sent', () async {
    final chat = FakeAgentChatRepository()
      ..reply = (_) => Result.error(const SocketException('offline'));
    final vm = AgentChatViewModel(chatRepository: chat);

    await vm.send('Hola');

    expect(vm.messages, hasLength(1));
    expect(vm.messages.single.failed, isTrue);
  });

  test('blank messages are not sent', () async {
    final chat = FakeAgentChatRepository();
    final vm = AgentChatViewModel(chatRepository: chat);

    await vm.send('   ');

    expect(chat.sent, isEmpty);
    expect(vm.messages, isEmpty);
  });
}
