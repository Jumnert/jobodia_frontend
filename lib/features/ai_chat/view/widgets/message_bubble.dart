import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/ai_chat/model/chat_message_model.dart';
import 'package:jobodia_frontend/features/ai_chat/view/widgets/bot_avatar.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});

  final ChatMessageModel message;

  bool get isUser => message.sender == ChatMessageSender.user;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.56,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message.text,
        style: TextStyle(
          color: palette.textPrimary,
          fontSize: 13,
          height: 1.18,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: isUser
          ? Align(alignment: Alignment.centerRight, child: bubble)
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: BotAvatar(size: 50),
                ),
                const SizedBox(width: 8),
                bubble,
              ],
            ),
    );
  }
}
