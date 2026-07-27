import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/quiet_glass_button.dart';
import 'package:jobodia_frontend/features/home/controller/main_nav_controller.dart';
import 'package:jobodia_frontend/features/notifications/controller/notifications_controller.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({
    required this.name,
    required this.avatarUrl,
    required this.onNotifications,
    super.key,
  });

  final String name;
  final String? avatarUrl;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final foreground = context.isDark ? Colors.white : palette.textPrimary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            foregroundColor: foreground,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          child: Text(
            'Hi, $name',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Semantics(
              label: 'Notifications',
              button: true,
              child: IconButton(
                onPressed: onNotifications,
                icon: Icon(Icons.notifications_none_rounded, color: foreground),
                style: IconButton.styleFrom(
                  backgroundColor: palette.surfaceMuted.withValues(alpha: 0.76),
                  shape: const CircleBorder(),
                ),
              ),
            ),
            Obx(() {
              final count = Get.isRegistered<NotificationsController>()
                  ? Get.find<NotificationsController>().unreadCount
                  : 0;
              if (count == 0) return const SizedBox.shrink();
              return Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(width: 8),
        QuietGlassIconButton(
          icon: Icons.chat_bubble_outline_rounded,
          tooltip: 'Chat with Jobodia AI',
          lightHaptic: true,
          onPressed: () => Get.find<MainNavController>().goToTab(2),
        ),
      ],
    );
  }
}
