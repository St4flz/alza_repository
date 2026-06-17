import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'package:alza/core/network/dio_client.dart';

class ChatProvider extends ChangeNotifier {
  final List<types.Message> _messages = [];
  bool _isTyping = false;
  
  final _user = const types.User(id: 'user', firstName: 'Usuario');
  final _ai = const types.User(id: 'ai', firstName: 'Alza+ AI');

  List<types.Message> get messages => _messages;
  bool get isTyping => _isTyping;
  types.User get user => _user;

  Future<void> sendMessage(types.PartialText message) async {
    final userMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: Uuid().v4(),
      text: message.text,
    );

    _messages.insert(0, userMessage);
    _isTyping = true;
    notifyListeners();

    try {
      // Formatear el historial para el backend
      final history = _messages.reversed.map((m) {
        if (m is types.TextMessage) {
          return {
            "role": m.author.id == 'user' ? 'user' : 'model',
            "text": m.text,
          };
        }
        return {"role": "user", "text": ""};
      }).toList();

      final response = await DioClient().dio.post(
        '/api/v1/chat/message',
        data: {"messages": history},
      );

      final aiText = response.data['data']['reply'];

      final aiMessage = types.TextMessage(
        author: _ai,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: Uuid().v4(),
        text: aiText,
      );

      _messages.insert(0, aiMessage);
    } catch (e) {
      final errorMessage = types.TextMessage(
        author: _ai,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: Uuid().v4(),
        text: 'Lo siento, hubo un error al consultar mis sistemas.',
      );
      _messages.insert(0, errorMessage);
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }
}
