import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'package:alza/core/network/dio_client.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart' as dio;

class ChatProvider extends ChangeNotifier {
  final List<types.Message> _messages = [];
  bool _isTyping = false;
  
  final _user = const types.User(id: 'user', firstName: 'Usuario');
  final _ai = const types.User(id: 'ai', firstName: 'Alza+ AI');

  final _audioRecorder = AudioRecorder();
  bool _isRecording = false;

  List<types.Message> get messages => _messages;
  bool get isTyping => _isTyping;
  bool get isRecording => _isRecording;
  types.User get user => _user;

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> toggleRecording() async {
    if (_isRecording) {
      await stopRecordingAndSend();
    } else {
      await startRecording();
    }
  }

  Future<void> startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );
        _isRecording = true;
        notifyListeners();
      }
    } catch (e) {
      print("Error starting record: $e");
    }
  }

  Future<void> stopRecordingAndSend() async {
    try {
      final path = await _audioRecorder.stop();
      _isRecording = false;
      notifyListeners();

      if (path != null) {
        await _sendAudioMessage(path);
      }
    } catch (e) {
      print("Error stopping record: $e");
    }
  }

  Future<void> _sendAudioMessage(String path) async {
    final userMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: '🎤 Mensaje de voz enviado',
    );

    _messages.insert(0, userMessage);
    _isTyping = true;
    notifyListeners();

    try {
      final history = _messages.reversed.where((m) => m is types.TextMessage && m.text != '🎤 Mensaje de voz enviado').map((m) {
        if (m is types.TextMessage) {
          return {
            "role": m.author.id == 'user' ? 'user' : 'model',
            "text": m.text,
          };
        }
        return {"role": "user", "text": ""};
      }).toList();

      final formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(path, filename: 'audio.m4a'),
        'history': jsonEncode(history),
      });

      final response = await DioClient().dio.post(
        '/api/v1/chat/audio',
        data: formData,
      );

      final aiText = response.data['data']['reply'];

      final aiMessage = types.TextMessage(
        author: _ai,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: aiText,
      );

      _messages.insert(0, aiMessage);
    } catch (e) {
      final errorMessage = types.TextMessage(
        author: _ai,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: 'Lo siento, hubo un error al procesar el audio.',
      );
      _messages.insert(0, errorMessage);
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

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
