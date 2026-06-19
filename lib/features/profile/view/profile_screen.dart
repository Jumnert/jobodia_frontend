import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/profile/controller/profile_controller.dart';
import 'package:jobodia_frontend/features/profile/view/widgets/experience_timeline.dart';
import 'package:jobodia_frontend/features/profile/view/widgets/profile_about_section.dart';
import 'package:jobodia_frontend/features/profile/view/widgets/profile_cover_header.dart';
import 'package:jobodia_frontend/features/profile/view/widgets/profile_identity_header.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = controller.profile;
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.scaffold,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Obx(
                  () => ProfileCoverHeader(
                    imageUrl: profile.coverImageUrl,
                    isSaved: controller.isSaved.value,
                    onShare: controller.shareProfile,
                    onSave: controller.toggleSaved,
                  ),
                ),
              ),
              CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 205)),
                  SliverToBoxAdapter(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.sizeOf(context).height - 205,
                          ),
                          decoration: BoxDecoration(
                            color: palette.surface,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(26),
                            ),
                          ),
                          padding: const EdgeInsets.fromLTRB(22, 78, 22, 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(
                                () => ProfileAboutSection(
                                  about: profile.about,
                                  isExpanded: controller.isAboutExpanded.value,
                                  onReadMore: controller.toggleAbout,
                                ),
                              ),
                              const SizedBox(height: 14),
                              ExperienceTimeline(
                                experiences: profile.experiences,
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          left: 22,
                          right: 18,
                          top: -26,
                          child: ProfileIdentityHeader(
                            name: profile.name,
                            role: profile.role,
                            avatarUrl: profile.avatarImageUrl,
                          ),
                        ),
                      ],
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
