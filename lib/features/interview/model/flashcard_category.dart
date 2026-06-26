import 'package:jobodia_frontend/features/interview/model/flashcard.dart';

/// A named group of flashcards shown as one deck.
class FlashcardCategory {
  const FlashcardCategory({required this.name, required this.cards, this.icon});

  final String name;
  final List<Flashcard> cards;
  final String? icon;
}
