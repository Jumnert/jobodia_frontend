import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/app/theme/app_theme.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/company_avatar.dart';
import 'package:jobodia_frontend/core/widgets/error_state.dart';
import 'package:jobodia_frontend/core/widgets/paginated_list_view.dart';
import 'package:jobodia_frontend/core/widgets/skeleton_card.dart';
import 'package:jobodia_frontend/features/auth/controller/auth_controller.dart';
import 'package:jobodia_frontend/features/home/controller/home_controller.dart';
import 'package:jobodia_frontend/features/home/model/job_feed_model.dart';
import 'package:jobodia_frontend/features/home/view/widgets/home_top_bar.dart';
import 'package:jobodia_frontend/features/home/view/widgets/job_feed_card.dart';
import 'package:jobodia_frontend/features/job_detail/view/job_detail_sheet.dart';
import 'package:jobodia_frontend/features/saved_jobs/controller/saved_jobs_controller.dart';
import 'package:jobodia_frontend/features/settings/controller/theme_controller.dart';

import 'package:share_plus/share_plus.dart';

/// Home feed screen shown after login succeeds.
class HomeScreen extends GetView<AuthController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = controller.currentUser.value;
    final palette = context.palette;
    final homeController = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: palette.scaffold,
      extendBody: true,
      body: Stack(
        children: [
          const Positioned.fill(child: _ThemeBackdrop()),
          Positioned.fill(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Obx(() {
                    if (homeController.hasError.value) {
                      return ErrorState(
                        message: 'failed_load_jobs'.tr,
                        subtitle: 'check_connection'.tr,
                        onRetry: homeController.retryLoading,
                      );
                    }
                    if (homeController.isLoading.value) {
                      return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          20,
                          MediaQuery.paddingOf(context).top + 72,
                          20,
                          92,
                        ),
                        itemCount: 3,
                        itemBuilder: (_, _) => const SkeletonJobCard(),
                      );
                    }

                    final page = homeController.visiblePage;
                    final jobs = page.jobs;

                    final pagedJobs = jobs;

                    return RefreshIndicator(
                      color: AppColors.brandPrimary,
                      backgroundColor: palette.surface,
                      onRefresh: () async {
                        await Future<void>.delayed(
                          const Duration(milliseconds: 600),
                        );
                        homeController.selectTab(
                          homeController.selectedTab.value,
                        );
                      },
                      child: PaginatedListView(
                        controller: homeController.scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          20,
                          MediaQuery.paddingOf(context).top + 72,
                          20,
                          92,
                        ),
                        hasMore: page.hasMore,
                        isLoadingMore: homeController.isLoadingMore.value,
                        onLoadMore: homeController.loadMore,
                        itemCount: pagedJobs.isEmpty ? 2 : pagedJobs.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _JobListingHeader(
                                jobCount: homeController.filteredJobs.length,
                              ),
                            );
                          }

                          if (pagedJobs.isEmpty) {
                            return _EmptyJobListing(
                              hasSearch: homeController.searchQuery.value
                                  .trim()
                                  .isNotEmpty,
                              hasFilters: homeController.hasActiveFilters,
                              onReset: () {
                                homeController.clearSearch();
                                homeController.clearFilters();
                                homeController.selectTab(0);
                              },
                            );
                          }

                          final jobIndex = index - 1;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _JobFeedContextMenu(
                              job: pagedJobs[jobIndex],
                              colorIndex: jobIndex,
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ),
                Positioned(
                  top: MediaQuery.paddingOf(context).top + 14,
                  left: 20,
                  right: 20,
                  child: HomeTopBar(
                    name: user?.name ?? 'User',
                    avatarUrl: user?.avatarUrl,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JobListingHeader extends StatelessWidget {
  const _JobListingHeader({required this.jobCount});

  final int jobCount;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'find_next_move'.tr,
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 25,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'opportunities_picked'.trParams({'count': '$jobCount'}),
          style: TextStyle(
            color: palette.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _EmptyJobListing extends StatelessWidget {
  const _EmptyJobListing({
    required this.hasSearch,
    required this.hasFilters,
    required this.onReset,
  });

  final bool hasSearch;
  final bool hasFilters;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final title = hasSearch || hasFilters
        ? 'no_jobs_match'.tr
        : 'no_jobs_available'.tr;
    final subtitle = hasSearch || hasFilters
        ? 'empty_search_help'.tr
        : 'empty_jobs_help'.tr;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      child: Column(
        children: [
          SizedBox(
            width: 220,
            height: 220,
            child: Image.asset(
              'assets/images/empty_states/no_jobs_available.png',
              fit: BoxFit.contain,
              semanticLabel: 'No jobs available',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          if (hasSearch || hasFilters) ...[
            const SizedBox(height: 18),
            FButton(
              variant: FButtonVariant.outline,
              onPress: onReset,
              prefix: const Icon(FLucideIcons.rotateCcw, size: 17),
              child: Text('clear_search_filters'.tr),
            ),
          ],
        ],
      ),
    );
  }
}

// Kept as an internal preview component for design testing in development.
// ignore: unused_element
class _ThemePickerDialog extends StatelessWidget {
  const _ThemePickerDialog({
    required this.controller,
    required this.onSelected,
  });

  final ThemeController controller;
  final ValueChanged<AppThemePreset> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Dialog(
      backgroundColor: palette.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose your look',
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'You can change it anytime by holding the background.',
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(FLucideIcons.x),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 190,
                child: Obx(() {
                  final selectedPreset = controller.preset.value;
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: AppThemePreset.values.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final preset = AppThemePreset.values[index];
                      return SizedBox(
                        width: 210,
                        child: _ThemePreviewCard(
                          preset: preset,
                          isSelected: selectedPreset == preset,
                          onTap: () => onSelected(preset),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemePreviewCard extends StatelessWidget {
  const _ThemePreviewCard({
    required this.preset,
    required this.isSelected,
    required this.onTap,
  });

  final AppThemePreset preset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      selected: isSelected,
      label: '${preset.label} theme',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected
                ? preset.accent.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? preset.accent : palette.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 1.55,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _ThemeBackdrop(preset: preset, preview: true),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 27,
                              height: 7,
                              decoration: BoxDecoration(
                                color: preset.accent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const Spacer(),
                            ...List.generate(
                              2,
                              (index) => Container(
                                height: 17,
                                margin: const EdgeInsets.only(top: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.78),
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x17000000),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          top: 7,
                          right: 7,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: preset.accent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              FLucideIcons.check,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                preset.label,
                maxLines: 1,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                preset.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: palette.textTertiary, fontSize: 9),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeBackdrop extends StatelessWidget {
  const _ThemeBackdrop({this.preset, this.preview = false});

  final AppThemePreset? preset;
  final bool preview;

  @override
  Widget build(BuildContext context) {
    final activePreset =
        preset ??
        (Get.isRegistered<ThemeController>()
            ? Get.find<ThemeController>().preset.value
            : AppThemePreset.defaultTheme);
    final isDark = context.isDark;
    final colors = _backgroundColors(activePreset, isDark);
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        child: CustomPaint(
          painter: _BackdropGlowPainter(
            accent: activePreset.accent,
            dark: isDark,
            preview: preview,
          ),
        ),
      ),
    );
  }

  List<Color> _backgroundColors(AppThemePreset preset, bool dark) {
    return switch ((preset, dark)) {
      (AppThemePreset.defaultTheme, false) => const [
        Color(0xFFF8FBFC),
        Color(0xFFF2F5F7),
      ],
      (AppThemePreset.defaultTheme, true) => const [
        Color(0xFF111719),
        Color(0xFF0A0A0A),
      ],
      (AppThemePreset.golden, false) => const [
        Color(0xFFFFFDF5),
        Color(0xFFFFF1C8),
      ],
      (AppThemePreset.golden, true) => const [
        Color(0xFF211A0D),
        Color(0xFF151109),
      ],
      (AppThemePreset.midnight, false) => const [
        Color(0xFFF5F7FF),
        Color(0xFFE5EAFE),
      ],
      (AppThemePreset.midnight, true) => const [
        Color(0xFF111A38),
        Color(0xFF080D1B),
      ],
      (AppThemePreset.rose, false) => const [
        Color(0xFFFFFAFC),
        Color(0xFFF9E4EB),
      ],
      (AppThemePreset.rose, true) => const [
        Color(0xFF291720),
        Color(0xFF1C1016),
      ],
      (AppThemePreset.forest, false) => const [
        Color(0xFFF8FCF9),
        Color(0xFFE3F2E9),
      ],
      (AppThemePreset.forest, true) => const [
        Color(0xFF12231B),
        Color(0xFF0B1712),
      ],
      (AppThemePreset.lavender, false) => const [
        Color(0xFFFCFAFF),
        Color(0xFFEDE6FA),
      ],
      (AppThemePreset.lavender, true) => const [
        Color(0xFF20182E),
        Color(0xFF151020),
      ],
    };
  }
}

class _BackdropGlowPainter extends CustomPainter {
  const _BackdropGlowPainter({
    required this.accent,
    required this.dark,
    required this.preview,
  });

  final Color accent;
  final bool dark;
  final bool preview;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              accent.withValues(alpha: dark ? 0.18 : 0.14),
              accent.withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.86, size.height * 0.14),
              radius: size.width * (preview ? 0.72 : 0.9),
            ),
          );
    canvas.drawCircle(
      Offset(size.width * 0.86, size.height * 0.14),
      size.width * (preview ? 0.72 : 0.9),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _BackdropGlowPainter oldDelegate) {
    return accent != oldDelegate.accent ||
        dark != oldDelegate.dark ||
        preview != oldDelegate.preview;
  }
}

class _JobFeedContextMenu extends StatelessWidget {
  const _JobFeedContextMenu({required this.job, required this.colorIndex});

  final JobFeedModel job;
  final int colorIndex;

  @override
  Widget build(BuildContext context) {
    final savedJobs = Get.find<SavedJobsController>();
    final homeController = Get.find<HomeController>();
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                unawaited(HapticFeedback.lightImpact());
                showJobDetailSheet(context, job);
              },
              onLongPress: () {
                unawaited(HapticFeedback.mediumImpact());
                _showJobActions(
                  context,
                  job: job,
                  savedJobs: savedJobs,
                  homeController: homeController,
                );
              },
              child: Obx(
                () => JobFeedCard(
                  job: job,
                  colorIndex: colorIndex,
                  isSaved: savedJobs.isSaved(job.id),
                  onToggleSave: () => savedJobs.toggleSave(job),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showJobActions(
    BuildContext context, {
    required JobFeedModel job,
    required SavedJobsController savedJobs,
    required HomeController homeController,
  }) {
    showFSheet<void>(
      context: context,
      side: FLayout.btt,
      mainAxisMaxRatio: 0.72,
      useSafeArea: true,
      barrierDismissible: true,
      builder: (sheetContext) => _JobActionsSheet(
        job: job,
        isSaved: savedJobs.isSaved(job.id),
        onView: () {
          Navigator.of(sheetContext).pop();
          showJobDetailSheet(context, job);
        },
        onSave: () {
          savedJobs.toggleSave(job);
          Navigator.of(sheetContext).pop();
        },
        onShare: () {
          Navigator.of(sheetContext).pop();
          SharePlus.instance.share(
            ShareParams(
              text: '${job.title} at ${job.company} — ${job.location}',
            ),
          );
        },
        onDismiss: () {
          homeController.dismiss(job);
          Navigator.of(sheetContext).pop();
        },
        onReport: () {
          Navigator.of(sheetContext).pop();
          Get.toNamed<void>(
            AppRoutes.report,
            arguments: {'jobId': job.id, 'jobTitle': job.title},
          );
        },
      ),
    );
  }
}

class _JobActionsSheet extends StatelessWidget {
  const _JobActionsSheet({
    required this.job,
    required this.isSaved,
    required this.onView,
    required this.onSave,
    required this.onShare,
    required this.onDismiss,
    required this.onReport,
  });

  final JobFeedModel job;
  final bool isSaved;
  final VoidCallback onView;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onDismiss;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final palette = context.palette;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      child: ColoredBox(
        color: theme.colors.background,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            10,
            16,
            MediaQuery.paddingOf(context).bottom + 18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    CompanyAvatar(companyName: job.company, size: 46),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.typography.body.md.copyWith(
                              color: palette.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${job.company} · ${job.location}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.typography.body.xs.copyWith(
                              color: palette.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: FButton(
                      onPress: onView,
                      prefix: const Icon(FLucideIcons.eye, size: 17),
                      child: Text('view_job'.tr),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FButton(
                      variant: FButtonVariant.outline,
                      onPress: onSave,
                      prefix: Icon(
                        isSaved
                            ? FLucideIcons.bookmarkCheck
                            : FLucideIcons.bookmark,
                        size: 17,
                      ),
                      child: Text(isSaved ? 'saved'.tr : 'save'.tr),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FTileGroup(
                children: [
                  FTile(
                    prefix: const _JobActionIcon(
                      icon: FLucideIcons.share2,
                      color: AppColors.info,
                    ),
                    title: Text('share_opportunity'.tr),
                    subtitle: Text('share_opportunity_help'.tr),
                    suffix: const Icon(FLucideIcons.chevronRight),
                    onPress: onShare,
                  ),
                  FTile(
                    prefix: const _JobActionIcon(
                      icon: FLucideIcons.eyeOff,
                      color: AppColors.warning,
                    ),
                    title: Text('not_interested'.tr),
                    subtitle: Text('not_interested_help'.tr),
                    suffix: const Icon(FLucideIcons.chevronRight),
                    onPress: onDismiss,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FTileGroup(
                children: [
                  FTile(
                    variant: FItemVariant.destructive,
                    prefix: const _JobActionIcon(
                      icon: FLucideIcons.flag,
                      color: AppColors.error,
                    ),
                    title: Text('report_job'.tr),
                    subtitle: Text('report_job_help'.tr),
                    suffix: const Icon(FLucideIcons.chevronRight),
                    onPress: onReport,
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

class _JobActionIcon extends StatelessWidget {
  const _JobActionIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 17),
    );
  }
}

// ---------------------------------------------------------------------------
// Top Pick hero card — gradient with AppColors.primary, full description.
