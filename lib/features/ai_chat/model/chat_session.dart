import 'dart:math';

import 'chat_message_model.dart';

class ChatSession {
  ChatSession({
    required this.id,
    required this.name,
    required this.messages,
    required this.createdAt,
  });

  final String id;
  final String name;
  final List<ChatMessageModel> messages;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'messages': messages.map((m) => m.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    final rawMessages = json['messages'];
    final safeMessages = rawMessages is List
        ? rawMessages
              .whereType<Map<String, dynamic>>()
              .map(ChatMessageModel.fromJson)
              .toList()
        : <ChatMessageModel>[];
    final rawId = json['id'] as String? ?? '';
    final suffix = Random().nextInt(0xFFFF).toRadixString(16).padLeft(4, '0');
    return ChatSession(
      id: '$rawId-$suffix',
      name: json['name'] as String? ?? '',
      messages: safeMessages,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
