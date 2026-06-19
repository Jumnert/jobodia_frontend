import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/job_detail/controller/job_detail_controller.dart';
import 'package:jobodia_frontend/features/job_detail/view/widgets/company_logo.dart';
import 'package:jobodia_frontend/features/job_detail/view/widgets/dashed_divider.dart';
import 'package:jobodia_frontend/features/job_detail/view/widgets/job_action_buttons.dart';
import 'package:jobodia_frontend/features/job_detail/view/widgets/job_detail_header.dart';
import 'package:jobodia_frontend/features/job_detail/view/widgets/job_text_section.dart';
import 'package:jobodia_frontend/features/job_detail/view/widgets/job_title_block.dart';
import 'package:jobodia_frontend/features/job_detail/view/widgets/more_company_jobs.dart';

class JobDetailScreen extends GetView<JobDetailController> {
  const JobDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final job = controller.job;
    final palette = context.palette;
    const logoSize = 106.0;
    const logoOverlap = 56.0;

    return Scaffold(
      backgroundColor: palette.scaffold,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            color: palette.surface,
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    12,
                    MediaQuery.paddingOf(context).top + 12,
                    12,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Obx(
                      () => Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: logoOverlap),
                            child: JobDetailHeader(
                              imageUrl: job.heroImageUrl,
                              isSaved: controller.isSaved.value,
                              onShare: controller.shareJob,
                              onSave: controller.toggleSaved,
                            ),
                          ),
                          const Positioned(
                            left: 24,
                            bottom: 0,
                            child: CompanyLogo(size: logoSize),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(36, 12, 28, 28),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        JobTitleBlock(job: job),
                        const DashedDivider(),
                        const SizedBox(height: 12),
                        JobTextSection(
                          title: 'Job Description',
                          body: job.description,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 14),
                        Obx(
                          () => JobTextSection(
                            title: 'About the role',
                            body: job.aboutRole,
                            maxLines: controller.isAboutRoleExpanded.value
                                ? null
                                : 4,
                            actionLabel: controller.isAboutRoleExpanded.value
                                ? 'Show less'
                                : 'Read more',
                            onActionPressed: controller.toggleAboutRole,
                          ),
                        ),
                        const SizedBox(height: 12),
                        JobActionButtons(onApply: controller.applyForJob),
                        const SizedBox(height: 14),
                        const DashedDivider(),
                        const SizedBox(height: 8),
                        MoreCompanyJobs(jobs: job.moreJobs),
                      ],
                    ),
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
