import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/utils/localized_time_ago.dart';
import 'package:jobodia_frontend/features/home/model/job_feed_model.dart';
import 'package:jobodia_frontend/features/home/controller/home_controller.dart';
import 'package:jobodia_frontend/features/job_detail/controller/job_detail_controller.dart';

/// Opens a draggable, scrollable job preview as a Forui modal sheet.
///
/// It intentionally blocks the screen behind it, so a tap on the scrim closes
/// the preview just like the close button does.
void showJobDetailSheet(BuildContext context, JobFeedModel job) {
  unawaited(_showJobDetailSheets(context, job));
}

Future<void> _showJobDetailSheets(
  BuildContext context,
  JobFeedModel initialJob,
) async {
  var currentJob = initialJob;
  while (context.mounted) {
    unawaited(HapticFeedback.lightImpact());
    final jobController = JobDetailController(source: currentJob);
    final selectedJob = await showFSheet<JobFeedModel>(
      context: context,
      side: FLayout.btt,
      // null lets the DraggableScrollableSheet own its sizing + drag behavior.
      mainAxisMaxRatio: null,
      barrierDismissible: true,
      builder: (sheetContext) => _JobDetailSheet(
        controller: jobController,
        source: currentJob,
        onClose: () => Navigator.of(sheetContext).pop(),
        onSelectSimilar: (job) => Navigator.of(sheetContext).pop(job),
      ),
    );
    if (selectedJob == null || !context.mounted) return;
    currentJob = selectedJob;
  }
}

class _JobDetailSheet extends StatelessWidget {
  const _JobDetailSheet({
    required this.controller,
    required this.source,
    required this.onClose,
    required this.onSelectSimilar,
  });

  final JobDetailController controller;
  final JobFeedModel source;
  final VoidCallback onClose;
  final ValueChanged<JobFeedModel> onSelectSimilar;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.88,
      minChildSize: 0.78,
      maxChildSize: 0.95,
      snap: false,
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            children: [
              const _DragHandle(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  children: [
                    _SheetHeader(source: source, onClose: onClose),
                    const SizedBox(height: 14),
                    _SheetOverview(source: source),
                    const SizedBox(height: 20),
                    if (source.tags.isNotEmpty) ...[
                      Text(
                        'key_skills'.tr,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _SheetTags(tags: source.tags),
                      const SizedBox(height: 18),
                    ],
                    Text(
                      'role_overview'.tr,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      source.fullDescription,
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _BulletSection(
                      title: 'what_you_do'.tr,
                      items: source.responsibilities,
                    ),
                    const SizedBox(height: 20),
                    _BulletSection(
                      title: 'what_looking_for'.tr,
                      items: source.requirements,
                    ),
                    const SizedBox(height: 20),
                    _BulletSection(
                      title: 'what_we_offer'.tr,
                      items: source.benefits,
                    ),
                    const SizedBox(height: 22),
                    _SimilarJobs(source: source, onSelected: onSelectSimilar),
                  ],
                ),
              ),
              _SheetActions(
                controller: controller,
                onClose: onClose,
                palette: palette,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BulletSection extends StatelessWidget {
  const _BulletSection({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 9),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: FTheme.of(context).colors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SimilarJobs extends StatelessWidget {
  const _SimilarJobs({required this.source, required this.onSelected});

  final JobFeedModel source;
  final ValueChanged<JobFeedModel> onSelected;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<HomeController>()) return const SizedBox.shrink();
    final jobs = List<JobFeedModel>.of(Get.find<HomeController>().jobs)
      ..removeWhere((job) => job.id == source.id)
      ..sort((a, b) => _score(b).compareTo(_score(a)));
    final similar = jobs.take(4).toList(growable: false);
    if (similar.isEmpty) return const SizedBox.shrink();

    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'similar_jobs'.tr,
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        FTileGroup(
          children: [
            for (final job in similar)
              FTile(
                prefix: const Icon(FLucideIcons.briefcaseBusiness),
                title: Text(job.title),
                subtitle: Text('${job.company} · ${job.location}'),
                details: Text('${job.matchPercent}%'),
                suffix: const Icon(FLucideIcons.chevronRight),
                onPress: () => onSelected(job),
              ),
          ],
        ),
      ],
    );
  }

  int _score(JobFeedModel candidate) {
    final sharedTags = candidate.tags
        .where((tag) => source.tags.contains(tag))
        .length;
    return sharedTags * 5 +
        (candidate.level == source.level ? 2 : 0) +
        (candidate.location == source.location ? 1 : 0);
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: context.palette.border,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.source, required this.onClose});

  final JobFeedModel source;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final colors = FTheme.of(context).colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    source.title,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${source.company} · ${source.companyTag}',
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ClipOval(
              child: Material(
                color: colors.primary.withValues(
                  alpha: context.isDark ? 0.14 : 0.1,
                ),
                child: InkWell(
                  onTap: onClose,
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(
                      FLucideIcons.x,
                      size: 18,
                      color: colors.primary.withValues(alpha: 0.82),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (source.matchPercent > 0) ...[
          const SizedBox(height: 12),
          FBadge(
            variant: FBadgeVariant.primary,
            child: Text(
              'match_percent'.trParams({'percent': '${source.matchPercent}'}),
            ),
          ),
        ],
      ],
    );
  }
}

class _SheetOverview extends StatelessWidget {
  const _SheetOverview({required this.source});

  final JobFeedModel source;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final items = <(IconData, String, String)>[
      (FLucideIcons.mapPin, 'location'.tr, source.location),
      (FLucideIcons.briefcaseBusiness, 'experience'.tr, source.level),
      if (source.salary.isNotEmpty)
        (FLucideIcons.banknote, 'salary'.tr, source.salary),
      if (source.distance.isNotEmpty)
        (FLucideIcons.navigation, 'distance'.tr, source.distance),
      (FLucideIcons.clock3, 'posted'.tr, localizedTimeAgo(source.timeAgo)),
      (FLucideIcons.building2, 'company'.tr, source.companyTag),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final (icon, label, value) in items)
          SizedBox(
            width: (MediaQuery.sizeOf(context).width - 50) / 2,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: palette.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 16, color: palette.iconMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            color: palette.textTertiary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          value,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _SheetTags extends StatelessWidget {
  const _SheetTags({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final tag in tags)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: palette.border),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              tag,
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _SheetActions extends StatelessWidget {
  const _SheetActions({
    required this.controller,
    required this.onClose,
    required this.palette,
  });

  final JobDetailController controller;
  final VoidCallback onClose;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.divider)),
      ),
      child: Row(
        children: [
          Obx(
            () => FButton.icon(
              variant: FButtonVariant.outline,
              onPress: controller.toggleSaved,
              child: Icon(
                controller.isSaved
                    ? FLucideIcons.bookmarkCheck
                    : FLucideIcons.bookmark,
              ),
            ),
          ),
          const SizedBox(width: 10),
          FButton.icon(
            variant: FButtonVariant.outline,
            onPress: controller.shareJob,
            child: const Icon(FLucideIcons.share2),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Obx(
              () => FButton(
                onPress: controller.isApplied ? null : controller.applyForJob,
                child: Text(
                  controller.isApplied ? 'applied'.tr : 'apply_now'.tr,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
