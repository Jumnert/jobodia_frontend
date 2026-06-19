import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = _notifications();
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.scaffold,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 18, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(Icons.chevron_left_rounded, size: 30),
                  ),
                  const Expanded(
                    child: Text(
                      'Notifications',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 22),
                itemCount: notifications.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: palette.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: palette.surfaceMuted,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            notification.icon,
                            color: palette.iconPrimary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      notification.title,
                                      style: TextStyle(
                                        color: palette.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  if (notification.unread)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: palette.textPrimary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notification.body,
                                style: TextStyle(
                                  color: palette.textSecondary,
                                  fontSize: 13,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                notification.time,
                                style: TextStyle(
                                  color: palette.textTertiary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_NotificationItem> _notifications() {
    return const [
      _NotificationItem(
        icon: Icons.work_outline_rounded,
        title: 'New job match',
        body:
            'Product Designer - SaaS is now a strong match based on your skills.',
        time: '2 min ago',
        unread: true,
      ),
      _NotificationItem(
        icon: Icons.smart_toy_outlined,
        title: 'AI CV update',
        body: 'Your CV draft is ready with stronger summary bullet points.',
        time: '18 min ago',
        unread: true,
      ),
      _NotificationItem(
        icon: Icons.favorite_border_rounded,
        title: 'Saved job reminder',
        body: 'The remote Flutter role you saved has 4 new updates.',
        time: '1 hour ago',
        unread: false,
      ),
      _NotificationItem(
        icon: Icons.school_outlined,
        title: 'Interview prep',
        body: 'You have 3 interview practice questions waiting in your plan.',
        time: 'Today',
        unread: false,
      ),
      _NotificationItem(
        icon: Icons.notifications_active_outlined,
        title: 'Weekly summary',
        body: '7 new jobs matched your filters this week.',
        time: 'Yesterday',
        unread: false,
      ),
    ];
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    required this.unread,
  });

  final IconData icon;
  final String title;
  final String body;
  final String time;
  final bool unread;
}
