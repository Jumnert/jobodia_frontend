import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jobodia_frontend/features/ai_chat/service/deepseek_chat_service.dart';
import 'package:jobodia_frontend/features/job_post/controller/job_post_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GetStorage storage;
  late DeepSeekChatService aiService;
  late JobPostController controller;

  setUpAll(() async {
    final directory = await Directory.systemTemp.createTemp('job_post_test_');
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'getApplicationDocumentsDirectory') {
            return directory.path;
          }
          return null;
        });
    await GetStorage.init('job_post_test');
    storage = GetStorage('job_post_test');
  });

  setUp(() async {
    await storage.erase();
    final client = MockClient(
      (_) async => http.Response(
        jsonEncode({
          'choices': [
            {
              'message': {
                'content': jsonEncode({
                  'company': 'Your company',
                  'location': 'Phnom Penh',
                  'workArrangement': 'Hybrid',
                  'employmentType': 'Full-time',
                  'description': 'A complete generated description.',
                  'requirements': 'Flutter\nDart',
                  'tags': 'Flutter, Dart',
                }),
              },
            },
          ],
        }),
        200,
      ),
    );
    aiService = DeepSeekChatService(client: client, apiKey: 'test-key');
    controller = JobPostController(storage: storage, aiService: aiService);
    controller.onInit();
  });

  tearDown(() {
    controller.onClose();
    aiService.close();
  });

  test('starts on the listing dashboard when there are no jobs', () {
    expect(controller.currentView.value, JobPostView.dashboard);
    expect(controller.publishedJobs, isEmpty);
  });

  test('AI brief fills the draft and opens review', () async {
    final generated = await controller.generateAiDraft(
      title: 'Flutter Developer',
      salary: '\$2,000 – \$3,000',
      startDate: '2026-08-15',
      endDate: '2026-09-15',
      experienceLevel: 'Senior',
    );

    expect(generated, isTrue);
    expect(controller.currentView.value, JobPostView.editor);
    expect(controller.step.value, 3);
    expect(controller.draft.title, 'Flutter Developer');
    expect(controller.draft.description, isNotEmpty);
    expect(controller.draft.applicationEndDate, '2026-09-15');
  });

  test('publishing adds the listing and opens success state', () async {
    await controller.generateAiDraft(
      title: 'Flutter Developer',
      salary: '\$2,000 – \$3,000',
      startDate: '2026-08-15',
      endDate: '2026-09-15',
      experienceLevel: 'Senior',
    );

    controller.publishJob();

    expect(controller.currentView.value, JobPostView.success);
    expect(controller.publishedJobs, hasLength(1));
    expect(storage.read<List>(JobPostController.publishedKey), hasLength(1));
  });
}
