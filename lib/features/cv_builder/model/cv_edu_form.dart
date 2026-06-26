import 'package:flutter/material.dart';
import 'package:jobodia_frontend/features/cv_builder/model/cv_data.dart';

/// Form state holder for a single education entry in the CV builder.
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
