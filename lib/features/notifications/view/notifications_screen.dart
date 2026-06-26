import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/empty_state.dart';
import 'package:jobodia_frontend/features/notifications/controller/notifications_controller.dart';

class NotificationsScreen extends GetView<NotificationsController> {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.scaffold,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 18, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: Get.back,
                    tooltip: 'Back',
                    icon: const Icon(Icons.chevron_left_rounded, size: 30),
                  ),
                  const Expanded(
                    child: Text(
                      'Notifications',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Obx(() {
                    if (controller.unreadCount == 0) {
                      return const SizedBox(width: 48);
                    }
                    return IconButton(
                      onPressed: controller.markAllRead,
                      icon: Icon(
                        Icons.done_all_rounded,
                        color: palette.iconPrimary,
                        size: 24,
                      ),
                      tooltip: 'Mark all read',
                    );
                  }),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                final notifications = controller.notifications;
                if (notifications.isEmpty) {
                  return const EmptyState(
                    icon: Icons.notifications_outlined,
                    title: 'No notifications yet',
                  );
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: palette.surface,
                  onRefresh: () async {
                    await Future<void>.delayed(
                      const Duration(milliseconds: 600),
                    );
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 22),
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return Dismissible(
                        key: ValueKey(notification.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          decoration: BoxDecoration(
                            color: palette.error,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (_) =>
                            controller.dismissNotification(notification.id),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Material(
                            color: palette.surface,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              splashColor: AppColors.brandTeal.withValues(
                                alpha: 0.1,
                              ),
                              onTap: () => controller.markRead(notification.id),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: palette.border),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: palette.surfaceMuted,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        notification.icon,
                                        color: palette.iconPrimary,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  notification.title,
                                                  style: TextStyle(
                                                    color: palette.textPrimary,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ),
                                              if (!notification.isRead)
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    color: palette.textPrimary,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            notification.body,
                                            style: TextStyle(
                                              color: palette.textSecondary,
                                              fontSize: 13,
                                              height: 1.35,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            notification.time,
                                            style: TextStyle(
                                              color: palette.textTertiary,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
