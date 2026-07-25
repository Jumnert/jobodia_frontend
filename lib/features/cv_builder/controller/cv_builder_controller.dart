// ignore_for_file: deprecated_member_use, avoid_print, curly_braces_in_flow_control_structures, unused_import, unnecessary_underscores, unused_field, unused_local_variable, use_build_context_synchronously, duplicate_ignore
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/core/utils/app_logger.dart';
import 'package:jobodia_frontend/core/utils/input_sanitizer.dart';
import 'package:jobodia_frontend/features/cv_builder/model/cv_data.dart';
import 'package:jobodia_frontend/features/cv_builder/model/cv_form_classes.dart';
import 'package:jobodia_frontend/features/cv_builder/service/auto_fill_service.dart';
import 'package:jobodia_frontend/features/cv_builder/service/resume_parser_service.dart'
    as jobodia_frontend_service;
import 'package:jobodia_frontend/features/profile/controller/profile_controller.dart';
import 'package:jobodia_frontend/services/secure_storage_service.dart';

class CvBuilderController extends GetxController {
  CvBuilderController({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  static const savedCvKey = 'savedCv';
  static const totalSteps = 5;

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

  /// Parses [text] with the real regex parser, fills the form with whatever
  /// fields were extracted, and shows a snackbar summarising the result.
  Future<void> importFromText(String text) async {
    if (text.trim().isEmpty) {
      Get.snackbar(
        'Nothing to parse',
        'Paste some resume text first.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isParsing.value = true;
    try {
      final parser = jobodia_frontend_service.ResumeParserService();
      final result = parser.parseFromText(text);
      _applyParsedFields(result.fields);

      final scored =
          jobodia_frontend_service.ResumeParserService.scoredFieldCount;
      final extracted = (result.confidence * scored).round();
      final message = result.warnings.isEmpty
          ? 'Parsed $extracted/$scored fields.'
          : 'Parsed $extracted/$scored fields.\n${result.warnings.join('\n')}';

      Get.snackbar(
        'Resume parsed',
        message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isParsing.value = false;
    }
  }

  /// Fills the form from the current user profile, when one is registered.
  void fillFromProfile() {
    if (!Get.isRegistered<ProfileController>()) {
      Get.snackbar(
        'No profile',
        'Your profile is not available to fill from.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final fields = AutoFillService().fillFromProfile(
      Get.find<ProfileController>(),
    );
    _applyParsedFields(fields);

    Get.snackbar(
      'Filled from profile',
      'Your profile details were copied into the form.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Populates every CV section with a realistic one-page example so the
  /// complete editing and export experience can be evaluated quickly.
  void fillWithSampleCv() {
    fullNameController.text = 'Sophea Dara';
    emailController.text = 'sophea.dara@example.com';
    phoneController.text = '+855 12 345 678';
    locationController.text = 'Phnom Penh, Cambodia';
    titleController.text = 'Senior Product Designer';
    summaryController.text =
        'Product designer with 6+ years of experience turning complex fintech '
        'and marketplace workflows into simple mobile experiences. I combine '
        'customer research, systems thinking, and close engineering partnership '
        'to ship accessible products that improve activation and retention.';
    skills.assignAll(const [
      'Product strategy',
      'UX research',
      'Interaction design',
      'Design systems',
      'Figma',
      'Prototyping',
      'Usability testing',
      'Data analysis',
      'Accessibility',
      'Agile delivery',
    ]);

    for (final entry in workExperiences) {
      entry.dispose();
    }
    final currentRole = CvWorkExperienceForm()
      ..roleController.text = 'Senior Product Designer'
      ..companyController.text = 'Mekong Digital Bank'
      ..startController.text = 'Mar 2022'
      ..endController.text = 'Present'
      ..descriptionController.text =
          'Led end-to-end design for mobile onboarding used by 180,000+ customers, increasing completed applications by 31%.\n'
          'Built and governed a 90-component design system that reduced design-to-development time by 28%.\n'
          'Partnered with research, product, compliance, and engineering across three cross-functional squads.';
    final previousRole = CvWorkExperienceForm()
      ..roleController.text = 'Product Designer'
      ..companyController.text = 'Jobodia Labs'
      ..startController.text = 'Jun 2019'
      ..endController.text = 'Feb 2022'
      ..descriptionController.text =
          'Redesigned job discovery and application tracking, improving weekly active use by 24%.\n'
          'Ran 40+ customer interviews and usability studies across candidate and recruiter journeys.\n'
          'Introduced accessibility reviews that brought core flows to WCAG 2.1 AA standards.';
    workExperiences.assignAll([currentRole, previousRole]);

    for (final entry in educations) {
      entry.dispose();
    }
    final degree = CvEducationForm()
      ..schoolController.text = 'Royal University of Phnom Penh'
      ..degreeController.text = 'B.A. Media and Communication'
      ..startController.text = '2015'
      ..endController.text = '2019'
      ..descriptionController.text =
          'Graduated with distinction. Focused on human-centered communication and digital media.';
    final certificate = CvEducationForm()
      ..schoolController.text = 'Interaction Design Foundation'
      ..degreeController.text = 'UX Management Specialization'
      ..startController.text = '2021'
      ..endController.text = '2022'
      ..descriptionController.text =
          'Coursework in design leadership, accessibility, and evidence-based product decisions.';
    educations.assignAll([degree, certificate]);

    selectedTemplateIndex.value = 1;
    stepIndex.value = totalSteps - 1;
    generateError.value = '';
    if (!Get.testMode) {
      Get.snackbar(
        'Sample CV ready',
        'Every section is filled. Review it or jump through the steps to test the full-page resume.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  /// Applies a partial field map (only keys present are written). Shared by
  /// [importFromText] and [fillFromProfile]; leaves untouched fields as-is.
  void _applyParsedFields(Map<String, dynamic> data) {
    void setText(TextEditingController c, String key) {
      final value = data[key];
      if (value is String && value.isNotEmpty) c.text = value;
    }

    setText(fullNameController, 'fullName');
    setText(emailController, 'email');
    setText(phoneController, 'phone');
    setText(locationController, 'location');
    setText(titleController, 'title');
    setText(summaryController, 'summary');

    final parsedSkills = data['skills'];
    if (parsedSkills is List && parsedSkills.isNotEmpty) {
      skills.assignAll(parsedSkills.map((e) => e.toString()).toList());
    }

    if (data.containsKey('company') ||
        data.containsKey('role') ||
        data.containsKey('workDesc')) {
      if (workExperiences.isEmpty) {
        workExperiences.add(CvWorkExperienceForm());
      }
      final workForm = workExperiences.first;
      _setIfPresent(workForm.companyController, data['company']);
      _setIfPresent(workForm.roleController, data['role']);
      _setIfPresent(workForm.startController, data['workStart']);
      _setIfPresent(workForm.endController, data['workEnd']);
      _setIfPresent(workForm.descriptionController, data['workDesc']);
    }

    if (data.containsKey('school') || data.containsKey('degree')) {
      if (educations.isEmpty) {
        educations.add(CvEducationForm());
      }
      final eduForm = educations.first;
      _setIfPresent(eduForm.schoolController, data['school']);
      _setIfPresent(eduForm.degreeController, data['degree']);
      _setIfPresent(eduForm.startController, data['eduStart']);
      _setIfPresent(eduForm.endController, data['eduEnd']);
    }
  }

  void _setIfPresent(TextEditingController c, Object? value) {
    if (value is String && value.isNotEmpty) c.text = value;
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
    final error = _validateStep(stepIndex.value);
    if (error != null) {
      generateError.value = error;
      return;
    }
    generateError.value = '';

    if (stepIndex.value < totalSteps - 1) {
      stepIndex.value++;
    } else {
      generateCv();
    }
  }

  String? _validateStep(int step) {
    switch (step) {
      case 0:
        if (fullNameController.text.trim().isEmpty) {
          return 'Add your full name to continue.';
        }
        if (emailController.text.trim().isEmpty &&
            phoneController.text.trim().isEmpty) {
          return 'Add an email address or phone number so employers can contact you.';
        }
        return null;
      case 1:
        if (titleController.text.trim().isEmpty) {
          return 'Add the professional title you want employers to see.';
        }
        return null;
      case 2:
        return _workEntryError();
      case 3:
        final educationError = _educationEntryError();
        if (educationError != null) return educationError;
        final hasWork = workExperiences.any((entry) => entry.hasContent);
        final hasEducation = educations.any((entry) => entry.hasContent);
        if (!hasWork && !hasEducation) {
          return 'Add at least one work experience or education entry.';
        }
        return null;
      default:
        return null;
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
    if (emailController.text.trim().isEmpty &&
        phoneController.text.trim().isEmpty) {
      return 'Add an email address or phone number before generating the CV.';
    }
    if (titleController.text.trim().isEmpty) {
      return 'Add a professional title before generating the CV.';
    }
    final workError = _workEntryError();
    if (workError != null) return workError;
    final educationError = _educationEntryError();
    if (educationError != null) return educationError;
    final hasWork = workExperiences.any((e) => e.hasContent);
    final hasEducation = educations.any((e) => e.hasContent);
    if (!hasWork && !hasEducation) {
      return 'Add at least one work experience or education entry.';
    }
    return null;
  }

  String? _workEntryError() {
    for (var index = 0; index < workExperiences.length; index++) {
      final entry = workExperiences[index];
      if (!entry.hasContent) continue;
      if (entry.roleController.text.trim().isEmpty ||
          entry.companyController.text.trim().isEmpty) {
        return 'Complete the role and company for experience ${index + 1}.';
      }
      if (entry.startDate != null &&
          entry.endDate != null &&
          entry.endDate!.isBefore(entry.startDate!)) {
        return 'The end date for experience ${index + 1} must be after its start date.';
      }
    }
    return null;
  }

  String? _educationEntryError() {
    for (var index = 0; index < educations.length; index++) {
      final entry = educations[index];
      if (!entry.hasContent) continue;
      if (entry.schoolController.text.trim().isEmpty ||
          entry.degreeController.text.trim().isEmpty) {
        return 'Complete the school and degree for education ${index + 1}.';
      }
      if (entry.startDate != null &&
          entry.endDate != null &&
          entry.endDate!.isBefore(entry.startDate!)) {
        return 'The end date for education ${index + 1} must be after its start date.';
      }
    }
    return null;
  }

  CvData _buildCvData() {
    return CvData(
      fullName: InputSanitizer.sanitizeText(fullNameController.text),
      title: InputSanitizer.sanitizeText(titleController.text),
      email: emailController.text.trim(),
      phone: InputSanitizer.sanitizeText(phoneController.text),
      location: InputSanitizer.sanitizeText(locationController.text),
      summary: InputSanitizer.stripControlChars(summaryController.text.trim()),
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

  /// Snapshot used by the design step to render the same PDF as final export.
  CvData buildDraftCv() => _buildCvData();

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
        _restoreEditableFields(cv);
      }
    } on Object catch (e, st) {
      AppLogger.error('Failed to load CV from secure storage', e, st);
    }
  }

  void _restoreEditableFields(CvData cv) {
    if (fullNameController.text.trim().isNotEmpty) return;

    fullNameController.text = cv.fullName;
    titleController.text = cv.title;
    emailController.text = cv.email;
    phoneController.text = cv.phone;
    locationController.text = cv.location;
    summaryController.text = cv.summary;
    selectedTemplateIndex.value = cv.templateIndex;
    skills.assignAll(cv.skills);
    headshotBytes.value = cv.headshotBytes;

    for (final entry in workExperiences) {
      entry.dispose();
    }
    workExperiences.assignAll(
      cv.workExperiences.isEmpty
          ? [CvWorkExperienceForm()]
          : cv.workExperiences.map((item) {
              final form = CvWorkExperienceForm();
              form.roleController.text = item.role;
              form.companyController.text = item.company;
              form.startController.text = item.start;
              form.endController.text = item.end;
              form.descriptionController.text = item.description;
              return form;
            }),
    );

    for (final entry in educations) {
      entry.dispose();
    }
    educations.assignAll(
      cv.educations.isEmpty
          ? [CvEducationForm()]
          : cv.educations.map((item) {
              final form = CvEducationForm();
              form.schoolController.text = item.school;
              form.degreeController.text = item.degree;
              form.startController.text = item.start;
              form.endController.text = item.end;
              form.descriptionController.text = item.description;
              return form;
            }),
    );
  }

  void previousStep() {
    if (stepIndex.value > 0) {
      generateError.value = '';
      stepIndex.value--;
    }
  }

  void goToStep(int step) {
    if (step < 0 || step >= totalSteps) return;
    generateError.value = '';
    stepIndex.value = step;
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
    final skill = InputSanitizer.sanitizeText(skillController.text);
    if (skill.isEmpty ||
        skills.length >= 15 ||
        skills.any((item) => item.toLowerCase() == skill.toLowerCase())) {
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
