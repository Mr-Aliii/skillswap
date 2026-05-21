/// Chat conversation metadata.
class ChatModel {
  const ChatModel({
    required this.id,
    required this.participantIds,
    this.lastMessage = '',
    this.lastMessageAt,
    this.unreadCount = 0,
    this.otherUserName = '',
    this.otherUserPhoto,
    this.otherUserId = '',
    this.isOtherOnline = false,
  });

  final String id;
  final List<String> participantIds;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final String otherUserName;
  final String? otherUserPhoto;
  final String otherUserId;
  final bool isOtherOnline;

  factory ChatModel.fromMap(Map<String, dynamic> map, String id) {
    return ChatModel(
      id: id,
      participantIds: List<String>.from(map['participantIds'] as List? ?? []),
      lastMessage: map['lastMessage'] as String? ?? '',
      lastMessageAt: _parseDate(map['lastMessageAt']),
      unreadCount: map['unreadCount'] as int? ?? 0,
      otherUserName: map['otherUserName'] as String? ?? '',
      otherUserPhoto: map['otherUserPhoto'] as String?,
      otherUserId: map['otherUserId'] as String? ?? '',
      isOtherOnline: map['isOtherOnline'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'participantIds': participantIds,
        'lastMessage': lastMessage,
        'lastMessageAt': lastMessageAt,
        'unreadCount': unreadCount,
        'otherUserName': otherUserName,
        'otherUserPhoto': otherUserPhoto,
        'otherUserId': otherUserId,
        'isOtherOnline': isOtherOnline,
      };

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
