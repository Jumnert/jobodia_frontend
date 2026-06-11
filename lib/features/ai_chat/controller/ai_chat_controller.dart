import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/features/ai_chat/model/chat_message_model.dart';

class AiChatController extends GetxController {
  final messageController = TextEditingController();
  final historySearchController = TextEditingController();
  final RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  final RxString historySearchQuery = ''.obs;

  final suggestions = const <String>[
    'Review my CV',
    'Find Jobs For Me',
    'Skill Recommendations',
    'Career Roadmap',
    'Interview tips',
  ];

  final chatHistory = const <String>[
    'Review my product designer CV',
    'Find remote Flutter jobs',
    'Prepare for UX interview',
    'Build a 30-day career roadmap',
    'Improve my portfolio summary',
    'What skills should I learn next?',
    'Salary negotiation tips',
    'Find internships near me',
    'Explain job match percentage',
    'Write a cover letter',
    'Practice behavioral questions',
    'Analyze my LinkedIn headline',
    'Junior developer roadmap',
    'Best fintech design skills',
    'Mock interview for startup role',
    'Help me choose job offers',
    'Create weekly learning plan',
    'Review my project descriptions',
    'Find government UX roles',
    'Improve resume bullet points',
  ];

  bool get hasMessages => messages.isNotEmpty;

  List<String> get filteredChatHistory {
    final query = historySearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return chatHistory;
    }

    return chatHistory
        .where((history) => history.toLowerCase().contains(query))
        .toList();
  }

  void sendMessage([String? text]) {
    final value = (text ?? messageController.text).trim();
    if (value.isEmpty) {
      return;
    }

    messages.add(ChatMessageModel(text: value, sender: ChatMessageSender.user));
    messageController.clear();

    messages.add(
      ChatMessageModel(
        text: _mockReplyFor(value),
        sender: ChatMessageSender.bot,
      ),
    );
  }

  void updateHistorySearch(String value) {
    historySearchQuery.value = value;
  }

  void startNewChat() {
    messages.clear();
    messageController.clear();
  }

  String _mockReplyFor(String message) {
    final normalized = message.toLowerCase();

    if (normalized.contains('cv') || normalized.contains('resume')) {
      return "Absolutely! Please upload your CV and I'll analyze it for you.";
    }

    if (normalized.contains('job')) {
      return "Sure. Tell me your preferred role, location, and expected salary, then I'll suggest matching jobs.";
    }

    if (normalized.contains('skill')) {
      return 'I can recommend skills based on your target role. What job title are you aiming for?';
    }

    if (normalized.contains('roadmap')) {
      return 'I can build a career roadmap for you. Share your current role and goal role first.';
    }

    if (normalized.contains('interview')) {
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
