import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/utils/safe_image_loader.dart';
import 'package:jobodia_frontend/core/widgets/animated_scale_button.dart';
import 'package:jobodia_frontend/features/cv_builder/controller/cv_builder_controller.dart';
import 'package:jobodia_frontend/features/cv_builder/model/cv_data.dart';
import 'package:jobodia_frontend/features/profile/controller/profile_controller.dart';
import 'package:jobodia_frontend/features/profile/view/widgets/experience_timeline.dart';
import 'package:jobodia_frontend/features/profile/view/widgets/profile_about_section.dart';
import 'package:jobodia_frontend/features/profile/model/profile_model.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final topInset = MediaQuery.paddingOf(context).top;

    return AdaptiveScaffold(
      body: Container(
        color: palette.scaffold,
        child: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      // Full-bleed cover banner (runs behind the toolbar) with
                      // the avatar overlapping its bottom edge.
                      _ProfileHeader(
                        controller: controller,
                        topInset: topInset,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Obx(
                              () => ProfileAboutSection(
                                about: controller.profile.about,
                                isExpanded: controller.isAboutExpanded.value,
                                onReadMore: controller.toggleAbout,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Obx(() {
                              final skills = controller.profile.skills;
                              if (skills.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return _SkillsSection(skills: skills);
                            }),
                            const SizedBox(height: 18),
                            Obx(() {
                              final links = controller.profile.portfolioLinks;
                              if (links.isEmpty) return const SizedBox.shrink();
                              return _PortfolioSection(links: links);
                            }),
                            const SizedBox(height: 18),
                            Obx(
                              () => ExperienceTimeline(
                                experiences: controller.profile.experiences,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Obx(() {
                              final cv = Get.find<CvBuilderController>()
                                  .generatedCv
                                  .value;
                              return _CvLinkCard(generatedCv: cv);
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // ── Floating glass toolbar (over the cover) ──
            Positioned(
              top: topInset + 14,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  AdaptiveButton.icon(
                    onPressed: () => Get.back<void>(),
                    icon: PlatformInfo.isIOS
                        ? Icons.arrow_back_ios_new_rounded
                        : Icons.arrow_back_rounded,
                    iconColor: palette.iconPrimary,
                    style: AdaptiveButtonStyle.glass,
                    minSize: const Size(44, 44),
                    useSmoothRectangleBorder: false,
                  ),
                  const Spacer(),
                  AdaptiveButton.icon(
                    onPressed: () => Get.toNamed<void>(AppRoutes.settings),
                    icon: Icons.settings_outlined,
                    iconColor: palette.iconPrimary,
                    style: AdaptiveButtonStyle.glass,
                    minSize: const Size(44, 44),
                    useSmoothRectangleBorder: false,
                  ),
                  const SizedBox(width: 8),
                  AdaptiveButton.icon(
                    onPressed: () => Get.toNamed<void>(AppRoutes.statistics),
                    icon: Icons.bar_chart_rounded,
                    iconColor: palette.iconPrimary,
                    style: AdaptiveButtonStyle.glass,
                    minSize: const Size(44, 44),
                    useSmoothRectangleBorder: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header: full-bleed cover + overlapping avatar + name + role + edit ────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.controller, required this.topInset});

  final ProfileController controller;
  final double topInset;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // Cover runs from the very top (behind the status bar + toolbar).
    final coverHeight = topInset + 150;
    const avatarSize = 104.0;

    return Obx(() {
      final profile = controller.profile;

      final avatar = Hero(
        tag: 'user-avatar',
        child: Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: palette.surface, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipOval(
            child: SafeImageLoader(
              url: profile.avatarImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: palette.surfaceMuted,
                child: Icon(
                  Icons.person_rounded,
                  size: 52,
                  color: palette.iconMuted,
                ),
              ),
            ),
          ),
        ),
      );

      return Column(
        children: [
          SizedBox(
            // cover + the half of the avatar that hangs below it.
            height: coverHeight + avatarSize / 2,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: coverHeight,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.accentPurple,
                          AppColors.accentPurpleDark,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: coverHeight - avatarSize / 2,
                  left: 0,
                  right: 0,
                  child: Center(child: avatar),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  profile.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: () => Get.toNamed<void>(AppRoutes.editProfile),
                visualDensity: VisualDensity.compact,
                tooltip: 'Edit profile',
                icon: Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: palette.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            profile.role,
            textAlign: TextAlign.center,
            style: TextStyle(color: palette.textSecondary, fontSize: 14),
          ),
        ],
      );
    });
  }
}

// ── Skills section ────────────────────────────────────────────────────────────

class _SkillsSection extends StatelessWidget {
  const _SkillsSection({required this.skills});

  final List<String> skills;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills',
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills.map((skill) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(22),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withAlpha(60)),
              ),
              child: Text(
                skill,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Portfolio section ─────────────────────────────────────────────────────────

class _PortfolioSection extends StatelessWidget {
  const _PortfolioSection({required this.links});

  final List<PortfolioLink> links;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Portfolio',
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        ...links.map((link) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: AnimatedScaleButton(
              onTap: () {
                Get.snackbar(
                  'Coming soon',
                  'This link will be available in a future update.',
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(16),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: palette.surfaceMuted.withAlpha(180),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: palette.textSecondary.withAlpha(30),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.link_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        link.title,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.open_in_new_rounded,
                      color: palette.textSecondary,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ── CV preview link card ──────────────────────────────────────────────────────

class _CvLinkCard extends StatelessWidget {
  const _CvLinkCard({required this.generatedCv});

  final CvData? generatedCv;

  static const _templateNames = ['Classic', 'Balanced', 'Modern'];

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final cv = generatedCv;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.textSecondary.withAlpha(40)),
      ),
      child: cv != null
          ? Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your CV',
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _templateNames[cv.templateIndex.clamp(
                          0,
                          _templateNames.length - 1,
                        )],
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Get.toNamed<void>(AppRoutes.cvPreview),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    backgroundColor: AppColors.primary.withAlpha(25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'Preview →',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            )
          : AnimatedScaleButton(
              onTap: () => Get.toNamed<void>(AppRoutes.cvBuilder),
              child: Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    color: palette.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'No CV yet — Build your CV →',
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
