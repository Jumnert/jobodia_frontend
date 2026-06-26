import 'package:get/get.dart';
import 'package:jobodia_frontend/features/messaging/model/messaging_models.dart';
import 'package:uuid/uuid.dart';

class MessagingController extends GetxController {
  final _uuid = const Uuid();
  late final RxList<ConversationModel> conversations;
  final currentMessages = <MessageModel>[].obs;

  final isTyping = false.obs;

  @override
  void onInit() {
    super.onInit();
    conversations = _mockConversations().obs;
  }

  void openConversation(String id) {
    currentMessages.value = _mockMessagesFor(id);

    // mark as read
    final idx = conversations.indexWhere((c) => c.id == id);
    if (idx != -1) {
      conversations[idx].unreadCount = 0;
      conversations.refresh();
    }
  }

  void sendMessage(String conversationId, String text) {
    final msg = MessageModel(
      id: _uuid.v4(),
      conversationId: conversationId,
      text: text,
      isFromUser: true,
      timestamp: DateTime.now(),
      isRead: true,
    );
    currentMessages.insert(0, msg);

    _updateLastMessage(conversationId, text);
    _simulateReply(conversationId, text);
  }

  void _updateLastMessage(String conversationId, String text) {
    final idx = conversations.indexWhere((c) => c.id == conversationId);
    if (idx != -1) {
      final c = conversations[idx];
      conversations[idx] = ConversationModel(
        id: c.id,
        recruiterName: c.recruiterName,
        recruiterCompany: c.recruiterCompany,
        jobTitle: c.jobTitle,
        lastMessage: text,
        lastMessageTime: DateTime.now(),
        unreadCount: c.unreadCount,
      );
    }
  }

  Future<void> _simulateReply(String conversationId, String userText) async {
    isTyping.value = true;
    await Future<void>.delayed(const Duration(seconds: 2));
    isTyping.value = false;

    final text =
        'Thanks for reaching out! We are currently reviewing applications. Let\'s schedule a call this week.';

    final reply = MessageModel(
      id: _uuid.v4(),
      conversationId: conversationId,
      text: text,
      isFromUser: false,
      timestamp: DateTime.now(),
    );

    if (currentMessages.isNotEmpty &&
        currentMessages.first.conversationId == conversationId) {
      currentMessages.insert(0, reply);
    }

    _updateLastMessage(conversationId, text);
  }

  List<ConversationModel> _mockConversations() => [
    ConversationModel(
      id: 'c1',
      recruiterName: 'Alice Chen',
      recruiterCompany: 'Google',
      jobTitle: 'Senior Flutter Dev',
      lastMessage: 'Are you free for a call tomorrow?',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
      unreadCount: 1,
    ),
    ConversationModel(
      id: 'c2',
      recruiterName: 'Bob Smith',
      recruiterCompany: 'Meta',
      jobTitle: 'Mobile Engineer',
      lastMessage: 'Thanks for applying!',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  List<MessageModel> _mockMessagesFor(String conversationId) {
    if (conversationId == 'c1') {
      return [
        MessageModel(
          id: _uuid.v4(),
          conversationId: 'c1',
          text: 'Are you free for a call tomorrow?',
          isFromUser: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        MessageModel(
          id: _uuid.v4(),
          conversationId: 'c1',
          text:
              'I saw your profile on Jobodia and I think you\'d be a great fit.',
          isFromUser: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
      ];
    } else {
      return [
        MessageModel(
          id: _uuid.v4(),
          conversationId: 'c2',
          text: 'Thanks for applying!',
          isFromUser: false,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
    }
  }
}
