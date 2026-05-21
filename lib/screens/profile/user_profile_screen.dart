import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_swap/core/constants/app_constants.dart';
import 'package:skill_swap/providers/service_providers.dart';
import 'package:skill_swap/routes/app_routes.dart';
import 'package:skill_swap/theme/app_colors.dart';
import 'package:skill_swap/widgets/common/gradient_button.dart';
import 'package:skill_swap/widgets/common/skill_chip.dart';

/// View another user's public profile.
class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userFuture = ref.watch(userServiceProvider).getUser(userId);

    return Scaffold(
      body: FutureBuilder(
        future: userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data;
          if (user == null) {
            return const Center(child: Text('User not found'));
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                    child: Center(
                      child: Hero(
                        tag: 'user_$userId',
                        child: CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.white,
                          child: Text(
                            user.name[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        user.name,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${user.experienceLevel} • ⭐ ${user.rating}',
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                      if (user.bio.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(user.bio),
                      ],
                      const SizedBox(height: 24),
                      const Text('Teaches',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Wrap(
                        spacing: 8,
                        children: user.skillsTeach
                            .map((s) => SkillChip(label: s))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text('Wants to learn',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Wrap(
                        spacing: 8,
                        children: user.skillsLearn
                            .map((s) => SkillChip(label: s, isTeach: false))
                            .toList(),
                      ),
                      const SizedBox(height: 32),
                      GradientButton(
                        label: 'Request Exchange',
                        icon: Icons.swap_horiz,
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.bookSession,
                          arguments: {
                            'targetUserId': user.id,
                            'targetUserName': user.name,
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
