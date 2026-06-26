// ignore_for_file: deprecated_member_use, avoid_print, curly_braces_in_flow_control_structures, unused_import, unnecessary_underscores, unused_field, unused_local_variable, use_build_context_synchronously, duplicate_ignore
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/core/utils/app_logger.dart';
import 'package:jobodia_frontend/features/cv_builder/model/cv_data.dart';
import 'package:jobodia_frontend/features/cv_builder/model/cv_form_classes.dart';
import 'package:jobodia_frontend/features/cv_builder/service/resume_parser_service.dart'
    as jobodia_frontend_service;
import 'package:jobodia_frontend/features/profile/controller/profile_controller.dart';
import 'package:jobodia_frontend/services/secure_storage_service.dart';

class CvBuilderController extends GetxController {
  CvBuilderController({GetStorage? storage, ImagePicker? picker})
    : _storage = storage ?? GetStorage(),
      _picker = picker ?? ImagePicker();

  static const savedCvKey = 'savedCv';

  final GetStorage _storage;
  final ImagePicker _picker;

  final RxInt stepIndex = 0.obs;
  final RxInt selectedTemplateIndex = 0.obs;
  final RxBool isGenerated = false.obs;
  bool showGeneratedSnackBar = true;

  /// Bytes of the chosen headshot, null when none selected.
  final Rxn<Uint8List> headshotBytes = Rxn<Uint8List>();

  /// Inline validation message shown on the template step, empty when valid.
  final RxString generateError = ''.obs;

  /// The most recently generated/persisted CV, null when none exists yet.
  final Rxn<CvData> generatedCv = Rxn<CvData>();

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

  final isParsing = false.obs;

  Future<void> importResume() async {
    isParsing.value = true;
    try {
      final parser = jobodia_frontend_service.ResumeParserService();
      final data = await parser.parseResumeMock();

      fullNameController.text = data['fullName'] as String;
      emailController.text = data['email'] as String;
      phoneController.text = data['phone'] as String;
      locationController.text = data['location'] as String;
      titleController.text = data['title'] as String;
      summaryController.text = data['summary'] as String;

      educations.clear();
      final eduForm = CvEducationForm();
      eduForm.schoolController.text = data['school'] as String;
      eduForm.degreeController.text = data['degree'] as String;
      eduForm.startController.text = data['eduStart'] as String;
      eduForm.endController.text = data['eduEnd'] as String;
      educations.add(eduForm);

      workExperiences.clear();
      final workForm = CvWorkExperienceForm();
      workForm.companyController.text = data['company'] as String;
      workForm.roleController.text = data['role'] as String;
      workForm.startController.text = data['workStart'] as String;
      workForm.endController.text = data['workEnd'] as String;
      workForm.descriptionController.text = data['workDesc'] as String;
      workExperiences.add(workForm);

      skills.assignAll((data['skills'] as List<dynamic>).cast<String>());

      Get.snackbar(
        'Success',
        'Resume parsed and auto-filled successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isParsing.value = false;
    }
  }

  final templateTitles = const ['Classic', 'Balanced', 'Modern'];
  static const int maxEntries = 3;

  bool get hasHeadshot => headshotBytes.value != null;

  bool get canAddWorkExperience => workExperiences.length < maxEntries;

  bool get canAddEducation => educations.length < maxEntries;

  @override
  void onInit() {
    super.onInit();
    _loadSavedCv();
    _seedFromProfile();
  }

  /// Pre-populate skills from the user's profile when the CV builder opens
  /// for the first time (skills list is still empty).
  void _seedFromProfile() {
    if (skills.isNotEmpty) return;
    if (!Get.isRegistered<ProfileController>()) return;
    final profileSkills = Get.find<ProfileController>().profile.skills;
    if (profileSkills.isNotEmpty) {
      skills.addAll(profileSkills);
    }
  }

  void nextStep() {
    if (stepIndex.value < 2) {
      stepIndex.value++;
    } else {
      generateCv();
    }
  }

  /// Validates input, builds the CV model, persists it, and opens the preview.
  void generateCv() {
    final error = _validate();
    if (error != null) {
      generateError.value = error;
      return;
    }
    generateError.value = '';

    try {
      final cv = _buildCvData();
      generatedCv.value = cv;
      isGenerated.value = true;
      _persist(cv);

      Get.toNamed(AppRoutes.cvPreview);
    } on Exception {
      generateError.value =
          'Failed to generate CV. Please check your entries and try again.';
    }
  }

  /// Returns an error message when required data is missing, null when valid.
  String? _validate() {
    if (fullNameController.text.trim().isEmpty) {
      return 'Add your full name before generating the CV.';
    }
    final hasWork = workExperiences.any((e) => e.hasContent);
    final hasEducation = educations.any((e) => e.hasContent);
    if (!hasWork && !hasEducation) {
      return 'Add at least one work experience or education entry.';
    }
    return null;
  }

  CvData _buildCvData() {
    return CvData(
      fullName: fullNameController.text.trim(),
      title: titleController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      location: locationController.text.trim(),
      summary: summaryController.text.trim(),
      templateIndex: selectedTemplateIndex.value,
      skills: List<String>.from(skills),
      workExperiences: workExperiences
          .where((e) => e.hasContent)
          .map((e) => e.toModel())
          .toList(),
      educations: educations
          .where((e) => e.hasContent)
          .map((e) => e.toModel())
          .toList(),
      headshotBytes: headshotBytes.value,
    );
  }

  void _persist(CvData cv) {
    final secure = SecureStorageService.to;
    secure.writeSecure(savedCvKey, jsonEncode(cv.toJson()));
  }

  void _loadSavedCv() async {
    try {
      final secure = SecureStorageService.to;
      final raw = await secure.readSecure(savedCvKey);
      if (raw != null) {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        final cv = CvData.fromJson(map);
        generatedCv.value = cv;
        isGenerated.value = true;
      }
    } on Object catch (e, st) {
      AppLogger.error('Failed to load CV from secure storage', e, st);
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

  Future<void> chooseHeadshot() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null) {
        // User dismissed the picker without choosing — leave state unchanged.
        return;
      }
      headshotBytes.value = await picked.readAsBytes();
    } on Object {
      Get.snackbar(
        'Photo unavailable',
        'Could not access your photos. Check photo permissions and try again.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  void removeHeadshot() {
    headshotBytes.value = null;
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

  String _formatMonthYear(DateTime date) => DateFormat('MMM yyyy').format(date);

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
