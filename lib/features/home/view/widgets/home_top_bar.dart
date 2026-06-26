import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/notifications/controller/notifications_controller.dart';
import 'package:jobodia_frontend/features/profile/controller/profile_controller.dart';
import 'package:jobodia_frontend/features/profile/view/profile_screen.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({
    required this.name,
    required this.avatarUrl,
    required this.onNotifications,
    required this.onSettings,
    super.key,
  });

  final String name;
  final String? avatarUrl;
  final VoidCallback onNotifications;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: palette.textPrimary,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
              children: [
                const TextSpan(text: 'Hi, '),
                TextSpan(text: '$name 👋'),
              ],
            ),
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Semantics(
              label: 'Notifications',
              button: true,
              child: GlassIconButton(
                onPressed: onNotifications,
                icon: Icon(
                  Icons.notifications_none_rounded,
                  color: palette.iconPrimary,
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
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      count > 9 ? '9+' : '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(width: 8),
        Semantics(
          label: 'Settings',
          button: true,
          child: GlassIconButton(
            onPressed: onSettings,
            icon: Icon(Icons.settings_outlined, color: palette.iconPrimary),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => Get.to(
            () => const ProfileScreen(),
            binding: BindingsBuilder(
              () => Get.lazyPut<ProfileController>(ProfileController.new),
            ),
          ),
          child: Hero(
            tag: 'user-avatar',
            child: Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: palette.border, width: 2),
                color: palette.surfaceMuted,
              ),
              child: ClipOval(
                child: avatarUrl == null
                    ? const Icon(Icons.person_outline_rounded)
                    : Image.network(
                        avatarUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) =>
                            progress == null
                            ? child
                            : Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: palette.textSecondary,
                                  ),
                                ),
                              ),
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.person_outline_rounded),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
