import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:jobodia_frontend/core/config/app_environment.dart';
import 'package:jobodia_frontend/features/auth/controller/auth_controller.dart';
import 'package:jobodia_frontend/features/messaging/model/messaging_models.dart';
import 'package:jobodia_frontend/services/api_client.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MessagingController extends GetxController {
  MessagingController({ApiClient? apiClient, this.connectOnInit = true})
    : _api = apiClient ?? ApiClient();

  final ApiClient _api;
  final bool connectOnInit;
  final _uuid = const Uuid();
  final conversations = <ConversationModel>[].obs;
  final currentMessages = <MessageModel>[].obs;
  final userSearchResults = <PublicUserModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMessages = false.obs;
  final isSearchingUsers = false.obs;
  final isSending = false.obs;
  final isTyping = false.obs;
  final errorMessage = ''.obs;
  final socketConnected = false.obs;

  WebSocketChannel? _socket;
  StreamSubscription<dynamic>? _socketSubscription;
  Timer? _reconnectTimer;
  Timer? _searchTimer;
  int _reconnectAttempt = 0;
  String? _activeConversationId;

  String get currentUserId => Get.isRegistered<AuthController>()
      ? Get.find<AuthController>().currentUser.value?.id ?? ''
      : '';

  @override
  void onInit() {
    super.onInit();
    if (!connectOnInit) return;
    unawaited(refreshConversations());
    unawaited(_connectSocket());
  }

  Future<void> refreshConversations() async {
    isLoading.value = conversations.isEmpty;
    errorMessage.value = '';
    try {
      final data = await _api.get('/api/v1/chat/conversations');
      conversations.assignAll(
        (data as List? ?? const []).whereType<Map>().map(
          (item) => ConversationModel.fromJson(Map<String, dynamic>.from(item)),
        ),
      );
    } on ApiException catch (error) {
      errorMessage.value = error.message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchUsers(String query) async {
    _searchTimer?.cancel();
    final normalized = query.trim();
    if (normalized.length < 2) {
      userSearchResults.clear();
      isSearchingUsers.value = false;
      return;
    }
    _searchTimer = Timer(const Duration(milliseconds: 280), () async {
      isSearchingUsers.value = true;
      try {
        final data = await _api.get(
          '/api/v1/users/search?q=${Uri.encodeQueryComponent(normalized)}&limit=20',
        );
        userSearchResults.assignAll(
          (data as List? ?? const []).whereType<Map>().map(
            (item) => PublicUserModel.fromJson(Map<String, dynamic>.from(item)),
          ),
        );
      } on ApiException catch (error) {
        errorMessage.value = error.message;
        userSearchResults.clear();
      } finally {
        isSearchingUsers.value = false;
      }
    });
  }

  Future<ConversationModel> startConversation(PublicUserModel user) async {
    final existing = conversations.firstWhereOrNull(
      (conversation) => conversation.otherUser.userId == user.userId,
    );
    if (existing != null) return existing;
    final data = await _api.post('/api/v1/chat/conversations', {
      'otherUserId': user.userId,
    });
    final conversation = ConversationModel.fromJson(
      Map<String, dynamic>.from(data as Map),
    );
    conversations.insert(0, conversation);
    return conversation;
  }

  Future<PublicUserModel> fetchUser(String userId) async {
    final data = await _api.get('/api/v1/users/$userId/public');
    return PublicUserModel.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<PublicUserModel> fetchCurrentUser() async {
    final data = await _api.get('/api/v1/users/me/public');
    return PublicUserModel.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<void> openConversation(String id) async {
    _activeConversationId = id;
    currentMessages.clear();
    isLoadingMessages.value = true;
    try {
      final data = await _api.get(
        '/api/v1/chat/conversations/$id/messages?limit=100',
      );
      final chronological = (data as List? ?? const [])
          .whereType<Map>()
          .map((item) => MessageModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      currentMessages.assignAll(chronological.reversed);
      await _api.post('/api/v1/chat/conversations/$id/read');
      final conversation = conversations.firstWhereOrNull((c) => c.id == id);
      if (conversation != null) {
        conversation.unreadCount = 0;
        conversations.refresh();
      }
    } on ApiException catch (error) {
      errorMessage.value = error.message;
    } finally {
      isLoadingMessages.value = false;
    }
  }

  void leaveConversation(String id) {
    if (_activeConversationId == id) _activeConversationId = null;
  }

  Future<void> sendMessage(String conversationId, String text) async {
    final normalized = text.trim();
    if (normalized.isEmpty) return;
    final temporaryId = 'pending-${_uuid.v4()}';
    final optimistic = MessageModel(
      id: temporaryId,
      conversationId: conversationId,
      text: normalized,
      senderUserId: currentUserId,
      timestamp: DateTime.now(),
      isPending: true,
    );
    currentMessages.insert(0, optimistic);
    _updateLastMessage(conversationId, normalized, optimistic.timestamp);
    isSending.value = true;
    try {
      final data = await _api.post(
        '/api/v1/chat/conversations/$conversationId/messages',
        {'text': normalized},
      );
      final saved = MessageModel.fromJson(
        Map<String, dynamic>.from(data as Map),
      );
      currentMessages.removeWhere((message) => message.id == temporaryId);
      if (!currentMessages.any((message) => message.id == saved.id)) {
        currentMessages.insert(0, saved);
      }
    } on ApiException catch (error) {
      currentMessages.removeWhere((message) => message.id == temporaryId);
      errorMessage.value = error.message;
      rethrow;
    } finally {
      isSending.value = false;
    }
  }

  void markUnread(String id) {
    final conversation = conversations.firstWhereOrNull((c) => c.id == id);
    if (conversation == null) return;
    if (conversation.unreadCount == 0) conversation.unreadCount = 1;
    conversations.refresh();
  }

  void toggleMuted(String id) {
    final conversation = conversations.firstWhereOrNull((c) => c.id == id);
    if (conversation == null) return;
    conversation.isMuted = !conversation.isMuted;
    conversations.refresh();
  }

  void archive(String id) {
    final conversation = conversations.firstWhereOrNull((c) => c.id == id);
    if (conversation == null) return;
    conversation.isArchived = true;
    conversations.refresh();
  }

  void block(String id) {
    final conversation = conversations.firstWhereOrNull((c) => c.id == id);
    if (conversation == null) return;
    conversation.isBlocked = true;
    conversations.refresh();
  }

  void deleteConversation(String id) {
    conversations.removeWhere((conversation) => conversation.id == id);
  }

  Future<void> _connectSocket() async {
    if (isClosed) return;
    final token = await _api.authToken();
    if (token.isEmpty) return;
    final apiUri = Uri.parse(AppConfig.apiBaseUrl);
    final socketUri = apiUri.replace(
      scheme: apiUri.scheme == 'https' ? 'wss' : 'ws',
      path: '/ws/chat',
      query: null,
    );
    try {
      final socket = IOWebSocketChannel.connect(
        socketUri,
        headers: {'Authorization': 'Bearer $token'},
        pingInterval: const Duration(seconds: 25),
        connectTimeout: const Duration(seconds: 12),
      );
      await socket.ready;
      _socket = socket;
      socketConnected.value = true;
      _reconnectAttempt = 0;
      _socketSubscription = socket.stream.listen(
        _handleSocketEvent,
        onError: (_) => _scheduleReconnect(),
        onDone: _scheduleReconnect,
        cancelOnError: true,
      );
    } on Object {
      _scheduleReconnect();
    }
  }

  void _handleSocketEvent(dynamic raw) {
    try {
      final decoded = jsonDecode(raw.toString());
      if (decoded is! Map<String, dynamic> ||
          decoded['type'] != 'message.created') {
        return;
      }
      final payload = decoded['message'];
      if (payload is! Map) return;
      final message = MessageModel.fromJson(Map<String, dynamic>.from(payload));
      currentMessages.removeWhere(
        (candidate) =>
            candidate.isPending &&
            candidate.conversationId == message.conversationId &&
            candidate.text == message.text &&
            message.senderUserId == currentUserId,
      );
      if (_activeConversationId == message.conversationId &&
          !currentMessages.any((candidate) => candidate.id == message.id)) {
        currentMessages.insert(0, message);
        if (message.senderUserId != currentUserId) {
          unawaited(
            _api.post(
              '/api/v1/chat/conversations/${message.conversationId}/read',
            ),
          );
        }
      }
      _updateLastMessage(
        message.conversationId,
        message.text,
        message.timestamp,
        incrementUnread:
            message.senderUserId != currentUserId &&
            _activeConversationId != message.conversationId,
      );
    } on Object {
      // Ignore malformed frames and keep the authenticated socket alive.
    }
  }

  void _updateLastMessage(
    String conversationId,
    String text,
    DateTime time, {
    bool incrementUnread = false,
  }) {
    final index = conversations.indexWhere((c) => c.id == conversationId);
    if (index == -1) {
      unawaited(refreshConversations());
      return;
    }
    final conversation = conversations.removeAt(index);
    conversation.lastMessage = text;
    conversation.lastMessageTime = time;
    if (incrementUnread) conversation.unreadCount += 1;
    conversations.insert(0, conversation);
  }

  void _scheduleReconnect() {
    socketConnected.value = false;
    unawaited(_socketSubscription?.cancel());
    _socketSubscription = null;
    _socket = null;
    _reconnectTimer?.cancel();
    final seconds = (1 << _reconnectAttempt.clamp(0, 5));
    _reconnectAttempt += 1;
    _reconnectTimer = Timer(Duration(seconds: seconds), _connectSocket);
  }

  @override
  void onClose() {
    _searchTimer?.cancel();
    _reconnectTimer?.cancel();
    unawaited(_socketSubscription?.cancel());
    unawaited(_socket?.sink.close());
    super.onClose();
  }
}
