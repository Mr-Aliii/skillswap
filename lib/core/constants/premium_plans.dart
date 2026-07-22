import 'package:skill_swap/models/premium_plan_model.dart';
import 'package:skill_swap/models/user_model.dart';

/// Premium plan catalog and user sorting helpers.
class PremiumPlans {
  PremiumPlans._();

  static const List<PremiumPlanModel> plans = [
    PremiumPlanModel(
      type: PremiumPlanType.weekly,
      title: 'Weekly',
      price: '\$2.99',
      pricePerWeek: '\$2.99/wk',
      duration: Duration(days: 7),
    ),
    PremiumPlanModel(
      type: PremiumPlanType.monthly,
      title: 'Monthly',
      price: '\$7.99',
      pricePerWeek: '\$1.99/wk',
      duration: Duration(days: 30),
      isPopular: true,
      saveLabel: 'Save 33%',
    ),
    PremiumPlanModel(
      type: PremiumPlanType.yearly,
      title: 'Yearly',
      price: '\$49.99',
      pricePerWeek: '\$0.96/wk',
      duration: Duration(days: 365),
      saveLabel: 'Best Value',
    ),
  ];

  static PremiumPlanModel planFor(PremiumPlanType type) {
    return plans.firstWhere((p) => p.type == type);
  }

  /// Premium + verified users appear first in lists.
  static List<UserModel> sortPremiumFirst(List<UserModel> users) {
    final sorted = List<UserModel>.from(users);
    sorted.sort((a, b) {
      final aPremium = a.showVerifiedBadge ? 1 : 0;
      final bPremium = b.showVerifiedBadge ? 1 : 0;
      if (aPremium != bPremium) return bPremium.compareTo(aPremium);
      return b.rating.compareTo(a.rating);
    });
    return sorted;
  }

  static List<UserModel> premiumOnly(List<UserModel> users) {
    return users.where((u) => u.showVerifiedBadge).toList();
  }
}
