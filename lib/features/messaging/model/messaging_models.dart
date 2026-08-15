class PublicUserModel {
  const PublicUserModel({
    required this.userId,
    required this.username,
    required this.displayName,
    required this.role,
    this.avatarUrl,
    this.bio,
    this.location,
  });

  final String userId;
  final String username;
  final String displayName;
  final String role;
  final String? avatarUrl;
  final String? bio;
  final String? location;

  bool get isOrganization => role.toUpperCase() == 'EMPLOYER';

  factory PublicUserModel.fromJson(Map<String, dynamic> json) {
    return PublicUserModel(
      userId: json['userId']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      displayName:
          json['displayName']?.toString() ??
          json['username']?.toString() ??
          'User',
      role: json['role']?.toString() ?? 'SEEKER',
      avatarUrl: json['avatarUrl']?.toString(),
      bio: json['bio']?.toString(),
      location: json['location']?.toString(),
    );
  }
}

class ConversationModel {
  ConversationModel({
    required this.id,
    required this.otherUser,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isMuted = false,
    this.isArchived = false,
    this.isBlocked = false,
  });

  final String id;
  final PublicUserModel otherUser;
  String lastMessage;
  DateTime lastMessageTime;
  int unreadCount;
  bool isMuted;
  bool isArchived;
  bool isBlocked;

  String get recruiterName => otherUser.displayName;
  String get recruiterCompany =>
      otherUser.isOrganization ? otherUser.displayName : otherUser.username;
  String get jobTitle => otherUser.role;
  String? get avatarUrl => otherUser.avatarUrl;
  bool get isOrganization => otherUser.isOrganization;

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id']?.toString() ?? '',
      otherUser: PublicUserModel.fromJson(
        Map<String, dynamic>.from(json['otherUser'] as Map? ?? const {}),
      ),
      lastMessage: json['lastMessage']?.toString() ?? 'Start a conversation',
      lastMessageTime:
          DateTime.tryParse(
            json['lastMessageAt']?.toString() ?? '',
          )?.toLocal() ??
          DateTime.now(),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class MessageModel {
  MessageModel({
    required this.id,
    required this.conversationId,
    required this.text,
    required this.senderUserId,
    required this.timestamp,
    this.isRead = false,
    this.isPending = false,
  });

  final String id;
  final String conversationId;
  final String text;
  final String senderUserId;
  final DateTime timestamp;
  bool isRead;
  final bool isPending;

  bool isFrom(String userId) => senderUserId == userId;

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversationId']?.toString() ?? '',
      senderUserId: json['senderUserId']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      timestamp:
          DateTime.tryParse(json['createdAt']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      isRead: json['read'] == true,
    );
  }
}
