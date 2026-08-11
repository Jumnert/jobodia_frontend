import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/theme/app_theme.dart';
import 'package:jobodia_frontend/features/messaging/controller/messaging_controller.dart';
import 'package:jobodia_frontend/features/messaging/view/conversation_detail_screen.dart';
import 'package:jobodia_frontend/theme/theme.dart' as forui_theme;

void main() {
  testWidgets('chat composer lays out with bounded action buttons', (
    tester,
  ) async {
    Get.testMode = true;
    final controller = Get.put(MessagingController());
    final conversation = controller.conversations.first;
    controller.openConversation(conversation.id);
    addTearDown(Get.reset);

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => FTheme(
          data: forui_theme.lightTheme,
          child: child ?? const SizedBox.shrink(),
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => Get.to<void>(
                  () => const ConversationDetailScreen(),
                  arguments: conversation,
                ),
                child: const Text('Open chat'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open chat'));
    await tester.pumpAndSettle();

    expect(find.text('Type Message..'), findsOneWidget);
    expect(find.byTooltip('Attach file'), findsOneWidget);
    expect(find.byTooltip('Record voice message'), findsOneWidget);
    expect(find.byTooltip('Send message'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
