import 'package:flutter/material.dart';
import 'package:jobodia_frontend/features/cv_builder/model/cv_data.dart';

/// Form state holder for a single work-experience entry in the CV builder.
class CvWorkExperienceForm {
  CvWorkExperienceForm();

  final companyController = TextEditingController();
  final roleController = TextEditingController();
  final startController = TextEditingController();
  final endController = TextEditingController();
  final descriptionController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

  bool get hasContent =>
      companyController.text.trim().isNotEmpty ||
      roleController.text.trim().isNotEmpty ||
      descriptionController.text.trim().isNotEmpty;

  CvWorkExperience toModel() => CvWorkExperience(
    role: roleController.text.trim(),
    company: companyController.text.trim(),
    start: startController.text.trim(),
    end: endController.text.trim(),
    description: descriptionController.text.trim(),
  );

  void dispose() {
    companyController.dispose();
    roleController.dispose();
    startController.dispose();
    endController.dispose();
    descriptionController.dispose();
  }
}
