class ConversationModel {
  ConversationModel({
    required this.id,
    required this.recruiterName,
    required this.recruiterCompany,
    required this.jobTitle,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isOrganization = false,
    this.isMuted = false,
    this.isArchived = false,
    this.isBlocked = false,
  });

  final String id;
  final String recruiterName;
  final String recruiterCompany;
  final String jobTitle;
  final String lastMessage;
  final DateTime lastMessageTime;
  int unreadCount;
  final bool isOrganization;
  bool isMuted;
  bool isArchived;
  bool isBlocked;
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
