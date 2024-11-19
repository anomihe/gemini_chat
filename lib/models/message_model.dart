class MessageModel {
  final String messageId;
  final String chatId;
  final Role role;
  final StringBuffer message;
  final List<String> imageUrl;
  final DateTime timeStamp;

  MessageModel(
      {required this.messageId,
      required this.chatId,
      required this.role,
      required this.message,
      required this.imageUrl,
      required this.timeStamp});

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'chatId': chatId,
      'role': role,
      'message': message.toString(),
      'imageUrl': imageUrl,
      'timeStamp': timeStamp.toIso8601String()
    };
  }

  factory MessageModel.from(Map<String, dynamic> json) {
    return MessageModel(
        messageId: json['messageId'],
        chatId: json['chatId'],
        role: json['role'],
        message: json['message'],
        imageUrl: json['imageUrl'],
        timeStamp: json['timeStamp']);
  }
  MessageModel copyWith({
    String? messageId,
    String? chatId,
    Role? role,
    StringBuffer? message,
    List<String>? imageUrl,
    DateTime? timeStamp,
  }) {
    return MessageModel(
        messageId: messageId ?? this.messageId,
        chatId: chatId ?? this.chatId,
        role: role ?? this.role,
        message: message ?? this.message,
        imageUrl: imageUrl ?? this.imageUrl,
        timeStamp: timeStamp ?? this.timeStamp);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageModel && other.messageId == messageId;
  }

  @override
  int get hashCode => messageId.hashCode;
}

enum Role {
  assistant,
  user,
}
