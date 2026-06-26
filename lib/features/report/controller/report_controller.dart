import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jobodia_frontend/services/secure_storage_service.dart';

class ReportController extends GetxController {
  ReportController({GetStorage? storage, ImagePicker? picker})
    : _storage = storage ?? GetStorage(),
      _picker = picker ?? ImagePicker();

  static const _reportsKey = 'submittedReports';

  final GetStorage _storage;
  final ImagePicker _picker;

  final RxBool isSubmitting = false.obs;
  final RxnString submitError = RxnString();

  /// Bytes of the attached screenshot, null when none selected.
  final Rxn<Uint8List> screenshotBytes = Rxn<Uint8List>();

  bool get hasScreenshot => screenshotBytes.value != null;

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

  /// Persists a report entry and navigates back with a success message.
  void submit({
    required String jobId,
    required String jobTitle,
    required String comment,
  }) {
    submitError.value = null;
    isSubmitting.value = true;
    try {
      final reports = _storage.read<List>(_reportsKey) ?? [];
      reports.add({
        'jobId': jobId,
        'jobTitle': jobTitle,
        'comment': comment,
        'submittedAt': DateTime.now().toIso8601String(),
        if (screenshotBytes.value != null)
          'screenshot': base64Encode(screenshotBytes.value!),
      });
      _storage.write(_reportsKey, reports);
      SecureStorageService.to.writeSecure(_reportsKey, jsonEncode(reports));
      screenshotBytes.value = null;

      Get.back<void>();
      Get.snackbar(
        'Report submitted',
        'Thank you — your report on "$jobTitle" has been recorded.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } on Exception {
      submitError.value = 'Failed to submit report. Please try again.';
    } finally {
      isSubmitting.value = false;
    }
  }

  void clearSubmitError() => submitError.value = null;
}
