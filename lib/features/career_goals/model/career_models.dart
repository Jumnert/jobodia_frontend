import 'package:flutter/material.dart';

class CareerGoalModel {
  CareerGoalModel({
    required this.id,
    required this.type,
    required this.title,
    required this.targetValue,
    required this.currentValue,
    this.deadline,
    this.isCompleted = false,
    this.completedAt,
    required this.createdAt,
  });

  final String id;
  final String
  type; // targetRole, targetSalary, skillToLearn, certificationToEarn
  final String title;
  final String targetValue;
  final String currentValue;
  final DateTime? deadline;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'title': title,
    'targetValue': targetValue,
    'currentValue': currentValue,
    'deadline': deadline?.toIso8601String(),
    'isCompleted': isCompleted,
    'completedAt': completedAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory CareerGoalModel.fromJson(Map<String, dynamic> json) =>
      CareerGoalModel(
        id: json['id'] as String,
        type: json['type'] as String,
        title: json['title'] as String,
        targetValue: json['targetValue'] as String,
        currentValue: json['currentValue'] as String,
        deadline: json['deadline'] != null
            ? DateTime.parse(json['deadline'] as String)
            : null,
        isCompleted: json['isCompleted'] as bool,
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  CareerGoalModel copyWith({
    String? title,
    String? targetValue,
    String? currentValue,
    DateTime? deadline,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return CareerGoalModel(
      id: id,
      type: type,
      title: title ?? this.title,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt,
    );
  }
}

class CareerMilestoneModel {
  CareerMilestoneModel({
    required this.id,
    required this.title,
    required this.description,
    required this.achievedAt,
    required this.icon,
    required this.category,
  });

  final String id;
  final String title;
  final String description;
  final DateTime achievedAt;
  final IconData icon;
  final String category; // application, interview, offer, skill, certification
}
