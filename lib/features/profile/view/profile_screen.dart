import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/utils/safe_image_loader.dart';
import 'package:jobodia_frontend/core/widgets/animated_scale_button.dart';
import 'package:jobodia_frontend/core/widgets/quiet_glass_button.dart';
import 'package:jobodia_frontend/features/cv_builder/controller/cv_builder_controller.dart';
import 'package:jobodia_frontend/features/cv_builder/model/cv_data.dart';
import 'package:jobodia_frontend/features/profile/controller/profile_controller.dart';
import 'package:jobodia_frontend/features/profile/view/widgets/experience_timeline.dart';
import 'package:jobodia_frontend/features/profile/view/widgets/profile_about_section.dart';
import 'package:jobodia_frontend/features/profile/model/profile_model.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({this.embedded = false, super.key});

  /// Whether this screen is embedded as a bottom-nav tab rather than pushed
  /// as a standalone route. When embedded, the floating back button is
  /// hidden since there is nothing to pop back to within the tab shell.
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
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
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Obx(
                              () => _ProfileSectionCard(
                                icon: FLucideIcons.userRound,
                                child: ProfileAboutSection(
                                  about: controller.profile.about,
                                  isExpanded: controller.isAboutExpanded.value,
                                  onReadMore: controller.toggleAbout,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Obx(() {
                              final skills = controller.profile.skills;
                              if (skills.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return _ProfileSectionCard(
                                icon: FLucideIcons.sparkles,
                                child: _SkillsSection(skills: skills),
                              );
                            }),
                            const SizedBox(height: 12),
                            Obx(() {
                              final links = controller.profile.portfolioLinks;
                              if (links.isEmpty) return const SizedBox.shrink();
                              return _ProfileSectionCard(
                                icon: FLucideIcons.globe2,
                                child: _PortfolioSection(links: links),
                              );
                            }),
                            const SizedBox(height: 12),
                            Obx(
                              () => _ProfileSectionCard(
                                icon: FLucideIcons.briefcase,
                                child: ExperienceTimeline(
                                  experiences: controller.profile.experiences,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
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
                  if (!embedded)
                    QuietGlassBackButton(onPressed: () => Get.back<void>())
                  else
                    const SizedBox(width: 44, height: 44),
                  const Spacer(),
                  QuietGlassIconButton(
                    onPressed: () => Get.toNamed<void>(AppRoutes.settings),
                    icon: FLucideIcons.settings,
                    foregroundColor: palette.iconPrimary,
                  ),
                  const SizedBox(width: 8),
                  QuietGlassIconButton(
                    onPressed: () => Get.toNamed<void>(AppRoutes.statistics),
                    icon: FLucideIcons.barChart,
                    foregroundColor: palette.iconPrimary,
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
    final coverHeight = topInset + 176;
    const avatarSize = 108.0;

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
                  FLucideIcons.userRound,
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
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF101820),
                          Color(0xFF1C4D55),
                          AppColors.brandTeal,
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -36,
                          top: -52,
                          child: Container(
                            width: 170,
                            height: 170,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                        ),
                        Positioned(
                          left: -55,
                          bottom: -70,
                          child: Container(
                            width: 190,
                            height: 190,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                                width: 32,
                              ),
                            ),
                          ),
                        ),
                      ],
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
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  profile.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                    letterSpacing: -0.6,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: () => Get.toNamed<void>(AppRoutes.editProfile),
                visualDensity: VisualDensity.compact,
                tooltip: 'Edit profile',
                icon: Icon(
                  FLucideIcons.penLine,
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
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: palette.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _ProfileMetric(
                    value: '${profile.experiences.length}',
                    label: 'Experience',
                  ),
                  SizedBox(height: 30, child: FDivider(axis: Axis.vertical)),
                  _ProfileMetric(
                    value: '${profile.skills.length}',
                    label: 'Skills',
                  ),
                  SizedBox(height: 30, child: FDivider(axis: Axis.vertical)),
                  _ProfileMetric(
                    value: '${profile.portfolioLinks.length}',
                    label: 'Projects',
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: palette.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSectionCard extends StatelessWidget {
  const _ProfileSectionCard({required this.icon, required this.child});

  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final theme = FTheme.of(context);
    return FCard(
      style: FCardStyle(
        decoration: ShapeDecoration(
          shape: RoundedSuperellipseBorder(
            side: BorderSide(color: palette.border),
            borderRadius: BorderRadius.circular(22),
          ),
          color: palette.surface,
        ),
        titleTextStyle: theme.typography.body.md,
        subtitleTextStyle: theme.typography.body.sm,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 17),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: Icon(
              icon,
              size: 19,
              color: AppColors.brandTeal.withValues(alpha: 0.65),
            ),
          ),
          Padding(padding: const EdgeInsets.only(right: 26), child: child),
        ],
      ),
    );
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
            return FBadge(
              variant: FBadgeVariant.outline,
              style: FBadgeStyle(
                decoration: ShapeDecoration(
                  shape: RoundedSuperellipseBorder(
                    side: BorderSide(
                      color: AppColors.brandTeal.withValues(alpha: 0.24),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: AppColors.brandTeal.withValues(alpha: 0.10),
                ),
                labelTextStyle: TextStyle(
                  color: AppColors.brandTeal,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
              ),
              child: Text(skill),
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
                      FLucideIcons.link,
                      color: AppColors.brandTeal,
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
                      FLucideIcons.externalLink,
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

    return FCard(
      style: FCardStyle(
        decoration: ShapeDecoration(
          shape: RoundedSuperellipseBorder(
            side: BorderSide(color: palette.textSecondary.withAlpha(40)),
            borderRadius: BorderRadius.circular(16),
          ),
          color: palette.surface,
        ),
        titleTextStyle: TextStyle(
          color: palette.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        subtitleTextStyle: TextStyle(
          color: palette.textSecondary,
          fontSize: 13,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    FLucideIcons.fileText,
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
