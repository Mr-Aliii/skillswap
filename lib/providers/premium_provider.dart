import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_swap/models/premium_plan_model.dart';
import 'package:skill_swap/models/user_model.dart';
import 'package:skill_swap/providers/auth_provider.dart';
import 'package:skill_swap/providers/home_provider.dart';
import 'package:skill_swap/providers/service_providers.dart';
import 'package:skill_swap/services/premium_service.dart';

final premiumServiceProvider = Provider<PremiumService>((ref) {
  return PremiumService(userService: ref.watch(userServiceProvider));
});

final selectedPremiumPlanProvider =
    StateProvider<PremiumPlanType>((ref) => PremiumPlanType.monthly);

final premiumPurchaseProvider =
    StateNotifierProvider<PremiumPurchaseNotifier, AsyncValue<void>>((ref) {
  return PremiumPurchaseNotifier(ref);
});

class PremiumPurchaseNotifier extends StateNotifier<AsyncValue<void>> {
  PremiumPurchaseNotifier(this._ref) : super(const AsyncData(null));

  final Ref _ref;

  Future<UserModel> purchase(PremiumPlanType plan) async {
    state = const AsyncLoading();
    try {
      final uid = _ref.read(authStateProvider).valueOrNull?.uid;
      if (uid == null) throw Exception('Not logged in');

      final updated = await _ref.read(premiumServiceProvider).purchasePremium(
            userId: uid,
            planType: plan,
          );
      state = const AsyncData(null);
      _ref.invalidate(currentUserProfileProvider);
      _ref.invalidate(recommendedUsersProvider);
      return updated;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
