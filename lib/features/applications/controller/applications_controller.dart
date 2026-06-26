import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/core/utils/app_logger.dart';
import 'package:jobodia_frontend/features/applications/model/job_application.dart';
import 'package:jobodia_frontend/features/home/model/job_feed_model.dart';
import 'package:jobodia_frontend/services/secure_storage_service.dart';

/// Tracks which jobs the seeker has applied to, with the applied date.
///
/// Persists a JSON-encodable list of `{jobId, appliedDate}` maps via
/// [GetStorage] so applications survive restarts. The simple shape lets a real
/// API replace this storage layer later without touching the UI.
class ApplicationsController extends GetxController {
  ApplicationsController({GetStorage? storage})
    : _storage = storage ?? GetStorage();

  static const applicationsKey = 'applications';

  final GetStorage _storage;

  /// Reactive list of applications, most recent first.
  final RxList<JobApplication> applications = <JobApplication>[].obs;

  @override
  void onInit() {
    super.onInit();
    applications.addAll(_readStored());
  }

  bool hasApplied(String id) => applications.any((a) => a.jobId == id);

  /// Records an application for [job]. No-op if already applied so the applied
  /// date and ordering stay stable.
  void apply(JobFeedModel job, {String? coverLetter}) {
    if (hasApplied(job.id)) {
      return;
    }
    applications.insert(
      0,
      JobApplication(
        jobId: job.id,
        appliedDate: DateTime.now(),
        coverLetter: coverLetter,
      ),
    );
    _persist();
  }

  JobApplication? applicationFor(String id) {
    for (final application in applications) {
      if (application.jobId == id) {
        return application;
      }
    }
    return null;
  }

  static const _validStatuses = {
    'applied',
    'phone_screen',
    'interview',
    'offer',
    'rejected',
  };

  /// Updates the pipeline [status] for the application with the given [jobId].
  /// Valid values: 'applied', 'phone_screen', 'interview', 'offer', 'rejected'.
  void updateStatus(String jobId, String newStatus) {
    if (!_validStatuses.contains(newStatus)) return;
    final index = applications.indexWhere((a) => a.jobId == jobId);
    if (index == -1) return;
    final old = applications[index];
    applications[index] = JobApplication(
      jobId: old.jobId,
      appliedDate: old.appliedDate,
      coverLetter: old.coverLetter,
      status: newStatus,
    );
    _persist();
  }

  void _persist() {
    final data = applications.map((a) => a.toJson()).toList();
    _storage.write(applicationsKey, data);
    SecureStorageService.to.writeSecure(applicationsKey, jsonEncode(data));
  }

  List<JobApplication> _readStored() {
    try {
      final raw = _storage.read<dynamic>(applicationsKey);
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map((e) => JobApplication.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } on Object catch (e, st) {
      AppLogger.error('Failed to load applications from storage', e, st);
    }
    return <JobApplication>[];
  }
}
