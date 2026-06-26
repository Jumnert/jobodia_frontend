import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/custom_button.dart';
import 'package:jobodia_frontend/core/widgets/custom_text_field.dart';
import 'package:jobodia_frontend/core/widgets/star_rating.dart';
import 'package:jobodia_frontend/features/company_reviews/controller/company_reviews_controller.dart';
import 'package:jobodia_frontend/features/company_reviews/model/company_review_model.dart';
import 'package:intl/intl.dart';

class CompanyReviewsScreen extends StatelessWidget {
  const CompanyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final ctrl = Get.put(CompanyReviewsController());
    final companyName = Get.arguments as String? ?? 'Google';

    return Scaffold(
      backgroundColor: palette.scaffold,
      appBar: AppBar(
        backgroundColor: palette.scaffold,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            color: palette.iconPrimary,
            size: 30,
          ),
          onPressed: Get.back,
        ),
        title: Text(
          '$companyName Reviews',
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Obx(() {
        final reviews = ctrl.reviewsForCompany(companyName);
        final avgRating = ctrl.averageRating(companyName);

        return Column(
          children: [
            _RatingOverview(
              companyName: companyName,
              avgRating: avgRating,
              totalReviews: reviews.length,
              palette: palette,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ).copyWith(bottom: 100),
                itemCount: reviews.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) =>
                    _ReviewCard(review: reviews[index], palette: palette),
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showWriteReviewSheet(context, ctrl, companyName),
        backgroundColor: AppColors.brandTeal,
        icon: const Icon(Icons.edit_rounded, color: Colors.white),
        label: const Text(
          'Write a Review',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showWriteReviewSheet(
    BuildContext context,
    CompanyReviewsController ctrl,
    String companyName,
  ) {
    int rating = 0;
    final titleCtrl = TextEditingController();
    final prosCtrl = TextEditingController();
    final consCtrl = TextEditingController();
    final adviceCtrl = TextEditingController();
    bool isCurrentEmployee = true;
    final jobTitleCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.palette.scaffold,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final palette = context.palette;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Review $companyName',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Overall Rating',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                StatefulBuilder(
                  builder: (context, setState) {
                    return StarRating(
                      rating: rating.toDouble(),
                      size: 40,
                      interactive: true,
                      onRatingChanged: (r) => setState(() => rating = r),
                    );
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Review Title',
                  hintText: 'e.g., Great place to work',
                  prefixIcon: Icons.title,
                  controller: titleCtrl,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Pros',
                  hintText: 'What did you like?',
                  prefixIcon: Icons.thumb_up_rounded,
                  controller: prosCtrl,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Cons',
                  hintText: 'What could be improved?',
                  prefixIcon: Icons.thumb_down_rounded,
                  controller: consCtrl,
                ),
                const SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, setState) => CheckboxListTile(
                    title: Text(
                      'I currently work here',
                      style: TextStyle(color: palette.textPrimary),
                    ),
                    value: isCurrentEmployee,
                    onChanged: (v) =>
                        setState(() => isCurrentEmployee = v ?? true),
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.brandTeal,
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Your Job Title',
                  hintText: 'e.g., Software Engineer',
                  prefixIcon: Icons.work_rounded,
                  controller: jobTitleCtrl,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  label: 'Submit Review',
                  onPressed: () {
                    if (rating == 0 || titleCtrl.text.length < 5) {
                      Get.snackbar(
                        'Error',
                        'Please provide a rating and a title (min 5 chars).',
                        backgroundColor: AppColors.error,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    ctrl.submitReview(
                      companyName: companyName,
                      reviewerName: 'You', // mock
                      rating: rating,
                      title: titleCtrl.text,
                      pros: prosCtrl.text,
                      cons: consCtrl.text,
                      advice: adviceCtrl.text,
                      isCurrentEmployee: isCurrentEmployee,
                      jobTitle: jobTitleCtrl.text,
                    );
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RatingOverview extends StatelessWidget {
  const _RatingOverview({
    required this.companyName,
    required this.avgRating,
    required this.totalReviews,
    required this.palette,
  });

  final String companyName;
  final double avgRating;
  final int totalReviews;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      color: palette.surface,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  avgRating.toStringAsFixed(1),
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                StarRating(rating: avgRating),
                const SizedBox(height: 4),
                Text(
                  '$totalReviews reviews',
                  style: TextStyle(color: palette.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review, required this.palette});

  final CompanyReviewModel review;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              StarRating(rating: review.rating.toDouble(), size: 16),
              Text(
                DateFormat.yMMMd().format(review.createdAt),
                style: TextStyle(color: palette.textTertiary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.title,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                review.jobTitle,
                style: TextStyle(color: palette.textSecondary, fontSize: 13),
              ),
              if (review.isCurrentEmployee) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brandTeal.withAlpha(25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Current Employee',
                    style: TextStyle(
                      color: AppColors.brandTeal,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          if (review.pros.isNotEmpty) ...[
            _BulletText(
              text: review.pros,
              color: AppColors.success,
              palette: palette,
              icon: Icons.add_circle_outline_rounded,
            ),
            const SizedBox(height: 8),
          ],
          if (review.cons.isNotEmpty) ...[
            _BulletText(
              text: review.cons,
              color: AppColors.error,
              palette: palette,
              icon: Icons.remove_circle_outline_rounded,
            ),
            const SizedBox(height: 8),
          ],
          if (review.advice.isNotEmpty) ...[
            _BulletText(
              text: review.advice,
              color: AppColors.info,
              palette: palette,
              icon: Icons.info_outline_rounded,
            ),
          ],
        ],
      ),
    );
  }
}

class _BulletText extends StatelessWidget {
  const _BulletText({
    required this.text,
    required this.color,
    required this.palette,
    required this.icon,
  });

  final String text;
  final Color color;
  final AppPalette palette;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: palette.textSecondary,
              height: 1.4,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
