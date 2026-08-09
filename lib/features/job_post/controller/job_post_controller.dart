import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/features/ai_chat/service/deepseek_chat_service.dart';
import 'package:jobodia_frontend/features/home/controller/home_controller.dart';
import 'package:jobodia_frontend/features/job_post/model/job_post_draft.dart';

enum JobPostView { dashboard, editor, success }

class JobPostController extends GetxController {
  JobPostController({GetStorage? storage, DeepSeekChatService? aiService})
    : _storage = storage ?? GetStorage(),
      _aiService = aiService ?? DeepSeekChatService(),
      _ownsAiService = aiService == null;

  static const draftKey = 'employerJobPostDraft';
  static const publishedKey = 'employerPublishedJobs';

  final GetStorage _storage;
  final DeepSeekChatService _aiService;
  final bool _ownsAiService;
  Timer? _saveTimer;
  bool _suppressAutoSave = false;

  final titleController = TextEditingController();
  final companyController = TextEditingController();
  final locationController = TextEditingController();
  final salaryController = TextEditingController();
  final descriptionController = TextEditingController();
  final requirementsController = TextEditingController();
  final tagsController = TextEditingController();
  final applicationStartController = TextEditingController();
  final applicationEndController = TextEditingController();

  final step = 0.obs;
  final workArrangement = 'On-site'.obs;
  final employmentType = 'Full-time'.obs;
  final experienceLevel = 'Mid-level'.obs;
  final hasSavedDraft = false.obs;
  final currentView = JobPostView.dashboard.obs;
  final isGeneratingAi = false.obs;
  final aiError = ''.obs;
  final publishedJobs = <JobPostDraft>[].obs;

  List<TextEditingController> get _textControllers => [
    titleController,
    companyController,
    locationController,
    salaryController,
    descriptionController,
    requirementsController,
    tagsController,
    applicationStartController,
    applicationEndController,
  ];

  JobPostDraft get draft => JobPostDraft(
    title: titleController.text.trim(),
    company: companyController.text.trim(),
    location: locationController.text.trim(),
    workArrangement: workArrangement.value,
    employmentType: employmentType.value,
    experienceLevel: experienceLevel.value,
    salary: salaryController.text.trim(),
    description: descriptionController.text.trim(),
    requirements: requirementsController.text.trim(),
    tags: tagsController.text.trim(),
    applicationStartDate: applicationStartController.text.trim(),
    applicationEndDate: applicationEndController.text.trim(),
  );

  @override
  void onInit() {
    super.onInit();
    _loadDraft();
    _loadPublishedJobs();
    for (final controller in _textControllers) {
      controller.addListener(_queueAutoSave);
    }
  }

  void _loadDraft() {
    final raw = _storage.read<Map>(draftKey);
    if (raw == null) return;
    final saved = JobPostDraft.fromJson(Map<String, dynamic>.from(raw));
    if (saved.isEmpty) return;

    titleController.text = saved.title;
    companyController.text = saved.company;
    locationController.text = saved.location;
    salaryController.text = saved.salary;
    descriptionController.text = saved.description;
    requirementsController.text = saved.requirements;
    tagsController.text = saved.tags;
    applicationStartController.text = saved.applicationStartDate;
    applicationEndController.text = saved.applicationEndDate;
    workArrangement.value = saved.workArrangement;
    employmentType.value = saved.employmentType;
    experienceLevel.value = saved.experienceLevel;
    hasSavedDraft.value = true;
  }

  void _loadPublishedJobs() {
    final raw = _storage.read<List>(publishedKey) ?? const [];
    publishedJobs.assignAll(
      raw.whereType<Map>().map(
        (item) => JobPostDraft.fromJson(Map<String, dynamic>.from(item)),
      ),
    );
  }

  void openSavedDraft() {
    currentView.value = JobPostView.editor;
  }

  void startManualPost() {
    _resetForm();
    currentView.value = JobPostView.editor;
  }

  void showDashboard() {
    if (currentView.value == JobPostView.editor) saveDraft();
    currentView.value = JobPostView.dashboard;
  }

  Future<bool> generateAiDraft({
    required String title,
    required String salary,
    required String startDate,
    required String endDate,
    required String experienceLevel,
  }) async {
    aiError.value = '';
    isGeneratingAi.value = true;
    try {
      final generated = await _aiService.generateJobPost(
        title: title,
        salary: salary,
        startDate: startDate,
        endDate: endDate,
        experienceLevel: experienceLevel,
      );
      _resetForm();
      titleController.text = title.trim();
      salaryController.text = salary.trim();
      applicationStartController.text = startDate.trim();
      applicationEndController.text = endDate.trim();
      this.experienceLevel.value = experienceLevel;
      companyController.text = generated['company']?.toString() ?? '';
      locationController.text = generated['location']?.toString() ?? '';
      workArrangement.value =
          generated['workArrangement']?.toString() ?? 'On-site';
      employmentType.value =
          generated['employmentType']?.toString() ?? 'Full-time';
      descriptionController.text = generated['description']?.toString() ?? '';
      requirementsController.text = generated['requirements']?.toString() ?? '';
      tagsController.text = generated['tags']?.toString() ?? '';
      step.value = 3;
      saveDraft();
      currentView.value = JobPostView.editor;
      return true;
    } on DeepSeekException catch (error) {
      aiError.value = error.message;
      return false;
    } on Object {
      aiError.value = 'AI could not create this listing. Please try again.';
      return false;
    } finally {
      isGeneratingAi.value = false;
    }
  }

  void _queueAutoSave() {
    if (_suppressAutoSave) return;
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 350), saveDraft);
  }

  void chooseWorkArrangement(String value) {
    workArrangement.value = value;
    saveDraft();
  }

  void chooseEmploymentType(String value) {
    employmentType.value = value;
    saveDraft();
  }

  void chooseExperienceLevel(String value) {
    experienceLevel.value = value;
    saveDraft();
  }

  void saveDraft({bool notify = false}) {
    final value = draft;
    if (value.isEmpty) {
      _storage.remove(draftKey);
      hasSavedDraft.value = false;
      return;
    }
    _storage.write(draftKey, {
      ...value.toJson(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
    hasSavedDraft.value = true;
    if (notify) {
      Get.snackbar(
        'Draft saved',
        'Your job post is saved on this device.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  bool nextStep() {
    if (!_isCurrentStepValid()) return false;
    saveDraft();
    if (step.value < 3) step.value++;
    return true;
  }

  void previousStep() {
    if (step.value > 0) step.value--;
  }

  bool _isCurrentStepValid() {
    final missing = switch (step.value) {
      0 =>
        titleController.text.trim().isEmpty ||
            companyController.text.trim().isEmpty ||
            locationController.text.trim().isEmpty,
      1 =>
        salaryController.text.trim().isEmpty ||
            applicationStartController.text.trim().isEmpty ||
            applicationEndController.text.trim().isEmpty,
      2 =>
        descriptionController.text.trim().isEmpty ||
            requirementsController.text.trim().isEmpty,
      _ => false,
    };
    if (!missing) return true;
    Get.snackbar(
      'Complete this step',
      'Fill in the required fields before continuing.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
    return false;
  }

  void publishJob() {
    final value = draft;
    final existing = _storage.read<List>(publishedKey) ?? <dynamic>[];
    final publishedJobs = existing
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    final publishedRecord = <String, dynamic>{
      ...value.toJson(),
      'id': 'local-${DateTime.now().microsecondsSinceEpoch}',
      'status': 'published',
      'publishedAt': DateTime.now().toIso8601String(),
    };
    publishedJobs.insert(0, publishedRecord);
    _storage.write(publishedKey, publishedJobs);
    _storage.remove(draftKey);
    hasSavedDraft.value = false;
    this.publishedJobs.insert(0, value);
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().addLocallyPublishedJob(publishedRecord);
    }
    currentView.value = JobPostView.success;
  }

  void startAnotherPost() {
    _resetForm();
    currentView.value = JobPostView.dashboard;
  }

  void _resetForm() {
    _suppressAutoSave = true;
    for (final controller in _textControllers) {
      controller.clear();
    }
    workArrangement.value = 'On-site';
    employmentType.value = 'Full-time';
    experienceLevel.value = 'Mid-level';
    step.value = 0;
    _storage.remove(draftKey);
    hasSavedDraft.value = false;
    _suppressAutoSave = false;
  }

  @override
  void onClose() {
    _saveTimer?.cancel();
    for (final controller in _textControllers) {
      controller
        ..removeListener(_queueAutoSave)
        ..dispose();
    }
    if (_ownsAiService) _aiService.close();
    super.onClose();
  }
}
