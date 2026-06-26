import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/error_state.dart';
import 'package:jobodia_frontend/core/widgets/paginated_list_view.dart';
import 'package:jobodia_frontend/core/widgets/skeleton_card.dart';
import 'package:jobodia_frontend/features/auth/controller/auth_controller.dart';
import 'package:jobodia_frontend/features/home/controller/home_controller.dart';
import 'package:jobodia_frontend/features/home/model/job_feed_model.dart';
import 'package:jobodia_frontend/features/home/view/widgets/app_bottom_navigation_bar.dart';
import 'package:jobodia_frontend/features/home/view/widgets/app_navigation.dart';
import 'package:jobodia_frontend/features/home/view/widgets/home_tab_bar.dart';
import 'package:jobodia_frontend/features/home/view/widgets/home_top_bar.dart';
import 'package:jobodia_frontend/features/home/view/widgets/job_feed_card.dart';
import 'package:jobodia_frontend/features/job_detail/controller/job_detail_controller.dart';
import 'package:jobodia_frontend/features/job_detail/view/job_detail_screen.dart';
import 'package:jobodia_frontend/features/saved_jobs/controller/saved_jobs_controller.dart';
import 'package:jobodia_frontend/features/market_trends/controller/market_trends_controller.dart';
import 'package:share_plus/share_plus.dart';

/// Home feed screen shown after login succeeds.
class HomeScreen extends GetView<AuthController> {
  const HomeScreen({super.key, this.showBottomNav = true});

  final bool? showBottomNav;

  @override
  Widget build(BuildContext context) {
    final user = controller.currentUser.value;
    final palette = context.palette;
    final homeController = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: palette.scaffold,
      extendBody: true,
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeTopBar(
                    name: user?.name ?? 'User',
                    avatarUrl: user?.avatarUrl,
                    onNotifications: () =>
                        Get.toNamed<void>(AppRoutes.notifications),
                    onSettings: () => Get.toNamed<void>(AppRoutes.settings),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Jobs you might like',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => HomeTabBar(
                      selectedIndex: homeController.selectedTab.value,
                      onChanged: homeController.selectTab,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (homeController.hasError.value) {
                  return ErrorState(
                    message: 'Failed to load jobs',
                    subtitle: 'Please check your connection and try again.',
                    onRetry: homeController.retryLoading,
                  );
                }
                if (homeController.isLoading.value) {
                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    itemBuilder: (_, __) => const SkeletonJobCard(),
                  );
                }

                final jobs = homeController.filteredJobs;

                if (jobs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
                      child: Text(
                        'No jobs match your search.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }

                // Top pick = job with highest matchPercent in filtered results.
                final topPick = jobs.reduce(
                  (a, b) => a.matchPercent >= b.matchPercent ? a : b,
                );
                final showHero = topPick.matchPercent >= 85;

                // Paginated subset of the feed.
                final pagedJobs = homeController.pagedJobs
                    .where((j) => !showHero || j.id != topPick.id)
                    .toList();

                return RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: palette.surface,
                  onRefresh: () async {
                    await Future<void>.delayed(
                      const Duration(milliseconds: 600),
                    );
                    homeController.selectTab(homeController.selectedTab.value);
                  },
                  child: PaginatedListView(
                    controller: homeController.scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 92),
                    hasMore: homeController.hasMoreJobs,
                    isLoadingMore: homeController.isLoadingMore.value,
                    onLoadMore: homeController.loadMore,
                    itemCount: (showHero ? 2 : 0) + 1 + pagedJobs.length,
                    itemBuilder: (context, index) {
                      // Hero card + header occupy the first 2 slots.
                      if (showHero && index == 0) {
                        return _TopPickCard(job: topPick);
                      }
                      if (showHero && index == 1) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 12),
                          child: Text(
                            'New this week',
                            style: TextStyle(
                              color: palette.textTertiary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.0,
                            ),
                          ),
                        );
                      }
                      if (index == (showHero ? 2 : 0)) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _MarketInsightsCard(palette: palette),
                        );
                      }
                      final jobIndex = index - (showHero ? 2 : 0) - 1;
                      if (jobIndex >= pagedJobs.length || jobIndex < 0) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
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
          ],
        ),
      ),
      bottomNavigationBar: (showBottomNav ?? true)
          ? AppBottomNavigationBar(
              selectedIndex: 0,
              onDestinationSelected: (index) =>
                  navigateMainDestination(context, index, currentIndex: 0),
              onSearchPressed: () => Get.toNamed<void>(AppRoutes.search),
            )
          : null,
    );
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
        return CupertinoContextMenu(
          actions: [
            CupertinoContextMenuAction(
              trailingIcon: CupertinoIcons.flag,
              onPressed: () {
                unawaited(HapticFeedback.lightImpact());
                Navigator.of(context).pop();
                Get.toNamed<void>(
                  AppRoutes.report,
                  arguments: {'jobId': job.id, 'jobTitle': job.title},
                );
              },
              child: const Text('Report'),
            ),
            CupertinoContextMenuAction(
              trailingIcon: savedJobs.isSaved(job.id)
                  ? CupertinoIcons.heart_fill
                  : CupertinoIcons.heart,
              onPressed: () {
                unawaited(HapticFeedback.lightImpact());
                savedJobs.toggleSave(job);
                Navigator.of(context).pop();
              },
              child: Text(savedJobs.isSaved(job.id) ? 'Unfave' : 'Fave'),
            ),
            CupertinoContextMenuAction(
              trailingIcon: CupertinoIcons.share,
              onPressed: () {
                unawaited(HapticFeedback.lightImpact());
                Navigator.of(context).pop();
                SharePlus.instance.share(
                  ShareParams(
                    text: '${job.title} at ${job.company} — ${job.location}',
                  ),
                );
              },
              child: const Text('Share'),
            ),
            CupertinoContextMenuAction(
              trailingIcon: CupertinoIcons.hand_thumbsdown,
              isDestructiveAction: true,
              onPressed: () {
                unawaited(HapticFeedback.heavyImpact());
                Navigator.of(context).pop();
                homeController.dismiss(job);
              },
              child: const Text('Not interested'),
            ),
          ],
          child: SizedBox(
            width: constraints.maxWidth,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () {
                  unawaited(HapticFeedback.lightImpact());
                  Get.to(
                    () => const JobDetailScreen(),
                    arguments: job,
                    binding: BindingsBuilder(
                      () => Get.lazyPut<JobDetailController>(
                        JobDetailController.new,
                      ),
                    ),
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
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Top Pick hero card — gradient with AppColors.primary, full description.
// ---------------------------------------------------------------------------

class _TopPickCard extends StatelessWidget {
  const _TopPickCard({required this.job});

  final JobFeedModel job;

  @override
  Widget build(BuildContext context) {
    final savedJobs = Get.find<SavedJobsController>();
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.85),
              AppColors.primary.withValues(alpha: 0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            unawaited(HapticFeedback.lightImpact());
            Get.to(
              () => const JobDetailScreen(),
              arguments: job,
              binding: BindingsBuilder(
                () => Get.lazyPut<JobDetailController>(JobDetailController.new),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Top Pick for you',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Obx(() {
                      final isSaved = savedJobs.isSaved(job.id);
                      return GestureDetector(
                        onTap: () {
                          unawaited(HapticFeedback.lightImpact());
                          savedJobs.toggleSave(job);
                        },
                        child: Icon(
                          isSaved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          size: 20,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  job.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${job.company} • ${job.location}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  job.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      job.salary,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${job.matchPercent}% match',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MarketInsightsCard extends StatelessWidget {
  const _MarketInsightsCard({required this.palette});
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(MarketTrendsController());
    return Obx(() {
      final skills = ctrl.topSkills().take(3).toList();
      if (skills.isEmpty) return const SizedBox.shrink();

      return InkWell(
        onTap: () => Get.toNamed<void>(AppRoutes.marketTrends),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.insights_rounded,
                        color: AppColors.brandTeal,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Market Insights',
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.chevron_right_rounded, color: palette.iconMuted),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Top trending skills right now:',
                style: TextStyle(color: palette.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: skills
                    .map(
                      (s) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.brandTeal.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              s.name,
                              style: const TextStyle(
                                color: AppColors.brandTeal,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.trending_up_rounded,
                              color: AppColors.brandTeal,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      );
    });
  }
}
