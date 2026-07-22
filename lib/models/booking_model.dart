/// Session booking request model.
class BookingModel {
  const BookingModel({
    required this.id,
    required this.requesterId,
    required this.hostId,
    required this.skill,
    required this.date,
    required this.timeSlot,
    this.status = 'pending',
    this.note = '',
    this.createdAt,
  });

  final String id;
  final String requesterId;
  final String hostId;
  final String skill;
  final DateTime date;
  final String timeSlot;
  final String status;
  final String note;
  final DateTime? createdAt;

  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    return BookingModel(
      id: id,
      requesterId: map['requesterId'] as String? ?? '',
      hostId: map['hostId'] as String? ?? '',
      skill: map['skill'] as String? ?? '',
      date: _parseDate(map['date']) ?? DateTime.now(),
      timeSlot: map['timeSlot'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      note: map['note'] as String? ?? '',
      createdAt: _parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'requesterId': requesterId,
        'hostId': hostId,
        'skill': skill,
        'date': date,
        'timeSlot': timeSlot,
        'status': status,
        'note': note,
        'createdAt': createdAt ?? DateTime.now(),
      };

  BookingModel copyWith({
    String? id,
    String? requesterId,
    String? hostId,
    String? skill,
    DateTime? date,
    String? timeSlot,
    String? status,
    String? note,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      hostId: hostId ?? this.hostId,
      skill: skill ?? this.skill,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
