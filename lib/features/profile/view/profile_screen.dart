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
import 'package:jobodia_frontend/features/profile/model/profile_model.dart';
import 'package:jobodia_frontend/features/profile/view/widgets/experience_timeline.dart';
import 'package:jobodia_frontend/features/profile/view/widgets/profile_about_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({this.embedded = false, super.key});

  final bool embedded;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ScrollController _scrollController = ScrollController(
    keepScrollOffset: false,
  );

  ProfileController get controller => Get.find<ProfileController>();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final topInset = MediaQuery.paddingOf(context).top;
    final contentTop = topInset + (widget.embedded ? 30 : 76);

    return Scaffold(
      backgroundColor: palette.scaffold,
      body: Stack(
        children: [
          Positioned.fill(
            child: Obx(
              () => ListView(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(
                  12,
                  contentTop,
                  12,
                  MediaQuery.paddingOf(context).bottom + 28,
                ),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        children: [
                          _ProfilePresentation(
                            profile: controller.profile,
                            isAboutExpanded: controller.isAboutExpanded.value,
                            onToggleAbout: controller.toggleAbout,
                          ),
                          _ProfileDetails(profile: controller.profile),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!widget.embedded)
            Positioned(
              top: topInset + 24,
              left: 24,
              child: QuietGlassBackButton(onPressed: () => Get.back<void>()),
            ),
        ],
      ),
    );
  }
}

class _ProfilePresentation extends StatelessWidget {
  const _ProfilePresentation({
    required this.profile,
    required this.isAboutExpanded,
    required this.onToggleAbout,
  });

  final ProfileModel profile;
  final bool isAboutExpanded;
  final VoidCallback onToggleAbout;

  static const _coverHeight = 184.0;
  static const _avatarSize = 112.0;
  static const _coverTop = 0.0;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          children: [
            const SizedBox(height: _coverTop),
            _ProfileCover(profile: profile, height: _coverHeight),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 76, 18, 22),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                      letterSpacing: -0.7,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    profile.role,
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 22),
                  ProfileAboutSection(
                    about: profile.about,
                    isExpanded: isAboutExpanded,
                    onReadMore: onToggleAbout,
                  ),
                  const SizedBox(height: 34),
                  _ProfileMetrics(profile: profile),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          top: _coverTop + _coverHeight - _avatarSize / 2,
          left: 24,
          child: _ProfileAvatar(profile: profile, size: _avatarSize),
        ),
        Positioned(
          top: _coverTop + _coverHeight + 30,
          right: 18,
          child: FButton(
            variant: FButtonVariant.outline,
            onPress: () => Get.toNamed<void>(AppRoutes.editProfile),
            prefix: const Icon(FLucideIcons.penLine, size: 15),
            child: const Text('Edit Profile'),
          ),
        ),
      ],
    );
  }
}

class _ProfileCover extends StatelessWidget {
  const _ProfileCover({required this.profile, required this.height});

  final ProfileModel profile;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final cover = profile.hasCoverBytes
        ? Image.memory(
            profile.coverBytes!,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          )
        : Image.asset(
            isDark
                ? 'assets/images/profile/profile_cover_dark.png'
                : 'assets/images/profile/profile_cover_light.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            cacheWidth: 1440,
            filterQuality: FilterQuality.high,
          );

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          child: KeyedSubtree(
            key: ValueKey('${isDark}_${profile.hasCoverBytes}'),
            child: cover,
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.profile, required this.size});

  final ProfileModel profile;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final initial = profile.name.trim().isEmpty
        ? 'U'
        : profile.name.trim().characters.first.toUpperCase();

    return Hero(
      tag: 'user-avatar',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: palette.surfaceMuted,
          border: Border.all(color: palette.surface, width: 5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Transform.scale(
          scale: 1.14,
          child: profile.hasAvatarBytes
              ? Image.memory(
                  profile.avatarBytes!,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                )
              : SafeImageLoader(
                  url: profile.avatarImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Center(
                    child: Text(
                      initial,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _ProfileMetrics extends StatelessWidget {
  const _ProfileMetrics({required this.profile});

  final ProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProfileMetric(
          value: '${profile.experiences.length}',
          label: 'Experience',
        ),
        _ProfileMetric(value: '${profile.skills.length}', label: 'Skills'),
        _ProfileMetric(
          value: '${profile.portfolioLinks.length}',
          label: 'Projects',
        ),
      ],
    );
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 29,
              fontWeight: FontWeight.w700,
              height: 1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            style: TextStyle(
              color: palette.textTertiary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDetails extends StatelessWidget {
  const _ProfileDetails({required this.profile});

  final ProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final sections = <Widget>[
      if (profile.experiences.isNotEmpty)
        ExperienceTimeline(experiences: profile.experiences),
      if (profile.skills.isNotEmpty) _SkillsSection(skills: profile.skills),
      if (profile.portfolioLinks.isNotEmpty)
        _LinkedAccountsSection(links: profile.portfolioLinks),
      if (Get.isRegistered<CvBuilderController>())
        Obx(
          () => _CvSection(
            generatedCv: Get.find<CvBuilderController>().generatedCv.value,
          ),
        ),
    ];

    if (sections.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 28, 18, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < sections.length; index++) ...[
            sections[index],
            if (index != sections.length - 1) ...[
              const SizedBox(height: 24),
              Divider(color: palette.divider, height: 1),
              const SizedBox(height: 24),
            ],
          ],
        ],
      ),
    );
  }
}

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
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills
              .map(
                (skill) => FBadge(
                  variant: FBadgeVariant.outline,
                  style: FBadgeStyle(
                    decoration: ShapeDecoration(
                      color: AppColors.brandTeal.withValues(alpha: 0.08),
                      shape: RoundedSuperellipseBorder(
                        side: BorderSide(
                          color: AppColors.brandTeal.withValues(alpha: 0.22),
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    labelTextStyle: const TextStyle(
                      color: AppColors.brandTeal,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 7,
                    ),
                  ),
                  child: Text(skill),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _LinkedAccountsSection extends StatelessWidget {
  const _LinkedAccountsSection({required this.links});

  final List<PortfolioLink> links;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Linked accounts',
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        for (var index = 0; index < links.length; index++) ...[
          AnimatedScaleButton(
            onTap: () => Get.snackbar(
              links[index].title,
              links[index].url,
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          links[index].title,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          links[index].url,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.textTertiary,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Open',
                    style: TextStyle(
                      color: AppColors.brandTeal,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (index != links.length - 1)
            Divider(color: palette.divider, height: 1),
        ],
      ],
    );
  }
}

class _CvSection extends StatelessWidget {
  const _CvSection({required this.generatedCv});

  final CvData? generatedCv;

  static const _templateNames = ['Classic', 'Balanced', 'Modern'];

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final cv = generatedCv;
    return AnimatedScaleButton(
      onTap: () => Get.toNamed<void>(
        cv == null ? AppRoutes.cvBuilder : AppRoutes.cvPreview,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resume',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    cv == null
                        ? 'No resume yet — create one now'
                        : '${_templateNames[cv.templateIndex.clamp(0, _templateNames.length - 1)]} template',
                    style: TextStyle(color: palette.textTertiary, fontSize: 13),
                  ),
                ],
              ),
            ),
            Text(
              cv == null ? 'Create' : 'Preview',
              style: const TextStyle(
                color: AppColors.brandTeal,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
