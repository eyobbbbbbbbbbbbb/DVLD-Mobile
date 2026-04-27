class Message {
  final int id;
  final int personId;
  final int? senderId;
  final String title;
  final String content;
  final bool isRead;
  final DateTime createdAt;
  final String messageType;

  Message({
    required this.id,
    required this.personId,
    this.senderId,
    required this.title,
    required this.content,
    required this.isRead,
    required this.createdAt,
    required this.messageType,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['messageID'],
      personId: json['personID'],
      senderId: json['senderID'],
      title: json['title'] ?? 'Notification',
      content: json['content'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      messageType: json['messageType'] ?? 'Notification',
    );
  }

  bool get isSystem => senderId == null;
  bool get isChat => messageType == 'Chat' || messageType == 'Compliance';
}
