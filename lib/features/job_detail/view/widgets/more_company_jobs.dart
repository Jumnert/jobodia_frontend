import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/home/controller/home_controller.dart';
import 'package:jobodia_frontend/features/job_detail/controller/job_detail_controller.dart';
import 'package:jobodia_frontend/features/job_detail/model/job_detail_model.dart';
import 'package:jobodia_frontend/features/job_detail/view/job_detail_screen.dart';

class MoreCompanyJobs extends StatelessWidget {
  const MoreCompanyJobs({required this.jobs, this.companyName, super.key});

  final List<RelatedJobModel> jobs;
  final String? companyName;

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
      final palette = context.palette;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No other jobs from this company',
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: companyName != null
              ? () => Get.toNamed(
                  AppRoutes.companyProfile,
                  arguments: companyName,
                )
              : null,
          child: Row(
            children: [
              Text(
                'More from this Company',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (companyName != null) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: palette.textSecondary,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 106,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: jobs.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) =>
                _RelatedJobCard(job: jobs[index], companyName: companyName),
          ),
        ),
      ],
    );
  }
}

class _RelatedJobCard extends StatelessWidget {
  const _RelatedJobCard({required this.job, this.companyName});

  final RelatedJobModel job;
  final String? companyName;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Material(
        color: palette.surfaceMuted,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          splashColor: AppColors.brandTeal.withValues(alpha: 0.1),
          onTap: () {
            // Try to find a matching job in the feed by title.
            final homeCtrl = Get.isRegistered<HomeController>()
                ? Get.find<HomeController>()
                : null;
            final titleLower = job.title.toLowerCase();
            final match = homeCtrl?.jobs.firstWhereOrNull(
              (j) =>
                  j.title.toLowerCase().contains(titleLower) ||
                  titleLower.contains(j.title.toLowerCase()),
            );
            if (match != null) {
              Get.to(
                () => const JobDetailScreen(),
                arguments: match,
                binding: BindingsBuilder(
                  () =>
                      Get.lazyPut<JobDetailController>(JobDetailController.new),
                ),
              );
            } else {
              Get.snackbar(
                'Coming soon',
                'Full detail for ${job.title} will be available later.',
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
              );
            }
          },
          child: Container(
            width: 170,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: palette.surfaceMuted,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: palette.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: palette.border),
                  ),
                  child: Text(
                    job.workMode,
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  job.department,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
