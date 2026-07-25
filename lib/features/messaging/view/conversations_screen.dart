import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/quiet_glass_button.dart';
import 'package:jobodia_frontend/features/messaging/controller/messaging_controller.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final controller = Get.isRegistered<MessagingController>()
        ? Get.find<MessagingController>()
        : Get.put(MessagingController());

    return Scaffold(
      backgroundColor: palette.scaffold,
      body: Stack(
        children: [
          Obx(() {
            if (controller.conversations.isEmpty) {
              return Center(
                child: Text(
                  'No messages yet',
                  style: TextStyle(color: palette.textSecondary),
                ),
              );
            }
            return ListView.separated(
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.paddingOf(context).top + 78,
                16,
                104,
              ),
              itemCount: controller.conversations.length,
              separatorBuilder: (_, _) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final conversation = controller.conversations[index];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      controller.openConversation(conversation.id);
                      Get.toNamed<void>(
                        '/conversation-detail',
                        arguments: conversation,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 11,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: AppColors.brandTeal.withValues(
                              alpha: 0.14,
                            ),
                            child: Text(
                              conversation.recruiterName.characters.first,
                              style: const TextStyle(
                                color: AppColors.brandTeal,
                                fontWeight: FontWeight.w800,
                                fontSize: 19,
                              ),
                            ),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        conversation.recruiterCompany,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: palette.textPrimary,
                                          fontSize: 15,
                                          fontWeight:
                                              conversation.unreadCount > 0
                                              ? FontWeight.w800
                                              : FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      DateFormat.MMMd().format(
                                        conversation.lastMessageTime,
                                      ),
                                      style: TextStyle(
                                        color: palette.textTertiary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  conversation.lastMessage,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: palette.textSecondary,
                                    fontSize: 13,
                                    fontWeight: conversation.unreadCount > 0
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (conversation.unreadCount > 0) ...[
                            const SizedBox(width: 10),
                            Container(
                              constraints: const BoxConstraints(minWidth: 20),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: const BoxDecoration(
                                color: AppColors.brandTeal,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(999),
                                ),
                              ),
                              child: Text(
                                '${conversation.unreadCount}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 12,
            left: 20,
            right: 20,
            child: Row(
              children: [
                QuietGlassBackButton(onPressed: Get.back),
                const Spacer(),
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: palette.surface.withValues(alpha: 0.78),
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
                  icon: Icons.search_rounded,
                  tooltip: 'Search messages',
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
