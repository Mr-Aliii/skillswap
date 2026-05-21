/// User profile model mapped to Firestore `users` collection.
class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.bio = '',
    this.photoUrl,
    this.skillsTeach = const [],
    this.skillsLearn = const [],
    this.experienceLevel = 'Intermediate',
    this.isOnline = false,
    this.rating = 0.0,
    this.sessionsCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String name;
  final String bio;
  final String? photoUrl;
  final List<String> skillsTeach;
  final List<String> skillsLearn;
  final String experienceLevel;
  final bool isOnline;
  final double rating;
  final int sessionsCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? 'User',
      bio: map['bio'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      skillsTeach: List<String>.from(map['skillsTeach'] as List? ?? []),
      skillsLearn: List<String>.from(map['skillsLearn'] as List? ?? []),
      experienceLevel: map['experienceLevel'] as String? ?? 'Intermediate',
      isOnline: map['isOnline'] as bool? ?? false,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      sessionsCount: map['sessionsCount'] as int? ?? 0,
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'bio': bio,
      'photoUrl': photoUrl,
      'skillsTeach': skillsTeach,
      'skillsLearn': skillsLearn,
      'experienceLevel': experienceLevel,
      'isOnline': isOnline,
      'rating': rating,
      'sessionsCount': sessionsCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  UserModel copyWith({
    String? email,
    String? name,
    String? bio,
    String? photoUrl,
    List<String>? skillsTeach,
    List<String>? skillsLearn,
    String? experienceLevel,
    bool? isOnline,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      skillsTeach: skillsTeach ?? this.skillsTeach,
      skillsLearn: skillsLearn ?? this.skillsLearn,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      isOnline: isOnline ?? this.isOnline,
      rating: rating,
      sessionsCount: sessionsCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
