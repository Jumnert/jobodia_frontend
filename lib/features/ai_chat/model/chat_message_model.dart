enum ChatMessageSender { user, bot }

class ChatMessageModel {
  ChatMessageModel({
    required this.text,
    required this.sender,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  final String text;
  final ChatMessageSender sender;
  final DateTime timestamp;

  ChatMessageModel copyWith({
    String? text,
    ChatMessageSender? sender,
    DateTime? timestamp,
  }) {
    return ChatMessageModel(
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    'sender': sender.name,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final senderName = json['sender'] as String?;
    final sender =
        ChatMessageSender.values.asNameMap()[senderName] ??
        ChatMessageSender.user;
    return ChatMessageModel(
      text: json['text'] as String? ?? '',
      sender: sender,
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
