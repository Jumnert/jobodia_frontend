import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/features/ai_chat/model/chat_message_model.dart';
import 'package:jobodia_frontend/features/ai_chat/model/chat_session.dart';
import 'package:jobodia_frontend/services/secure_storage_service.dart';

class AiChatController extends GetxController {
  static const _activeKey = 'activeChatMessages';
  static const _sessionsKey = 'chatSessions';

  final _storage = GetStorage();

  final messageController = TextEditingController();
  final historySearchController = TextEditingController();
  final RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  final RxString historySearchQuery = ''.obs;
  final RxBool isTyping = false.obs;

  final RxList<ChatSession> sessions = <ChatSession>[].obs;
  final RxList<String> suggestions = <String>[
    'Review my CV',
    'Find Jobs For Me',
    'Skill Recommendations',
    'Career Roadmap',
    'Interview tips',
  ].obs;

  bool get hasMessages => messages.isNotEmpty;

  List<ChatSession> get filteredSessions {
    final query = historySearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return sessions;
    }
    return sessions.where((s) => s.name.toLowerCase().contains(query)).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _loadActiveMessages();
    _loadSessions();
  }

  void _loadActiveMessages() {
    final stored = _storage.read<List>(_activeKey);
    if (stored != null) {
      messages.assignAll(
        stored
            .map(
              (m) => ChatMessageModel.fromJson(
                Map<String, dynamic>.from(m as Map),
              ),
            )
            .toList(),
      );
    }
  }

  void _loadSessions() {
    final stored = _storage.read<List>(_sessionsKey);
    if (stored != null) {
      sessions.assignAll(
        stored
            .map(
              (s) => ChatSession.fromJson(Map<String, dynamic>.from(s as Map)),
            )
            .toList(),
      );
    }
  }

  void _persistActiveMessages() {
    final data = messages.map((m) => m.toJson()).toList();
    _storage.write(_activeKey, data);
    SecureStorageService.to.writeSecure(_activeKey, jsonEncode(data));
  }

  void _persistSessions() {
    final data = sessions.map((s) => s.toJson()).toList();
    _storage.write(_sessionsKey, data);
    SecureStorageService.to.writeSecure(_sessionsKey, jsonEncode(data));
  }

  void sendMessage([String? text]) {
    final value = (text ?? messageController.text).trim();
    if (value.isEmpty) {
      return;
    }

    suggestions.clear();

    messages.add(ChatMessageModel(text: value, sender: ChatMessageSender.user));
    messageController.clear();
    _persistActiveMessages();

    // Simulate typing delay
    isTyping.value = true;
    Future.delayed(const Duration(milliseconds: 1500), () {
      final reply = _mockReplyFor(value);
      messages.add(
        ChatMessageModel(text: reply, sender: ChatMessageSender.bot),
      );
      isTyping.value = false;
      _persistActiveMessages();
      _generateFollowUps(reply);
    });
  }

  void _generateFollowUps(String reply) {
    if (_matchesAny(reply, ['cv', 'resume'])) {
      suggestions.assignAll([
        'Improve my summary',
        'Add skills to CV',
        'Show CV templates',
      ]);
    } else if (_matchesAny(reply, ['job', 'search'])) {
      suggestions.assignAll([
        'Filter by remote jobs',
        'Show salary ranges',
        'View saved jobs',
      ]);
    } else if (_matchesAny(reply, ['interview'])) {
      suggestions.assignAll([
        'Practice questions',
        'Behavioral tips',
        'Technical prep',
      ]);
    } else {
      suggestions.assignAll([
        'Tell me more',
        'What else can you help with?',
        'Find jobs for me',
      ]);
    }
  }

  void updateHistorySearch(String value) {
    historySearchQuery.value = value;
  }

  void startNewChat() {
    if (messages.isNotEmpty) {
      final firstUserMsg = messages.firstWhere(
        (m) => m.sender == ChatMessageSender.user,
        orElse: () => messages.first,
      );
      final timestamp = DateTime.now();
      final name = firstUserMsg.text.length > 40
          ? '${firstUserMsg.text.substring(0, 40)}...'
          : firstUserMsg.text;

      sessions.insert(
        0,
        ChatSession(
          id: timestamp.millisecondsSinceEpoch.toString(),
          name: name,
          messages: List<ChatMessageModel>.from(messages),
          createdAt: timestamp,
        ),
      );

      if (sessions.length > 20) {
        sessions.removeRange(20, sessions.length);
      }
      _persistSessions();
    }

    messages.clear();
    suggestions.clear();
    messageController.clear();
    _storage.remove(_activeKey);
  }

  void loadSession(ChatSession session) {
    messages.assignAll(session.messages);
    suggestions.clear();
    _persistActiveMessages();
  }

  void deleteSession(int index) {
    sessions.removeAt(index);
    _persistSessions();
  }

  /// Returns `true` if [text] (lowercased) contains any of [keywords].
  static bool _matchesAny(String text, List<String> keywords) {
    final lower = text.toLowerCase();
    return keywords.any(lower.contains);
  }

  String _mockReplyFor(String message) {
    if (_matchesAny(message, ['cv', 'resume'])) {
      return "Absolutely! Please upload your CV and I'll analyze it for you.";
    }

    if (_matchesAny(message, ['job'])) {
      return "Sure. Tell me your preferred role, location, and expected salary, then I'll suggest matching jobs.";
    }

    if (_matchesAny(message, ['skill'])) {
      return 'I can recommend skills based on your target role. What job title are you aiming for?';
    }

    if (_matchesAny(message, ['roadmap'])) {
      return 'I can build a career roadmap for you. Share your current role and goal role first.';
    }

    if (_matchesAny(message, ['interview'])) {
      return "Let's practice. Tell me the role you're interviewing for and I'll prepare questions.";
    }

    return "Got it. I'll help with that. Can you share a little more detail?";
  }

  @override
  void onClose() {
    messageController.dispose();
    historySearchController.dispose();
    super.onClose();
  }
}
