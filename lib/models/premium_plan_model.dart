/// Premium subscription plan type.
enum PremiumPlanType {
  weekly('weekly', 'Weekly'),
  monthly('monthly', 'Monthly'),
  yearly('yearly', 'Yearly');

  const PremiumPlanType(this.id, this.label);
  final String id;
  final String label;

  static PremiumPlanType? fromId(String? id) {
    if (id == null) return null;
    for (final p in PremiumPlanType.values) {
      if (p.id == id) return p;
    }
    return null;
  }
}

/// Pricing plan details for the premium badge.
class PremiumPlanModel {
  const PremiumPlanModel({
    required this.type,
    required this.title,
    required this.price,
    required this.pricePerWeek,
    required this.duration,
    this.isPopular = false,
    this.saveLabel,
  });

  final PremiumPlanType type;
  final String title;
  final String price;
  final String pricePerWeek;
  final Duration duration;
  final bool isPopular;
  final String? saveLabel;
}
