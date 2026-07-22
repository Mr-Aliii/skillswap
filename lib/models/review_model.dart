/// Review model for user ratings and feedback after sessions.
class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.revieweeId,
    required this.reviewerId,
    required this.bookingId,
    required this.rating,
    this.comment = '',
    this.skill = '',
    this.createdAt,
  });

  final String id;
  final String revieweeId; // User being reviewed
  final String reviewerId; // User giving the review
  final String bookingId;
  final double rating; // 1-5 stars
  final String comment;
  final String skill;
  final DateTime? createdAt;

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    return ReviewModel(
      id: id,
      revieweeId: map['revieweeId'] as String? ?? '',
      reviewerId: map['reviewerId'] as String? ?? '',
      bookingId: map['bookingId'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      comment: map['comment'] as String? ?? '',
      skill: map['skill'] as String? ?? '',
      createdAt: _parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'revieweeId': revieweeId,
        'reviewerId': reviewerId,
        'bookingId': bookingId,
        'rating': rating,
        'comment': comment,
        'skill': skill,
        'createdAt': createdAt ?? DateTime.now(),
      };

  ReviewModel copyWith({
    String? id,
    String? revieweeId,
    String? reviewerId,
    String? bookingId,
    double? rating,
    String? comment,
    String? skill,
    DateTime? createdAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      revieweeId: revieweeId ?? this.revieweeId,
      reviewerId: reviewerId ?? this.reviewerId,
      bookingId: bookingId ?? this.bookingId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      skill: skill ?? this.skill,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}