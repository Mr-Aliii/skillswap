import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skill_swap/config/app_config.dart';
import 'package:skill_swap/core/constants/premium_plans.dart';
import 'package:skill_swap/core/errors/app_exception.dart';
import 'package:skill_swap/models/premium_plan_model.dart';
import 'package:skill_swap/models/user_model.dart';
import 'package:skill_swap/services/user_service.dart';
import 'package:uuid/uuid.dart';

/// Premium badge purchase — updates user profile in Firestore.
class PremiumService {
  PremiumService({UserService? userService})
      : _userService = userService ?? UserService();

  final UserService _userService;
  final _uuid = const Uuid();

  FirebaseFirestore? get _firestore =>
      AppConfig.isDemoMode ? null : FirebaseFirestore.instance;

  Future<UserModel> purchasePremium({
    required String userId,
    required PremiumPlanType planType,
  }) async {
    final plan = PremiumPlans.planFor(planType);
    final expiresAt = DateTime.now().add(plan.duration);

    final user = await _userService.getUser(userId);
    if (user == null) {
      throw AppException('User profile not found');
    }

    final updated = user.copyWith(
      isPremium: true,
      isVerified: true,
      premiumPlan: planType.id,
      premiumExpiresAt: expiresAt,
    );

    if (AppConfig.isDemoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      return updated;
    }

    await _firestore!.collection(AppConfig.usersCollection).doc(userId).update({
      'isPremium': true,
      'isVerified': true,
      'premiumPlan': planType.id,
      'premiumExpiresAt': Timestamp.fromDate(expiresAt),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _firestore!
        .collection(AppConfig.premiumSubscriptionsCollection)
        .doc(_uuid.v4())
        .set({
      'userId': userId,
      'plan': planType.id,
      'price': plan.price,
      'purchasedAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'status': 'active',
    });

    return updated;
  }
}
