import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/home/controller/home_controller.dart';
import 'package:jobodia_frontend/features/home/model/job_feed_model.dart';
import 'package:jobodia_frontend/features/home/view/widgets/job_feed_card.dart';
import 'package:jobodia_frontend/features/job_detail/controller/job_detail_controller.dart';
import 'package:jobodia_frontend/features/job_detail/view/job_detail_screen.dart';
import 'package:jobodia_frontend/features/saved_jobs/controller/saved_jobs_controller.dart';
import 'package:share_plus/share_plus.dart';

class SearchResultsList extends StatelessWidget {
  const SearchResultsList({
    super.key,
    required this.jobs,
    required this.query,
    required this.homeController,
  });

  final List<JobFeedModel> jobs;
  final String query;
  final HomeController homeController;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: palette.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              "No jobs found for '$query'",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: homeController.clearSearch,
              child: const Text('Clear search'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: palette.surface,
      onRefresh: () async {
        await Future<void>.delayed(const Duration(milliseconds: 600));
        homeController.updateSearchQuery(query);
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 92),
        itemCount: jobs.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: SearchJobCard(job: jobs[index], colorIndex: index),
        ),
      ),
    );
  }
}

class SearchJobCard extends StatelessWidget {
  const SearchJobCard({super.key, required this.job, required this.colorIndex});

  final JobFeedModel job;
  final int colorIndex;

  @override
  Widget build(BuildContext context) {
    final savedJobs = Get.find<SavedJobsController>();
    final homeController = Get.find<HomeController>();
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
      child: Material(
        type: MaterialType.transparency,
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
  }
}
