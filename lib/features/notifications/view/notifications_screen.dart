import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/empty_state.dart';
import 'package:jobodia_frontend/features/notifications/controller/notifications_controller.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController(
    keepScrollOffset: false,
  );
  final ValueNotifier<double> _headerCollapseProgress = ValueNotifier(0);

  NotificationsController get controller => Get.find<NotificationsController>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateHeaderCollapse);
  }

  void _updateHeaderCollapse() {
    final next = (_scrollController.offset / 56).clamp(0.0, 1.0);
    if ((next - _headerCollapseProgress.value).abs() < 0.002) return;
    _headerCollapseProgress.value = next;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateHeaderCollapse);
    _scrollController.dispose();
    _headerCollapseProgress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    final notificationList = Obx(() {
      final notifications = controller.notifications;
      return notifications.isEmpty
          ? Padding(
              padding: EdgeInsets.only(bottom: widget.embedded ? 90 : 0),
              child: const EmptyState(
                icon: FLucideIcons.bell,
                title: 'No notifications yet',
              ),
            )
          : RefreshIndicator(
              color: AppColors.brandPrimary,
              backgroundColor: palette.surface,
              onRefresh: () async {
                await Future<void>.delayed(const Duration(milliseconds: 600));
              },
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  18,
                  24,
                  18,
                  widget.embedded ? 128 : 22,
                ),
                itemCount: notifications.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16, left: 4),
                      child: Text(
                        'Previously',
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }
                  if (index == notifications.length + 1) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 32, bottom: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Missing notifications?',
                            style: TextStyle(
                              color: palette.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Go to historical notifications.',
                            style: const TextStyle(
                              color: AppColors.brandPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final notification = notifications[index - 1];
                  final cardColor = Color.alphaBlend(
                    AppColors.brandPrimary.withValues(
                      alpha: notification.isRead ? 0.035 : 0.09,
                    ),
                    palette.surfaceMuted,
                  );
                  final cardBorder = notification.isRead
                      ? palette.border
                      : AppColors.brandPrimary.withValues(alpha: 0.2);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Dismissible(
                      key: ValueKey(notification.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        decoration: BoxDecoration(
                          color: palette.error,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          FLucideIcons.trash2,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (_) =>
                          controller.dismissNotification(notification.id),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Material(
                          color: cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(color: cardBorder),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            splashColor: AppColors.brandTeal.withValues(
                              alpha: 0.1,
                            ),
                            onTap: () => controller.markRead(notification.id),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.brandPrimary.withValues(
                                        alpha: notification.isRead ? 0.1 : 0.16,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      notification.icon,
                                      color: AppColors.brandPrimary,
                                      size: 21,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                notification.title,
                                                style: TextStyle(
                                                  color: palette.textPrimary,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              notification.time,
                                              style: TextStyle(
                                                color: palette.textPrimary,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            if (!notification.isRead) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                width: 10,
                                                height: 10,
                                                decoration: const BoxDecoration(
                                                  color: Color(
                                                    0xFF007AFF,
                                                  ), // iOS blue dot
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          notification.body,
                                          style: TextStyle(
                                            color: palette.textPrimary,
                                            fontSize: 14,
                                            height: 1.35,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
    });

    final content = ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      child: ColoredBox(color: palette.surface, child: notificationList),
    );
    final safeTop = MediaQuery.paddingOf(context).top;
    final header = _NotificationsCollapsingHeader(
      progress: _headerCollapseProgress,
      showBack: !widget.embedded,
      onBack: () => Get.back<void>(),
      onMarkAllRead: controller.markAllRead,
    );

    final body = Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.brandPrimary.withValues(
                    alpha: context.isDark ? 0.26 : 0.2,
                  ),
                  AppColors.brandPrimary.withValues(
                    alpha: context.isDark ? 0.08 : 0.055,
                  ),
                  palette.surface,
                ],
              ),
            ),
          ),
        ),
        ValueListenableBuilder<double>(
          valueListenable: _headerCollapseProgress,
          child: content,
          builder: (context, progress, child) {
            final eased = Curves.easeOutCubic.transform(progress);
            return Positioned(
              top: safeTop + 116 - (42 * eased),
              left: 0,
              right: 0,
              bottom: 0,
              child: child!,
            );
          },
        ),
        Positioned(top: 0, left: 0, right: 0, child: header),
      ],
    );
    if (widget.embedded) return body;
    return Scaffold(backgroundColor: palette.scaffold, body: body);
  }
}

class _NotificationsCollapsingHeader extends StatelessWidget {
  const _NotificationsCollapsingHeader({
    required this.progress,
    required this.showBack,
    required this.onBack,
    required this.onMarkAllRead,
  });

  final ValueListenable<double> progress;
  final bool showBack;
  final VoidCallback onBack;
  final VoidCallback onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: progress,
      builder: (context, value, _) {
        final theme = FTheme.of(context);
        final safeTop = MediaQuery.paddingOf(context).top;
        final eased = Curves.easeOutCubic.transform(value);
        final height = safeTop + 116 - (42 * eased);
        final leadingInset = showBack ? 62.0 : 18.0;

        return RepaintBoundary(
          child: SizedBox(
            height: height,
            child: ClipRect(
              child: ColoredBox(
                color: Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.only(top: safeTop),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Align(
                        alignment: Alignment(-eased, 0),
                        child: Transform.translate(
                          offset: Offset(leadingInset * eased, 0),
                          child: Text(
                            'Notifications',
                            maxLines: 1,
                            style: theme.typography.body.xl.copyWith(
                              color: theme.colors.foreground,
                              fontSize: 29 - (9 * eased),
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5 + (0.2 * eased),
                            ),
                          ),
                        ),
                      ),
                      if (showBack)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _NotificationHeaderAction(
                            tooltip: 'Back',
                            icon: FLucideIcons.chevronLeft,
                            onPressed: onBack,
                            progress: eased,
                          ),
                        ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _NotificationHeaderAction(
                          tooltip: 'Mark all as read',
                          icon: FLucideIcons.checkCheck,
                          label: 'Read all',
                          onPressed: onMarkAllRead,
                          progress: eased,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NotificationHeaderAction extends StatelessWidget {
  const _NotificationHeaderAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    required this.progress,
    this.label,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final double progress;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = FTheme.of(context).colors;
    final expand = label == null
        ? 0.0
        : Curves.easeOutCubic.transform(progress);
    final textOpacity = Curves.easeIn.transform(
      ((expand - 0.2) / 0.8).clamp(0.0, 1.0),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Tooltip(
        message: tooltip,
        child: SizedBox(
          width: lerpDouble(44, label == null ? 44 : 116, expand)!,
          height: 44,
          child: Material(
            color: colors.background.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(22),
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(22),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 44,
                    child: Center(
                      child: Icon(icon, size: 20, color: colors.foreground),
                    ),
                  ),
                  if (label != null)
                    ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: expand,
                        child: Opacity(
                          opacity: textOpacity,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: Text(
                              label!,
                              maxLines: 1,
                              style: TextStyle(
                                color: colors.foreground,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
