import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/home/model/job_feed_model.dart';
import 'package:jobodia_frontend/features/job_detail/controller/job_detail_controller.dart';

/// Opens a draggable, scrollable job preview as a Forui modal sheet.
///
/// It intentionally blocks the screen behind it, so a tap on the scrim closes
/// the preview just like the close button does.
void showJobDetailSheet(BuildContext context, JobFeedModel job) {
  unawaited(HapticFeedback.lightImpact());

  final jobController = JobDetailController(source: job);

  unawaited(
    showFSheet<void>(
      context: context,
      side: FLayout.btt,
      // null lets the DraggableScrollableSheet own its sizing + drag behavior.
      mainAxisMaxRatio: null,
      barrierDismissible: true,
      builder: (sheetContext) => _JobDetailSheet(
        controller: jobController,
        source: job,
        onClose: () => Navigator.of(sheetContext).pop(),
      ),
    ),
  );
}

class _JobDetailSheet extends StatelessWidget {
  const _JobDetailSheet({
    required this.controller,
    required this.source,
    required this.onClose,
  });

  final JobDetailController controller;
  final JobFeedModel source;
  final VoidCallback onClose;

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
                        'Skills & requirements',
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
                      'Role overview',
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
                color: colors.primary,
                child: InkWell(
                  onTap: onClose,
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(
                      FLucideIcons.x,
                      size: 18,
                      color: colors.primaryForeground,
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
            child: Text('${source.matchPercent}% match'),
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
      (FLucideIcons.mapPin, 'Location', source.location),
      (FLucideIcons.briefcaseBusiness, 'Experience', source.level),
      if (source.salary.isNotEmpty)
        (FLucideIcons.banknote, 'Salary', source.salary),
      if (source.distance.isNotEmpty)
        (FLucideIcons.navigation, 'Distance', source.distance),
      (FLucideIcons.clock3, 'Posted', source.timeAgo),
      (FLucideIcons.building2, 'Company', source.companyTag),
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
                child: Text(controller.isApplied ? 'Applied' : 'Apply now'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
