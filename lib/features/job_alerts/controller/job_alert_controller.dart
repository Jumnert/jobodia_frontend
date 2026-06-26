import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/features/home/controller/home_controller.dart';
import 'package:jobodia_frontend/features/home/model/job_feed_model.dart';
import 'package:jobodia_frontend/features/job_alerts/model/job_alert_model.dart';
import 'package:jobodia_frontend/features/notifications/controller/notifications_controller.dart';
import 'package:jobodia_frontend/features/notifications/model/notification_item.dart';
import 'package:uuid/uuid.dart';

class JobAlertController extends GetxController {
  final _storage = GetStorage();
  final RxList<JobAlertModel> alerts = <JobAlertModel>[].obs;
  Timer? _mockAlertTimer;

  static const _storageKey = 'jobAlerts';
  final _uuid = const Uuid();

  @override
  void onInit() {
    super.onInit();
    _loadAlerts();
    _startMockAlertsSimulation();
  }

  @override
  void onClose() {
    _mockAlertTimer?.cancel();
    super.onClose();
  }

  void _loadAlerts() {
    final data = _storage.read<String>(_storageKey);
    if (data != null) {
      try {
        final List<dynamic> decoded = jsonDecode(data) as List<dynamic>;
        alerts.value = decoded
            .map((e) => JobAlertModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        // Fallback to empty
      }
    }
  }

  void _saveAlerts() {
    final encoded = jsonEncode(alerts.map((e) => e.toJson()).toList());
    _storage.write(_storageKey, encoded);
  }

  void createAlert({
    required String name,
    required List<String> keywords,
    String? location,
    String? level,
    int? minSalary,
  }) {
    final alert = JobAlertModel(
      id: _uuid.v4(),
      name: name,
      keywords: keywords,
      location: location,
      level: level,
      minSalary: minSalary,
      createdAt: DateTime.now(),
    );
    alerts.add(alert);
    _saveAlerts();
    // Give a quick test of the alert immediately
    _checkAlert(alert);
  }

  void deleteAlert(String id) {
    alerts.removeWhere((e) => e.id == id);
    _saveAlerts();
  }

  void toggleAlert(String id) {
    final index = alerts.indexWhere((e) => e.id == id);
    if (index != -1) {
      final old = alerts[index];
      alerts[index] = old.copyWith(isActive: !old.isActive);
      _saveAlerts();
    }
  }

  void _startMockAlertsSimulation() {
    // Check every hour in mock
    _mockAlertTimer = Timer.periodic(const Duration(hours: 1), (_) {
      for (final alert in alerts.where((e) => e.isActive)) {
        _checkAlert(alert);
      }
    });
  }

  void checkForNewMatches() {
    for (final alert in alerts.where((e) => e.isActive)) {
      _checkAlert(alert);
    }
  }

  void _checkAlert(JobAlertModel alert) {
    if (!Get.isRegistered<HomeController>()) return;
    if (!Get.isRegistered<NotificationsController>()) return;

    final homeCtrl = Get.find<HomeController>();
    final notifCtrl = Get.find<NotificationsController>();

    final matchingJobs = <JobFeedModel>[];
    for (final job in homeCtrl.filteredJobs) {
      bool matches = true;

      if (alert.keywords.isNotEmpty) {
        final lowerTitle = job.title.toLowerCase();
        final lowerCompany = job.company.toLowerCase();
        bool hasKeyword = false;
        for (final kw in alert.keywords) {
          if (lowerTitle.contains(kw.toLowerCase()) ||
              lowerCompany.contains(kw.toLowerCase())) {
            hasKeyword = true;
            break;
          }
        }
        if (!hasKeyword) matches = false;
      }

      if (alert.location != null && alert.location!.isNotEmpty) {
        if (job.location != alert.location) matches = false;
      }

      if (alert.level != null && alert.level!.isNotEmpty) {
        if (job.level != alert.level) matches = false;
      }

      if (matches) {
        matchingJobs.add(job);
      }
    }

    if (matchingJobs.isNotEmpty) {
      final displayJobs = matchingJobs.take(3).map((e) => e.title).join(', ');
      final subtitle = matchingJobs.length > 3
          ? 'Includes $displayJobs and ${matchingJobs.length - 3} more.'
          : displayJobs;

      notifCtrl.addNotification(
        NotificationItem(
          id: _uuid.v4(),
          title: 'New jobs for "${alert.name}"',
          body: subtitle,
          icon: Icons.work_outline_rounded,
          time: 'Just now',
          isRead: false,
        ),
      );
    }
  }
}
