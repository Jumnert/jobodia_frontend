import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/cv_builder/controller/cv_builder_controller.dart';
import 'package:jobodia_frontend/features/home/controller/home_controller.dart';
import 'package:jobodia_frontend/features/job_detail/controller/job_detail_controller.dart';
import 'package:jobodia_frontend/features/job_detail/controller/notes_controller.dart';
import 'package:jobodia_frontend/features/job_detail/view/widgets/company_logo.dart';
import 'package:jobodia_frontend/features/job_detail/view/widgets/dashed_divider.dart';
import 'package:jobodia_frontend/features/job_detail/view/widgets/job_action_buttons.dart';
import 'package:jobodia_frontend/features/job_detail/view/widgets/job_detail_header.dart';
import 'package:jobodia_frontend/features/job_detail/view/widgets/job_text_section.dart';
import 'package:jobodia_frontend/features/job_detail/view/widgets/job_title_block.dart';
import 'package:jobodia_frontend/features/job_detail/view/widgets/match_breakdown_sheet.dart';
import 'package:jobodia_frontend/features/job_detail/view/widgets/more_company_jobs.dart';

class JobDetailScreen extends GetView<JobDetailController> {
  const JobDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.scaffold,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            color: palette.surface,
            child: CustomScrollView(
              slivers: [
                _JobHeaderSliver(controller: controller),
                _JobDetailsSliver(controller: controller),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Salary range bar — shows where this job's salary sits relative to all jobs.
// -----------------------------------------------------------------------------

class _SalaryRangeBar extends StatelessWidget {
  const _SalaryRangeBar({required this.controller});

  final JobDetailController controller;

  (int, int) _parseSalary(String salary) {
    final amounts = RegExp(r'[\d,]+').allMatches(salary).map((m) {
      return int.parse(m.group(0)!.replaceAll(',', ''));
    }).toList();
    if (amounts.isEmpty) return (0, 0);
    if (amounts.length == 1) return (amounts.first, amounts.first);
    return (amounts.first, amounts[1]);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final salary = controller.sourceSalary;
    if (salary.isEmpty) return const SizedBox.shrink();

    final homeCtrl = Get.find<HomeController>();
    final globalMin = homeCtrl.minAvailableSalary;
    final globalMax = homeCtrl.maxAvailableSalary;
    final range = globalMax - globalMin;

    final (jobMin, jobMax) = _parseSalary(salary);

    final startFill = range <= 0
        ? 0.0
        : ((jobMin - globalMin) / range).clamp(0.0, 1.0);
    final endFill = range <= 0
        ? 1.0
        : ((jobMax - globalMin) / range).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Salary range',
          style: TextStyle(
            fontSize: 12,
            color: palette.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (_, constraints) {
            final width = constraints.maxWidth;
            return Stack(
              children: [
                // Grey track
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                // Teal fill segment
                Positioned(
                  left: width * startFill,
                  width: (width * (endFill - startFill)).clamp(6.0, width),
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0EA5A4),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 4),
        Text(
          salary,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: palette.textPrimary,
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Tappable match badge — opens the "Why this match?" bottom sheet on tap.
// -----------------------------------------------------------------------------

class _MatchBadgeTile extends StatelessWidget {
  const _MatchBadgeTile({required this.controller});

  final JobDetailController controller;

  static const _kTeal = Color(0xFF0EA5A4);

  @override
  Widget build(BuildContext context) {
    final pct = controller.matchPercent;
    if (pct == 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        showModalBottomSheet<void>(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => MatchBreakdownSheet(
            matchPercent: controller.matchPercent,
            tags: controller.sourceTags,
            location: controller.sourceLocation,
            level: controller.sourceLevel,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _kTeal.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _kTeal.withValues(alpha: 0.40)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome_rounded, size: 14, color: _kTeal),
            const SizedBox(width: 6),
            Text(
              '$pct% match',
              style: const TextStyle(
                color: _kTeal,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.info_outline_rounded,
              size: 14,
              color: _kTeal.withValues(alpha: 0.70),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// My Notes card — per-job note-taking with local persistence.
// -----------------------------------------------------------------------------

class _NotesCard extends StatefulWidget {
  const _NotesCard({required this.controller});

  final JobDetailController controller;

  @override
  State<_NotesCard> createState() => _NotesCardState();
}

class _NotesCardState extends State<_NotesCard> {
  late final NotesController notesController;
  late final TextEditingController textCtrl;

  @override
  void initState() {
    super.initState();
    notesController = Get.find<NotesController>();
    textCtrl = TextEditingController(
      text: notesController.getNote(widget.controller.jobId),
    );
  }

  @override
  void dispose() {
    textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_note_rounded,
                size: 20,
                color: palette.textPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                'My Notes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: palette.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: textCtrl,
            maxLines: 5,
            minLines: 3,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: palette.textPrimary,
            ),
            onChanged: (text) =>
                notesController.saveNote(widget.controller.jobId, text),
            decoration: InputDecoration(
              hintText: 'Write your notes about this job...',
              hintStyle: TextStyle(color: palette.textSecondary),
              filled: true,
              fillColor: palette.scaffold,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ],
      ),
    );
  }
}

class _JobHeaderSliver extends StatelessWidget {
  const _JobHeaderSliver({required this.controller});
  final JobDetailController controller;

  @override
  Widget build(BuildContext context) {
    const logoSize = 106.0;
    const logoOverlap = 56.0;
    final job = controller.job!;
    return SliverPadding(
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
                  isSaved: controller.isSaved,
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
    );
  }
}

class _JobDetailsSliver extends StatelessWidget {
  const _JobDetailsSliver({required this.controller});
  final JobDetailController controller;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final job = controller.job!;
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(36, 12, 28, 28),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            JobTitleBlock(job: job),
            const SizedBox(height: 12),
            _SalaryRangeBar(controller: controller),
            const SizedBox(height: 12),
            _MatchBadgeTile(controller: controller),
            const DashedDivider(),
            const SizedBox(height: 12),
            JobTextSection(title: 'Job Description', body: job.description),
            const SizedBox(height: 14),
            Obx(
              () => JobTextSection(
                title: 'About the role',
                body: job.aboutRole,
                isExpanded: controller.isAboutRoleExpanded.value,
                actionLabel: controller.isAboutRoleExpanded.value
                    ? 'Show less'
                    : 'Read more',
                onActionPressed: controller.toggleAboutRole,
              ),
            ),
            const SizedBox(height: 12),
            // CV ↔ Job Match Analysis card
            Obx(() {
              final cvRegistered = Get.isRegistered<CvBuilderController>();
              final cvData = cvRegistered
                  ? Get.find<CvBuilderController>().generatedCv.value
                  : null;
              if (cvData == null) return const SizedBox.shrink();

              final cvSkills = cvData.skills;
              final jobTags = controller.sourceTags;

              final matchedSkills = cvSkills
                  .where(
                    (s) => jobTags.any(
                      (t) =>
                          t.toLowerCase().contains(s.toLowerCase()) ||
                          s.toLowerCase().contains(t.toLowerCase()),
                    ),
                  )
                  .toList();

              final missingSkills = jobTags
                  .where(
                    (t) => !cvSkills.any(
                      (s) =>
                          t.toLowerCase().contains(s.toLowerCase()) ||
                          s.toLowerCase().contains(t.toLowerCase()),
                    ),
                  )
                  .toList();

              final fitPercent = jobTags.isEmpty
                  ? 100
                  : ((matchedSkills.length / jobTags.length) * 100)
                        .round()
                        .clamp(0, 100);

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: palette.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.compare_arrows_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'How your CV matches',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: palette.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '$fitPercent%',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (matchedSkills.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Matched skills',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: palette.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: matchedSkills
                            .map(
                              (s) => Chip(
                                label: Text(
                                  s,
                                  style: const TextStyle(fontSize: 11),
                                ),
                                backgroundColor: AppColors.primary.withValues(
                                  alpha: 0.1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                side: BorderSide.none,
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            )
                            .toList(),
                      ),
                      if (matchedSkills.any(
                        (s) => s.toLowerCase() == 'flutter',
                      )) ...[
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.trending_up_rounded,
                              color: AppColors.success,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            const Expanded(
                              child: Text(
                                'Flutter is in high demand (+12% this quarter)',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                    if (missingSkills.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Skills to add',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: palette.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: missingSkills
                            .map(
                              (s) => Chip(
                                label: Text(
                                  s,
                                  style: const TextStyle(fontSize: 11),
                                ),
                                backgroundColor: palette.surfaceMuted,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                side: BorderSide.none,
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Add ${missingSkills.take(3).join(", ")} to your CV to improve your match.',
                        style: TextStyle(
                          fontSize: 12,
                          color: palette.textTertiary,
                          height: 1.4,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Get.toNamed(AppRoutes.cvBuilder),
                        icon: const Icon(Icons.description_outlined, size: 18),
                        label: const Text('Improve CV'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            Obx(
              () => JobActionButtons(
                onApply: controller.applyForJob,
                isApplied: controller.isApplied,
                isAboutExpanded: controller.isAboutRoleExpanded.value,
                onToggleAbout: controller.toggleAboutRole,
              ),
            ),
            const SizedBox(height: 14),
            const DashedDivider(),
            const SizedBox(height: 12),
            _NotesCard(controller: controller),
            const SizedBox(height: 14),
            const DashedDivider(),
            const SizedBox(height: 8),
            MoreCompanyJobs(jobs: job.moreJobs),
          ],
        ),
      ),
    );
  }
}
