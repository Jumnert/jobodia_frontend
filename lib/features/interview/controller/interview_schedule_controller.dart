import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/features/interview/model/interview_schedule.dart';

class InterviewScheduleController extends GetxController {
  static const _key = 'interviewSchedules';
  final _storage = GetStorage();
  final schedules = <InterviewSchedule>[].obs;

  @override
  void onInit() {
    super.onInit();
    final stored = _storage.read<List>(_key);
    if (stored != null) {
      schedules.assignAll(
        stored.map(
          (s) => InterviewSchedule.fromJson(s as Map<String, dynamic>),
        ),
      );
    }
  }

  void schedule(String jobId, DateTime dateTime, {String notes = ''}) {
    schedules.removeWhere((s) => s.jobId == jobId);
    schedules.add(
      InterviewSchedule(jobId: jobId, dateTime: dateTime, notes: notes),
    );
    schedules.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    _persist();
  }

  void remove(String jobId) {
    schedules.removeWhere((s) => s.jobId == jobId);
    _persist();
  }

  bool hasUpcomingIn7Days() {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));
    return schedules.any(
      (s) => s.dateTime.isAfter(now) && s.dateTime.isBefore(weekFromNow),
    );
  }

  void _persist() {
    _storage.write(_key, schedules.map((s) => s.toJson()).toList());
  }
}
