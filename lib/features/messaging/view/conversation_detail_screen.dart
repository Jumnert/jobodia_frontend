import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final ctrl = Get.find<MessagingController>();
    final c = Get.arguments as ConversationModel;

    return Scaffold(
      backgroundColor: palette.scaffold,
      appBar: AppBar(
        backgroundColor: palette.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            color: palette.iconPrimary,
            size: 30,
          ),
          onPressed: Get.back,
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.brandTeal.withAlpha(40),
              child: Text(
                c.recruiterName[0],
                style: const TextStyle(
                  color: AppColors.brandTeal,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.recruiterName,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${c.jobTitle} @ ${c.recruiterCompany}',
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.separated(
                controller: _scrollCtrl,
                reverse: true,
                padding: const EdgeInsets.all(20),
                itemCount:
                    ctrl.currentMessages.length + (ctrl.isTyping.value ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (ctrl.isTyping.value && index == 0) {
                    return _TypingIndicator(palette: palette);
                  }

                  final actualIndex = ctrl.isTyping.value ? index - 1 : index;
                  final msg = ctrl.currentMessages[actualIndex];

                  return _MessageBubble(message: msg, palette: palette);
                },
              ),
            ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(
              16,
            ).copyWith(bottom: MediaQuery.of(context).padding.bottom + 16),
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
          color: isMe ? AppColors.brandTeal : palette.surfaceMuted,
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
            color: isMe ? Colors.white : palette.textPrimary,
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
