import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/messaging/controller/messaging_controller.dart';
import 'package:intl/intl.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final ctrl = Get.put(MessagingController());

    return Scaffold(
      backgroundColor: palette.scaffold,
      appBar: AppBar(
        backgroundColor: palette.scaffold,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            color: palette.iconPrimary,
            size: 30,
          ),
          onPressed: Get.back,
        ),
        title: Text(
          'Messages',
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Obx(() {
        if (ctrl.conversations.isEmpty) {
          return Center(
            child: Text(
              'No messages yet',
              style: TextStyle(color: palette.textSecondary),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: ctrl.conversations.length,
          separatorBuilder: (_, __) =>
              Divider(color: palette.border, height: 1),
          itemBuilder: (context, index) {
            final c = ctrl.conversations[index];
            return ListTile(
              onTap: () {
                ctrl.openConversation(c.id);
                Get.toNamed<void>('/conversation-detail', arguments: c);
              },
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              leading: Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.brandTeal.withAlpha(40),
                    child: Text(
                      c.recruiterName[0],
                      style: const TextStyle(
                        color: AppColors.brandTeal,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  if (c.unreadCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${c.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              title: Text(
                c.recruiterName,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontWeight: c.unreadCount > 0
                      ? FontWeight.w800
                      : FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(
                    '${c.jobTitle} @ ${c.recruiterCompany}',
                    style: TextStyle(
                      color: AppColors.brandTeal,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    c.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: c.unreadCount > 0
                          ? palette.textPrimary
                          : palette.textSecondary,
                      fontWeight: c.unreadCount > 0
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
              trailing: Text(
                DateFormat.MMMd().format(c.lastMessageTime),
                style: TextStyle(color: palette.textTertiary, fontSize: 12),
              ),
            );
          },
        );
      }),
    );
  }
}
