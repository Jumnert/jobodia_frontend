import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/core/widgets/quiet_glass_button.dart';
import 'package:jobodia_frontend/features/profile/controller/profile_controller.dart';
import 'package:jobodia_frontend/features/profile/view/profile_screen.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({required this.name, required this.avatarUrl, super.key});

  final String name;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final fallbackInitial = name.trim().isEmpty
        ? 'U'
        : name.trim().substring(0, 1).toUpperCase();
    final avatar = avatarUrl == null || avatarUrl!.trim().isEmpty
        ? FAvatar.raw(
            size: 42,
            child: Text(
              fallbackInitial,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          )
        : FAvatar(
            size: 42,
            image: NetworkImage(avatarUrl!),
            fallback: Text(
              fallbackInitial,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Semantics(
          label: 'Open profile for $name',
          button: true,
          child: FButton.raw(
            onPress: () => Get.to<void>(
              () => const ProfileScreen(),
              binding: BindingsBuilder(
                () => Get.lazyPut<ProfileController>(ProfileController.new),
              ),
            ),
            variant: FButtonVariant.ghost,
            style: const FButtonStyleDelta.delta(
              contentStyle: FButtonContentStyleDelta.delta(
                constraints: BoxConstraints(minWidth: 42, minHeight: 42),
                padding: EdgeInsetsGeometryDelta.value(EdgeInsets.zero),
              ),
            ),
            child: avatar,
          ),
        ),
        const Spacer(),
        QuietGlassIconButton(
          icon: FLucideIcons.search,
          tooltip: 'Search jobs',
          lightHaptic: true,
          onPressed: () => Get.toNamed<void>(AppRoutes.search),
        ),
        const SizedBox(width: 8),
        QuietGlassIconButton(
          icon: FLucideIcons.messageCircle,
          tooltip: 'Messages',
          lightHaptic: true,
          onPressed: () => Get.toNamed<void>(AppRoutes.conversations),
        ),
      ],
    );
  }
}
