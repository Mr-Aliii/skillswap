import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_swap/models/skill_model.dart';
import 'package:skill_swap/models/user_model.dart';
import 'package:skill_swap/providers/auth_provider.dart';
import 'package:skill_swap/providers/service_providers.dart';
import 'package:skill_swap/utils/dummy_data.dart';

final recommendedUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final profile = ref.watch(currentUserProfileProvider).valueOrNull;
  return ref
      .watch(userServiceProvider)
      .getRecommendedUsers(excludeUid: profile?.id);
});

final trendingSkillsProvider = Provider<List<SkillModel>>((ref) {
  return DummyData.trendingSkills;
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<UserModel>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];
  return ref.watch(userServiceProvider).searchUsers(query);
});
