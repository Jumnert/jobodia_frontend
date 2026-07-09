import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jobodia_frontend/core/utils/app_logger.dart';
import 'package:jobodia_frontend/core/utils/input_sanitizer.dart';
import 'package:jobodia_frontend/services/secure_storage_service.dart';

class ReportController extends GetxController {
  ReportController({GetStorage? storage, ImagePicker? picker})
    : _storage = storage ?? GetStorage(),
      _picker = picker ?? ImagePicker();

  static const _reportsKey = 'submittedReports';

  final GetStorage _storage;
  final ImagePicker _picker;

  /// In-memory copy of submitted reports, loaded from secure storage on init.
  final List<Map<String, dynamic>> _reports = [];

  /// Read-only view of the submitted reports.
  List<Map<String, dynamic>> get reports => List.unmodifiable(_reports);

  final RxBool isSubmitting = false.obs;
  final RxnString submitError = RxnString();

  /// Bytes of the attached screenshot, null when none selected.
  final Rxn<Uint8List> screenshotBytes = Rxn<Uint8List>();

  bool get hasScreenshot => screenshotBytes.value != null;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  /// Loads reports from secure storage, migrating any legacy plaintext copy
  /// written by older builds and removing the plaintext afterwards.
  Future<void> _load() async {
    try {
      final raw = await SecureStorageService.to.readSecure(_reportsKey);
      if (raw != null) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          _reports.addAll(
            decoded.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
          );
        }
        return;
      }
      final legacy = _storage.read<List>(_reportsKey);
      if (legacy != null) {
        _reports.addAll(
          legacy.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
        );
        await SecureStorageService.to.writeSecure(
          _reportsKey,
          jsonEncode(_reports),
        );
        _storage.remove(_reportsKey);
      }
    } on Object catch (e, st) {
      AppLogger.error('Failed to load reports from secure storage', e, st);
    }
  }

  /// Opens the gallery picker and stores the selected image bytes.
  Future<void> pickScreenshot() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 80,
      );
      if (picked == null) return;
      screenshotBytes.value = await picked.readAsBytes();
    } on Object {
      Get.snackbar(
        'Photo unavailable',
        'Could not access your photos. Check photo permissions and try again.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  void removeScreenshot() {
    screenshotBytes.value = null;
  }

  /// Persists a report entry to secure storage and navigates back.
  void submit({
    required String jobId,
    required String jobTitle,
    required String comment,
  }) {
    submitError.value = null;
    isSubmitting.value = true;
    try {
      _reports.add({
        'jobId': jobId,
        'jobTitle': InputSanitizer.sanitizeText(jobTitle),
        'comment': InputSanitizer.stripControlChars(comment),
        'submittedAt': DateTime.now().toIso8601String(),
        if (screenshotBytes.value != null)
          'screenshot': base64Encode(screenshotBytes.value!),
      });
      SecureStorageService.to.writeSecure(_reportsKey, jsonEncode(_reports));
      screenshotBytes.value = null;

      Get.back<void>();
      Get.snackbar(
        'Report submitted',
        'Thank you — your report on "$jobTitle" has been recorded.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } on Exception catch (e, st) {
      AppLogger.error('Failed to submit report', e, st);
      submitError.value = 'Failed to submit report. Please try again.';
    } finally {
      isSubmitting.value = false;
    }
  }

  void clearSubmitError() => submitError.value = null;
}
