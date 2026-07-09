import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/core/utils/app_logger.dart';
import 'package:jobodia_frontend/core/utils/input_sanitizer.dart';
import 'package:jobodia_frontend/services/secure_storage_service.dart';

class NotesController extends GetxController {
  static const _key = 'jobNotes';
  final _storage = GetStorage();
  final notes = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  /// Loads notes from secure storage. Migrates any legacy plaintext copy
  /// (written by older builds) into secure storage, then deletes it.
  Future<void> _load() async {
    try {
      final raw = await SecureStorageService.to.readSecure(_key);
      if (raw != null) {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          notes.addAll(
            decoded.map((k, v) => MapEntry(k.toString(), v.toString())),
          );
        }
        return;
      }
      final legacy = _storage.read<Map<String, dynamic>>(_key);
      if (legacy != null) {
        notes.addAll(legacy.map((k, v) => MapEntry(k, v.toString())));
        await SecureStorageService.to.writeSecure(_key, jsonEncode(legacy));
        _storage.remove(_key);
      }
    } on Object catch (e, st) {
      AppLogger.error('Failed to load notes from secure storage', e, st);
    }
  }

  String getNote(String jobId) => notes[jobId] ?? '';

  void saveNote(String jobId, String text) {
    // Strip control chars but preserve newlines/tabs for multi-line notes.
    final sanitized = InputSanitizer.stripControlChars(text);
    if (sanitized.trim().isEmpty) {
      notes.remove(jobId);
    } else {
      notes[jobId] = sanitized;
    }
    notes.refresh();
    final data = Map<String, String>.from(notes);
    SecureStorageService.to.writeSecure(_key, jsonEncode(data));
  }
}
