enum ChatMessageSender { user, bot }

class ChatMessageModel {
  const ChatMessageModel({required this.text, required this.sender});

  final String text;
  final ChatMessageSender sender;
}
