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
