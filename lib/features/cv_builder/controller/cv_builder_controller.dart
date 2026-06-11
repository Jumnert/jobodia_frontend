import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CvWorkExperienceForm {
  CvWorkExperienceForm();

  final companyController = TextEditingController();
  final roleController = TextEditingController();
  final startController = TextEditingController();
  final endController = TextEditingController();
  final descriptionController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

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

  void dispose() {
    schoolController.dispose();
    degreeController.dispose();
    startController.dispose();
    endController.dispose();
    descriptionController.dispose();
  }
}

class CvBuilderController extends GetxController {
  final RxInt stepIndex = 0.obs;
  final RxInt selectedTemplateIndex = 0.obs;
  final RxBool isGenerated = false.obs;
  final RxBool hasHeadshot = false.obs;
  bool showGeneratedSnackBar = true;

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  final titleController = TextEditingController();
  final summaryController = TextEditingController();
  final skillController = TextEditingController();

  final RxList<String> skills = <String>[].obs;
  final RxList<CvWorkExperienceForm> workExperiences = <CvWorkExperienceForm>[
    CvWorkExperienceForm(),
  ].obs;
  final RxList<CvEducationForm> educations = <CvEducationForm>[
    CvEducationForm(),
  ].obs;

  final templateTitles = const ['Classic', 'Balanced', 'Modern'];
  static const int maxEntries = 3;

  bool get canAddWorkExperience => workExperiences.length < maxEntries;

  bool get canAddEducation => educations.length < maxEntries;

  void nextStep() {
    if (stepIndex.value < 2) {
      stepIndex.value++;
    } else {
      isGenerated.value = true;
      if (showGeneratedSnackBar) {
        Get.snackbar(
          'CV generation',
          'Mock CV generated with the selected template.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
    }
  }

  void previousStep() {
    if (stepIndex.value > 0) {
      stepIndex.value--;
    }
  }

  void selectTemplate(int index) {
    selectedTemplateIndex.value = index;
  }

  void chooseHeadshot() {
    hasHeadshot.value = true;
  }

  void removeHeadshot() {
    hasHeadshot.value = false;
  }

  void addWorkExperience() {
    if (!canAddWorkExperience) {
      return;
    }

    workExperiences.add(CvWorkExperienceForm());
  }

  void removeWorkExperience(CvWorkExperienceForm entry) {
    if (workExperiences.length == 1) {
      return;
    }

    workExperiences.remove(entry);
    entry.dispose();
  }

  void addEducation() {
    if (!canAddEducation) {
      return;
    }

    educations.add(CvEducationForm());
  }

  void removeEducation(CvEducationForm entry) {
    if (educations.length == 1) {
      return;
    }

    educations.remove(entry);
    entry.dispose();
  }

  void setWorkStartDate(CvWorkExperienceForm entry, DateTime date) {
    entry.startDate = date;
    entry.startController.text = _formatMonthYear(date);
  }

  void setWorkEndDate(CvWorkExperienceForm entry, DateTime date) {
    entry.endDate = date;
    entry.endController.text = _formatMonthYear(date);
  }

  void setEducationStartDate(CvEducationForm entry, DateTime date) {
    entry.startDate = date;
    entry.startController.text = _formatMonthYear(date);
  }

  void setEducationEndDate(CvEducationForm entry, DateTime date) {
    entry.endDate = date;
    entry.endController.text = _formatMonthYear(date);
  }

  void addSkill() {
    final skill = skillController.text.trim();
    if (skill.isEmpty || skills.contains(skill)) {
      return;
    }

    skills.add(skill);
    skillController.clear();
  }

  void removeSkill(String skill) {
    skills.remove(skill);
  }

  String _formatMonthYear(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    locationController.dispose();
    titleController.dispose();
    summaryController.dispose();
    for (final entry in workExperiences) {
      entry.dispose();
    }
    for (final entry in educations) {
      entry.dispose();
    }
    skillController.dispose();
    super.onClose();
  }
}
