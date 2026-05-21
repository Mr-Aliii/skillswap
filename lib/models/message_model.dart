/// Chat message model.
class MessageModel {
  const MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.createdAt,
    this.isRead = false,
  });

  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final DateTime createdAt;
  final bool isRead;

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      chatId: map['chatId'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      text: map['text'] as String? ?? '',
      createdAt: _parseDate(map['createdAt']) ?? DateTime.now(),
      isRead: map['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'chatId': chatId,
        'senderId': senderId,
        'text': text,
        'createdAt': createdAt,
        'isRead': isRead,
      };

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
