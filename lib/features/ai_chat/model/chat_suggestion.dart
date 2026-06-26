/// A follow-up suggestion shown at the end of an AI chat response.
class ChatSuggestion {
  const ChatSuggestion({required this.text, this.icon});

  final String text;
  final String? icon;
}
