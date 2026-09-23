import 'package:dio/dio.dart';

/// Sends one chat message over the pinned `dio` client (010-escalar-agente,
/// contracts/agent-chat-port.md). Text only — there is no attachment field.
class AgentChatService {
  AgentChatService({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<String> send(String message) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/v1/escalations/chat',
      data: {'message': message},
    );
    return response.data!['reply'] as String;
  }
}
