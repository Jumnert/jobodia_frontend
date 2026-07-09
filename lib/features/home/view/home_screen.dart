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
import 'package:jobodia_frontend/features/home/view/widgets/home_top_bar.dart';
import 'package:jobodia_frontend/features/home/view/widgets/job_feed_card.dart';
import 'package:jobodia_frontend/features/job_detail/controller/job_detail_controller.dart';
import 'package:jobodia_frontend/features/job_detail/view/job_detail_screen.dart';
import 'package:jobodia_frontend/features/saved_jobs/controller/saved_jobs_controller.dart';

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
          Positioned.fill(
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
                  itemBuilder: (_, _) => const SkeletonJobCard(),
                );
              }

              final page = homeController.visiblePage;
              final jobs = page.jobs;

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

              final pagedJobs = jobs;

              return RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: palette.surface,
                onRefresh: () async {
                  await Future<void>.delayed(const Duration(milliseconds: 600));
                  homeController.selectTab(homeController.selectedTab.value);
                },
                child: PaginatedListView(
                  controller: homeController.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    20,
                    MediaQuery.paddingOf(context).top + 14 + 44 + 14,
                    20,
                    92,
                  ),
                  hasMore: page.hasMore,
                  isLoadingMore: homeController.isLoadingMore.value,
                  onLoadMore: homeController.loadMore,
                  itemCount: pagedJobs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _JobFeedContextMenu(
                        job: pagedJobs[index],
                        colorIndex: index,
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
              onNotifications: () => Get.toNamed<void>(AppRoutes.notifications),
            ),
          ),
        ],
      ),
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
