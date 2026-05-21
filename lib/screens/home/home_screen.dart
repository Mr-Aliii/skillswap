import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_swap/core/constants/app_constants.dart';
import 'package:skill_swap/providers/home_provider.dart';
import 'package:skill_swap/routes/app_routes.dart';
import 'package:skill_swap/theme/app_colors.dart';
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
    final trending = ref.watch(trendingSkillsProvider);
    final searchResults = ref.watch(searchResultsProvider);
    final query = ref.watch(searchQueryProvider);

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
                          IconButton(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.notifications,
                            ),
                            icon: Badge(
                              label: const Text('2'),
                              child: const Icon(Icons.notifications_outlined),
                            ),
                          ),
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
                            child: Text(user.name[0]),
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
                        itemBuilder: (_, i) => UserCard(
                          user: users[i],
                          heroTag: 'user_${users[i].id}',
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.userProfile,
                            arguments: {'userId': users[i].id},
                          ),
                          onConnect: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Connection request sent to ${users[i].name}'),
                              ),
                            );
                          },
                        ),
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
