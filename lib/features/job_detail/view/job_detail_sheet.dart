import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/home/model/job_feed_model.dart';
import 'package:jobodia_frontend/features/job_detail/controller/job_detail_controller.dart';
import 'package:jobodia_frontend/features/job_detail/view/job_detail_screen.dart';

/// Tracks the single active job sheet so a previous one is always disposed
/// before a new one opens. Only one job preview is ever shown at a time.
FPersistentSheetController? _activeJobSheet;

/// Opens a draggable, scrollable job preview as a forui persistent sheet.
///
/// When [context] sits under an [FScaffold]/[FSheets] ancestor (the main shell
/// provides one) a preview sheet is shown. Otherwise — e.g. from a pushed
/// route without that ancestor — it safely falls back to the full
/// [JobDetailScreen]. The full screen is also reachable from the sheet's
/// "Open full details" action.
void showJobDetailSheet(BuildContext context, JobFeedModel job) {
  unawaited(HapticFeedback.lightImpact());

  // Dispose any previously shown preview before creating a new one.
  _activeJobSheet?.dispose();
  _activeJobSheet = null;

  final jobController = JobDetailController(source: job);

  try {
    _activeJobSheet = showFPersistentSheet(
      context: context,
      side: FLayout.btt,
      // null lets the DraggableScrollableSheet own its sizing + drag behavior.
      mainAxisMaxRatio: null,
      builder: (context, controller) => _JobDetailSheet(
        controller: jobController,
        source: job,
        onClose: controller.hide,
        onOpenFull: () {
          controller.hide();
          _openFullDetail(job);
        },
      ),
    );
  } on FlutterError {
    // No FScaffold/FSheets ancestor (e.g. a pushed route): open full screen.
    _openFullDetail(job);
  }
}

void _openFullDetail(JobFeedModel job) {
  Get.to<void>(
    () => const JobDetailScreen(),
    arguments: job,
    binding: BindingsBuilder(
      () => Get.lazyPut<JobDetailController>(JobDetailController.new),
    ),
  );
}

class _JobDetailSheet extends StatelessWidget {
  const _JobDetailSheet({
    required this.controller,
    required this.source,
    required this.onClose,
    required this.onOpenFull,
  });

  final JobDetailController controller;
  final JobFeedModel source;
  final VoidCallback onClose;
  final VoidCallback onOpenFull;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      snap: true,
      snapSizes: const [0.6, 0.95],
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
                    _SheetHeader(source: source, onOpenFull: onOpenFull),
                    const SizedBox(height: 14),
                    _SheetMetaRow(source: source),
                    const SizedBox(height: 16),
                    if (source.tags.isNotEmpty) ...[
                      _SheetTags(tags: source.tags),
                      const SizedBox(height: 18),
                    ],
                    Text(
                      'About this role',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      source.description,
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FButton(
                      variant: FButtonVariant.outline,
                      onPress: onOpenFull,
                      suffix: const Icon(FLucideIcons.arrowUpRight, size: 18),
                      child: const Text('Open full details'),
                    ),
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
  const _SheetHeader({required this.source, required this.onOpenFull});

  final JobFeedModel source;
  final VoidCallback onOpenFull;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
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
                '${source.company} · ${source.location}',
                style: TextStyle(color: palette.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
        if (source.matchPercent > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              '${source.matchPercent}% match',
              style: const TextStyle(
                color: AppColors.brandPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}

class _SheetMetaRow extends StatelessWidget {
  const _SheetMetaRow({required this.source});

  final JobFeedModel source;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final items = <(IconData, String)>[
      (FLucideIcons.briefcase, source.level),
      if (source.salary.isNotEmpty) (FLucideIcons.banknote, source.salary),
      (FLucideIcons.clock, source.timeAgo),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        for (final (icon, label) in items)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: palette.surfaceMuted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: palette.iconMuted),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
                child: Text(controller.isApplied ? 'Applied' : 'Apply now'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
