import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/quiet_glass_button.dart';
import 'package:jobodia_frontend/features/messaging/controller/messaging_controller.dart';
import 'package:jobodia_frontend/features/messaging/model/messaging_models.dart';

enum _ChatFilter { all, unread, individual, organizations }

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  late final MessagingController _controller;
  _ChatFilter _filter = _ChatFilter.all;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<MessagingController>()
        ? Get.find<MessagingController>()
        : Get.put(MessagingController());
  }

  List<ConversationModel> _filtered(List<ConversationModel> source) {
    final active = source
        .where((chat) => !chat.isArchived && !chat.isBlocked)
        .toList(growable: false);
    return switch (_filter) {
      _ChatFilter.all => active,
      _ChatFilter.unread =>
        active.where((chat) => chat.unreadCount > 0).toList(growable: false),
      _ChatFilter.individual =>
        active.where((chat) => !chat.isOrganization).toList(growable: false),
      _ChatFilter.organizations =>
        active.where((chat) => chat.isOrganization).toList(growable: false),
    };
  }

  void _openConversation(ConversationModel conversation) {
    _controller.openConversation(conversation.id);
    Get.toNamed<void>(AppRoutes.conversationDetail, arguments: conversation);
  }

  void _showActions(ConversationModel conversation) {
    unawaited(HapticFeedback.mediumImpact());
    showFSheet<void>(
      context: context,
      side: FLayout.btt,
      mainAxisMaxRatio: 0.7,
      useSafeArea: true,
      barrierDismissible: true,
      builder: (sheetContext) => _ConversationActionsSheet(
        conversation: conversation,
        controller: _controller,
        close: () => Navigator.of(sheetContext).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: palette.scaffold,
      body: Column(
        children: [
          SizedBox(height: topInset + 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: QuietGlassBackButton(onPressed: Get.back),
                  ),
                  Text(
                    'chats'.tr,
                    style: FTheme.of(context).typography.display.sm.copyWith(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: QuietGlassIconButton(
                      icon: FLucideIcons.ellipsisVertical,
                      tooltip: 'chat_options'.tr,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _ChatFilter.values
                  .map(
                    (filter) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FButton(
                        variant: _filter == filter
                            ? FButtonVariant.primary
                            : FButtonVariant.outline,
                        onPress: () {
                          HapticFeedback.selectionClick();
                          setState(() => _filter = filter);
                        },
                        child: Text(_filterLabel(filter).tr),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Obx(() {
              final conversations = _filtered(_controller.conversations);
              if (conversations.isEmpty) {
                return Center(
                  child: Text(
                    _filter == _ChatFilter.unread
                        ? 'no_unread_chats'.tr
                        : 'no_messages'.tr,
                    style: TextStyle(color: palette.textSecondary),
                  ),
                );
              }

              return ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  16,
                  4,
                  16,
                  MediaQuery.paddingOf(context).bottom + 20,
                ),
                itemCount: conversations.length,
                separatorBuilder: (_, _) =>
                    Divider(height: 1, indent: 62, color: palette.divider),
                itemBuilder: (context, index) {
                  final conversation = conversations[index];
                  return _ConversationTile(
                    conversation: conversation,
                    onTap: () => _openConversation(conversation),
                    onLongPress: () => _showActions(conversation),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  String _filterLabel(_ChatFilter filter) => switch (filter) {
    _ChatFilter.all => 'all',
    _ChatFilter.unread => 'unread',
    _ChatFilter.individual => 'individual',
    _ChatFilter.organizations => 'organizations',
  };
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.onTap,
    required this.onLongPress,
  });

  final ConversationModel conversation;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final unread = conversation.unreadCount > 0;

    return Semantics(
      button: true,
      label: '${conversation.recruiterName}, ${conversation.lastMessage}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 13),
            child: Row(
              children: [
                _ConversationAvatar(conversation: conversation, size: 46),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.recruiterName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontSize: 14.5,
                                fontWeight: unread
                                    ? FontWeight.w800
                                    : FontWeight.w700,
                              ),
                            ),
                          ),
                          if (conversation.isMuted) ...[
                            Icon(
                              FLucideIcons.bellOff,
                              size: 13,
                              color: palette.iconMuted,
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            _chatTime(conversation.lastMessageTime),
                            style: TextStyle(
                              color: palette.textTertiary,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: unread
                                    ? palette.textPrimary
                                    : palette.textSecondary,
                                fontSize: 12.5,
                                fontWeight: unread
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                          if (unread) ...[
                            const SizedBox(width: 10),
                            Container(
                              constraints: const BoxConstraints(
                                minWidth: 21,
                                minHeight: 18,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.brandPrimary,
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                conversation.unreadCount > 99
                                    ? '99+'
                                    : '${conversation.unreadCount}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _chatTime(DateTime value) {
    final difference = DateTime.now().difference(value);
    if (difference.inDays == 0) return DateFormat.Hm().format(value);
    if (difference.inDays == 1) return 'yesterday'.tr;
    if (difference.inDays < 7) {
      return 'days_ago'.trParams({'count': '${difference.inDays}'});
    }
    return 'last_week'.tr;
  }
}

class _ConversationAvatar extends StatelessWidget {
  const _ConversationAvatar({required this.conversation, required this.size});

  final ConversationModel conversation;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initial = conversation.recruiterName.trim().isEmpty
        ? '?'
        : conversation.recruiterName.trim().characters.first.toUpperCase();
    final colors = conversation.isOrganization
        ? const [Color(0xFFE5F7D6), Color(0xFFBEEA98)]
        : const [Color(0xFFE8EEF6), Color(0xFFD5DFEC)];

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        border: Border.all(color: context.palette.border),
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.black.withValues(alpha: 0.72),
          fontSize: size * 0.38,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ConversationActionsSheet extends StatelessWidget {
  const _ConversationActionsSheet({
    required this.conversation,
    required this.controller,
    required this.close,
  });

  final ConversationModel conversation;
  final MessagingController controller;
  final VoidCallback close;

  void _run(VoidCallback action) {
    action();
    close();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final palette = context.palette;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      child: ColoredBox(
        color: theme.colors.background,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            10,
            16,
            MediaQuery.paddingOf(context).bottom + 18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _ConversationAvatar(conversation: conversation, size: 46),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conversation.recruiterName,
                          style: theme.typography.body.md.copyWith(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          conversation.recruiterCompany,
                          style: theme.typography.body.xs.copyWith(
                            color: palette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              FTileGroup(
                children: [
                  FTile(
                    prefix: const Icon(FLucideIcons.mail),
                    title: Text('mark_unread'.tr),
                    onPress: () =>
                        _run(() => controller.markUnread(conversation.id)),
                  ),
                  FTile(
                    prefix: Icon(
                      conversation.isMuted
                          ? FLucideIcons.bellRing
                          : FLucideIcons.bellOff,
                    ),
                    title: Text(conversation.isMuted ? 'unmute'.tr : 'mute'.tr),
                    onPress: () =>
                        _run(() => controller.toggleMuted(conversation.id)),
                  ),
                  FTile(
                    prefix: const Icon(FLucideIcons.archive),
                    title: Text('archive'.tr),
                    onPress: () =>
                        _run(() => controller.archive(conversation.id)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FTileGroup(
                children: [
                  FTile(
                    variant: FItemVariant.destructive,
                    prefix: const Icon(FLucideIcons.ban),
                    title: Text('block_user'.tr),
                    onPress: () =>
                        _run(() => controller.block(conversation.id)),
                  ),
                  FTile(
                    variant: FItemVariant.destructive,
                    prefix: const Icon(FLucideIcons.trash2),
                    title: Text('delete_chat'.tr),
                    onPress: () => _run(
                      () => controller.deleteConversation(conversation.id),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
