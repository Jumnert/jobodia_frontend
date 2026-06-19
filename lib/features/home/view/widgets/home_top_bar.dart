import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
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
        GlassIconButton(
          onPressed: onNotifications,
          icon: Icon(
            Icons.notifications_none_rounded,
            color: palette.iconPrimary,
          ),
        ),
        const SizedBox(width: 8),
        GlassIconButton(
          onPressed: onSettings,
          icon: Icon(Icons.settings_outlined, color: palette.iconPrimary),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => Get.to(
            () => const ProfileScreen(),
            binding: BindingsBuilder(
              () => Get.lazyPut<ProfileController>(ProfileController.new),
            ),
          ),
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
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.person_outline_rounded),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
