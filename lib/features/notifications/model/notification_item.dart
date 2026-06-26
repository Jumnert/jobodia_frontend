import 'package:flutter/material.dart';

class NotificationItem {
  NotificationItem({
    required this.id,
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
  });

  final String id;
  final IconData icon;
  final String title;
  final String body;
  final String time;
  bool isRead;
}
