/// In-app notification model.
class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    this.createdAt,
    this.data,
  });

  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime? createdAt;
  final Map<String, dynamic>? data;

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      type: map['type'] as String? ?? 'general',
      isRead: map['isRead'] as bool? ?? false,
      createdAt: _parseDate(map['createdAt']),
      data: map['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'title': title,
        'body': body,
        'type': type,
        'isRead': isRead,
        'createdAt': createdAt ?? DateTime.now(),
        'data': data,
      };

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
