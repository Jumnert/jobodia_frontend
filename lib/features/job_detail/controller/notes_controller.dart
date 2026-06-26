import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/services/secure_storage_service.dart';

class NotesController extends GetxController {
  static const _key = 'jobNotes';
  final _storage = GetStorage();
  final notes = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    final stored = _storage.read<Map<String, dynamic>>(_key);
    if (stored != null) {
      notes.addAll(stored.map((k, v) => MapEntry(k, v as String)));
    }
  }

  String getNote(String jobId) => notes[jobId] ?? '';

  void saveNote(String jobId, String text) {
    if (text.trim().isEmpty) {
      notes.remove(jobId);
    } else {
      notes[jobId] = text;
    }
    notes.refresh();
    final data = Map<String, String>.from(notes);
    _storage.write(_key, data);
    SecureStorageService.to.writeSecure(_key, jsonEncode(data));
  }
}
