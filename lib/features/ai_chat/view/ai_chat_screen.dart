import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/quiet_glass_button.dart';
import 'package:jobodia_frontend/features/ai_chat/controller/ai_chat_controller.dart';
import 'package:jobodia_frontend/features/ai_chat/model/chat_message_model.dart';
import 'package:jobodia_frontend/features/ai_chat/view/widgets/bot_avatar.dart';
import 'package:jobodia_frontend/features/ai_chat/view/widgets/chat_history_drawer.dart';
import 'package:jobodia_frontend/features/ai_chat/view/widgets/message_bubble.dart';
import 'package:jobodia_frontend/features/ai_chat/view/widgets/message_composer.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  AiChatController get controller => Get.find<AiChatController>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final palette = context.palette;
    final isDark = context.isDark;
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final composerBottomPadding = keyboardVisible
        ? 10.0
        : 8.0;
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: ChatHistoryDrawer(controller: controller),
      body: Container(
        color: palette.scaffold,
        child: Stack(
          children: [
            Positioned.fill(
              child: Obx(
                () => _ProcessingBackdrop(
                  visible: controller.isTyping.value,
                  isDark: isDark,
                ),
              ),
            ),
            Positioned.fill(
              child: Column(
                children: [
                  Expanded(child: _ChatContent(controller: controller)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                    child: MessageComposer(controller: controller),
                  ),
                  SizedBox(height: composerBottomPadding),
                ],
              ),
            ),
            Positioned(
              top: topInset + 14,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  SizedBox(
                    width: 152,
                    child: Obx(
                      () => _ModelMultiSelect(
                        selectedModel: controller.selectedModel.value,
                        onChanged: controller.selectModel,
                      ),
                    ),
                  ),
                  const Spacer(),
                  QuietGlassIconButton(
                    icon: FLucideIcons.plus,
                    tooltip: 'New chat',
                    lightHaptic: true,
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      controller.startNewChat();
                    },
                  ),
                  const SizedBox(width: 8),
                  QuietGlassIconButton(
                    onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                    icon: FLucideIcons.history,
                    tooltip: 'Chat history',
                    lightHaptic: true,
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

class _ModelMultiSelect extends StatelessWidget {
  const _ModelMultiSelect({
    required this.selectedModel,
    required this.onChanged,
  });

  final JobodiaAiModel selectedModel;
  final ValueChanged<JobodiaAiModel> onChanged;

  @override
  Widget build(BuildContext context) {
    return FSelectMenuTile<JobodiaAiModel>(
      autoHide: true,
      divider: FItemDivider.none,
      selectControl: FMultiValueControl.managedRadio(
        initial: selectedModel,
        onChange: (models) {
          if (models.isNotEmpty) onChanged(models.first);
        },
      ),
      title: Row(
        children: [
          BotAvatar(size: 22, model: selectedModel),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              selectedModel.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      suffix: const Icon(FLucideIcons.chevronsUpDown, size: 16),
      menu: [
        for (final model in JobodiaAiModel.values)
          FSelectTile<JobodiaAiModel>(
            value: model,
            title: Row(
              children: [
                BotAvatar(size: 28, model: model),
                const SizedBox(width: 10),
                Expanded(child: Text(model.label)),
              ],
            ),
            subtitle: Text(model.description),
          ),
      ],
    );
  }
}

class _ChatContent extends StatelessWidget {
  const _ChatContent({required this.controller});

  final AiChatController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.hasMessages) {
        return _EmptyChatState(controller: controller);
      }

      return _ConversationList(
        messages: controller.messages.toList(growable: false),
        controller: controller,
      );
    });
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
      FLucideIcons.fileText,
      FLucideIcons.briefcase,
      FLucideIcons.brain,
      FLucideIcons.map,
      FLucideIcons.globe,
    ];

    return Obx(() {
      final items = <(IconData, String)>[];
      for (var i = 0; i < controller.suggestions.length; i++) {
        items.add((
          i < defaultIcons.length
              ? defaultIcons[i]
              : FLucideIcons.messageCircle,
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
              child: _EmptyChatEntrance(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _FloatingMascot(
                      size: 148,
                      model: controller.selectedModel.value,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'What can I help with?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.7,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Ask Jobodia about your CV, job search, skills, or next interview.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Get started',
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 9),
                    SizedBox(
                      height: 78,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 9),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return SizedBox(
                            width: 205,
                            child: _SuggestionTile(
                              icon: item.$1,
                              label: item.$2,
                              onTap: () => controller.sendMessage(item.$2),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
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
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 78,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.border),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.brandTeal.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 18, color: AppColors.brandTeal),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 12,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
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

class _FloatingMascot extends StatefulWidget {
  const _FloatingMascot({required this.size, required this.model});

  final double size;
  final JobodiaAiModel model;

  @override
  State<_FloatingMascot> createState() => _FloatingMascotState();
}

class _FloatingMascotState extends State<_FloatingMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: BotAvatar(size: widget.size, model: widget.model),
      builder: (context, child) {
        final phase = _controller.value * math.pi * 2;
        return Transform.translate(
          offset: Offset(0, math.sin(phase) * 4),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: widget.size * .82,
                height: widget.size * .82,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.brandTeal.withValues(alpha: .18),
                      AppColors.brandTeal.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
              child!,
            ],
          ),
        );
      },
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
      controller: controller.conversationScrollController,
      padding: EdgeInsets.fromLTRB(
        18,
        MediaQuery.paddingOf(context).top + 72,
        18,
        6,
      ),
      itemCount: messages.length + 1,
      itemBuilder: (context, index) {
        if (index == messages.length) {
          return Obx(() => _TypingRow(visible: controller.isTyping.value));
        }

        final message = messages[index];
        final isLastBot = index == lastBotIndex;
        final revealText =
            message.sender == ChatMessageSender.bot &&
            controller.takeResponseReveal(message);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MessageBubble(
              key: ValueKey(message.timestamp.microsecondsSinceEpoch),
              message: message,
              shouldAnimate:
                  message.sender == ChatMessageSender.bot &&
                  index == messages.length - 1,
              revealText: revealText,
              showDelivery:
                  message.sender == ChatMessageSender.user &&
                  index == messages.length - 1,
              onRegenerate:
                  message.sender == ChatMessageSender.bot &&
                      message.resumeAnalysis == null
                  ? () => controller.regenerateResponse(index)
                  : null,
              onRevealProgress: controller.keepLatestVisible,
            ),
            if (isLastBot)
              Obx(() {
                final suggestions = controller.suggestions;
                if (suggestions.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10, left: 39),
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

class _TypingRow extends StatelessWidget {
  const _TypingRow({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AnimatedSize(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      child: visible
          ? Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                key: const ValueKey('typing'),
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: palette.surfaceMuted,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(5),
                        bottomRight: Radius.circular(18),
                      ),
                    ),
                    child: _TypingPulse(color: palette.textSecondary),
                  ),
                ],
              ),
            )
          : const SizedBox(
              key: ValueKey('idle'),
              width: double.infinity,
              height: 2,
            ),
    );
  }
}

class _TypingPulse extends StatefulWidget {
  const _TypingPulse({required this.color});

  final Color color;

  @override
  State<_TypingPulse> createState() => _TypingPulseState();
}

class _TypingPulseState extends State<_TypingPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();
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
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final phase = (_ctrl.value + (index * 0.22)) % 1;
            final lift = phase < 0.5 ? phase * 2 : (1 - phase) * 2;
            return Transform.translate(
              offset: Offset(0, -2.5 * lift),
              child: Container(
                width: 6,
                height: 6,
                margin: EdgeInsets.only(right: index == 2 ? 0 : 4),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.45 + lift * 0.5),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _EmptyChatEntrance extends StatefulWidget {
  const _EmptyChatEntrance({required this.child});

  final Widget child;

  @override
  State<_EmptyChatEntrance> createState() => _EmptyChatEntranceState();
}

class _EmptyChatEntranceState extends State<_EmptyChatEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.035),
          end: Offset.zero,
        ).animate(curve),
        child: widget.child,
      ),
    );
  }
}

class _ProcessingBackdrop extends StatefulWidget {
  const _ProcessingBackdrop({required this.visible, required this.isDark});

  final bool visible;
  final bool isDark;

  @override
  State<_ProcessingBackdrop> createState() => _ProcessingBackdropState();
}

class _ProcessingBackdropState extends State<_ProcessingBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3600),
  );

  @override
  void initState() {
    super.initState();
    if (widget.visible) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant _ProcessingBackdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible == oldWidget.visible) return;
    if (widget.visible) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: widget.visible ? 1 : 0,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOut,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _ProcessingGradientPainter(
              animation: _controller,
              isDark: widget.isDark,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class _ProcessingGradientPainter extends CustomPainter {
  _ProcessingGradientPainter({
    required Animation<double> animation,
    required this.isDark,
  }) : _animation = animation,
       super(repaint: animation);

  final Animation<double> _animation;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final phase = _animation.value * math.pi * 2;
    _paintGlow(
      canvas,
      Offset(
        size.width * (.22 + math.sin(phase) * .08),
        size.height * (.33 + math.cos(phase) * .06),
      ),
      size.width * .78,
      AppColors.brandTeal.withValues(alpha: isDark ? .27 : .22),
    );
    _paintGlow(
      canvas,
      Offset(
        size.width * (.82 + math.cos(phase + .9) * .08),
        size.height * (.53 + math.sin(phase + .9) * .08),
      ),
      size.width * .70,
      Color.lerp(AppColors.brandTeal, Colors.white, .42)!.withValues(
        alpha: isDark ? .2 : .16,
      ),
    );
    _paintGlow(
      canvas,
      Offset(
        size.width * (.48 + math.sin(phase * 2 + 1.7) * .10),
        size.height * (.76 + math.cos(phase * 2 + 1.7) * .05),
      ),
      size.width * .66,
      Color.lerp(AppColors.brandTeal, Colors.black, .14)!.withValues(
        alpha: isDark ? .2 : .15,
      ),
    );
  }

  void _paintGlow(Canvas canvas, Offset center, double radius, Color color) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0)],
      ).createShader(rect);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _ProcessingGradientPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
