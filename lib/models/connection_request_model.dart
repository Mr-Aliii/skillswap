/// Connection request model representing connection status between two users.
class ConnectionRequestModel {
  const ConnectionRequestModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status, // 'pending', 'accepted', 'declined'
    this.createdAt,
  });

  final String id;
  final String senderId;
  final String receiverId;
  final String status;
  final DateTime? createdAt;

  factory ConnectionRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return ConnectionRequestModel(
      id: id,
      senderId: map['senderId'] as String? ?? '',
      receiverId: map['receiverId'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      createdAt: _parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'senderId': senderId,
        'receiverId': receiverId,
        'status': status,
        'createdAt': createdAt ?? DateTime.now(),
      };

  ConnectionRequestModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? status,
    DateTime? createdAt,
  }) {
    return ConnectionRequestModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
