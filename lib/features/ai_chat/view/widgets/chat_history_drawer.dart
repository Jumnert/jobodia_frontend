import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/features/ai_chat/controller/ai_chat_controller.dart';

Future<void> showChatHistorySheet(
  BuildContext context, {
  required AiChatController controller,
}) async {
  await showFSheet<void>(
    context: context,
    side: FLayout.rtl,
    mainAxisMaxRatio: 0.9,
    useSafeArea: true,
    barrierDismissible: true,
    constraints: const BoxConstraints(maxWidth: 380),
    builder: (sheetContext) => _ChatHistorySheet(controller: controller),
  );
}

class _ChatHistorySheet extends StatelessWidget {
  const _ChatHistorySheet({required this.controller});

  final AiChatController controller;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
      child: ColoredBox(
        color: theme.colors.background,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Chat history',
                      style: theme.typography.display.sm.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  FButton.icon(
                    variant: FButtonVariant.ghost,
                    onPress: () => Navigator.of(context).pop(),
                    child: const Icon(FLucideIcons.x),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              FTextField(
                control: FTextFieldControl.managed(
                  controller: controller.historySearchController,
                  onChange: (value) =>
                      controller.updateHistorySearch(value.text),
                ),
                hint: 'Search chats',
                textInputAction: TextInputAction.search,
                prefixBuilder: (context, style, variants) =>
                    FTextField.prefixIconBuilder(
                      context,
                      style,
                      variants,
                      const Icon(FLucideIcons.search),
                    ),
              ),
              const SizedBox(height: 12),
              FButton(
                variant: FButtonVariant.outline,
                onPress: () {
                  controller.startNewChat();
                  Navigator.of(context).pop();
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FLucideIcons.messageCirclePlus, size: 18),
                    SizedBox(width: 8),
                    Text('New chat'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  final sessions = controller.filteredSessions;
                  if (sessions.isEmpty) {
                    return Center(
                      child: Text(
                        'No chats found.',
                        style: theme.typography.body.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: sessions.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      return FTile(
                        prefix: const Icon(FLucideIcons.messageCircle),
                        title: Text(
                          session.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        suffix: FButton.icon(
                          variant: FButtonVariant.ghost,
                          onPress: () {
                            final sourceIndex = controller.sessions.indexWhere(
                              (item) => item.id == session.id,
                            );
                            if (sourceIndex >= 0) {
                              controller.deleteSession(sourceIndex);
                            }
                          },
                          child: const Icon(FLucideIcons.trash2, size: 17),
                        ),
                        onPress: () {
                          controller.loadSession(session);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
