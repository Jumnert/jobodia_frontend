import 'package:flutter/material.dart';

/// A single study flashcard. [front] holds the concept/question, [back] holds
/// the answer or a code snippet. [isCode] renders [back] in a monospace style.
class Flashcard {
  const Flashcard({
    required this.front,
    required this.back,
    this.isCode = false,
  });

  final String front;
  final String back;
  final bool isCode;
}

class FlashcardCategory {
  FlashcardCategory({
    required this.name,
    required this.icon,
    required this.accent,
    this.cards = const [],
  });

  final String name;
  final IconData icon;
  final Color accent;
  List<Flashcard> cards;
}

final List<FlashcardCategory> flashcardCategories = [
  FlashcardCategory(
    name: 'HTML',
    icon: Icons.html_rounded,
    accent: const Color(0xFFE44D26),
  ),
  FlashcardCategory(
    name: 'CSS',
    icon: Icons.css_rounded,
    accent: const Color(0xFF2965F1),
  ),
  FlashcardCategory(
    name: 'JavaScript',
    icon: Icons.javascript_rounded,
    accent: const Color(0xFFF0DB4F),
  ),
];
