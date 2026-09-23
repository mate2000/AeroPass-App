import 'package:flutter/material.dart';

import '../../../core/design/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'agent_chat_viewmodel.dart';

/// The informational chat (010-escalar-agente). Composition only
/// (Principle VIII). There is deliberately **no attachment control**, so no
/// identity document can be sent through it (FR-014); the notice says so,
/// and says the chat cannot complete verification (FR-021).
class AgentChatView extends StatefulWidget {
  const AgentChatView({required this.viewModel, super.key});

  final AgentChatViewModel viewModel;

  @override
  State<AgentChatView> createState() => _AgentChatViewState();
}

class _AgentChatViewState extends State<AgentChatView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text;
    _controller.clear();
    await widget.viewModel.send(text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.agentChatTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.amberTile,
              padding: const EdgeInsets.all(12),
              child: Text(
                l10n.agentChatNotice,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: widget.viewModel,
                builder: (context, _) {
                  final messages = widget.viewModel.messages;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return Align(
                        alignment: message.fromAgent
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          constraints: const BoxConstraints(maxWidth: 280),
                          decoration: BoxDecoration(
                            color: message.fromAgent
                                ? const Color(0xFFF1F4F7)
                                : AppColors.navy,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.text,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: message.fromAgent
                                      ? AppColors.textPrimary
                                      : Colors.white,
                                ),
                              ),
                              if (message.failed)
                                Text(
                                  l10n.agentChatNotSent,
                                  style: textTheme.labelSmall?.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: l10n.agentChatHint,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.navy,
                    ),
                    onPressed: _send,
                    child: Text(l10n.agentChatSend),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
