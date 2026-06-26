import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/company_avatar.dart';
import 'package:jobodia_frontend/core/widgets/star_rating.dart';
import 'package:jobodia_frontend/features/company/controller/company_controller.dart';
import 'package:jobodia_frontend/features/company/model/company_model.dart';
import 'package:jobodia_frontend/features/company_reviews/controller/company_reviews_controller.dart';
import 'package:jobodia_frontend/features/home/controller/home_controller.dart';
import 'package:jobodia_frontend/features/home/model/job_feed_model.dart';

class CompanyProfileScreen extends StatelessWidget {
  const CompanyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final companyName = Get.arguments as String?;
    final companyCtrl = Get.find<CompanyController>();
    final homeCtrl = Get.find<HomeController>();
    final company = companyName != null
        ? companyCtrl.companyByName(companyName)
        : null;
    final palette = context.palette;

    if (company == null) {
      return Scaffold(
        backgroundColor: palette.scaffold,
        appBar: AppBar(
          backgroundColor: palette.surface,
          foregroundColor: palette.textPrimary,
          elevation: 0,
          title: const Text('Company'),
        ),
        body: Center(
          child: Text(
            'Company not found',
            style: TextStyle(color: palette.textSecondary),
          ),
        ),
      );
    }

    final initials = company.name.length >= 2
        ? company.name.substring(0, 2).toUpperCase()
        : company.name.toUpperCase();

    final openPositions = companyCtrl.jobsForCompany(company, homeCtrl.jobs);

    return Scaffold(
      backgroundColor: palette.scaffold,
      appBar: AppBar(
        backgroundColor: palette.surface,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        title: Text(company.name),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -- Header: avatar + name + industry chip --
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        company.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: palette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          company.industry,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // -- Stats row --
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        label: 'Industry',
                        value: company.industry,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatTile(
                        label: 'Headcount',
                        value: company.headcount,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // -- About section --
                Text(
                  'About',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  company.about,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: palette.textSecondary,
                  ),
                ),

                const SizedBox(height: 24),
                _CompanyReviewsPreview(
                  companyName: company.name,
                  palette: palette,
                ),
                const SizedBox(height: 24),

                // -- Follow / Unfollow button --
                Obx(() {
                  final following = companyCtrl.isFollowing(company.name);
                  return SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: following
                        ? OutlinedButton.icon(
                            onPressed: () =>
                                companyCtrl.toggleFollow(company.name),
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Following'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: () =>
                                companyCtrl.toggleFollow(company.name),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Follow'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                  );
                }),

                const SizedBox(height: 28),

                // -- Open positions --
                Text(
                  'Open Positions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                if (openPositions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No open positions at the moment',
                        style: TextStyle(
                          fontSize: 14,
                          color: palette.textTertiary,
                        ),
                      ),
                    ),
                  )
                else
                  ...openPositions.map((job) => _JobListTile(job: job)),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private helper widgets
// ---------------------------------------------------------------------------

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: palette.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: palette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _JobListTile extends StatelessWidget {
  const _JobListTile({required this.job});
  final JobFeedModel job;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: palette.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Get.toNamed(AppRoutes.jobDetail, arguments: job),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: palette.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: palette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${job.level}  ·  ${job.location}',
                        style: TextStyle(
                          fontSize: 13,
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  job.salary,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
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

class _CompanyReviewsPreview extends StatelessWidget {
  const _CompanyReviewsPreview({
    required this.companyName,
    required this.palette,
  });
  final String companyName;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(CompanyReviewsController());
    return Obx(() {
      final reviews = ctrl.reviewsForCompany(companyName);
      if (reviews.isEmpty) return const SizedBox.shrink();

      final avgRating = ctrl.averageRating(companyName);
      final previews = reviews.take(3).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reviews',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary,
                ),
              ),
              Row(
                children: [
                  StarRating(rating: avgRating, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    avgRating.toStringAsFixed(1),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: palette.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...previews.map(
            (r) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: palette.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StarRating(rating: r.rating.toDouble(), size: 12),
                      Text(
                        r.jobTitle,
                        style: TextStyle(
                          color: palette.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    r.title,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  if (r.pros.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      r.pros,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Get.toNamed<void>(
                AppRoutes.companyReviews,
                arguments: companyName,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brandTeal,
                side: const BorderSide(color: AppColors.brandTeal),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('See all ${reviews.length} reviews'),
            ),
          ),
        ],
      );
    });
  }
}
