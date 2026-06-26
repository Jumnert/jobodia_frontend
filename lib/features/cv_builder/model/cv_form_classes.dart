import 'package:flutter/material.dart';
import 'package:jobodia_frontend/features/cv_builder/model/cv_data.dart';

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

class CvEducationForm {
  CvEducationForm();

  final schoolController = TextEditingController();
  final degreeController = TextEditingController();
  final startController = TextEditingController();
  final endController = TextEditingController();
  final descriptionController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

  bool get hasContent =>
      schoolController.text.trim().isNotEmpty ||
      degreeController.text.trim().isNotEmpty ||
      descriptionController.text.trim().isNotEmpty;

  CvEducation toModel() => CvEducation(
    school: schoolController.text.trim(),
    degree: degreeController.text.trim(),
    start: startController.text.trim(),
    end: endController.text.trim(),
    description: descriptionController.text.trim(),
  );

  void dispose() {
    schoolController.dispose();
    degreeController.dispose();
    startController.dispose();
    endController.dispose();
    descriptionController.dispose();
  }
}
