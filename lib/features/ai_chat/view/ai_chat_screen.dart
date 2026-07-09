import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/ai_chat/controller/ai_chat_controller.dart';
import 'package:jobodia_frontend/features/ai_chat/model/chat_message_model.dart';
import 'package:jobodia_frontend/features/ai_chat/view/widgets/bot_avatar.dart';
import 'package:jobodia_frontend/features/ai_chat/view/widgets/chat_history_drawer.dart';
import 'package:jobodia_frontend/features/ai_chat/view/widgets/message_bubble.dart';
import 'package:jobodia_frontend/features/ai_chat/view/widgets/message_composer.dart';

class AiChatScreen extends GetView<AiChatController> {
  AiChatScreen({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.isDark;
    final fg = isDark ? Colors.white : palette.iconPrimary;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final topInset = MediaQuery.paddingOf(context).top;

    return AdaptiveScaffold(
      scaffoldKey: _scaffoldKey,
      useHeroBackButton: false,
      endDrawer: ChatHistoryDrawer(controller: controller),
      body: Container(
        color: palette.scaffold,
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
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
                                            color: palette.surface,
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _TypingDot(
                                                delay: 0,
                                                color: palette.textSecondary,
                                              ),
                                              const SizedBox(width: 4),
                                              _TypingDot(
                                                delay: 200,
                                                color: palette.textSecondary,
                                              ),
                                              const SizedBox(width: 4),
                                              _TypingDot(
                                                delay: 400,
                                                color: palette.textSecondary,
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
                    padding: EdgeInsets.fromLTRB(14, 8, 14, 58 + bottomPadding),
                    child: MessageComposer(controller: controller),
                  ),
                ],
              ),
            ),
            // ── Floating glass toolbar (like the Settings page) ──
            Positioned(
              top: topInset + 14,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  AdaptiveButton.icon(
                    onPressed: controller.startNewChat,
                    icon: Icons.add_comment_outlined,
                    iconColor: fg,
                    style: AdaptiveButtonStyle.glass,
                    minSize: const Size(44, 44),
                    useSmoothRectangleBorder: false,
                  ),
                  const Spacer(),
                  AdaptiveButton(
                    onPressed: () {},
                    label: 'Jobodia AI',
                    textColor: isDark ? Colors.white : palette.textPrimary,
                    style: AdaptiveButtonStyle.glass,
                    minSize: const Size(150, 44),
                    useSmoothRectangleBorder: false,
                  ),
                  const Spacer(),
                  AdaptiveButton.icon(
                    onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                    icon: Icons.history_rounded,
                    iconColor: fg,
                    style: AdaptiveButtonStyle.glass,
                    minSize: const Size(44, 44),
                    useSmoothRectangleBorder: false,
                  ),
                ],
              ),
            ),
          ],
        ),
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
    final topInset = MediaQuery.paddingOf(context).top;
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

      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(14, topInset + 72, 14, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - (topInset + 96),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Center(child: BotAvatar(size: 88)),
                  const SizedBox(height: 28),
                  Text(
                    'What can I help you with?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 32),
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
              ),
            ),
          );
        },
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
    // Precompute the last bot message index once (O(n)) instead of scanning
    // the tail of the list for every row (which was O(n^2)).
    var lastBotIndex = -1;
    for (var i = messages.length - 1; i >= 0; i--) {
      if (messages[i].sender == ChatMessageSender.bot) {
        lastBotIndex = i;
        break;
      }
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        18,
        MediaQuery.paddingOf(context).top + 72,
        18,
        16,
      ),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isLastBot = index == lastBotIndex;

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
