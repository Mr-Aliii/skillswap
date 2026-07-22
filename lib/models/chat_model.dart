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
    this.names,
    this.photoUrls,
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
  final Map<String, String>? names;
  final Map<String, String>? photoUrls;

  factory ChatModel.fromMap(Map<String, dynamic> map, String id, {String? currentUserId}) {
    final participantIds = List<String>.from(map['participantIds'] as List? ?? []);
    
    String otherId = map['otherUserId'] as String? ?? '';
    String otherName = map['otherUserName'] as String? ?? '';
    String? otherPhoto = map['otherUserPhoto'] as String?;
    
    if (currentUserId != null && participantIds.length == 2) {
      final resolvedOtherId = participantIds.firstWhere(
        (uid) => uid != currentUserId,
        orElse: () => '',
      );
      if (resolvedOtherId.isNotEmpty) {
        otherId = resolvedOtherId;
        final namesMap = map['names'] as Map?;
        if (namesMap != null && namesMap.containsKey(resolvedOtherId)) {
          otherName = namesMap[resolvedOtherId] as String? ?? otherName;
        }
        final photosMap = map['photoUrls'] as Map?;
        if (photosMap != null && photosMap.containsKey(resolvedOtherId)) {
          otherPhoto = photosMap[resolvedOtherId] as String? ?? otherPhoto;
        }
      }
    }

    return ChatModel(
      id: id,
      participantIds: participantIds,
      lastMessage: map['lastMessage'] as String? ?? '',
      lastMessageAt: _parseDate(map['lastMessageAt']),
      unreadCount: map['unreadCount'] as int? ?? 0,
      otherUserName: otherName,
      otherUserPhoto: otherPhoto,
      otherUserId: otherId,
      isOtherOnline: map['isOtherOnline'] as bool? ?? false,
      names: map['names'] != null ? Map<String, String>.from(map['names'] as Map) : null,
      photoUrls: map['photoUrls'] != null ? Map<String, String>.from(map['photoUrls'] as Map) : null,
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
        if (names != null) 'names': names,
        if (photoUrls != null) 'photoUrls': photoUrls,
      };

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
