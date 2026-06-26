import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/applications/controller/applications_controller.dart';
import 'package:jobodia_frontend/features/applications/model/job_application.dart';
import 'package:jobodia_frontend/features/interview/controller/interview_schedule_controller.dart';
import 'package:jobodia_frontend/features/home/controller/home_controller.dart';
import 'package:jobodia_frontend/features/home/model/job_feed_model.dart';
import 'package:jobodia_frontend/features/home/view/widgets/job_feed_card.dart';
import 'package:jobodia_frontend/features/job_detail/controller/job_detail_controller.dart';
import 'package:jobodia_frontend/features/job_detail/view/job_detail_screen.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';

class ApplicationsScreen extends StatelessWidget {
  ApplicationsScreen({super.key});

  final RxString _selectedStatus = 'All'.obs;

  static const _statusFilters = <String>[
    'All',
    'Applied',
    'Phone Screen',
    'Interview',
    'Offer',
    'Rejected',
  ];

  static const _statusValues = <String, String>{
    'Applied': 'applied',
    'Phone Screen': 'phone_screen',
    'Interview': 'interview',
    'Offer': 'offer',
    'Rejected': 'rejected',
  };

  /// Reverse lookup: status value -> display label.
  static const _statusLabels = <String, String>{
    'applied': 'Applied',
    'phone_screen': 'Phone Screen',
    'interview': 'Interview',
    'offer': 'Offer',
    'rejected': 'Rejected',
  };

  static const _statusIcons = <String, IconData>{
    'applied': Icons.send_rounded,
    'phone_screen': Icons.phone_rounded,
    'interview': Icons.people_rounded,
    'offer': Icons.celebration_rounded,
    'rejected': Icons.cancel_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final applications = Get.find<ApplicationsController>();
    final homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());

    return Scaffold(
      backgroundColor: palette.scaffold,
      appBar: AppBar(
        backgroundColor: palette.scaffold,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: Get.back,
          icon: const Icon(Icons.chevron_left_rounded, size: 30),
        ),
        title: const Text(
          'Applications',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.applicationAnalytics),
            icon: Icon(Icons.analytics_outlined, color: palette.iconPrimary),
            tooltip: 'Analytics',
          ),
        ],
      ),
      body: Obx(() {
        final allEntries = applications.applications
            .map((application) {
              final job = homeController.jobById(application.jobId);
              return job == null ? null : (job, application);
            })
            .whereType<(JobFeedModel, JobApplication)>()
            .toList();

        if (allEntries.isEmpty) {
          return _EmptyState(palette: palette);
        }

        // Filter by selected status tab.
        final selectedFilter = _selectedStatus.value;
        final entries = selectedFilter == 'All'
            ? allEntries
            : allEntries
                  .where((e) => e.$2.status == _statusValues[selectedFilter])
                  .toList();

        return Column(
          children: [
            // ── Filter chips row ──
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _statusFilters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final label = _statusFilters[index];
                  return Obx(() {
                    final isSelected = _selectedStatus.value == label;
                    return GestureDetector(
                      onTap: () {
                        unawaited(HapticFeedback.lightImpact());
                        _selectedStatus.value = label;
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : palette.surfaceMuted,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : palette.border,
                          ),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : palette.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
            const SizedBox(height: 12),
            // ── Applications list ──
            Expanded(
              child: entries.isEmpty
                  ? Center(
                      child: Text(
                        'No "$selectedFilter" applications',
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.primary,
                      backgroundColor: palette.surface,
                      onRefresh: () async {
                        await Future<void>.delayed(
                          const Duration(milliseconds: 600),
                        );
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final (job, application) = entries[index];
                          final appliedDate = application.appliedDate;
                          final coverLetter = application.coverLetter;
                          final statusLabel =
                              _statusLabels[application.status] ?? 'Applied';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Material(
                                  type: MaterialType.transparency,
                                  child: InkWell(
                                    onTap: () {
                                      unawaited(HapticFeedback.lightImpact());
                                      Get.to(
                                        () => const JobDetailScreen(),
                                        arguments: job,
                                        binding: BindingsBuilder(
                                          () =>
                                              Get.lazyPut<JobDetailController>(
                                                JobDetailController.new,
                                              ),
                                        ),
                                      );
                                    },
                                    child: Stack(
                                      children: [
                                        JobFeedCard(
                                          job: job,
                                          colorIndex: index,
                                        ),
                                        // ── "Move to..." menu ──
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: PopupMenuButton<String>(
                                            icon: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(
                                                  alpha: 0.35,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.more_horiz_rounded,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                            onSelected: (value) {
                                              if (value ==
                                                  '__schedule_interview') {
                                                _pickAndScheduleInterview(
                                                  context,
                                                  job.id,
                                                );
                                              } else {
                                                applications.updateStatus(
                                                  job.id,
                                                  value,
                                                );
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              ..._statusValues.entries
                                                  .where(
                                                    (e) =>
                                                        e.value !=
                                                        application.status,
                                                  )
                                                  .map(
                                                    (
                                                      e,
                                                    ) => PopupMenuItem<String>(
                                                      value: e.value,
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            _statusIcons[e
                                                                .value],
                                                            size: 18,
                                                            color: palette
                                                                .textPrimary,
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            'Move to ${e.key}',
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: palette
                                                                  .textPrimary,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                              const PopupMenuDivider(),
                                              PopupMenuItem<String>(
                                                value: '__schedule_interview',
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .calendar_month_rounded,
                                                      size: 18,
                                                      color: AppColors.primary,
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      'Schedule Interview',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            palette.textPrimary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _statusIcons[application.status] ??
                                            Icons.check_circle_rounded,
                                        size: 14,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        statusLabel,
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        size: 11,
                                        color: palette.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Applied on ${_formatDate(appliedDate)}',
                                        style: TextStyle(
                                          color: palette.textSecondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (coverLetter != null &&
                                    coverLetter.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 4,
                                      top: 4,
                                    ),
                                    child: Text(
                                      coverLetter.length > 60
                                          ? '${coverLetter.substring(0, 60)}...'
                                          : coverLetter,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: palette.textSecondary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _pickAndScheduleInterview(
    BuildContext context,
    String jobId,
  ) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (pickedDate == null) return;

    if (!context.mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    final combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    Get.find<InterviewScheduleController>().schedule(jobId, combined);

    Get.snackbar(
      'Interview scheduled!',
      'Check the Interview Prep tab for details.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.work_outline_rounded,
              size: 56,
              color: palette.iconMuted,
            ),
            const SizedBox(height: 14),
            Text(
              'No applications yet',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Jobs you apply to will appear here so you can track them.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
