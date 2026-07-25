import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/quiet_glass_button.dart';
import 'package:jobodia_frontend/features/messaging/controller/messaging_controller.dart';
import 'package:jobodia_frontend/features/messaging/model/messaging_models.dart';

class ConversationDetailScreen extends StatefulWidget {
  const ConversationDetailScreen({super.key});

  @override
  State<ConversationDetailScreen> createState() =>
      _ConversationDetailScreenState();
}

class _ConversationDetailScreenState extends State<ConversationDetailScreen> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage(MessagingController ctrl, String conversationId) {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;

    ctrl.sendMessage(conversationId, text);
    _textCtrl.clear();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final ctrl = Get.find<MessagingController>();
    final c = Get.arguments as ConversationModel;

    return Scaffold(
      backgroundColor: palette.scaffold,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: MediaQuery.paddingOf(context).top + 70),
              Expanded(
                child: Obx(
                  () => ListView.separated(
                    controller: _scrollCtrl,
                    reverse: true,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    itemCount:
                        ctrl.currentMessages.length +
                        (ctrl.isTyping.value ? 1 : 0),
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (ctrl.isTyping.value && index == 0) {
                        return _TypingIndicator(palette: palette);
                      }

                      final actualIndex = ctrl.isTyping.value
                          ? index - 1
                          : index;
                      final msg = ctrl.currentMessages[actualIndex];

                      return _MessageBubble(message: msg, palette: palette);
                    },
                  ),
                ),
              ),

              // Input Area
              Container(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  10,
                  16,
                  12,
                ).copyWith(bottom: MediaQuery.of(context).padding.bottom + 12),
                decoration: BoxDecoration(
                  color: palette.surface,
                  border: Border(top: BorderSide(color: palette.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textCtrl,
                        style: TextStyle(color: palette.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: palette.textSecondary),
                          filled: true,
                          fillColor: palette.surfaceMuted,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(ctrl, c.id),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColors.brandTeal,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => _sendMessage(ctrl, c.id),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 12,
            left: 20,
            right: 20,
            child: Row(
              children: [
                QuietGlassBackButton(onPressed: Get.back),
                const SizedBox(width: 10),
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: palette.surface.withValues(alpha: 0.84),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: palette.border),
                  ),
                  child: Text(
                    'Messages',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Spacer(),
                QuietGlassIconButton(
                  icon: Icons.more_horiz_rounded,
                  tooltip: 'Conversation options',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.palette});

  final MessageModel message;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    final isMe = message.isFromUser;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? palette.textPrimary : palette.surface,
          border: isMe ? null : Border.all(color: palette.border),
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: isMe
                ? const Radius.circular(4)
                : const Radius.circular(20),
            bottomLeft: isMe
                ? const Radius.circular(20)
                : const Radius.circular(4),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isMe ? palette.scaffold : palette.textPrimary,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator({required this.palette});
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: palette.surfaceMuted,
          borderRadius: BorderRadius.circular(
            20,
          ).copyWith(bottomLeft: const Radius.circular(4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(palette: palette, delay: 0),
            const SizedBox(width: 4),
            _Dot(palette: palette, delay: 150),
            const SizedBox(width: 4),
            _Dot(palette: palette, delay: 300),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  const _Dot({required this.palette, required this.delay});
  final AppPalette palette;
  final int delay;

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: widget.palette.iconMuted,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
