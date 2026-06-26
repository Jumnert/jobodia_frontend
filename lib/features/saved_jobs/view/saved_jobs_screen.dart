import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/undo_snackbar.dart';
import 'package:jobodia_frontend/features/home/controller/home_controller.dart';
import 'package:jobodia_frontend/features/home/model/job_feed_model.dart';
import 'package:jobodia_frontend/features/home/view/widgets/job_feed_card.dart';
import 'package:jobodia_frontend/features/job_detail/controller/job_detail_controller.dart';
import 'package:jobodia_frontend/features/job_detail/view/job_detail_screen.dart';
import 'package:jobodia_frontend/features/saved_jobs/controller/saved_jobs_controller.dart';

class SavedJobsScreen extends StatefulWidget {
  const SavedJobsScreen({super.key});

  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  final Set<String> _comparisonSet = {};

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final savedJobs = Get.find<SavedJobsController>();
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
          'Saved Jobs',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        actions: [
          if (_comparisonSet.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: GestureDetector(
                  onTap: () => setState(() => _comparisonSet.clear()),
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Obx(() {
        final jobs = savedJobs.orderedSavedIds
            .map(homeController.jobById)
            .whereType<JobFeedModel>()
            .toList();

        if (jobs.isEmpty) {
          return _EmptyState(palette: palette);
        }

        return Stack(
          children: [
            RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: palette.surface,
              onRefresh: () async {
                await Future<void>.delayed(const Duration(milliseconds: 600));
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                itemCount: jobs.length,
                itemBuilder: (context, index) {
                  final job = jobs[index];
                  final isSelected = _comparisonSet.contains(job.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onLongPress: () {
                          setState(() {
                            if (isSelected) {
                              _comparisonSet.remove(job.id);
                            } else if (_comparisonSet.length < 3) {
                              _comparisonSet.add(job.id);
                            }
                          });
                        },
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
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: isSelected
                                ? Border.all(
                                    color: AppColors.primary,
                                    width: 2.5,
                                  )
                                : null,
                          ),
                          child: JobFeedCard(
                            job: job,
                            colorIndex: index,
                            isSaved: true,
                            onToggleSave: () {
                              savedJobs.remove(job.id);
                              showUndoSnackbar(
                                message: 'Job removed from saved',
                                onUndo: () => savedJobs.toggleSave(job),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // ── Floating "Compare (N)" button ──
            if (_comparisonSet.length >= 2)
              Positioned(
                left: 20,
                right: 20,
                bottom: 24,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _showComparisonSheet(context, palette, homeController),
                  icon: const Icon(Icons.compare_arrows_rounded, size: 20),
                  label: Text(
                    'Compare (${_comparisonSet.length})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 6,
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  void _showComparisonSheet(
    BuildContext context,
    AppPalette palette,
    HomeController homeController,
  ) {
    final selectedJobs = _comparisonSet
        .map(homeController.jobById)
        .whereType<JobFeedModel>()
        .toList();

    if (selectedJobs.length < 2) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ComparisonSheet(jobs: selectedJobs, palette: palette),
    ).whenComplete(() {
      setState(() => _comparisonSet.clear());
    });
  }
}

class _ComparisonSheet extends StatelessWidget {
  const _ComparisonSheet({required this.jobs, required this.palette});

  final List<JobFeedModel> jobs;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    final rows = <_ComparisonRow>[
      _ComparisonRow('Title', jobs.map((j) => j.title).toList()),
      _ComparisonRow('Company', jobs.map((j) => j.company).toList()),
      _ComparisonRow('Salary', jobs.map((j) => j.salary).toList()),
      _ComparisonRow('Location', jobs.map((j) => j.location).toList()),
      _ComparisonRow('Match %', jobs.map((j) => '${j.matchPercent}%').toList()),
      _ComparisonRow(
        'Work Mode',
        jobs
            .map((j) => j.distance.contains('remote') ? 'Remote' : 'On-site')
            .toList(),
      ),
      _ComparisonRow('Level', jobs.map((j) => j.level).toList()),
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ── Handle bar ──
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: palette.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // ── Title ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(
                      Icons.compare_arrows_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Job Comparison',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: palette.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // ── Table ──
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Table(
                    border: TableBorder(
                      horizontalInside: BorderSide(
                        color: palette.divider,
                        width: 1,
                      ),
                      verticalInside: BorderSide(
                        color: palette.divider,
                        width: 1,
                      ),
                    ),
                    columnWidths: {
                      0: const FixedColumnWidth(90),
                      for (var i = 0; i < jobs.length; i++)
                        i + 1: const FlexColumnWidth(),
                    },
                    children: [
                      // ── Header row ──
                      TableRow(
                        decoration: BoxDecoration(
                          color: palette.surfaceMuted,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                        ),
                        children: [
                          _headerCell('', palette),
                          for (final job in jobs)
                            _headerCell(job.company, palette),
                        ],
                      ),
                      // ── Data rows ──
                      for (final row in rows)
                        TableRow(
                          children: [
                            _labelCell(row.label, palette),
                            for (final value in row.values)
                              _dataCell(value, palette),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _headerCell(String text, AppPalette palette) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
      ),
    ),
  );

  static Widget _labelCell(String text, AppPalette palette) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: palette.textSecondary,
      ),
    ),
  );

  static Widget _dataCell(String text, AppPalette palette) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: palette.textPrimary,
      ),
    ),
  );
}

class _ComparisonRow {
  const _ComparisonRow(this.label, this.values);
  final String label;
  final List<String> values;
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
              Icons.bookmark_border_rounded,
              size: 56,
              color: palette.iconMuted,
            ),
            const SizedBox(height: 14),
            Text(
              'No saved jobs yet',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap the bookmark on any job to save it here for later.',
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
