import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
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
  late final ConversationModel _conversation;

  @override
  void initState() {
    super.initState();
    _conversation = Get.arguments as ConversationModel;
  }

  @override
  void dispose() {
    if (Get.isRegistered<MessagingController>()) {
      Get.find<MessagingController>().leaveConversation(_conversation.id);
    }
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(
    MessagingController ctrl,
    String conversationId,
  ) async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;

    _textCtrl.clear();
    try {
      await ctrl.sendMessage(conversationId, text);
    } on Object {
      if (!mounted) return;
      _textCtrl.text = text;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ctrl.errorMessage.value.isEmpty
                ? 'Message failed to send.'
                : ctrl.errorMessage.value,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final ctrl = Get.find<MessagingController>();
    final c = _conversation;

    return Scaffold(
      backgroundColor: palette.scaffold,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: MediaQuery.paddingOf(context).top + 70),
              Expanded(
                child: Obx(
                  () => ctrl.isLoadingMessages.value
                      ? const Center(child: FCircularProgress())
                      : ListView.separated(
                          controller: _scrollCtrl,
                          reverse: true,
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                          itemCount:
                              ctrl.currentMessages.length +
                              (ctrl.isTyping.value ? 1 : 0),
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            if (ctrl.isTyping.value && index == 0) {
                              return _TypingIndicator(palette: palette);
                            }

                            final actualIndex = ctrl.isTyping.value
                                ? index - 1
                                : index;
                            final msg = ctrl.currentMessages[actualIndex];

                            return _MessageBubble(
                              message: msg,
                              palette: palette,
                            );
                          },
                        ),
                ),
              ),

              // Input Area
              Container(
                padding: const EdgeInsets.fromLTRB(
                  12,
                  12,
                  12,
                  12,
                ).copyWith(bottom: MediaQuery.of(context).padding.bottom + 12),
                decoration: BoxDecoration(
                  color: palette.surfaceMuted,
                  border: Border(top: BorderSide(color: palette.border)),
                ),
                child: FTextField(
                  control: FTextFieldControl.managed(controller: _textCtrl),
                  size: FTextFieldSizeVariant.lg,
                  style: FTextFieldStyleDelta.delta(
                    color: FVariantsValueDelta.delta([
                      FVariantValueDeltaOperation.all(palette.surface),
                    ]),
                    constraints: const BoxConstraints(minHeight: 56),
                    contentPadding: const EdgeInsetsGeometryDelta.value(
                      EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                    ),
                    border: FVariantsValueDelta.delta([
                      FVariantValueDeltaOperation.all(
                        OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: palette.border),
                        ),
                      ),
                    ]),
                  ),
                  hint: 'Type Message..',
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.send,
                  autocorrect: true,
                  enableSuggestions: true,
                  onSubmit: (_) => _sendMessage(ctrl, c.id),
                  prefixBuilder: (context, style, variants) =>
                      FTextField.prefixIconBuilder(
                        context,
                        style,
                        variants,
                        _ComposerIconButton(
                          tooltip: 'Attach file',
                          onPress: () {},
                          child: const Icon(
                            Icons.attach_file_rounded,
                            size: 21,
                          ),
                        ),
                      ),
                  suffixBuilder: (_, _, _) => Padding(
                    padding: const EdgeInsetsDirectional.only(end: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ComposerIconButton(
                          tooltip: 'Record voice message',
                          onPress: () {},
                          child: const Icon(Icons.mic_none_rounded, size: 22),
                        ),
                        const SizedBox(width: 2),
                        _ComposerIconButton(
                          tooltip: 'Send message',
                          onPress: () => _sendMessage(ctrl, c.id),
                          backgroundColor: AppColors.chatComposerAction,
                          foregroundColor: Colors.white,
                          child: const Icon(Icons.send_rounded, size: 19),
                        ),
                      ],
                    ),
                  ),
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
                Flexible(
                  child: GestureDetector(
                    onTap: () => Get.toNamed<void>(
                      AppRoutes.publicProfile,
                      arguments: c.otherUser,
                    ),
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: palette.surface.withValues(alpha: 0.84),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: palette.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 15,
                            backgroundColor: palette.surfaceMuted,
                            backgroundImage: c.avatarUrl?.isNotEmpty == true
                                ? NetworkImage(c.avatarUrl!)
                                : null,
                            child: c.avatarUrl?.isNotEmpty == true
                                ? null
                                : Text(
                                    c.recruiterName.characters.first
                                        .toUpperCase(),
                                    style: const TextStyle(fontSize: 11),
                                  ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              c.recruiterName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                QuietGlassIconButton(
                  icon: FLucideIcons.ellipsis,
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

class _ComposerIconButton extends StatelessWidget {
  const _ComposerIconButton({
    required this.tooltip,
    required this.onPress,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String tooltip;
  final VoidCallback onPress;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Tooltip(
      message: tooltip,
      child: SizedBox.square(
        dimension: 40,
        child: FButton.raw(
          variant: FButtonVariant.ghost,
          onPress: onPress,
          semanticsLabel: tooltip,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: IconTheme(
                data: IconThemeData(
                  color: foregroundColor ?? palette.iconPrimary,
                ),
                child: child,
              ),
            ),
          ),
        ),
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
    final userId = Get.find<MessagingController>().currentUserId;
    final isMe = message.isFrom(userId);

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
