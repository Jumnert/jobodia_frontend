import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/utils/safe_image_loader.dart';
import 'package:jobodia_frontend/core/widgets/quiet_glass_button.dart';
import 'package:jobodia_frontend/features/home/controller/main_nav_controller.dart';
import 'package:jobodia_frontend/features/notifications/controller/notifications_controller.dart';
import 'package:jobodia_frontend/features/profile/controller/profile_controller.dart';
import 'package:jobodia_frontend/features/profile/view/profile_screen.dart';
import 'package:jobodia_frontend/features/settings/controller/theme_controller.dart';

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
        AdaptiveButton(
          onPressed: () {},
          label: 'Hi, $name',
          textColor: foreground,
          style: AdaptiveButtonStyle.glass,
          size: AdaptiveButtonSize.large,
          minSize: const Size(150, 44),
          useSmoothRectangleBorder: false,
        ),
        const Spacer(),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Semantics(
              label: 'Notifications',
              button: true,
              child: AdaptiveButton.icon(
                onPressed: onNotifications,
                icon: Icons.notifications_none_rounded,
                iconColor: foreground,
                style: AdaptiveButtonStyle.glass,
                size: AdaptiveButtonSize.large,
                minSize: const Size(44, 44),
                useSmoothRectangleBorder: false,
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
        const SizedBox(width: 8),
        Semantics(
          label: 'Profile',
          button: true,
          child: Hero(
            tag: 'user-avatar',
            child: AdaptiveButton.child(
              onPressed: () => Get.to(
                () => const ProfileScreen(),
                binding: BindingsBuilder(
                  () => Get.lazyPut<ProfileController>(ProfileController.new),
                ),
              ),
              style: AdaptiveButtonStyle.glass,
              size: AdaptiveButtonSize.large,
              minSize: const Size(44, 44),
              useSmoothRectangleBorder: false,
              padding: EdgeInsets.zero,
              child: SizedBox(
                width: 36,
                height: 36,
                child: ClipOval(
                  child: Obx(() {
                    const icons = [
                      'aqua_orbit.png',
                      'briefcase.png',
                      'rocket.png',
                      'compass.png',
                      'document.png',
                      'idea.png',
                      'summit.png',
                      'ai_orb.png',
                      'handshake.png',
                      'gem.png',
                    ];
                    if (Get.isRegistered<ThemeController>()) {
                      final index =
                          Get.find<ThemeController>().profileIconIndex.value;
                      return Image.asset(
                        'assets/images/profile_icons/${icons[index]}',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.person_outline_rounded,
                          color: foreground,
                        ),
                      );
                    }
                    return SafeImageLoader(
                      url: avatarUrl ?? 'https://i.pravatar.cc/150?img=32',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.person_outline_rounded, color: foreground),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
