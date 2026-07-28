import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/empty_state.dart';
import 'package:jobodia_frontend/core/widgets/quiet_glass_button.dart';
import 'package:jobodia_frontend/features/notifications/controller/notifications_controller.dart';

class NotificationsScreen extends GetView<NotificationsController> {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Obx(() {
              final notifications = controller.notifications;
              return notifications.isEmpty
                  ? const EmptyState(
                      icon: FLucideIcons.bell,
                      title: 'No notifications yet',
                    )
                  : RefreshIndicator(
                      color: AppColors.primary,
                      backgroundColor: palette.surface,
                      onRefresh: () async {
                        await Future<void>.delayed(
                          const Duration(milliseconds: 600),
                        );
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          18,
                          MediaQuery.paddingOf(context).top + 80,
                          18,
                          22,
                        ),
                        itemCount: notifications.length + 2,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: 16,
                                left: 4,
                              ),
                              child: Text(
                                'Previously',
                                style: TextStyle(
                                  color: palette.textSecondary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }
                          if (index == notifications.length + 1) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                top: 32,
                                bottom: 24,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Missing notifications?',
                                    style: TextStyle(
                                      color: palette.textSecondary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Go to historical notifications.',
                                    style: const TextStyle(
                                      color: AppColors.brandPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final notification = notifications[index - 1];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Dismissible(
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
                                  FLucideIcons.trash2,
                                  color: Colors.white,
                                ),
                              ),
                              onDismissed: (_) => controller
                                  .dismissNotification(notification.id),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Material(
                                  color: palette.surface,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(18),
                                    splashColor: AppColors.brandTeal.withValues(
                                      alpha: 0.1,
                                    ),
                                    onTap: () =>
                                        controller.markRead(notification.id),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: const BoxDecoration(
                                              color: Color(
                                                0xFFFCA5A5,
                                              ), // Pink bg
                                              shape: BoxShape.circle,
                                            ),
                                            alignment: Alignment.center,
                                            child: const Text(
                                              'V.',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 14),
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
                                                          color: palette
                                                              .textPrimary,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      notification.time,
                                                      style: TextStyle(
                                                        color:
                                                            palette.textPrimary,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                    if (!notification
                                                        .isRead) ...[
                                                      const SizedBox(width: 8),
                                                      Container(
                                                        width: 10,
                                                        height: 10,
                                                        decoration:
                                                            const BoxDecoration(
                                                              color: Color(
                                                                0xFF007AFF,
                                                              ), // iOS blue dot
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  notification.body,
                                                  style: TextStyle(
                                                    color: palette.textPrimary,
                                                    fontSize: 14,
                                                    height: 1.35,
                                                    fontWeight: FontWeight.w500,
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
                            ),
                          );
                        },
                      ),
                    );
            }),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 14,
            left: 20,
            right: 20,
            child: Row(
              children: [
                QuietGlassBackButton(onPressed: () => Get.back<void>()),
                const Spacer(),
                QuietGlassIconButton(
                  onPressed: () {},
                  icon: FLucideIcons.bell,
                  foregroundColor: palette.iconPrimary,
                ),
                const Spacer(),
                QuietGlassIconButton(
                  onPressed: controller.markAllRead,
                  icon: FLucideIcons.checkCheck,
                  foregroundColor: palette.iconPrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
