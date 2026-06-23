import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:alza/features/chat/providers/chat_provider.dart';
import 'package:alza/app/style/app_colors.dart';
import 'package:alza/app/style/app_fonts.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blanco.solid,
      appBar: AppBar(
        title: Text(
          'Asistente Financiero',
          style: AppFonts.montserrat(
            color: AppColors.negro.solid,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.blanco.solid,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.negro.solid),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, child) {
          return Chat(
            messages: provider.messages,
            onSendPressed: provider.sendMessage,
            onAttachmentPressed: provider.toggleRecording,
            user: provider.user,
            typingIndicatorOptions: TypingIndicatorOptions(
              typingUsers: provider.isTyping ? [const types.User(id: 'ai')] : [],
            ),
            theme: DefaultChatTheme(
              primaryColor: AppColors.negro.solid,
              secondaryColor: Colors.grey[200]!,
              backgroundColor: AppColors.blanco.solid,
              inputBackgroundColor: Colors.grey[100]!,
              inputTextColor: AppColors.negro.solid,
              receivedMessageBodyTextStyle: AppFonts.montserrat(color: AppColors.negro.solid),
              sentMessageBodyTextStyle: AppFonts.montserrat(color: AppColors.blanco.solid),
              inputTextCursorColor: AppColors.negro.solid,
              sendButtonIcon: Icon(Icons.send_rounded, color: AppColors.verde.solid),
              attachmentButtonIcon: Icon(
                provider.isRecording ? Icons.stop_circle_rounded : Icons.mic_rounded, 
                color: provider.isRecording ? Colors.red : AppColors.negro.solid,
              ),
            ),
          );
        },
      ),
    );
  }
}
