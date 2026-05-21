/// Skill catalog model for Firestore `skills` collection.
class SkillModel {
  const SkillModel({
    required this.id,
    required this.name,
    required this.category,
    this.description = '',
    this.iconName = 'star',
    this.trending = false,
    this.learnersCount = 0,
  });

  final String id;
  final String name;
  final String category;
  final String description;
  final String iconName;
  final bool trending;
  final int learnersCount;

  factory SkillModel.fromMap(Map<String, dynamic> map, String id) {
    return SkillModel(
      id: id,
      name: map['name'] as String? ?? '',
      category: map['category'] as String? ?? 'Other',
      description: map['description'] as String? ?? '',
      iconName: map['iconName'] as String? ?? 'star',
      trending: map['trending'] as bool? ?? false,
      learnersCount: map['learnersCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'category': category,
        'description': description,
        'iconName': iconName,
        'trending': trending,
        'learnersCount': learnersCount,
      };
}
