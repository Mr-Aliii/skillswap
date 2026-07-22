import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_swap/core/constants/app_constants.dart';
import 'package:skill_swap/providers/auth_provider.dart';
import 'package:skill_swap/providers/home_provider.dart';
import 'package:skill_swap/providers/service_providers.dart';
import 'package:skill_swap/routes/app_routes.dart';
import 'package:skill_swap/theme/app_colors.dart';
import 'package:skill_swap/utils/dummy_data.dart';
import 'package:skill_swap/widgets/cards/category_chip.dart';
import 'package:skill_swap/widgets/cards/skill_card.dart';
import 'package:skill_swap/widgets/cards/user_card.dart';
import 'package:skill_swap/widgets/common/shimmer_loader.dart';

/// Dashboard with search, categories, trending skills, and recommendations.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  bool _searchFocused = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recommended = ref.watch(recommendedUsersProvider);
    final premiumUsers = ref.watch(premiumUsersProvider);
    final trending = ref.watch(trendingSkillsProvider);
    final searchResults = ref.watch(searchResultsProvider);
    final query = ref.watch(searchQueryProvider);
    final currentUser = ref.watch(currentUserProfileProvider).valueOrNull;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(recommendedUsersProvider);
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello 👋',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: Theme.of(context).hintColor),
                                ),
                                Text(
                                  'Find skills to swap',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          _NotificationBadge(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AnimatedContainer(
                        duration: AppConstants.animationNormal,
                        decoration: BoxDecoration(
                          boxShadow: _searchFocused
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.2),
                                    blurRadius: 12,
                                  ),
                                ]
                              : null,
                        ),
                        child: TextField(
                          controller: _searchController,
                          onTap: () => setState(() => _searchFocused = true),
                          onSubmitted: (_) =>
                              setState(() => _searchFocused = false),
                          onChanged: (v) =>
                              ref.read(searchQueryProvider.notifier).state = v,
                          decoration: InputDecoration(
                            hintText: 'Search skills or people...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: query.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      ref.read(searchQueryProvider.notifier).state =
                                          '';
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (query.isNotEmpty)
                searchResults.when(
                  data: (users) => SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final user = users[i];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?'),
                          ),
                          title: Text(user.name),
                          subtitle: Text(user.skillsTeach.join(', ')),
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.userProfile,
                            arguments: {'userId': user.id},
                          ),
                        );
                      },
                      childCount: users.length,
                    ),
                  ),
                  loading: () => const SliverToBoxAdapter(
                    child: ShimmerCard(height: 60),
                  ),
                  error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
                )
              else ...[
                SliverToBoxAdapter(
                  child: premiumUsers.when(
                    data: (users) {
                      if (users.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Row(
                              children: [
                                Icon(Icons.workspace_premium,
                                    color: Colors.amber.shade700, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  'Premium Members',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 220,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: users.length,
                              itemBuilder: (_, i) => UserCard(
                                user: users[i],
                                heroTag: 'premium_${users[i].id}',
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.userProfile,
                                  arguments: {'userId': users[i].id},
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        CategoryChip(
                          label: 'All',
                          selected: _selectedCategory == 'All',
                          onTap: () => setState(() => _selectedCategory = 'All'),
                        ),
                        ...AppConstants.skillCategories.map(
                          (c) => CategoryChip(
                            label: c,
                            selected: _selectedCategory == c,
                            onTap: () => setState(() => _selectedCategory = c),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Text(
                      'Trending Skills',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 130,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: trending.length,
                      itemBuilder: (_, i) => SkillCard(skill: trending[i]),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recommended for You',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('See all'),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 220,
                    child: recommended.when(
                      data: (users) => ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: users.length,
                        itemBuilder: (_, i) {
                          final u = users[i];
                          // Find matched skills: current user wants to learn ↔ this user teaches
                          final matched = currentUser?.skillsLearn
                                  .where((s) => u.skillsTeach.contains(s))
                                  .toList() ??
                              <String>[];
                          return UserCard(
                            user: u,
                            heroTag: 'user_${u.id}',
                            matchedSkills: matched,
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.userProfile,
                              arguments: {'userId': u.id},
                            ),
                            onConnect: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Connection request sent to ${u.name}'),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      loading: () => ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: 3,
                        itemBuilder: (_, __) => const SizedBox(
                          width: 200,
                          child: ShimmerCard(height: 200),
                        ),
                      ),
                      error: (_, __) => const Center(child: Text('Failed to load')),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

final _unreadCountProvider = FutureProvider<int>((ref) async {
  final uid =
      ref.watch(authStateProvider).valueOrNull?.uid ?? DummyData.demoUserId;
  final items =
      await ref.watch(notificationServiceProvider).getNotifications(uid);
  return items.where((n) => !n.isRead).length;
});

class _NotificationBadge extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadAsync = ref.watch(_unreadCountProvider);
    final count = unreadAsync.valueOrNull ?? 0;

    return IconButton(
      onPressed: () =>
          Navigator.pushNamed(context, AppRoutes.notifications),
      icon: Badge(
        isLabelVisible: count > 0,
        label: count > 0 ? Text('$count') : null,
        child: const Icon(Icons.notifications_outlined),
      ),
    );
  }
}
