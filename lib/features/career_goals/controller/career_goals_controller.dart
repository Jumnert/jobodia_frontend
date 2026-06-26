import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/features/career_goals/model/career_models.dart';
import 'package:uuid/uuid.dart';

class CareerGoalsController extends GetxController {
  final _uuid = const Uuid();
  final RxList<CareerGoalModel> goals = <CareerGoalModel>[].obs;
  final RxList<CareerMilestoneModel> milestones = <CareerMilestoneModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _seedData();
  }

  void _seedData() {
    goals.addAll([
      CareerGoalModel(
        id: 'g1',
        type: 'targetRole',
        title: 'Become a Senior Developer',
        targetValue: 'Senior Developer',
        currentValue: 'Mid-level Developer',
        deadline: DateTime.now().add(const Duration(days: 365)),
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      CareerGoalModel(
        id: 'g2',
        type: 'skillToLearn',
        title: 'Master Flutter Animations',
        targetValue: '100',
        currentValue: '60',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ]);

    milestones.addAll([
      CareerMilestoneModel(
        id: 'm1',
        title: 'Joined Jobodia',
        description: 'Created your professional profile.',
        achievedAt: DateTime.now().subtract(const Duration(days: 90)),
        icon: Icons.person_add_alt_1_rounded,
        category: 'application',
      ),
      CareerMilestoneModel(
        id: 'm2',
        title: 'Earned Flutter Basics Certification',
        description: 'Passed the skill assessment with 90%.',
        achievedAt: DateTime.now().subtract(const Duration(days: 60)),
        icon: Icons.verified_rounded,
        category: 'certification',
      ),
      CareerMilestoneModel(
        id: 'm3',
        title: 'First Interview Scheduled',
        description: 'Google reached out for a Mobile Engineer role.',
        achievedAt: DateTime.now().subtract(const Duration(days: 10)),
        icon: Icons.chat_bubble_outline_rounded,
        category: 'interview',
      ),
    ]);
  }

  void addGoal({
    required String type,
    required String title,
    required String targetValue,
    required String currentValue,
    DateTime? deadline,
  }) {
    goals.insert(
      0,
      CareerGoalModel(
        id: _uuid.v4(),
        type: type,
        title: title,
        targetValue: targetValue,
        currentValue: currentValue,
        deadline: deadline,
        createdAt: DateTime.now(),
      ),
    );
    Get.back(); // close sheet
    Get.snackbar('Goal Added', 'Your new career goal has been saved.');
  }

  void updateGoalProgress(String id, String currentValue) {
    final idx = goals.indexWhere((g) => g.id == id);
    if (idx != -1) {
      goals[idx] = goals[idx].copyWith(currentValue: currentValue);
    }
  }

  void completeGoal(String id) {
    final idx = goals.indexWhere((g) => g.id == id);
    if (idx != -1) {
      final g = goals[idx];
      goals[idx] = g.copyWith(isCompleted: true, completedAt: DateTime.now());

      // Auto-generate milestone
      milestones.insert(
        0,
        CareerMilestoneModel(
          id: _uuid.v4(),
          title: 'Goal Completed',
          description: g.title,
          achievedAt: DateTime.now(),
          icon: Icons.emoji_events_rounded,
          category: 'skill',
        ),
      );
    }
  }
}
