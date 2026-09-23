// 010-escalar-agente T010/T027: the chat screen — the notice, no attachment
// control, messages and replies, and no effect on the escalation's outcome.
import 'package:aeropass_app/features/enrollment/escalation/agent_chat_view.dart';
import 'package:aeropass_app/features/enrollment/escalation/agent_chat_viewmodel.dart';
import 'package:aeropass_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_agent_chat_repository.dart';

Future<FakeAgentChatRepository> _pump(WidgetTester tester) async {
  final chat = FakeAgentChatRepository();
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AgentChatView(viewModel: AgentChatViewModel(chatRepository: chat)),
    ),
  );
  return chat;
}

void main() {
  testWidgets(
    'shows the notice that the chat cannot verify or take documents',
    (tester) async {
      await _pump(tester);

      expect(
        find.text(
          'Este chat responde tus dudas. No puede completar tu verificación y '
          'nunca recibe documentos.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('has no attachment control of any kind', (tester) async {
    await _pump(tester);

    for (final icon in [
      Icons.attach_file,
      Icons.attachment,
      Icons.photo_camera,
      Icons.camera_alt,
      Icons.image,
      Icons.add_photo_alternate,
      Icons.upload_file,
    ]) {
      expect(find.byIcon(icon), findsNothing, reason: '$icon');
    }
  });

  testWidgets('sending shows the message and the reply', (tester) async {
    final chat = await _pump(tester);

    await tester.enterText(find.byType(TextField), 'Hola');
    await tester.tap(find.text('Enviar'));
    await tester.pumpAndSettle();

    expect(chat.sent, ['Hola']);
    expect(find.text('Hola'), findsOneWidget);
    expect(find.text('eco: Hola'), findsOneWidget);
  });
}
