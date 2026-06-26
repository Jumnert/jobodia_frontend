import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/auth/controller/auth_controller.dart';
import 'package:jobodia_frontend/features/ai_chat/controller/ai_chat_controller.dart';
import 'package:jobodia_frontend/features/ai_chat/model/chat_message_model.dart';
import 'package:jobodia_frontend/features/ai_chat/view/widgets/bot_avatar.dart';
import 'package:jobodia_frontend/features/ai_chat/view/widgets/chat_history_drawer.dart';
import 'package:jobodia_frontend/features/ai_chat/view/widgets/message_bubble.dart';
import 'package:jobodia_frontend/features/ai_chat/view/widgets/message_composer.dart';
import 'package:jobodia_frontend/features/home/view/widgets/app_bottom_navigation_bar.dart';
import 'package:jobodia_frontend/features/home/view/widgets/app_navigation.dart';

class AiChatScreen extends GetView<AiChatController> {
  const AiChatScreen({super.key, this.showBottomNav = true});

  final bool? showBottomNav;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: context.palette.scaffold,
      extendBody: true,
      endDrawer: ChatHistoryDrawer(controller: controller),
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
        child: Column(
          children: [
            const _ChatHeader(),
            Expanded(
              child: Obx(
                () => controller.hasMessages
                    ? Column(
                        children: [
                          Expanded(
                            child: _ConversationList(
                              messages: controller.messages,
                              controller: controller,
                            ),
                          ),
                          if (controller.isTyping.value)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 18,
                                bottom: 8,
                                right: 18,
                              ),
                              child: Row(
                                children: [
                                  const BotAvatar(size: 32),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.palette.surface,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _TypingDot(
                                          delay: 0,
                                          color: context.palette.textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        _TypingDot(
                                          delay: 200,
                                          color: context.palette.textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        _TypingDot(
                                          delay: 400,
                                          color: context.palette.textSecondary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      )
                    : _EmptyChatState(controller: controller),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14, 8, 14, 132 + bottomPadding),
              child: MessageComposer(controller: controller),
            ),
          ],
        ),
      ),
      bottomNavigationBar: (showBottomNav ?? true)
          ? AppBottomNavigationBar(
              selectedIndex: 2,
              onDestinationSelected: (index) =>
                  navigateMainDestination(context, index, currentIndex: 2),
              onSearchPressed: () => Get.toNamed<void>(AppRoutes.search),
            )
          : null,
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: Row(
        children: [
          IconButton(
            onPressed: Get.back,
            tooltip: 'Back',
            icon: const Icon(Icons.chevron_left_rounded, size: 30),
          ),
          const Expanded(
            child: Text(
              'Jobodia Ai',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(
            onPressed: () => Scaffold.of(context).openEndDrawer(),
            icon: const Icon(Icons.more_horiz_rounded),
          ),
        ],
      ),
    );
  }
}

class _EmptyChatState extends StatelessWidget {
  const _EmptyChatState({required this.controller});

  final AiChatController controller;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final defaultIcons = [
      Icons.article_outlined,
      Icons.work_outline_rounded,
      Icons.psychology_alt_outlined,
      Icons.map_outlined,
      Icons.travel_explore_rounded,
    ];

    return Obx(() {
      final items = <(IconData, String)>[];
      for (var i = 0; i < controller.suggestions.length; i++) {
        items.add((
          i < defaultIcons.length
              ? defaultIcons[i]
              : Icons.chat_bubble_outline_rounded,
          controller.suggestions[i],
        ));
      }

      return ListView(
        padding: const EdgeInsets.fromLTRB(14, 20, 14, 12),
        children: [
          const SizedBox(height: 12),
          const Center(child: BotAvatar(size: 96)),
          const SizedBox(height: 42),
          Text(
            'Hi, ${Get.find<AuthController>().currentUser.value?.name ?? 'there'}!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'How can I help you today?',
            textAlign: TextAlign.center,
            style: TextStyle(color: palette.textPrimary, fontSize: 18),
          ),
          const SizedBox(height: 64),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SuggestionTile(
                icon: item.$1,
                label: item.$2,
                onTap: () => controller.sendMessage(item.$2),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: SizedBox(
          height: 54,
          child: Row(
            children: [
              const SizedBox(width: 20),
              Icon(icon, size: 27, color: palette.iconPrimary),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConversationList extends StatelessWidget {
  const _ConversationList({required this.messages, required this.controller});

  final List<ChatMessageModel> messages;
  final AiChatController controller;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 42, 18, 16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isLastBot =
            message.sender == ChatMessageSender.bot &&
            (index == messages.length - 1 ||
                messages
                    .sublist(index + 1)
                    .every((m) => m.sender == ChatMessageSender.user));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MessageBubble(message: message),
            if (isLastBot)
              Obx(() {
                final suggestions = controller.suggestions;
                if (suggestions.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 28, left: 58),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: suggestions
                          .map(
                            (s) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ActionChip(
                                label: Text(
                                  s,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: context.palette.textPrimary,
                                  ),
                                ),
                                backgroundColor: context.palette.surface,
                                side: BorderSide(
                                  color: context.palette.textSecondary
                                      .withValues(alpha: 0.3),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                onPressed: () => controller.sendMessage(s),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}

class _TypingDot extends StatefulWidget {
  const _TypingDot({required this.delay, required this.color});

  final int delay;
  final Color color;

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final value = _ctrl.value;
        return Container(
          width: 8,
          height: 8 + (value * 4),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.4 + value * 0.6),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
