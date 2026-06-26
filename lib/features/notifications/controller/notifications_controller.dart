import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/features/notifications/model/notification_item.dart';

import 'package:jobodia_frontend/core/widgets/undo_snackbar.dart';

class NotificationsController extends GetxController {
  NotificationsController({GetStorage? storage})
    : _storage = storage ?? GetStorage();

  static const _readKey = 'readNotificationIds';
  final GetStorage _storage;

  late final RxList<NotificationItem> notifications;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    notifications = _mockNotifications().obs;
    _loadReadState();
  }

  void markRead(String id) {
    final n = notifications.firstWhereOrNull((n) => n.id == id);
    if (n != null) {
      n.isRead = true;
      notifications.refresh();
      _persist();
    }
  }

  void addNotification(NotificationItem item) {
    notifications.insert(0, item);
    _persist();
  }

  void dismissNotification(String id) {
    final removedIndex = notifications.indexWhere((n) => n.id == id);
    if (removedIndex == -1) return;

    final removedItem = notifications[removedIndex];
    notifications.removeAt(removedIndex);
    _persist();

    showUndoSnackbar(
      message: 'Notification removed',
      onUndo: () {
        notifications.insert(removedIndex, removedItem);
        _persist();
      },
    );
  }

  void markAllRead() {
    for (final n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
    _persist();
  }

  void _loadReadState() {
    final readIds = _storage.read<List>(_readKey)?.cast<String>() ?? [];
    for (final n in notifications) {
      if (readIds.contains(n.id)) n.isRead = true;
    }
    notifications.refresh();
  }

  void _persist() {
    final readIds = notifications
        .where((n) => n.isRead)
        .map((n) => n.id)
        .toList();
    _storage.write(_readKey, readIds);
  }

  List<NotificationItem> _mockNotifications() => [
    NotificationItem(
      id: 'n1',
      icon: Icons.work_outline_rounded,
      title: 'New job match',
      body:
          'Product Designer - SaaS is now a strong match based on your skills.',
      time: '2 min ago',
      isRead: false,
    ),
    NotificationItem(
      id: 'n2',
      icon: Icons.smart_toy_outlined,
      title: 'AI CV update',
      body: 'Your CV draft is ready with stronger summary bullet points.',
      time: '18 min ago',
      isRead: false,
    ),
    NotificationItem(
      id: 'n3',
      icon: Icons.favorite_border_rounded,
      title: 'Saved job reminder',
      body: 'The remote Flutter role you saved has 4 new updates.',
      time: '1 hour ago',
    ),
    NotificationItem(
      id: 'n4',
      icon: Icons.school_outlined,
      title: 'Interview prep',
      body: 'You have 3 interview practice questions waiting in your plan.',
      time: 'Today',
    ),
    NotificationItem(
      id: 'n5',
      icon: Icons.notifications_active_outlined,
      title: 'Weekly summary',
      body: '7 new jobs matched your filters this week.',
      time: 'Yesterday',
    ),
  ];
}
