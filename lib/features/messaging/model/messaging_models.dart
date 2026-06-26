class ConversationModel {
  ConversationModel({
    required this.id,
    required this.recruiterName,
    required this.recruiterCompany,
    required this.jobTitle,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });

  final String id;
  final String recruiterName;
  final String recruiterCompany;
  final String jobTitle;
  final String lastMessage;
  final DateTime lastMessageTime;
  int unreadCount;
}

class MessageModel {
  MessageModel({
    required this.id,
    required this.conversationId,
    required this.text,
    required this.isFromUser,
    required this.timestamp,
    this.isRead = false,
  });

  final String id;
  final String conversationId;
  final String text;
  final bool isFromUser;
  final DateTime timestamp;
  bool isRead;
}
