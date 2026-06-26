import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/applications/controller/applications_controller.dart';
import 'package:jobodia_frontend/features/company/controller/company_controller.dart';
import 'package:jobodia_frontend/features/cv_builder/controller/cv_builder_controller.dart';
import 'package:jobodia_frontend/features/cv_builder/model/cv_data.dart';
import 'package:jobodia_frontend/features/job_alerts/controller/job_alert_controller.dart';
import 'package:jobodia_frontend/features/profile/controller/profile_controller.dart';
import 'package:jobodia_frontend/features/profile/view/widgets/experience_timeline.dart';
import 'package:jobodia_frontend/features/profile/view/widgets/profile_about_section.dart';
import 'package:jobodia_frontend/features/profile/view/widgets/profile_cover_header.dart';
import 'package:jobodia_frontend/features/profile/view/widgets/profile_identity_header.dart';
import 'package:jobodia_frontend/features/profile/model/profile_model.dart';
import 'package:jobodia_frontend/features/saved_jobs/controller/saved_jobs_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.scaffold,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed<void>(AppRoutes.editProfile),
        backgroundColor: AppColors.primary,
        tooltip: 'Edit profile',
        child: const Icon(Icons.edit_rounded, color: Colors.white),
      ),
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
                    imageUrl: controller.profile.coverImageUrl,
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
                        Obx(
                          () => Container(
                            constraints: BoxConstraints(
                              minHeight:
                                  MediaQuery.sizeOf(context).height - 205,
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
                                // ── Activity stats row ──────────────────────
                                Obx(() {
                                  final saved = Get.find<SavedJobsController>()
                                      .savedIds
                                      .length;
                                  final applied =
                                      Get.find<ApplicationsController>()
                                          .applications
                                          .length;
                                  final cvReady =
                                      Get.find<CvBuilderController>()
                                          .isGenerated
                                          .value;
                                  final following =
                                      Get.find<CompanyController>()
                                          .followingCount;
                                  final alertsCount =
                                      Get.isRegistered<JobAlertController>()
                                      ? Get.find<JobAlertController>().alerts
                                            .where((a) => a.isActive)
                                            .length
                                      : 0;
                                  return _ActivityStatsRow(
                                    savedCount: saved,
                                    appliedCount: applied,
                                    cvReady: cvReady,
                                    followingCount: following,
                                    alertsCount: alertsCount,
                                  );
                                }),
                                const SizedBox(height: 18),
                                _InviteFriendsCard(palette: palette),
                                const SizedBox(height: 12),
                                _MarketValueCard(palette: palette),
                                const SizedBox(height: 12),
                                _CertificationsCard(palette: palette),
                                const SizedBox(height: 12),
                                _CareerGoalsCard(palette: palette),
                                const SizedBox(height: 18),
                                Obx(
                                  () => ProfileAboutSection(
                                    about: controller.profile.about,
                                    isExpanded:
                                        controller.isAboutExpanded.value,
                                    onReadMore: controller.toggleAbout,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Obx(() {
                                  final skills = controller.profile.skills;
                                  if (skills.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  return _SkillsSection(skills: skills);
                                }),
                                const SizedBox(height: 14),
                                Obx(() {
                                  final links =
                                      controller.profile.portfolioLinks;
                                  if (links.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  return _PortfolioSection(links: links);
                                }),
                                const SizedBox(height: 14),
                                Obx(
                                  () => ExperienceTimeline(
                                    experiences: controller.profile.experiences,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                // ── CV preview link card ─────────────────────
                                Obx(() {
                                  final cv = Get.find<CvBuilderController>()
                                      .generatedCv
                                      .value;
                                  return _CvLinkCard(generatedCv: cv);
                                }),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 22,
                          right: 18,
                          top: -26,
                          child: Obx(
                            () => ProfileIdentityHeader(
                              name: controller.profile.name,
                              role: controller.profile.role,
                              avatarUrl: controller.profile.avatarImageUrl,
                            ),
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

// ── Activity stats row ────────────────────────────────────────────────────────

class _ActivityStatsRow extends StatelessWidget {
  const _ActivityStatsRow({
    required this.savedCount,
    required this.appliedCount,
    required this.cvReady,
    required this.followingCount,
    required this.alertsCount,
  });

  final int savedCount;
  final int appliedCount;
  final bool cvReady;
  final int followingCount;
  final int alertsCount;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        SizedBox(
          width: (MediaQuery.of(context).size.width - 60) / 3,
          child: _StatTile(
            value: '$savedCount',
            label: 'Saved',
            onTap: () => Get.toNamed<void>(AppRoutes.savedJobs),
            palette: palette,
          ),
        ),
        SizedBox(
          width: (MediaQuery.of(context).size.width - 60) / 3,
          child: _StatTile(
            value: '$appliedCount',
            label: 'Applied',
            onTap: () => Get.toNamed<void>(AppRoutes.applications),
            palette: palette,
          ),
        ),
        SizedBox(
          width: (MediaQuery.of(context).size.width - 60) / 3,
          child: _StatTile(
            value: cvReady ? '✓' : '—',
            label: 'CV Ready',
            onTap: () => Get.toNamed<void>(AppRoutes.cvBuilder),
            palette: palette,
          ),
        ),
        SizedBox(
          width: (MediaQuery.of(context).size.width - 60) / 3,
          child: _StatTile(
            value: '$followingCount',
            label: 'Following',
            onTap: () {},
            palette: palette,
          ),
        ),
        SizedBox(
          width: (MediaQuery.of(context).size.width - 60) / 3,
          child: _StatTile(
            value: '$alertsCount',
            label: 'Alerts',
            onTap: () => Get.toNamed<void>(AppRoutes.jobAlerts),
            palette: palette,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.onTap,
    required this.palette,
  });

  final String value;
  final String label;
  final VoidCallback onTap;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: palette.surfaceMuted.withAlpha(180),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: palette.textSecondary.withAlpha(30)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: palette.textSecondary, fontSize: 12),
            ),
          ],
        ),
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
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: palette.surfaceMuted,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                skill,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
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
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Get.snackbar(
                    'Coming soon',
                    'This link will be available in a future update.',
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                  );
                },
                borderRadius: BorderRadius.circular(12),
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
          : InkWell(
              onTap: () => Get.toNamed<void>(AppRoutes.cvBuilder),
              borderRadius: BorderRadius.circular(16),
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

class _InviteFriendsCard extends StatelessWidget {
  const _InviteFriendsCard({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed<void>(AppRoutes.referrals),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.brandTeal.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.volunteer_activism_rounded,
                color: AppColors.brandTeal,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invite Friends',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Earn \$50 for every successful hire',
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: palette.iconMuted),
          ],
        ),
      ),
    );
  }
}

class _MarketValueCard extends StatelessWidget {
  const _MarketValueCard({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed<void>(AppRoutes.salaryInsights),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.brandTeal.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.insights_rounded,
                color: AppColors.brandTeal,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Market Value',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'View salary insights for your role',
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: palette.iconMuted),
          ],
        ),
      ),
    );
  }
}

class _CertificationsCard extends StatelessWidget {
  const _CertificationsCard({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed<void>(AppRoutes.assessments),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.brandTeal.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_rounded,
                color: AppColors.brandTeal,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Certifications',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Take skill assessments to earn badges',
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: palette.iconMuted),
          ],
        ),
      ),
    );
  }
}

class _CareerGoalsCard extends StatelessWidget {
  const _CareerGoalsCard({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed<void>(AppRoutes.careerGoals),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.trending_up_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Career Goals',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Track your progress & milestones',
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: palette.iconMuted),
          ],
        ),
      ),
    );
  }
}
