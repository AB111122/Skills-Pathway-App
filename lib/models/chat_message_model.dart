enum ChatSender { user, assistant }
enum ChatMessageStatus { sending, sent, failed }

class ChatMessageModel {
  final String id;
  final ChatSender sender;
  final String content;
  final DateTime timestamp;
  final ChatMessageStatus status;
  const ChatMessageModel({required this.id, required this.sender, required this.content, required this.timestamp, this.status = ChatMessageStatus.sent});
}
