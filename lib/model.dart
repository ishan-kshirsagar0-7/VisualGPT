enum ChatMessageType { user, bot }

class ChatMessage {
  final String text;
  final ChatMessageType chatMessageType;
  final bool isImage;

  ChatMessage({required this.text, required this.chatMessageType, required this.isImage});
}
