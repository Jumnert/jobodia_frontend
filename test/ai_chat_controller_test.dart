import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/features/ai_chat/controller/ai_chat_controller.dart';
import 'package:jobodia_frontend/features/ai_chat/model/chat_message_model.dart';
import 'package:jobodia_frontend/features/ai_chat/model/chat_session.dart';
import 'package:jobodia_frontend/services/secure_storage_service.dart';

/// Mock path_provider so GetStorage can initialize in tests.
Future<void> _setupPathProviderMock() async {
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  final tempDir = await Directory.systemTemp.createTemp('gs_chat_test_');

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall call) async {
        if (call.method == 'getApplicationDocumentsDirectory') {
          return tempDir.path;
        }
        return null;
      });
}

/// Mock flutter_secure_storage to avoid platform channel errors.
void _setupSecureStorageMock() {
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall call) async {
        if (call.method == 'write') return null;
        if (call.method == 'read') return null;
        if (call.method == 'delete') return null;
        if (call.method == 'deleteAll') return null;
        if (call.method == 'readAll') return <String, String>{};
        return null;
      });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _setupPathProviderMock();
    _setupSecureStorageMock();
    await GetStorage.init();
    // Register SecureStorageService so Get.find() works.
    Get.put(SecureStorageService());
  });

  setUp(() async {
    final storage = GetStorage();
    await storage.erase();
  });

  late AiChatController ctrl;

  setUp(() {
    ctrl = AiChatController();
  });

  tearDown(() {
    ctrl.dispose();
  });

  group('sendMessage', () {
    test('adds a user message to messages list', () {
      ctrl.sendMessage('Hello');

      final userMessages = ctrl.messages
          .where((m) => m.sender == ChatMessageSender.user)
          .toList();

      expect(userMessages, hasLength(1));
      expect(userMessages.first.text, 'Hello');
    });

    test('clears suggestions after sending', () {
      expect(ctrl.suggestions, isNotEmpty); // default suggestions

      ctrl.sendMessage('Test');

      expect(ctrl.suggestions, isEmpty);
    });

    test('bot reply is added after delay', () async {
      ctrl.sendMessage('Help me find jobs');

      // Wait for the mock reply delay (1500ms) plus buffer.
      await Future<void>.delayed(const Duration(milliseconds: 2000));

      final botMessages = ctrl.messages
          .where((m) => m.sender == ChatMessageSender.bot)
          .toList();

      expect(botMessages, hasLength(1));
      expect(botMessages.first.text, isNotEmpty);
    });

    test('bot reply is keyword-based for "cv" message', () async {
      ctrl.sendMessage('Review my CV');

      await Future<void>.delayed(const Duration(milliseconds: 2000));

      final botReply = ctrl.messages
          .where((m) => m.sender == ChatMessageSender.bot)
          .first;

      expect(botReply.text.toLowerCase(), contains('cv'));
    });

    test('bot reply is keyword-based for "interview" message', () async {
      ctrl.sendMessage('Help me with interview prep');

      await Future<void>.delayed(const Duration(milliseconds: 2000));

      final botReply = ctrl.messages
          .where((m) => m.sender == ChatMessageSender.bot)
          .first;

      expect(botReply.text.toLowerCase(), contains('practice'));
    });

    test('ignores empty text', () {
      ctrl.sendMessage('');
      ctrl.sendMessage('   ');

      expect(ctrl.messages, isEmpty);
    });

    test('uses controller text when no argument given', () {
      ctrl.messageController.text = 'Typed message';
      ctrl.sendMessage();

      final userMessages = ctrl.messages
          .where((m) => m.sender == ChatMessageSender.user)
          .toList();

      expect(userMessages, hasLength(1));
      expect(userMessages.first.text, 'Typed message');
    });

    test('does nothing when both text param and controller are empty', () {
      ctrl.messageController.text = '';
      ctrl.sendMessage();

      expect(ctrl.messages, isEmpty);
    });
  });

  group('sessions', () {
    test('deleteSession removes session at index', () {
      ctrl.sessions.addAll([
        ChatSession(
          id: '1',
          name: 'Session 1',
          messages: [],
          createdAt: DateTime(2025),
        ),
        ChatSession(
          id: '2',
          name: 'Session 2',
          messages: [],
          createdAt: DateTime(2025),
        ),
        ChatSession(
          id: '3',
          name: 'Session 3',
          messages: [],
          createdAt: DateTime(2025),
        ),
      ]);

      ctrl.deleteSession(1);

      expect(ctrl.sessions.length, 2);
      expect(ctrl.sessions.first.name, 'Session 1');
      expect(ctrl.sessions.last.name, 'Session 3');
    });

    test('startNewChat creates a session from current messages', () async {
      ctrl.sendMessage('Hello');
      await Future<void>.delayed(const Duration(milliseconds: 2000));

      ctrl.startNewChat();

      expect(ctrl.sessions.length, 1);
      expect(ctrl.messages, isEmpty);
    });

    test('startNewChat uses first user message as session name', () async {
      ctrl.sendMessage('Find me a job');
      await Future<void>.delayed(const Duration(milliseconds: 2000));

      ctrl.startNewChat();

      expect(ctrl.sessions.first.name, 'Find me a job');
    });

    test('startNewChat truncates long session names', () async {
      final longText = 'A' * 50;
      ctrl.sendMessage(longText);
      await Future<void>.delayed(const Duration(milliseconds: 2000));

      ctrl.startNewChat();

      expect(ctrl.sessions.first.name.length, lessThanOrEqualTo(43));
      expect(ctrl.sessions.first.name, endsWith('...'));
    });

    test('startNewChat does nothing with empty messages', () {
      ctrl.startNewChat();

      expect(ctrl.sessions, isEmpty);
    });
  });

  group('hasMessages', () {
    test('returns false when no messages', () {
      expect(ctrl.hasMessages, isFalse);
    });

    test('returns true after sending a message', () {
      ctrl.sendMessage('Hi');

      expect(ctrl.hasMessages, isTrue);
    });
  });

  group('updateHistorySearch', () {
    test('updates historySearchQuery', () {
      ctrl.updateHistorySearch('flutter');

      expect(ctrl.historySearchQuery.value, 'flutter');
    });
  });

  group('filteredSessions', () {
    setUp(() {
      ctrl.sessions.addAll([
        ChatSession(
          id: '1',
          name: 'Flutter help',
          messages: [],
          createdAt: DateTime(2025),
        ),
        ChatSession(
          id: '2',
          name: 'Job search',
          messages: [],
          createdAt: DateTime(2025),
        ),
      ]);
    });

    test('returns all sessions when query is empty', () {
      expect(ctrl.filteredSessions.length, 2);
    });

    test('filters sessions by name', () {
      ctrl.updateHistorySearch('Flutter');

      expect(ctrl.filteredSessions.length, 1);
      expect(ctrl.filteredSessions.first.name, 'Flutter help');
    });

    test('returns empty when no match', () {
      ctrl.updateHistorySearch('xyz');

      expect(ctrl.filteredSessions, isEmpty);
    });

    test('case insensitive search', () {
      ctrl.updateHistorySearch('flutter');

      expect(ctrl.filteredSessions.length, 1);
    });
  });
}
