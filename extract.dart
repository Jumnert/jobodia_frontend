// ignore_for_file: deprecated_member_use, avoid_print, curly_braces_in_flow_control_structures, unused_import, unnecessary_underscores, unused_field, unused_local_variable, use_build_context_synchronously, duplicate_ignore
import 'dart:convert';
import 'dart:io';
import 'package:jobodia_frontend/features/interview/data/flashcard_data.dart';

void main() {
  final Map<String, List<Map<String, dynamic>>> data = {
    'HTML': flashcardCategories
        .firstWhere((c) => c.name == 'HTML')
        .cards
        .map((c) => {'front': c.front, 'back': c.back, 'isCode': c.isCode})
        .toList(),
    'CSS': flashcardCategories
        .firstWhere((c) => c.name == 'CSS')
        .cards
        .map((c) => {'front': c.front, 'back': c.back, 'isCode': c.isCode})
        .toList(),
    'JavaScript': flashcardCategories
        .firstWhere((c) => c.name == 'JavaScript')
        .cards
        .map((c) => {'front': c.front, 'back': c.back, 'isCode': c.isCode})
        .toList(),
  };

  final dir = Directory('assets/data');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  final file = File('assets/data/flashcards.json');
  file.writeAsStringSync(jsonEncode(data));
  print('Done!');
}
